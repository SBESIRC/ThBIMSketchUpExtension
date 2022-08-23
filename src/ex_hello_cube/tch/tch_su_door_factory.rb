require 'sketchup.rb'

module Examples
  module ThTCH2SUDoorFactory
    module_function

    def create_door(model, tch_door)
      #
    end

    def create_face(entities, tch_door)
      var pts = [
        Geom::Point3d.new(-tch_door.length/2.0, -tch_door.width/2.0, 0.0)
        Geom::Point3d.new(-tch_door.length/2.0, tch_door.width/2.0, 0.0)
        Geom::Point3d.new(tch_door.length/2.0, tch_door.width/2.0, 0.0)
        Geom::Point3d.new(tch_door.length/2.0, -tch_door.width/2.0, 0.0)
      ]
      face = entities.add_face(pts)
      face.transform!(ThTCH2SUGeomUtil.multiple_transformations(1.0, tch_door.x_vector, tch_door.origin))
    end

  end # module HelloCube
end # module Examples
