# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThSUComponentData.proto

require 'google/protobuf'

require 'ThTCHGeometry_pb'
require 'ThSUMaterialData_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThSUComponentData.proto", :syntax => :proto3) do
    add_message "ThSUComponentData" do
      optional :definition_index, :int32, 1
      optional :ifc_classification, :string, 2
      optional :instance_name, :string, 3
      optional :transformations, :message, 4, "ThTCHMatrix3d"
      optional :material, :message, 5, "ThSUMaterialData"
    end
  end
end

ThSUComponentData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThSUComponentData").msgclass
