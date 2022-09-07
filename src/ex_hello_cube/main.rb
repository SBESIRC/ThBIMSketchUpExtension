# Copyright 2016-2022 Trimble Inc
# Licensed under the MIT license
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/tch")
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/data")
require 'sketchup.rb'
require 'google/protobuf'
require_relative 'data/ThTCHProjectData_pb'
require_relative 'data/ThSUProjectData_pb'
require_relative 'tch/tch_su_project_builder'
require_relative 'tch/tch_su_geom_utils'
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
      definitions = Sketchup.active_model.definitions
      definitions.each{ |comp_def|
        comp_def_name = comp_def.name
        comp_instances = comp_def.instances
        if comp_def_name != "Laura" and !comp_def.group? and comp_instances.length > 0 and !comp_def_name.include?("ThDefinition")
          su_component_definition = ThSUCompDefinitionData.new
          su_component_definition.definition_name = comp_def_name
          faces = comp_def.entities.grep(Sketchup::Face)
          faces.each{ |face|
            begin
              # 0: Include PolygonMeshPoints,
              # 1: Include PolygonMeshUVQFront,
              # 2: Include PolygonMeshUVQBack,
              # 4: Include PolygonMeshNormals.
              su_face_data = ThSUFaceData.new
              mesh = face.mesh(4)
              su_mesh = ThSUPolygonMesh.new
              pts = mesh.points
              pts.each{ |pt|
                su_mesh.points.push ThTCH2SUGeomUtil.to_proto_point3d(pt)
              }
              nump = mesh.count_polygons
              (1..nump).each do |i|
                su_mesh.polygons.push ThTCH2SUGeomUtil.to_proto_polygon(mesh.polygon_at(i))
                su_mesh.normals.push ThTCH2SUGeomUtil.to_proto_vector3d(mesh.normal_at(i))
              end
              su_face_data.mesh = su_mesh
              su_component_definition.faces.push su_face_data
            rescue => e
              e.message
            end
          }
          comp_instances.each{ |instance|
            su_component_data = ThSUBuildingElementData.new
            su_component_instance = ThSUComponentData.new
            su_component_instance.definition = su_component_definition
            su_component_instance.transformations = ThTCH2SUGeomUtil.to_proto_transformation(instance.transformation)
            su_component_data.component = su_component_instance
            su_component_data.root = ThTCHRootData.new
            su_component_data.root.globalId = instance.entityID.to_s
            su_component_data.root.name = instance.name.to_s

            su_project.buildings.push su_component_data
          }
        end
      }
      begin
        Pipe::Client.new('THSU2Viewer_TestPipe') do |pipe|
          encoded_data = ThSUProjectData.encode(su_project)
          result = pipe.writeCadPipeData(encoded_data)
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
          command_tool1.small_icon = "../Img/ToCAD.png"             # 工具在工具条上显示的图标
          command_tool1.large_icon = "../Img/ToCAD.png"
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
          command_tool2.small_icon = "../Img/ToViewer.png"             # 工具在工具条上显示的图标
          command_tool2.large_icon = "../Img/ToViewer.png"
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
