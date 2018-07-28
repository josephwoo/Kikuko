# -*- coding: UTF-8 -*-

require_relative './gen-rb/transfer_serv'
require_relative './os_util'

require 'pathname'

class ServHandler

  def initialize()
    @os_type = OS::OS_UNKNOWN
    @home_dir = Pathname(Dir.home)

    if OS.windows?
      @os_type = OS::OS_WIN
      @home_dir/='Desktop\File Temp'
    elsif OS.mac?
      @os_type = OS::OS_MAC_OX
      @home_dir/='Downloads'
    end
  end

  def download(file_info, length=0, offset=0)
    if length == 0
      IO.binread(file_info.path)
    else
      IO.binread(file_info.path, length, offset)
    end
  end

  def upload(file_info, payload)
    save_path = @home_dir/file_info.name
    begin
      IO.binwrite(save_path, payload, file_info.size)
    rescue Exception => e
      puts e.to_s
    end
  end

  def already_exist(file_info)
    File.exist? @home_dir/file_info.name
  end

  def print_message(msg)
    puts "=> " + msg
  end


  def find_file_path()
    files = @home_dir.children.find_all {|c| !c.directory? && c.basename.to_s[0] != '.'}

    begin
      Array.new(files.count) do |i|
        f = files[i]
        TRFileInfo.new({name: OS.encode_utf8(@os_type, f.basename.to_s),
                        path: OS.encode_utf8(@os_type, f.to_s),
                        size: f.size })
      end
    rescue Exception => e
      puts e.to_s
    end
  end

end