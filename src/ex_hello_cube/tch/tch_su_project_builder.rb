require 'sketchup.rb'
require_relative 'tch_su_storey_factory.rb'

module Examples
  module HelloCube
    class ThTCH2SUProjectBuilder
        def self.Building(data)
          if data.is_a?(ThTCHProjectData)
            model = Sketchup.active_model
            project_site = data.site
            project_site_buildings = project_site.buildings
            # 暂时先假定只有一个building，等后续多建筑后再去扩展
            building = project_site_buildings.first
            storeys = building.storeys
            storeys.each{ |storey|
              # 后期在这里做逻辑
              # 创建geometry
              ThTCH2SUStoreyFactory.ParseFloor(model, storey)
            }
          else
            value = false
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
