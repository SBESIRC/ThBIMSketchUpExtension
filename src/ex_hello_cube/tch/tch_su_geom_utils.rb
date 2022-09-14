require 'sketchup.rb'
# require 'ThTCH2SUGeomUtil'

module Examples
  module ThTCH2SUGeomUtil
    module_function

    def to_su_point3d(pt)
      Geom::Point3d.new(pt.x.mm, pt.y.mm, pt.z.mm)
    end

    def to_su_vector3d(v)
      Geom::Vector3d.new(v.x, v.y, v.z)
    end

    def to_su_transformation(m)
      arr = [
        m.data11, m.data12, m.data13, m.data14,
        m.data21, m.data22, m.data23, m.data24,
        m.data31, m.data32, m.data33, m.data34,
        m.data41, m.data42, m.data43, m.data44,
      ]
      Geom::Transformation.new(arr)
    end
    
    # def multiple_transformations(scale, rotation, vector)
    #   # https://forums.sketchup.com/t/tranformation-move-and-rotate/154112
    #   var z_axis = Geom::Vector3d.new(0, 0, 1)
    #   var scale_trans = Geom::Transformation.scaling(scale, scale, scale)
    #   var rotation_trans = Geom::Transformation.rotation(ORIGIN, z_axis, rotation)
    #   var translation_trans = Geom::Transformation.translation(vector)
    #   translation_trans * rotation_trans * scale_trans
    # end

    def double_transformations(origin, direction)
      translation_trans = Geom::Transformation.new(origin, direction)
    end

    def multiple_transformations(scale, direction, origin)
      # https://forums.sketchup.com/t/tranformation-move-and-rotate/154112
      x_axis = Geom::Vector3d.new(1, 0, 0)
      scale_trans = Geom::Transformation.scaling(scale, scale, scale)
      rotation_trans = find_rotation_transformation(direction, x_axis)
      translation_trans = Geom::Transformation.translation(origin)
      translation_trans * rotation_trans * scale_trans
    end

    def find_rotation_transformation(vector1, vector2)
      # https://forums.sketchup.com/t/rotation-transformation-via-two-vectors/125678
      norm = (vector1 * vector2).normalize
      rot_angle = Math.atan2((vector1 * vector2) % norm, vector1 % vector2)
      Geom::Transformation.rotation(ORIGIN, norm, rot_angle)
    end

    def planar_angle(vector1, vector2)
      # https://forums.sketchup.com/t/rotation-transformation-via-two-vectors/125678
      normal = (vector1 * vector2).normalize
      Math.atan2((vector2 * vector1) % normal, vector1 % vector2)
    end

  end
end # module Examples
