# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThTCHRailingData.proto

require 'google/protobuf'

require 'ThTCHBuiltElementData_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThTCHRailingData.proto", :syntax => :proto3) do
    add_message "ThTCHRailingData" do
      optional :build_element, :message, 1, "ThTCHBuiltElementData"
    end
  end
end

ThTCHRailingData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThTCHRailingData").msgclass
