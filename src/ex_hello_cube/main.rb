# Copyright 2016-2022 Trimble Inc
# Licensed under the MIT license
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/tch")
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/data")
require 'sketchup.rb'
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
          Pipe::Client.new('THSUPush_TestPipe') do |pipe|
            pipe_data = pipe.readCadPipeData
            pipe_data_head = pipe_data[0,10]
            # value1 = pipe_data_head.getbyte(0)
            pipe_data_body = pipe_data[10..pipe_data.length]
            model = ThTCHProjectData.decode(pipe_data_body)
            ThTCH2SUProjectBuilder.Building(model)
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
      su_project.root.name = "测试项目"
      su_project.root.globalId = "su_test_pipe_data"
      entities = Sketchup.active_model.entities
      definition_dic = Hash.new
      begin
        entities.each{ |ent|
          if ent.is_a?(Sketchup::Group)
            definition = ent.definition
            name = definition.name
            if definition.name != "Laura" and !definition.name.include?("ThDefinition")
              su_component_definition = ThProtoBufExtention.to_ptoto_comp_definition_data(definition)
              su_component_data = ThProtoBufExtention.to_proto_component_data(ent, su_component_definition)
              su_project.buildings.push su_component_data
            end
          elsif ent.is_a?(Sketchup::ComponentInstance)
            definition = ent.definition
            if definition.name != "Laura" and !definition.name.include?("ThDefinition")
              if definition_dic[definition].nil?
                su_component_definition = ThProtoBufExtention.to_ptoto_comp_definition_data(definition)
                definition_dic[definition] = su_component_definition
              elsif
                su_component_definition = definition_dic[definition]
              end
              su_component_data = ThProtoBufExtention.to_proto_component_data(ent, su_component_definition)
              su_project.buildings.push su_component_data
            end
          end
        }
      rescue => e
        e.message
      end

      begin
        encoded_data_body = ThSUProjectData.encode(su_project)
        # # 为文件增加头部标识
        # encoded_data_head = [84, 72, 2, 0, 0, 0, 0, 0, 0, 0]
        # encoded_data = encoded_data_head.pack('C*') + encoded_data_body
        # outfile = File.new('D:\\SketchUpProject.ThBim', 'wb')
        # outfile.write(encoded_data)
        # outfile.close
        Pipe::Client.new('THSU2Viewer_TestPipe') do |pipe|
          result = pipe.writeCadPipeData(encoded_data_body)
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
            self.get_su_build_info
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
      file_loaded(__FILE__)
    end
  end # module HelloCube
end # module Examples
