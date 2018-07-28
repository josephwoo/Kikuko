require 'thrift'

require_relative './Service/gen-rb/transfer_serv'
require_relative './Service/serv_handler'

require "socket"

SERVICE_PORT = 8404

local_ip = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
transport = Thrift::ServerSocket.new(local_ip, SERVICE_PORT)
factory = Thrift::FramedTransportFactory.new
processor = TransferServ::Processor.new(ServHandler.new)

server = Thrift::ThreadPoolServer.new(processor, transport, factory)
puts "📡 => #{local_ip}:#{SERVICE_PORT}"
server.serve