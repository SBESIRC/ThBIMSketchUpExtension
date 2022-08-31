# Copyright 2016-2022 Trimble Inc
# Licensed under the MIT license
require 'sketchup.rb'
require 'google/protobuf'
require_relative 'data/ThTCHBuildingData_pb'
require_relative 'tch/tch_su_building_builder'
require_relative '../win32/pipe'
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
            model = ThTCHBuildingData.decode(pipe_data_body)
            ThTCH2SUBuildingBuilder.Building(model)
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

    def self.get_su_build_info
      definitions = Sketchup.active_model.definitions
      definitions.each{ |comp_def|
        comp_instances = comp_def.instances
        if comp_instances.length > 0
          faces = comp_def.entities.grep(Sketchup::Face)
          faces.each{ |face|
            flags = 7
            mesh = face.mesh(flags)
            pts = mesh.points
            polygons = mesh.polygons
          }
          comp_instances.each{ |instance|
            t = instance.transformation
          }
        end
      }
    end

    def self.CreatEntity(data)
      model = Sketchup.active_model
      model.start_operation('Create Cube', true)
      group = model.active_entities.add_group
      entities = group.entities
      pt1_x = 
      points = [
        Geom::Point3d.new(data.origin.x + data.width / 2, data.origin.y + data.length / 2, 0),
        Geom::Point3d.new(data.origin.x - data.width / 2, data.origin.y + data.length / 2, 0),
        Geom::Point3d.new(data.origin.x - data.width / 2, data.origin.y - data.length / 2, 0),
        Geom::Point3d.new(data.origin.x + data.width / 2, data.origin.y - data.length / 2, 0),
      ]
      face = entities.add_face(points)
      face.pushpull(-1 * data.height)
      model.commit_operation
    end

    def self.Show_ToolBar
      toolbar = UI::Toolbar.new "CAD插件"                   # 创建一个名为Test工具条
      if toolbar.visible? and toolbar.length > 0
        toolbar.hide
      else
        if toolbar.length < 1
          # Command1
          command_tool1 = UI::Command.new("测试管道连接") {           # 创建一个工具名为Test的命令
              if(@TimerFlag == false)
                self.StartWin32PipeMonitor
              else
                self.CloseWin32PipeMonitor
              end
          }
          command_tool1.small_icon = "../Img/ToolPencilSmall.png"             # 工具在工具条上显示的图标
          command_tool1.large_icon = "../Img/ToolPencilLarge.png"
          command_tool1.set_validation_proc {
            if @TimerFlag
              MF_CHECKED
            else
              MF_UNCHECKED
            end
          }
          command_tool1.tooltip = "Test Pipe Connect"                      # 对该工具的一些说明
          command_tool1.status_bar_text = "测试 管道 连接" # 在状态栏中显示的内容
          
          # Command2
          command_tool2 = UI::Command.new("测试Viewer连接") {           # 创建一个工具名为Test的命令
            self.get_su_build_info
          }
          command_tool2.small_icon = "../Img/ToolPencilLarge.png"             # 工具在工具条上显示的图标
          command_tool2.large_icon = "../Img/ToolPencilSmall.png"
          # command_tool2.set_validation_proc {
          #   if @TimerFlag
          #     MF_CHECKED
          #   else
          #     MF_UNCHECKED
          #   end
          # }
          command_tool2.tooltip = "Test Viewer Connect"                      # 对该工具的一些说明
          command_tool2.status_bar_text = "测试 Viewer 连接" # 在状态栏中显示的内容


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
