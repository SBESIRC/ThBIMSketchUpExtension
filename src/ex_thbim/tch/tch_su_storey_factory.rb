require 'sketchup.rb'
require_relative 'tch_su_wall_factory.rb'
require_relative 'tch_su_slab_factory.rb'
require_relative 'tch_su_element_factory.rb'
require_relative 'tch_su_railing_factory.rb'

module Examples
  module HelloCube
    class ThTCHStoreyFactory
      def self.ParseFloor(model, storey, material_dic)
        if storey.is_a?(ThTCHBuildingStoreyData)
          def_def_list = model.definitions
          story_description = storey.build_element.root.description
          comp_def = def_list[story_description]
          if comp_def.nil?
            comp_def = def_list.add story_description
            # comp_def.description = storey.root.name
            entities = comp_def.entities
            begin
              # Wall
              storey_walls = storey.walls
              storey_walls.each{ |wall|
                ThTCH2SUWALLFACTORY.to_su_wall(entities, wall, material_dic["wall"], material_dic["door"], material_dic["window"])
              }

              # Slab
              storey_slabs = storey.slabs
              storey_slabs.each{ |slab|
                ThTCH2SUSLABFACTORY.to_su_slab(entities, slab, material_dic["slab"])
              }

              # Railing
              storey_railings = storey.railings
              storey_railings.each{ |railing|
                ThTCH2SURAILINGFACTORY.to_su_railing(entities, railing, material_dic["railing"])
              }
            rescue => e
              e.message
            end

            # a transformation that does nothing to just get the job done.
            trans = Geom::Transformation.new(ThTCH2SUGeomUtil.to_su_point3d(storey.origin)) # an empty, default transformation.
            # Now, insert the Cube component.
            instance = model.active_entities.add_instance(comp_def, trans)
            instance.name = storey.build_element.root.name
            instance.locked = true
          else
            entities = comp_def.entities
            entities_dic = Hash.new
            entities.each{ |ent|
              if ent.is_a?(Sketchup::Group)
                entities_dic[ent.description] = ent
              end
            }

            # Wall
            storey_walls = storey.walls
            storey_walls.each{ |wall|
              wall_group = entities_dic[wall.build_element.root.globalId]
              if wall_group.nil?
                ThTCH2SUWALLFACTORY.to_su_wall(entities, wall, material_dic["wall"], material_dic["door"], material_dic["window"])
              else
                entities_dic.delete(wall.build_element.root.globalId)
              end
            }

            # Slab
            storey_slabs = storey.slabs
            storey_slabs.each{ |slab|
              slab_group = entities_dic[slab.build_element.root.globalId]
              if slab_group.nil?
                ThTCH2SUSLABFACTORY.to_su_slab(entities, slab, material_dic["slab"])
              else
                entities_dic.delete(slab.build_element.root.globalId)
              end
            }

            # Railing
            storey_railings = storey.railings
            storey_railings.each{ |railing|
              railing_group = entities_dic[railing.build_element.root.globalId]
              if railing_group.nil?
                ThTCH2SURAILINGFACTORY.to_su_railing(entities, railing, material_dic["railing"])
              else 
                entities_dic.delete(railing.build_element.root.globalId)
              end
            }

            # 剩余元素
            entities_dic.each{ |key,value|
              if value.name != "门" and value.name != "窗"
                value = entities.erase_entities value
              end
            }
          end
        else
          result = false
        end
      end

      def self.full_refresh_floor(model, globalid, storey, material_dic)
        if storey.is_a?(ThTCHBuildingStoreyData)
          def_def_list = model.definitions
          story_description = globalid + storey.build_element.root.description
          comp_def = def_list[story_description]
          if comp_def.nil?
            comp_def = def_list.add story_description
            # comp_def.description = storey.root.name
            entities = comp_def.entities
            begin
              # Wall
              storey_walls = storey.walls
              storey_walls.each{ |wall|
                ThTCH2SUWALLFACTORY.to_su_wall(entities, wall, material_dic["wall"], material_dic["door"], material_dic["window"])
              }

              # Slab
              storey_slabs = storey.slabs
              storey_slabs.each{ |slab|
                ThTCH2SUSLABFACTORY.to_su_slab(entities, slab, material_dic["slab"])
              }

              # Railing
              storey_railings = storey.railings
              storey_railings.each{ |railing|
                ThTCH2SURAILINGFACTORY.to_su_railing(entities, railing, material_dic["railing"])
              }
            rescue => e
              e.message
            end
          end
          # a transformation that does nothing to just get the job done.
          trans = Geom::Transformation.new(ThTCH2SUGeomUtil.to_su_point3d(storey.origin)) # an empty, default transformation.
          # Now, insert the Cube component.
          instance = model.active_entities.add_instance(comp_def, trans)
          instance.name = storey.build_element.root.name
          instance.locked = true
        else
          result = false
        end
      end

      def self.incremental_update_floor(model, globalid, storey, cache_storey, material_dic)
        if storey.is_a?(ThTCHBuildingStoreyData) and storey.memory_storey_id.length == 0
          def_def_list = model.definitions
          story_description = globalid + storey.build_element.root.description
          comp_def = def_list[story_description]
          entities = comp_def.entities
          if comp_def.nil?
            comp_def = def_list.add story_description
            # comp_def.description = storey.root.name
            begin
              # Wall
              storey_walls = storey.walls
              storey_walls.each{ |wall|
                ThTCH2SUWALLFACTORY.to_su_wall(entities, wall, material_dic["wall"], material_dic["door"], material_dic["window"])
              }

              # Slab
              storey_slabs = storey.slabs
              storey_slabs.each{ |slab|
                ThTCH2SUSLABFACTORY.to_su_slab(entities, slab, material_dic["slab"])
              }

              # Railing
              storey_railings = storey.railings
              storey_railings.each{ |railing|
                ThTCH2SURAILINGFACTORY.to_su_railing(entities, railing, material_dic["railing"])
              }
            rescue => e
              e.message
            end

            # a transformation that does nothing to just get the job done.
            trans = Geom::Transformation.new(ThTCH2SUGeomUtil.to_su_point3d(storey.origin)) # an empty, default transformation.
            # Now, insert the Cube component.
            instance = model.active_entities.add_instance(comp_def, trans)
            instance.name = storey.build_element.root.name
            instance.locked = true
          else
            # 增量更新
            # Wall
            storey_walls = storey.walls
            cache_storey_walls = cache_storey.walls
            if storey_walls != cache_storey_walls
              storey_walls.each{ |wall|
                cache_walls = cache_storey_walls.select{ |o| o.build_element.root.globalId == wall.build_element.root.globalId }
                if !cache_walls.nil? and cache_walls.length == 1
                  cache_wall = cache_walls.first
                  cache_storey_walls.delete cache_wall
                  if cache_wall != wall
                    self.delete_group(entities, cache_wall.build_element.root.globalId)
                    cache_wall.doors.each{ |door|
                      self.delete_group(entities, door.build_element.root.globalId)
                    }
                    cache_wall.windows.each{ |window|
                      self.delete_group(entities, window.build_element.root.globalId)
                    }
                    ThTCH2SUWALLFACTORY.to_su_wall(entities, wall, material_dic["wall"], material_dic["door"], material_dic["window"])
                  end
                else
                  ThTCH2SUWALLFACTORY.to_su_wall(entities, wall, material_dic["wall"], material_dic["door"], material_dic["window"])
                end
              }
              cache_storey_walls.each{ |wall|
                self.delete_group(entities, wall.build_element.root.globalId)
                wall.doors.each{ |door|
                  self.delete_group(entities, door.build_element.root.globalId)
                }
                wall.windows.each{ |window|
                  self.delete_group(entities, window.build_element.root.globalId)
                }
              }
            end

            # Slab
            storey_slabs = storey.slabs
            cache_storey_slabs = cache_storey.slabs
            if storey_slabs != cache_storey_slabs
              storey_slabs.each{ |slab|
                cache_slabs = cache_storey_slabs.select{ |o| o.build_element.root.globalId == slab.build_element.root.globalId }
                if !cache_slabs.nil? and cache_slabs.length == 1
                  cache_slab = cache_slabs.first
                  cache_storey_slabs.delete cache_slab
                  if cache_slab != slab
                    self.delete_group(entities, cache_slab.build_element.root.globalId)
                    ThTCH2SUSLABFACTORY.to_su_slab(entities, slab, material_dic["slab"])
                  end
                else
                  ThTCH2SUSLABFACTORY.to_su_slab(entities, slab, material_dic["slab"])
                end
              }
              cache_storey_slabs.each{ |slab|
                self.delete_group(entities, slab.build_element.root.globalId)
              }
            end

            # Railing
            storey_railings = storey.railings
            cache_storey_railings = cache_storey.railings
            if storey_railings != cache_storey_railings
              storey_railings.each{ |railing|
                cache_railings = cache_storey_railings.select{ |o| o.build_element.root.globalId == railing.build_element.root.globalId }
                if !cache_railings.nil? and cache_railings.length == 1
                  cache_railing = cache_railings.first
                  cache_railings.delete cache_railing
                  if cache_railing != railing
                    self.delete_group(entities, cache_railing.build_element.root.globalId)
                    ThTCH2SURAILINGFACTORY.to_su_railing(entities, railing, material_dic["railing"])
                  end
                else
                  ThTCH2SURAILINGFACTORY.to_su_railing(entities, railing, material_dic["railing"])
                end
              }
              cache_storey_railings.each{ |railing|
                self.delete_group(entities, railing.build_element.root.globalId)
              }
            end

          end
        else
          result = false
        end
      end

      def self.delete_group(entities, group_id)
        entities.each{ |ent|
          if ent.is_a?(Sketchup::Group) and ent.description == group_id
            ent.erase!
          end
        }
      end
    end

    class ThSUStoreyFactory
      def self.full_refresh_floor(definitions, storey)
        begin
          if storey.is_a?(ThSUBuildingStoreyData)
            def_list = Sketchup.active_model.definitions
            story_description = storey.root.globalId
            if true
              comp_def = def_list.add story_description
              entities = comp_def.entities
                # elements
                buildings = storey.buildings
                buildings.each{ |element|
                  ThTCH2SUELEMENTFACTORY.to_su_element(entities, definitions[element.component.definition_index], element.component.transformations)
                }
            end
            # a transformation that does nothing to just get the job done.
            #trans = Geom::Transformation.new(ThTCH2SUGeomUtil.to_su_point3d(storey.origin)) # an empty, default transformation.
            transform = Geom::Transformation.new
            # Now, insert the Cube component.
            instance = Sketchup.active_model.active_entities.add_instance(comp_def, trans)
            # instance.name = storey.build_element.root.name
            instance.locked = true
          else
            result = false
          end
        rescue => e
          e.message
        end
      end
    end
  end # module HelloCube
end # module Examples
