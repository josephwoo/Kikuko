#
# Autogenerated by Thrift Compiler (0.9.3)
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#

require 'thrift'

class TRFileInfo
  include ::Thrift::Struct, ::Thrift::Struct_Union
  NAME = 1
  PATH = 2
  SIZE = 3

  FIELDS = {
    NAME => {:type => ::Thrift::Types::STRING, :name => 'name'},
    PATH => {:type => ::Thrift::Types::STRING, :name => 'path'},
    SIZE => {:type => ::Thrift::Types::I64, :name => 'size'}
  }

  def struct_fields; FIELDS; end

  def validate
  end

  ::Thrift::Struct.generate_accessors self
end

