# Copyright 2016-2022 Trimble Inc
# Licensed under the MIT license
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/tch")
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/data")
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/vendor")
require 'sketchup.rb'
require 'json'
require 'google/protobuf'
require_relative 'data/ProtobufMessage_pb'
require_relative 'tch/tch_su_project_builder'
require_relative 'tch/protobuf_extension'
require_relative 'utility/client.rb'

module Examples
  module HelloCube
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

    def self.create_grid(rows = 5, columns = 5)
      # mesh = self.generate_grid_mesh(rows, columns)
      # model = Sketchup.active_model
      # model.start_operation('Grid', true)
      # group = model.active_entities.add_group
      # # group.entities.fill_from_mesh(mesh, true, Geom::PolygonMesh::AUTO_SOFTEN)
      # # group.entities.fill_from_mesh(mesh, true, Geom::PolygonMesh::HIDE_BASED_ON_INDEX)
      # group.entities.fill_from_mesh(mesh, true, Geom::PolygonMesh::SOFTEN_BASED_ON_INDEX)
      # #group.entities.fill_from_mesh(mesh, true, Geom::PolygonMesh::SMOOTH_SOFT_EDGES)
      # model.commit_operation
      Sketchup.active_model.entities.grep(Sketchup::Face).each{ |face|
        l = face.edges.length
        face.edges.each{ |e|
          a = e.smooth?
          b = e.soft?
          c = e.hidden?
          d = e.visible?
        }
      }
    end

    def self.generate_grid_mesh(rows, columns)
      # Compute the number of points and polygons we'll create. This is important
      # for max performance so PolygonMesh can allocate enough memory up front
      # and choose appropriate internal algorithm for looking up points.
      num_polygons = rows * columns
  
      row_points = rows + 1
      col_points = columns + 1
      num_points = row_points * col_points
  
      mesh = Geom::PolygonMesh.new()
  
      # To minimize the number of times points are looked up they are added
      # explicitly before adding any polygons.
      # As of SketchUp 2021.1 this step is less important, one can pass the points
      # to mesh.add_polygon instead of the indicies. There is however always a
      # performance benefit of building the polygons with indicies.

      # mesh.add_point(Geom::Point3d.new(0, 0, 0)) 
      # mesh.add_point(Geom::Point3d.new(100, 0, 0)) 
      # mesh.add_point(Geom::Point3d.new(100, 100, 0)) 
      # mesh.add_point(Geom::Point3d.new(0, 100, 0)) 
      # mesh.add_point(Geom::Point3d.new(0, 0, 100)) 
      # mesh.add_point(Geom::Point3d.new(100, 0, 100)) 
      # mesh.add_point(Geom::Point3d.new(100, 100, 100)) 
      # mesh.add_point(Geom::Point3d.new(0, 100, 100)) 
      # mesh.add_polygon([1, 2, 3])
      # mesh.add_polygon([1, 3, 4])
      # mesh.add_polygon([1, 2, 6, 5])
      # mesh.add_polygon([2, 6, 7, 3])
      # mesh.add_polygon([5, 6, 7, 8])
      # mesh.add_polygon([8, 7, 3, 4])
      # mesh.add_polygon([5, 8, 4, 1])

      indicies = []
      row_points.times { |x|
        col_points.times { |y|
          point = Geom::Point3d.new(x * 10, y * 10, 0)
          indicies << mesh.add_point(point) 
        }
      }
  
      (0...rows).each { |x|
        (0...columns).each { |y|
          i1 = (col_points * y) + x
          i2 = i1 + 1
          i3 = i2 + col_points
          i4 = i3 - 1
          polygon = [i1, i2, i3, i4].map { |i| indicies[i] }
          mesh.add_polygon(polygon)
        }
      }
  
      mesh
    end

    # 获取SU构建信息并发送至Viewer
    def self.get_su_build_info
      su_project = ThSUProjectData.new
      su_project.root = ThTCHRootData.new
      su_project.root.name = "空项目"
      su_project.root.globalId = "su_test_pipe_data"
      su_project.is_face_mesh = false
      su_project.project_path = Sketchup.active_model.path
      building_data = ThSUBuildingData.new
      begin
        skpfile = Sketchup.active_model.path
        if skpfile.length > 0
          su_project.root.name = File.basename(skpfile, ".*")
          file_path = File.expand_path('../../YDB/',skpfile)
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
        storey_data.stdFlr_no = -100
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
      if su_project.building.storeys.length == 1 and su_project.building.storeys.first.stdFlr_no == -100
        su_project.building.storeys.first.stdFlr_no = 1
      else
        first_storey = su_project.building.storeys.first
        last_storey = su_project.building.storeys.last
        if first_storey.stdFlr_no == -100
          first_storey.stdFlr_no = su_project.building.storeys[1].stdFlr_no - 1
          first_storey.height = su_project.building.storeys[1].elevation - first_storey.elevation
          if first_storey.stdFlr_no == 0
            first_storey.stdFlr_no = -1
          end
        end
        if last_storey.stdFlr_no == -100
          last_storey.stdFlr_no = su_project.building.storeys[su_project.building.storeys.length - 2].stdFlr_no + 1
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
      toolbar = UI::Toolbar.new "CAD插件"                   # 创建一个名为Test工具条
      if toolbar.visible? and toolbar.length > 0
        toolbar.hide
      else
        if toolbar.length < 1
          # Command1
          command_tool1 = UI::Command.new("开启CAD监听") {           # 创建一个工具名为Test的命令
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
          command_tool1.tooltip = "Turn on CAD monitoring"                      # 对该工具的一些说明
          command_tool1.status_bar_text = "开启 CAD 监听" # 在状态栏中显示的内容

          # Command2
          command_tool2 = UI::Command.new("推送数据至Viewer") {           # 创建一个工具名为Test的命令
            self.create_grid
            message = self.get_su_build_info
            self.push_to_viewer(message)
          }
          command_tool2.small_icon = "Img/ToViewer.png"             # 工具在工具条上显示的图标
          command_tool2.large_icon = "Img/ToViewer.png"
          command_tool2.tooltip = "Push To Viewer"                      # 对该工具的一些说明
          command_tool2.status_bar_text = "推送至 Viewer" # 在状态栏中显示的内容

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
      menu.add_item('CAD插件') {
        self.Show_ToolBar
      }
      # 主动调用一次使ToolBar先显示出来
      self.Show_ToolBar
      # file_loaded(__FILE__)
    end
  end # module HelloCube
end # module Examples
