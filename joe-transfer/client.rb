# -*- coding: UTF-8 -*-
#
require 'thrift'
require_relative './Service/gen-rb/transfer_serv'

require 'pathname'

begin
  HOST = '192.168.1.101'
  PORT = 8404
  DEFAULT_TIMEOUT = 3600

  transport = Thrift::FramedTransport.new(Thrift::Socket.new(HOST, PORT, DEFAULT_TIMEOUT))
  protocol = Thrift::BinaryProtocol.new(transport)
  client = TransferServ::Client.new(protocol)

  transport.open

  path = Pathname('/Users/Joe/Desktop/g.mp4')

  file_info = TRFileInfo.new({name: path.basename.to_s,
                  path: path.to_s,
                  size: File.size(path) })

  client.upload(file_info, IO.read(path))
  puts "💪 => Done"
rescue Exception => e
  puts "🔵 => " + e.to_s
end

transport.close