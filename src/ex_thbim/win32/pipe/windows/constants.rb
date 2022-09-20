require 'ffi'

module Windows
  module Constants
    include FFI::Library

    PIPE_WAIT             = 0x00000000
    PIPE_NOWAIT           = 0x00000001
    PIPE_ACCESS_INBOUND   = 0x00000001
    PIPE_ACCESS_OUTBOUND  = 0x00000002
    PIPE_ACCESS_DUPLEX    = 0x00000003
    PIPE_TYPE_BYTE        = 0x00000000
    PIPE_TYPE_MESSAGE     = 0x00000004
    PIPE_READMODE_BYTE    = 0x00000000
    PIPE_READMODE_MESSAGE = 0x00000002
    PIPE_CLIENT_END       = 0x00000000
    PIPE_SERVER_END       = 0x00000001

    PIPE_UNLIMITED_INSTANCES = 255

    FILE_FLAG_OVERLAPPED = 0x40000000
    FILE_FLAG_FIRST_PIPE_INSTANCE = 0x00080000
    FILE_FLAG_WRITE_THROUGH       = 0x80000000
    FILE_ATTRIBUTE_NORMAL        = 0x00000080

    INFINITE = 0xFFFFFFFF
    NMPWAIT_WAIT_FOREVER = 0xFFFFFFFF

    ERROR_PIPE_BUSY = 231
    ERROR_IO_PENDING = 997
    ERROR_PIPE_CONNECTED = 535
    ERROR_PIPE_LISTENING = 536
    ERROR_SUCCESS = 0

    WAIT_TIMEOUT = 0x102
    WAIT_OBJECT_0 = 0

    GENERIC_READ  = 0x80000000
    GENERIC_WRITE = 0x40000000
    FILE_SHARE_READ  = 1
    FILE_SHARE_WRITE = 2
    OPEN_EXISTING    = 3

    INVALID_HANDLE_VALUE = FFI::Pointer.new(-1).address
  end
end