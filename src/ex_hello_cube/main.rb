# Copyright 2016-2022 Trimble Inc
# Licensed under the MIT license
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/tch")
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/data")
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
    @CommandTool

    def self.StartWin32PipeMonitor
      @TimerID = UI.start_timer(2, true){
        begin
          Pipe::Client.new('THSUPush_TestPipe') do |pipe|
            data = pipe.readCadPipeData
            model = ThTCHBuildingData.decode(data)
            ThTCH2SUBuildingBuilder.Building(model)

            # self.CreatEntity(model)
            # puts "Got [#{data}] back from server"
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

    def self.ReadFile1
      # file = File.open("D:/SketchUp/ThBIMSketchUpExtension/src/ex_hello_cube/data.bin","r")
      # data2 = file.read
      # file_data = file.readlines.map(&:chomp)

      # contents = File.open("D:/SketchUp/ThBIMSketchUpExtension/src/ex_hello_cube/data.bin", "r") { |f| f.read }
      # data = contents
      # s = IO.read("D:/SketchUp/ThBIMSketchUpExtension/src/ex_hello_cube/data.bin")

      # data1 = File.read("D:/SketchUp/ThBIMSketchUpExtension/src/ex_hello_cube/data.bin")
      # model = ThTCHBuildingData.decode(data)
      # value = ThTCH2SUBuildingBuilder.Building(model)
    end

    def self.Show_ToolBar
      toolbar = UI::Toolbar.new "CAD插件"                   # 创建一个名为Test工具条
      if toolbar.visible? and toolbar.length > 0
        toolbar.hide
      else
        if toolbar.length < 1
          @CommandTool = UI::Command.new("测试管道连接") {           # 创建一个工具名为Test的命令
              if(@TimerFlag == false)
                self.StartWin32PipeMonitor
              else
                self.CloseWin32PipeMonitor
              end
              # self.ReadFile1
          }
          @CommandTool.small_icon = "../Img/ToolPencilSmall.png"             # 工具在工具条上显示的图标
          @CommandTool.large_icon = "../Img/ToolPencilLarge.png"
          @CommandTool.set_validation_proc {
            if @TimerFlag
              MF_CHECKED
            else
              MF_UNCHECKED
            end
          }
          @CommandTool.tooltip = "Test Pipe Connect"                      # 对该工具的一些说明
          @CommandTool.status_bar_text = "测试 管道 连接" # 在状态栏中显示的内容
          toolbar = toolbar.add_item @CommandTool                     # 将这个命名添加到工具条上
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
