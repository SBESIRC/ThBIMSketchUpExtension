require 'sketchup.rb'
require_relative 'tch_su_wall_factory.rb'

module Examples
  module HelloCube
    class ThTCH2SUStoreyFactory
      def self.ParseFloor(model, storey)
        if storey.is_a?(ThTCHBuildingStoreyData)
          list = model.definitions
          comp_def = list[storey.root.description]
          if comp_def.nil?
            comp_def = list.add storey.root.description
            # comp_def.description = storey.root.name
            entities = comp_def.entities
            storey_doors = storey.doors
            storey_windows = storey.windows
            storey_walls = storey.walls
            storey_walls.each{ |wall|
              ThTCH2SUWALLFACTORY.to_su_wall(entities, wall)
            }
          end
          
          # a transformation that does nothing to just get the job done.
          trans = Geom::Transformation.new(ThTCH2SUGeomUtil.to_su_point3d(storey.origin)) # an empty, default transformation.
          # Now, insert the Cube component.
          instance = model.active_entities.add_instance(comp_def, trans)
          instance.name = storey.root.name
        else
          result = false
        end
      end
    end
    # class Person
    #   # extend/include/prepend go first
    #   extend SomeModule
    #   include AnotherModule
    #   prepend YetAnotherModule

    #   # inner classes
    #   CustomError = Class.new(StandardError)

    #   # constants are next
    #   SOME_CONSTANT = 20

    #   # afterwards we have attribute macros
    #   attr_reader :name

    #   # followed by other macros (if any)
    #   validates :name

    #   # public class methods are next in line
    #   def self.some_method
    #   end

    #   # initialization goes between class methods and other instance methods
    #   def initialize
    #   end

    #   # followed by other public instance methods
    #   def some_method
    #   end

    #   # protected and private methods are grouped near the end
    #   protected

    #   def some_protected_method
    #   end

    #   private

    #   def some_private_method
    #   end
    # end
  end # module HelloCube
end # module Examples
