# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThSUFaceData.proto

require 'google/protobuf'

require 'ThSUGeometry_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThSUFaceData.proto", :syntax => :proto3) do
    add_message "ThSUFaceData" do
      optional :mesh, :message, 1, "ThSUPolygonMesh"
    end
  end
end

ThSUFaceData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThSUFaceData").msgclass
