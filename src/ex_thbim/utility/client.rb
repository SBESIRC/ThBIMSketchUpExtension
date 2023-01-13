require_relative 'pipe.rb'
require_relative 'Win32API.rb'

# The Win32 module serves as a namespace only
module ThBM

  # The Pipe::Client class encapsulates the client side of a named pipe
  # connection.
  #
  class Pipe::Client < Pipe

    # Create and return a new Pipe::Client instance. The +name+, +pipe_mode+,
    # and +open_mode+ are passed to the Win32::Pipe superclass.
    #
    # The default +pipe_mode+ is NOWAIT.
    #
    # The default +open_mode+ is FILE_ATTRIBUTE_NORMAL | FILE_FLAG_WRITE_THROUGH.
    #
    # In block form the client object is yield, and is automatically
    # disconnected and closed at the end of the block.
    #
    # Example:
    #
    #   require 'win32/pipe'
    #
    #   Pipe::Client.new('foo') do |pipe|
    #     puts "Connected..."
    #     pipe.write("Ruby rocks!")
    #     data = pipe.read
    #     puts "Got [#{data}] back from pipe server"
    #  end
    #
    def initialize(name, pipe_mode = DEFAULT_PIPE_MODE, open_mode = DEFAULT_OPEN_MODE, pipe_buffer_size = DEFAULT_PIPE_BUFFER_SIZE)
      super(name, pipe_mode, open_mode, pipe_buffer_size)
      @pipe = Kernel32.CreateFileW(
        @name.encode("UTF-16LE"),
        GENERIC_READ | GENERIC_WRITE,
        FILE_SHARE_READ | FILE_SHARE_WRITE,
        nil,
        OPEN_EXISTING,
        @open_mode,
        0
      )

      if @pipe.to_i == INVALID_HANDLE_VALUE
        raise SystemCallError.new("CreateFile", Kernel32.GetLastError())
      end

      if (Kernel32.GetLastError() == ERROR_PIPE_BUSY)
        unless Kernel32.WaitNamedPipeW(@name.encode("UTF-16LE"), NMPWAIT_USE_DEFAULT_WAIT)
          raise SystemCallError.new("WaitNamedPipe", Kernel32.GetLastError())
        end
      end

      if block_given?
        begin
          yield self
        ensure
          disconnect
          close
        end
      end
    end

  end
end
