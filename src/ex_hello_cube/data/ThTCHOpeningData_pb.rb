# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThTCHOpeningData.proto

require 'google/protobuf'

require 'ThTCHBuiltElementData_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThTCHOpeningData.proto", :syntax => :proto3) do
    add_message "ThTCHOpeningData" do
      optional :build_element, :message, 1, "ThTCHBuiltElementData"
    end
  end
end

ThTCHOpeningData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThTCHOpeningData").msgclass
