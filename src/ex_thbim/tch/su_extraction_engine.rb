require 'sketchup.rb'

module ThBM
    class SUExtractionEngine
        @@view_hash_data
        @@su_project

        #构造函数
        def initialize
            @@su_project = ThSUProjectData.new
            @@su_project.root = ThTCHRootData.new
            @@su_project.root.name = "空项目"
            @@su_project.root.globalId = "su_test_pipe_data"
            @@su_project.is_face_mesh = false
            @@su_project.project_path = Sketchup.active_model.path

            @@view_hash_data = { "剖面视图" => [] , "平面视图" => [] }
        end

        def extract_storey_config
            building_data = ThSUBuildingData.new
            begin
              skpfile = Sketchup.active_model.path
              if skpfile.length > 0
                @@su_project.root.name = File.basename(skpfile, ".*")
                file_path = File.expand_path('../../YDB/',skpfile)
                cad_file_path = File.expand_path('../../IFC/',skpfile)
                if File.directory? file_path
                  Dir.entries(file_path, encoding:'UTF-8').each{ |file_name|
                    if file_name.include? ".ifc.json"
                      file_full_path = File::join(file_path, file_name)
                      json_string = File.read(file_full_path)
                      json = JSON.parse(json_string)
                      for i in 0..json.length - 1
                        obj = json[i]
                        storey_data = ThSUBuildingStoreyData.new
                        storey_data.root = ThTCHRootData.new
                        storey_data.root.globalId = "su_storey_" + obj["No"].to_s
                        storey_data.root.name = obj["Name"]
                        storey_data.number = obj["No"]
                        storey_data.elevation = obj["Elevation"]
                        storey_data.height = obj["Height"]
                        if i == json.length - 1
                          storey_data.highest = obj["Highest"]
                        else
                          storey_data.highest = 0
                        end
                        storey_data.stdFlr_no = obj["StdFlrNo"]
                        building_data.storeys.push storey_data
                      end
                      find_storey_config = true
                      break
                    end
                  }
                end
                if building_data.storeys.length == 0 and File.directory? cad_file_path
                  Dir.entries(cad_file_path, encoding:'UTF-8').each{ |file_name|
                    if file_name.include? ".StoreyInfo.json"
                      file_full_path = File::join(cad_file_path, file_name)
                      json_string = File.read(file_full_path)
                      json = JSON.parse(json_string)
                      key, value = json.first
                      for i in 0..value.length - 1
                        obj = value[i]
                        storey_data = ThSUBuildingStoreyData.new
                        storey_data.root = ThTCHRootData.new
                        storey_data.root.globalId = obj["StoreyName"]
                        storey_data.root.name = obj["PaperName"]
                        storey_data.number = obj["FloorNo"].to_i
                        storey_data.elevation = obj["Bottom_Elevation"]
                        storey_data.height = obj["Height"]
                        storey_data.highest = 0
                        storey_data.stdFlr_no = obj["StdFlrNo"].to_i
                        building_data.storeys.push storey_data
                      end
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
              storey_data.elevation = 1.0e10
              storey_data.height = -1.0e10
              storey_data.stdFlr_no = -100
              storey_data.highest = 0
              building_data.storeys.push storey_data
            end
            @@su_project.building = building_data
        end

        def extract_active_model_data
            entities = Sketchup.active_model.entities
            entities.each{ |ent|
                if ent.is_a?(Sketchup::Group) or ent.is_a?(Sketchup::ComponentInstance)
                    code = ThProtoBufExtention.get_hash_code(2166136261, ent.entityID)
                    to_proto_definition_data(ent, ent.transformation, code)
                end
            }
        end

        def get_project
            @@su_project
        end

        def get_stair_view_data
            @@view_hash_data
        end

        def to_proto_definition_data(ent, tr, hashcode)
            ent_layer = ent.layer
            definition = ent.definition
            su_component_definition = ThSUCompDefinitionData.new
            if definition.name != "Laura" and !definition.name.include?("ThDefinition") and !definition.name.include?(".dwg")
                su_definition_index = @@su_project.definitions.index{ |d| d.definition_name == definition.name}
                minz = 1.0e8
                maxz = -1.0e8
                if ent_layer.name == "楼梯剖面视图框"
                    faces = definition.entities.grep(Sketchup::Face)
                    cut_face_index = faces.index{ |f| f.layer.name == "楼梯剖切面" }
                    if !cut_face_index.nil?
                        cut_face = faces[cut_face_index]
                        opposite_cut_face_index = faces.index{ |f| f != cut_face && f.normal.parallel?(cut_face.normal) }
                        opposite_cut_face = faces[opposite_cut_face_index]
                        vector = opposite_cut_face.bounds.center - cut_face.bounds.center
                        profile_data = {"Face" => [],"Vector" => nil}
                        cut_face.outer_loop.vertices.each{ |v|
                            profile_data["Face"].push ThProtoBufExtention.to_proto_point3d(v.position.transform(tr))
                        }
                        profile_data["Vector"] = ThProtoBufExtention.to_proto_vector3d(vector.transform(tr))
                        @@view_hash_data["剖面视图"].push profile_data
                    end
                elsif ent_layer.name == "楼梯平面视图框"
                    faces = definition.entities.grep(Sketchup::Face)
                    cut_face = nil
                    cut_face_center = nil
                    opposite_cut_face_center = nil
                    faces.each{ |f|
                        centerpt = tr * f.bounds.center
                        if maxz < centerpt.z.to_mm
                            maxz = centerpt.z.to_mm
                            cut_face = f
                            cut_face_center = centerpt
                        end
                        if minz > centerpt.z.to_mm
                            minz = centerpt.z.to_mm
                            opposite_cut_face_center = centerpt
                        end
                    }
                    profile_data = {"FloorNo" => "", "Face" => [],"Vector" => nil}
                    vector = opposite_cut_face_center - cut_face_center
                    cut_face.outer_loop.vertices.each{ |v|
                        profile_data["Face"].push ThProtoBufExtention.to_proto_point3d(v.position.transform(tr))
                    }
                    profile_data["Vector"] = ThProtoBufExtention.to_proto_vector3d(vector)
                    centerz = (minz + maxz) / 2
                    storey_index = @@su_project.building.storeys.rindex{ |o| centerz > o.elevation}
                    if !storey_index.nil?
                        storey = @@su_project.building.storeys[storey_index]
                        profile_data["FloorNo"] = storey.number
                    end
                    @@view_hash_data["平面视图"].push profile_data
                else
                    definition.entities.each{ |e|
                        if e.is_a?(Sketchup::Face)
                            if su_definition_index.nil?
                                su_face_data = ThSUFaceBrepData.new
                                e.loops.each{ |su_loop|
                                    if su_loop.outer?
                                        su_face_data.outer_loop = ThProtoBufExtention.to_proto_loop_data(su_loop)
                                    else
                                        su_face_data.inner_loops.push ThProtoBufExtention.to_proto_loop_data(su_loop)
                                    end
                                }
                                su_component_definition.brep_faces.push su_face_data
                            end
                            centerpt_z = (tr * e.bounds.center).z.to_mm
                            minz = [minz, centerpt_z].min
                            maxz = [maxz, centerpt_z].max
                        elsif e.is_a?(Sketchup::Group) or e.is_a?(Sketchup::ComponentInstance)
                            to_proto_definition_data(e, tr * e.transformation, get_hash_code(hashcode, e.entityID))
                        end
                    }
                    if su_component_definition.brep_faces.length > 0
                        su_component_definition.definition_name = definition.name
                        su_definition_index = su_project_add_definition(@@su_project, su_component_definition)
                    end
                    if !su_definition_index.nil?
                        su_component_data = to_su_component_data(ent, tr, su_definition_index, hashcode)
                        ifc_type = definition.get_attribute("AppliedSchemaTypes", "IFC 2x3")
                        if !ifc_type.nil?
                            su_component_data.component.ifc_classification = ifc_type
                        end
    
                        if @@su_project.building.storeys.length == 1 and @@su_project.building.storeys.first.stdFlr_no == -100
                            first_storey = @@su_project.building.storeys.first
                            first_storey.buildings.push su_component_data
                            first_storey.elevation = [first_storey.elevation, minz].min
                            first_storey.height = [first_storey.height, maxz - first_storey.elevation].max
                        else
                            centerz = (minz + maxz) / 2
                            # 临时逻辑：对SU的横向构建(梁/板),判断归属楼层的时候，按下降500去判断归属
                            # 为了去应对梁板的翻高现象
                            if ent.layer.name == "S_BEAM" or ent.layer.name == "S_SLAB" or ent.layer.name == "S_FLOOR"
                                centerz = centerz - 500
                            end
                            storey_index = @@su_project.building.storeys.rindex{ |o| centerz > o.elevation}
                            if storey_index.nil?
                                first_storey = @@su_project.building.storeys.first
                                if first_storey.stdFlr_no == -100
                                    first_storey.buildings.push su_component_data
                                    first_storey.elevation = [first_storey.elevation, minz].min
                                else
                                    storey_data = ThSUBuildingStoreyData.new
                                    storey_data.root = ThTCHRootData.new
                                    storey_data.number = @@su_project.building.storeys.first.number - 1
                                    storey_data.elevation = minz
                                    storey_data.height = 0
                                    storey_data.highest = 0
                                    storey_data.stdFlr_no = -100
                                    if storey_data.number == 0
                                        storey_data.number = -1
                                    end
                                    storey_data.root.globalId = "su_storey_" + storey_data.number.to_s
                                    storey_data.buildings.push su_component_data
                                    @@su_project.building.storeys.insert(0, storey_data)
                                end
                            else
                                storey = @@su_project.building.storeys[storey_index]
                                if storey.stdFlr_no == -100
                                    storey.buildings.push su_component_data
                                    storey.height = [storey.height, maxz - storey.elevation].max
                                elsif storey.elevation + storey.height + storey.highest < centerz
                                    storey_data = ThSUBuildingStoreyData.new
                                    storey_data.root = ThTCHRootData.new
                                    storey_data.number = @@su_project.building.storeys.last.number + 1
                                    storey_data.elevation = storey.elevation + storey.height + storey.highest
                                    storey_data.height = maxz - storey_data.elevation
                                    storey_data.highest = 0
                                    storey_data.stdFlr_no = -100
                                    storey_data.root.globalId = "su_storey_" + storey_data.number.to_s
                                    storey_data.buildings.push su_component_data
                                    @@su_project.building.storeys.push storey_data
                                else
                                    storey.buildings.push su_component_data
                                end
                            end
                        end
                    end
                end
            end
        end

        def su_project_add_definition(su_project, su_definition)
            su_project.definitions.push su_definition
            return su_project.definitions.length - 1
        end

        def to_su_component_data(ent, tr, su_component_definition_index, hashcode)
            su_component_data = ThSUBuildingElementData.new
            su_component_data.root = ThTCHRootData.new
            su_component_data.root.globalId = hashcode.to_s
            su_component_data.root.name = ent.name.to_s
            su_component_data.component = ThSUComponentData.new
            su_component_data.component.transformations = ThProtoBufExtention.to_proto_transformation(tr)
            su_component_data.component.definition_index = su_component_definition_index
            if !(ent_layer = ent.layer).nil?
                case ent_layer.name
                when "S_BEAM"
                    su_component_data.component.ifc_classification = "IfcBeam"
                    ent_name = ent.name
                    if !ent_name.nil?
                        su_component_data.component.instance_name = ent_name
                    end
                when "S_COLU"
                    su_component_data.component.ifc_classification = "IfcColumn"
                when "S_FLOOR", "S_SLAB"
                    su_component_data.component.ifc_classification = "IfcSlab"
                when "S_WALL"
                    su_component_data.component.ifc_classification = "IfcWall"
                when "S_CONS_构造柱"
                    su_component_data.component.ifc_classification = "IfcColumn"
                    su_component_data.component.instance_name = "S_CONS_构造柱"
                when "S_CONS_通高墙"
                    su_component_data.component.ifc_classification = "IfcWall"
                    su_component_data.component.instance_name = "S_CONS_通高墙"
                when "S_CONS_窗台墙"
                    su_component_data.component.ifc_classification = "IfcWall"
                    su_component_data.component.instance_name = "S_CONS_窗台墙"
                when "S_COLU_梯柱"
                    su_component_data.component.ifc_classification = "IfcColumn"
                    su_component_data.component.instance_name = "S_COLU_梯柱"
                when "S_BEAM_梯梁"
                    su_component_data.component.ifc_classification = "IfcBeam"
                    ent_name = ent.name
                    if !ent_name.nil?
                        su_component_data.component.instance_name = ent_name + ";S_BEAM_梯梁"
                    else
                        su_component_data.component.instance_name = "S_BEAM_梯梁"
                    end
                when "Layer0" # 没有图层时的默认图层名
                    material = ent.material
                    if !material.nil?
                        su_material = ThProtoBufExtention.to_proto_material(material)
                        su_component_data.component.material = su_material
                    end
                end
            end
            su_component_data
        end

        def get_hash_code(hash, code)
            hash * 16777619 ^ code
        end

    end # module ThProtoBufExtention
end # module ThBM