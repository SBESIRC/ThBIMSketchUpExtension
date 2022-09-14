require 'sketchup.rb'
require_relative 'tch_su_wall_factory.rb'
require_relative 'tch_su_slab_factory.rb'
require_relative 'tch_su_railing_factory.rb'

module Examples
  module HelloCube
    class ThTCH2SUStoreyFactory
      def self.ParseFloor(model, storey, material_dic)
        if storey.is_a?(ThTCHBuildingStoreyData)
          list = model.definitions
          comp_def = list[storey.root.description]
          if comp_def.nil?
              comp_def = list.add storey.root.description
              # comp_def.description = storey.root.name
              entities = comp_def.entities
              storey_doors = storey.doors
              storey_windows = storey.windows

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
          end
          
          # a transformation that does nothing to just get the job done.
          trans = Geom::Transformation.new(ThTCH2SUGeomUtil.to_su_point3d(storey.origin)) # an empty, default transformation.
          # Now, insert the Cube component.
          instance = model.active_entities.add_instance(comp_def, trans)
          instance.name = storey.root.name
          instance.locked = true
        else
          result = false
        end
      end
    end
  end # module HelloCube
end # module Examples
