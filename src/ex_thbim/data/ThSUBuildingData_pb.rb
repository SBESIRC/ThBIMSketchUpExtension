# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThSUBuildingData.proto

require 'google/protobuf'

require 'ThTCHRootData_pb'
require 'ThSUBuildingStoreyData_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThSUBuildingData.proto", :syntax => :proto3) do
    add_message "ThSUBuildingData" do
      optional :root, :message, 1, "ThTCHRootData"
      repeated :storeys, :message, 2, "ThSUBuildingStoreyData"
    end
  end
end

ThSUBuildingData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThSUBuildingData").msgclass
