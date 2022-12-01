# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThTCHBuiltElementData.proto

Sketchup.require 'google/protobuf'

Sketchup.require 'ThTCHRootData_pb'
Sketchup.require 'ThTCHGeometry_pb'
Sketchup.require 'ThTCHProperty_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThTCHBuiltElementData.proto", :syntax => :proto3) do
    add_message "ThTCHBuiltElementData" do
      optional :root, :message, 1, "ThTCHRootData"
      optional :length, :double, 2
      optional :width, :double, 3
      optional :height, :double, 4
      optional :origin, :message, 5, "ThTCHPoint3d"
      optional :x_vector, :message, 6, "ThTCHVector3d"
      optional :outline, :message, 7, "ThTCHMPolygon"
      proto3_optional :enum_material, :string, 8
      repeated :Properties, :message, 9, "ThTCHProperty"
    end
  end
end

ThTCHBuiltElementData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThTCHBuiltElementData").msgclass
