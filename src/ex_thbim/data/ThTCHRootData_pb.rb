# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThTCHRootData.proto

Sketchup.require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThTCHRootData.proto", :syntax => :proto3) do
    add_message "ThTCHRootData" do
      optional :globalId, :string, 1
      proto3_optional :name, :string, 2
      proto3_optional :description, :string, 3
    end
  end
end

ThTCHRootData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThTCHRootData").msgclass
