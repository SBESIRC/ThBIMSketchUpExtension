# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: MessageHeader.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("MessageHeader.proto", :syntax => :proto3) do
    add_message "MessageHeader" do
      optional :major, :string, 1
      optional :source, :enum, 2, "MessageSourceEnum"
      optional :description, :string, 3
    end
    add_enum "MessageSourceEnum" do
      value :CAD, 0
      value :SU, 1
      value :Platform3D, 2
    end
  end
end

MessageHeader = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("MessageHeader").msgclass
MessageSourceEnum = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("MessageSourceEnum").enummodule
