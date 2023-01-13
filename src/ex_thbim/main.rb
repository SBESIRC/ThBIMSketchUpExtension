# Copyright 2016-2022 Trimble Inc
# Licensed under the MIT license
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/tch")
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/data")
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/vendor")
require 'sketchup.rb'
require 'json'
require 'google/protobuf'
require_relative 'tch/su_extraction_engine'
require_relative 'data/ProtobufMessage_pb'
require_relative 'tch/tch_su_project_builder'
require_relative 'tch/protobuf_extension'
require_relative 'utility/client.rb'

module ThBM
  module Main
    @PipeTimerID = 0
    @PipeTimerFlag = false

    def self.StartWin32PipeMonitor
      @PipeTimerID = UI.start_timer(2, true){
        begin
          Pipe::Client.new('THCAD2SUPIPE') do |pipe|
            pipe.read()
            message = ProtobufMessage.decode(pipe.buffer)
            message_majer = message.header.major
            message.cad_projects.each{ |project|
              ThTCHProjectBuilder.building_project(project)
            }
            message.su_projects.each{ |project|
              ThSUProjectBuilder.building_project(project)
            }
          end
        rescue => e
          e.message
        end
      }
      @PipeTimerFlag = true
    end

    def self.CloseWin32PipeMonitor
      UI.stop_timer(@PipeTimerID)
      @PipeTimerFlag = false
    end

    # 获取SU构建信息并发送至Viewer
    def self.get_su_build_info
      begin
        engine = SUExtractionEngine.new
        engine.extract_storey_config
        engine.extract_active_model_data
        su_project = engine.get_project
        view_hash_data = engine.get_stair_view_data
        file = Sketchup.active_model.path
      rescue => e
        e.message
      end
      if file.length > 0
        file_path = File.dirname(file)
        file_basename = File.basename(file, ".*")
        filename = File.join(file_path, file_basename + ".json")
        jsonified = JSON.generate(view_hash_data)
        outfile = File.new(filename, 'wb')
        outfile.write(jsonified)
        outfile.close
      end

      if su_project.building.storeys.length == 1 and su_project.building.storeys.first.stdFlr_no == -100
        su_project.building.storeys.first.stdFlr_no = 1
        su_project.building.storeys.first.elevation = su_project.building.storeys.first.elevation.floor
        su_project.building.storeys.first.height = su_project.building.storeys.first.height.ceil
      else
        first_storey = su_project.building.storeys.first
        last_storey = su_project.building.storeys.last
        if first_storey.stdFlr_no == -100
          first_storey.stdFlr_no = su_project.building.storeys[1].stdFlr_no - 1
          first_storey.elevation = first_storey.elevation.floor
          first_storey.height = su_project.building.storeys[1].elevation - first_storey.elevation
          if first_storey.stdFlr_no == 0
            first_storey.stdFlr_no = -1
          end
        end
        if last_storey.stdFlr_no == -100
          last_storey.stdFlr_no = su_project.building.storeys[su_project.building.storeys.length - 2].stdFlr_no + 1
          last_storey.height = last_storey.height.ceil
        end
      end

      message = ProtobufMessage.new
      message.header = MessageHeader.new
      message.header.major = ""
      message.header.source = MessageSourceEnum::SU
      message.su_projects.push su_project
      message
    end

    def self.push_to_viewer(message)
      begin
        encoded_data = ProtobufMessage.encode(message)
        Pipe::Client.new('THSU2P3DIPE') do |pipe|
          pipe.write(encoded_data)
        end
        file = Sketchup.active_model.path
        if file.length > 0
          file_path = File.dirname(file)
          file_basename = File.basename(file, ".*")
          filename = File.join(file_path, file_basename + ".thbim")
          outfile = File.new(filename, 'wb')
          outfile.write(encoded_data)
          outfile.close
        end
      rescue => e
        e.message
      end
    end

    def self.Show_ToolBar
      toolbar = UI::Toolbar.new "天华SU插件"                   # 创建一个名为Test工具条
      if toolbar.visible? and toolbar.length > 0
        toolbar.hide
      else
        if toolbar.length < 1
          # Command1
          command_tool1 = UI::Command.new("开启监听") {           # 创建一个工具名为Test的命令
              if(@PipeTimerFlag == false)
                self.StartWin32PipeMonitor
              else
                self.CloseWin32PipeMonitor
              end
          }
          command_tool1.small_icon = "Img/ToCAD.png"             # 工具在工具条上显示的图标
          command_tool1.large_icon = "Img/ToCAD.png"
          command_tool1.set_validation_proc {
            if @PipeTimerFlag
              MF_CHECKED
            else
              MF_UNCHECKED
            end
          }
          command_tool1.tooltip = "Turn on monitoring"                      # 对该工具的一些说明
          command_tool1.status_bar_text = "开启 监听" # 在状态栏中显示的内容

          # Command2
          command_tool2 = UI::Command.new("推送数据至平台") {           # 创建一个工具名为Test的命令
            message = self.get_su_build_info
            self.push_to_viewer(message)
          }
          command_tool2.small_icon = "Img/ToViewer.png"             # 工具在工具条上显示的图标
          command_tool2.large_icon = "Img/ToViewer.png"
          command_tool2.tooltip = "Push To Platform3D"                      # 对该工具的一些说明
          command_tool2.status_bar_text = "推送至 平台" # 在状态栏中显示的内容

          toolbar = toolbar.add_item command_tool1                     # 将Tool1添加到工具条上
          toolbar = toolbar.add_separator                              # 添加分隔符
          toolbar = toolbar.add_item command_tool2                     # 将Tool2添加到工具条上
        end
        toolbar.show                                       # 在SktchUp中显示该工具条
      end
    end

    # Main
    unless file_loaded?(__FILE__)
      menu = UI.menu('Tools')
      menu.add_item('天华SU插件') {
        self.Show_ToolBar
      }
      # 主动调用一次使ToolBar先显示出来
      self.Show_ToolBar
      # file_loaded(__FILE__)
    end
  end # module HelloCube
end # module ThBM
