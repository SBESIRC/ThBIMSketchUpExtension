# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThSUComponentData.proto

Sketchup.require 'google/protobuf'

Sketchup.require 'ThTCHGeometry_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThSUComponentData.proto", :syntax => :proto3) do
    add_message "ThSUComponentData" do
      optional :definition_index, :int32, 1
      optional :ifc_classification, :string, 2
      optional :instance_name, :string, 3
      optional :transformations, :message, 4, "ThTCHMatrix3d"
    end
  end
end

ThSUComponentData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThSUComponentData").msgclass
