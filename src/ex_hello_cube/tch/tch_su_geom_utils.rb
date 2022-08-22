require 'sketchup.rb'

module Examples
  module HelloCube

    class ThTCH2SUGeomUtil
        def self.to_su_point3d(pt)
          Geom::Point3d.new(pt.x, pt.y, pt.z)
        end

        def self.to_su_vector3d(v)
          Geom::Point3d.new(v.x, v.y, v.z)
        end

        def self.to_su_transformation(m)
          arr = [
            m.data11, m.data12, m.data13, m.data14,
            m.data21, m.data22, m.data23, m.data24,
            m.data31, m.data32, m.data33, m.data34,
            m.data41, m.data42, m.data43, m.data44,
          ]
          Geom::Transformation.new(arr)
        end
    end

  end # module HelloCube
end # module Examples

