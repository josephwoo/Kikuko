module OS
  OS_UNKNOWN = 0
  OS_WIN = 1
  OS_MAC_OX = 2

  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end

  def OS.encode_utf8(os_type, value)
    case os_type
    when OS_MAC_OX
      value.force_encoding('UTF-8')
    when OS_WIN
      value.encode('UTF-8')
    end
  end
end