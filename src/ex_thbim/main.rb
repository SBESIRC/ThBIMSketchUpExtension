# Copyright 2016-2022 Trimble Inc
# Licensed under the MIT license
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/tch")
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/data")
require 'sketchup.rb'
require 'json'
require 'google/protobuf'
require_relative 'data/ThTCHProjectData_pb'
require_relative 'data/ThSUProjectData_pb'
require_relative 'tch/tch_su_project_builder'
require_relative 'tch/protobuf_extension'
require_relative 'win32/pipe'
include Win32

module Examples
  module HelloCube
    @TimerID = 0
    @TimerFlag = false

    def self.StartWin32PipeMonitor
      @TimerID = UI.start_timer(2, true){
        begin
          Pipe::Client.new('THCAD2SUPIPE') do |pipe|
            pipe_data = pipe.readCadPipeData
            pipe_data_head = pipe_data[0,10]
            if pipe_data_head.getbyte(0) == 84 and pipe_data_head.getbyte(1) == 72 and pipe_data_head.getbyte(2) == 1 and pipe_data_head.getbyte(3) == 1
              pipe_data_body = pipe_data[10..pipe_data.length]
              model = ThTCHProjectData.decode(pipe_data_body)
              ThTCH2SUProjectBuilder.Building(model)
            end
          end
        rescue => e
          e.message
        end
      }
      @TimerFlag = true
    end

    def self.CloseWin32PipeMonitor
      UI.stop_timer(@TimerID)
      @TimerFlag = false
    end

    # 获取SU构建信息并发送至Viewer
    def self.get_su_build_info
      su_project = ThSUProjectData.new
      su_project.root = ThTCHRootData.new
      su_project.root.name = "空项目"
      su_project.root.globalId = "su_test_pipe_data"
      su_project.is_face_mesh = false
      building_data = ThSUBuildingData.new
      begin
        skpfile = Sketchup.active_model.path
        if skpfile.length > 0
          su_project.root.name = File.basename(skpfile, ".*")
          file_path = File.dirname(skpfile)
          if File.directory? file_path
            Dir.entries(file_path, encoding:'UTF-8').each{ |file_name|
              if file_name.include? ".ifc.json"
                file_full_path = File::join(file_path, file_name)
                json_string = File.read(file_full_path)
                json = JSON.parse(json_string)
                json.each{ |obj|
                  storey_data = ThSUBuildingStoreyData.new
                  storey_data.root = ThTCHRootData.new
                  storey_data.root.globalId = "su_storey_" + obj["No"].to_s
                  storey_data.root.name = obj["Name"]
                  storey_data.number = obj["No"]
                  storey_data.elevation = obj["Elevation"]
                  storey_data.height = obj["Height"]
                  storey_data.stdFlr_no = obj["StdFlrNo"]
                  building_data.storeys.push storey_data
                }
                break
              end
            }
          end
        end
      rescue => e
        e.message
      end
      if building_data.storeys.length == 0
        storey_data = ThSUBuildingStoreyData.new
        storey_data.root = ThTCHRootData.new
        storey_data.root.globalId = "su_storey_1"
        storey_data.number = 1 #虚拟楼层
        storey_data.elevation = -1.0e10
        storey_data.height = 2.0e10
        storey_data.stdFlr_no = 1
        building_data.storeys.push storey_data
      end
      su_project.building = building_data
      entities = Sketchup.active_model.entities
      entities.each{ |ent|
        if ent.is_a?(Sketchup::Group) or ent.is_a?(Sketchup::ComponentInstance)
          code = ThProtoBufExtention.get_hash_code(2166136261, ent.entityID)
          definition_datas = ThProtoBufExtention.to_proto_definition_data(su_project, ent, ent.transformation, code)
        end
      }
      su_project
    end

    def self.push_to_viewer(su_project)
      begin
        encoded_data_body = ThSUProjectData.encode(su_project)
        # 为文件增加头部标识
        Pipe::Client.new('THSU2P3DIPE') do |pipe|
          encoded_data_head = [84, 72, 1, 2, 0, 0, 0, 0, 0, 0]
          encoded_data = encoded_data_head.pack('C*') + encoded_data_body
          pipe.writeCadPipeData(encoded_data)
        end
        file = Sketchup.active_model.path
        if file.length > 0
          file_path = File.dirname(file)
          file_basename = File.basename(file, ".*")
          filename = File.join(file_path, file_basename + ".thbim")
          encoded_data_head = [84, 72, 3, 2, 0, 0, 0, 0, 0, 0]
          encoded_data = encoded_data_head.pack('C*') + encoded_data_body
          outfile = File.new(filename, 'wb')
          outfile.write(encoded_data)
          outfile.close
        end
      rescue => e
        e.message
      end
    end

    def self.Show_ToolBar
      toolbar = UI::Toolbar.new "CAD插件"                   # 创建一个名为Test工具条
      if toolbar.visible? and toolbar.length > 0
        toolbar.hide
      else
        if toolbar.length < 1
          # Command1
          command_tool1 = UI::Command.new("开启CAD监听") {           # 创建一个工具名为Test的命令
              if(@TimerFlag == false)
                self.StartWin32PipeMonitor
              else
                self.CloseWin32PipeMonitor
              end
          }
          command_tool1.small_icon = "Img/ToCAD.png"             # 工具在工具条上显示的图标
          command_tool1.large_icon = "Img/ToCAD.png"
          command_tool1.set_validation_proc {
            if @TimerFlag
              MF_CHECKED
            else
              MF_UNCHECKED
            end
          }
          command_tool1.tooltip = "Turn on CAD monitoring"                      # 对该工具的一些说明
          command_tool1.status_bar_text = "开启 CAD 监听" # 在状态栏中显示的内容

          # Command2
          command_tool2 = UI::Command.new("推送数据至Viewer") {           # 创建一个工具名为Test的命令
            su_project = self.get_su_build_info
            self.push_to_viewer(su_project)
          }
          command_tool2.small_icon = "Img/ToViewer.png"             # 工具在工具条上显示的图标
          command_tool2.large_icon = "Img/ToViewer.png"
          command_tool2.tooltip = "Push To Viewer"                      # 对该工具的一些说明
          command_tool2.status_bar_text = "推送至 Viewer" # 在状态栏中显示的内容


          toolbar = toolbar.add_item command_tool1                     # 将这个命名添加到工具条上
          toolbar = toolbar.add_separator                              # 添加分隔符
          toolbar = toolbar.add_item command_tool2                     # 将这个命名添加到工具条上
        end
        toolbar.show                                       # 在SktchUp中显示该工具条
      end
    end

    # Main
    unless file_loaded?(__FILE__)
      menu = UI.menu('Tools')
      menu.add_item('CAD插件') {
        self.Show_ToolBar
      }
      # 主动调用一次使ToolBar先显示出来
      self.Show_ToolBar
      # file_loaded(__FILE__)
    end
  end # module HelloCube
end # module Examples
