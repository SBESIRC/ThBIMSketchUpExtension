require 'sketchup.rb'
# require 'ThTCH2SUGeomUtil'

module Examples
  module ThTCH2SUGeomUtil
    module_function

    def to_su_point3d(pt)
      Geom::Point3d.new(pt.x, pt.y, pt.z)
    end

    def to_proto_point3d(pt)
      proto_pt = ThTCHPoint3d.new
      proto_pt.x = pt.x.to_f
      proto_pt.y = pt.y.to_f
      proto_pt.z = pt.z.to_f
      proto_pt
    end

    def to_proto_polygon(polygon)
      proto_polygon = ThSUPolygon.new
      proto_polygon.indices.push polygon[0]
      proto_polygon.indices.push polygon[1]
      proto_polygon.indices.push polygon[2]
      proto_polygon
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

    def to_proto_transformation(m)
      arr = m.to_a
      proto_matrix = ThTCHMatrix3d.new
      proto_matrix.data11 = arr[0].to_f
      proto_matrix.data12 = arr[1].to_f
      proto_matrix.data13 = arr[2].to_f
      proto_matrix.data14 = arr[3].to_f

      proto_matrix.data21 = arr[4].to_f
      proto_matrix.data22 = arr[5].to_f
      proto_matrix.data23 = arr[6].to_f
      proto_matrix.data24 = arr[7].to_f

      proto_matrix.data31 = arr[8].to_f
      proto_matrix.data32 = arr[9].to_f
      proto_matrix.data33 = arr[10].to_f
      proto_matrix.data34 = arr[11].to_f

      proto_matrix.data41 = arr[12].to_f
      proto_matrix.data42 = arr[13].to_f
      proto_matrix.data43 = arr[14].to_f
      proto_matrix.data44 = arr[15].to_f

      proto_matrix
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
