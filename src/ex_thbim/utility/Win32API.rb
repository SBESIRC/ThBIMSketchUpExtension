require 'fiddle'
require 'fiddle/import'
require 'fiddle/types'

module Examples

  module Win32API

    NULL = 0

    NO_ERROR = 0

    # Defined in handleapi.h
    # define INVALID_HANDLE_VALUE ((HANDLE)(LONG_PTR)-1)
    INVALID_HANDLE_VALUE = 18446744073709551615

    # https://docs.microsoft.com/en-gb/windows/win32/debug/system-error-codes
    ERROR_SUCCESS = 0x00
    ERROR_NOT_LOCKED = 0x9E
    ERROR_CLIPBOARD_NOT_OPEN = 0x58A

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

    # https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-waitnamedpipea
    NMPWAIT_WAIT_FOREVER = 0xFFFFFFFF
    NMPWAIT_USE_DEFAULT_WAIT = 0x00000000

    ERROR_PIPE_BUSY = 231
    ERROR_IO_PENDING = 997
    ERROR_PIPE_CONNECTED = 535
    ERROR_PIPE_LISTENING = 536
    ERROR_SUCCESS = 0
    ERROR_MORE_DATA = 234

    WAIT_TIMEOUT = 0x102
    WAIT_OBJECT_0 = 0

    GENERIC_READ  = 0x80000000
    GENERIC_WRITE = 0x40000000
    FILE_SHARE_READ  = 1
    FILE_SHARE_WRITE = 2
    OPEN_EXISTING    = 3

    module Kernel32

      GMEM_FIXED = 0x0000
      GMEM_MOVEABLE = 0x0002

      extend Fiddle::Importer

      dlload 'Kernel32'
      include Fiddle::Win32Types

      typealias 'LPVOID', 'void*'
      typealias 'HGLOBAL', 'void*'
      typealias 'SIZE_T', 'size_t'
      typealias 'LPDWORD', 'DWORD*'
      typealias 'LPCVOID', 'const void*'
      typealias 'LPCWSTR', 'const wchar_t*'

      SECURITY_ATTRIBUTES = struct [
        'DWORD nLength',
        'LPVOID lpSecurityDescriptor',
        'BOOL  bInheritHandle',
      ]
      typealias 'LPSECURITY_ATTRIBUTES', 'SECURITY_ATTRIBUTES*'

      OVERLAPPED = struct [
        'DWORD64 internal',
        'DWORD64 internal_high',
        'DWORD offset',
        'DWORD offset_high',
        'DWORD64 hEvent'
      ]
      typealias 'LPOVERLAPPED', 'OVERLAPPED*'

      # https://docs.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-getlasterror
      #
      # DWORD GetLastError()
      extern 'DWORD GetLastError()'

      # https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-globallock
      #
      # A handle to the global memory object. This handle is returned by either
      # the GlobalAlloc or GlobalReAlloc function.
      #
      # Return: If the function succeeds, the return value is a pointer to the
      #         first byte of the memory block.
      #         If the function fails, the return value is NULL. To get extended
      #         error information, call GetLastError.
      #
      # LPVOID GlobalLock(
      #   HGLOBAL hMem
      # );
      extern 'LPVOID GlobalLock(HGLOBAL)'

      # https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-globallock
      #
      # A handle to the global memory object. This handle is returned by either
      # the GlobalAlloc or GlobalReAlloc function.
      #
      # Return: If the memory object is still locked after decrementing the lock
      #         count, the return value is a nonzero value. If the memory object
      #         is unlocked after decrementing the lock count, the function
      #         returns zero and GetLastError returns NO_ERROR.
      #
      #         If the function fails, the return value is zero and GetLastError
      #         returns a value other than NO_ERROR.
      #
      # BOOL GlobalUnlock(
      #   HGLOBAL hMem
      # );
      extern 'BOOL GlobalUnlock(HGLOBAL)'

      # https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-globalalloc
      # DECLSPEC_ALLOCATOR HGLOBAL GlobalAlloc(
      #   UINT   uFlags,
      #   SIZE_T dwBytes
      # );
      extern 'HGLOBAL GlobalAlloc(UINT, SIZE_T)'

      # https://learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle
      #
      # BOOL CloseHandle(
      #  [in] HANDLE hObject
      #);
      extern 'BOOL CloseHandle(HANDLE)'

      # https://learn.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-connectnamedpipe
      # BOOL ConnectNamedPipe(
      #  [in]                HANDLE       hNamedPipe,
      #  [in, out, optional] LPOVERLAPPED lpOverlapped
      #);
      extern 'BOOL ConnectNamedPipe(HANDLE, LPOVERLAPPED)'

      # https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createeventa
      #
      # HANDLE CreateEventA(
      #  [in, optional] LPSECURITY_ATTRIBUTES lpEventAttributes,
      #  [in]           BOOL                  bManualReset,
      #  [in]           BOOL                  bInitialState,
      #  [in, optional] LPCSTR                lpName
      #);
      extern 'HANDLE CreateEventA(LPSECURITY_ATTRIBUTES, BOOL, BOOL, LPCSTR)'

      # https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilea
      #
      # HANDLE CreateFileA(
      #  [in]           LPCSTR                lpFileName,
      #  [in]           DWORD                 dwDesiredAccess,
      #  [in]           DWORD                 dwShareMode,
      #  [in, optional] LPSECURITY_ATTRIBUTES lpSecurityAttributes,
      #  [in]           DWORD                 dwCreationDisposition,
      #  [in]           DWORD                 dwFlagsAndAttributes,
      #  [in, optional] HANDLE                hTemplateFile
      #);
      extern 'HANDLE CreateFileA(LPCSTR, DWORD, DWORD, LPSECURITY_ATTRIBUTES, DWORD, DWORD, HANDLE)'

      # https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilew
      #
      # HANDLE CreateFileW(
      #  [in]           LPCWSTR               lpFileName,
      #  [in]           DWORD                 dwDesiredAccess,
      #  [in]           DWORD                 dwShareMode,
      #  [in, optional] LPSECURITY_ATTRIBUTES lpSecurityAttributes,
      #  [in]           DWORD                 dwCreationDisposition,
      #  [in]           DWORD                 dwFlagsAndAttributes,
      #  [in, optional] HANDLE                hTemplateFile
      #);
      extern 'HANDLE CreateFileW(LPCWSTR, DWORD, DWORD, LPSECURITY_ATTRIBUTES, DWORD, DWORD, HANDLE)'

      # https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createnamedpipea
      #
      # HANDLE CreateNamedPipeA(
      #  [in]           LPCSTR                lpName,
      #  [in]           DWORD                 dwOpenMode,
      #  [in]           DWORD                 dwPipeMode,
      #  [in]           DWORD                 nMaxInstances,
      #  [in]           DWORD                 nOutBufferSize,
      #  [in]           DWORD                 nInBufferSize,
      #  [in]           DWORD                 nDefaultTimeOut,
      #  [in, optional] LPSECURITY_ATTRIBUTES lpSecurityAttributes
      #);
      extern 'HANDLE CreateNamedPipeA(LPCSTR, DWORD, DWORD, DWORD, DWORD, DWORD, DWORD, LPSECURITY_ATTRIBUTES)'

      # https://learn.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-createpipe
      #
      # BOOL CreatePipe(
      #  [out]          PHANDLE               hReadPipe,
      #  [out]          PHANDLE               hWritePipe,
      #  [in, optional] LPSECURITY_ATTRIBUTES lpPipeAttributes,
      #  [in]           DWORD                 nSize
      #);
      extern 'BOOL CreatePipe(PHANDLE, PHANDLE, LPSECURITY_ATTRIBUTES, DWORD)'

      # https://learn.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-disconnectnamedpipe
      #
      # BOOL DisconnectNamedPipe(
      #  [in] HANDLE hNamedPipe
      #);
      extern 'BOOL DisconnectNamedPipe(HANDLE)'

      # https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-flushfilebuffers
      #
      # BOOL FlushFileBuffers(
      #  [in] HANDLE hFile
      #);
      extern 'BOOL FlushFileBuffers(HANDLE)'

      # https://learn.microsoft.com/en-us/windows/win32/api/ioapiset/nf-ioapiset-getoverlappedresult
      #
      # BOOL GetOverlappedResult(
      #  [in]  HANDLE       hFile,
      #  [in]  LPOVERLAPPED lpOverlapped,
      #  [out] LPDWORD      lpNumberOfBytesTransferred,
      #  [in]  BOOL         bWait
      #);
      extern 'BOOL GetOverlappedResult(HANDLE, LPOVERLAPPED, LPDWORD, BOOL)'

      # https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-readfile
      #
      # BOOL ReadFile(
      #  [in]                HANDLE       hFile,
      #  [out]               LPVOID       lpBuffer,
      #  [in]                DWORD        nNumberOfBytesToRead,
      #  [out, optional]     LPDWORD      lpNumberOfBytesRead,
      #  [in, out, optional] LPOVERLAPPED lpOverlapped
      #);
      extern 'BOOL ReadFile(HANDLE, LPVOID, DWORD, LPDWORD, LPOVERLAPPED)'


      # https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobject
      #
      # DWORD WaitForSingleObject(
      #  [in] HANDLE hHandle,
      #  [in] DWORD  dwMilliseconds
      #);
      extern 'DWORD WaitForSingleObject(HANDLE, DWORD)'

      # https://learn.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-waitnamedpipew
      #
      # BOOL WaitNamedPipeW(
      #  [in] LPCWSTR lpNamedPipeName,
      #  [in] DWORD   nTimeOut
      #);
      extern 'BOOL WaitNamedPipeW(LPCWSTR, DWORD)'

      # https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-writefile
      #
      # BOOL WriteFile(
      #  [in]                HANDLE       hFile,
      #  [in]                LPCVOID      lpBuffer,
      #  [in]                DWORD        nNumberOfBytesToWrite,
      #  [out, optional]     LPDWORD      lpNumberOfBytesWritten,
      #  [in, out, optional] LPOVERLAPPED lpOverlapped
      #);
      extern 'BOOL WriteFile(HANDLE, LPCVOID, DWORD, LPDWORD, LPOVERLAPPED)'

    end

    module User32

      # Copied from the WinUser.h header
      CF_TEXT = 1

      extend Fiddle::Importer

      dlload 'User32'
      include Fiddle::Win32Types

      # https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-openclipboard
      #
      # A handle to the window to be associated with the open clipboard. If this
      # parameter is NULL, the open clipboard is associated with the current task.
      #
      # Return: 0 = error; non-0 = success
      #
      # BOOL OpenClipboard(
      #   HWND hWndNewOwner
      # );
      extern 'BOOL OpenClipboard(HWND)'

      # https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-closeclipboard
      # Return: 0 = error; non-0 = success
      #
      # BOOL CloseClipboard();
      extern 'BOOL CloseClipboard()'

      # https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-emptyclipboard
      # Return: 0 = error; non-0 = success
      #
      # BOOL EmptyClipboard();
      extern 'BOOL EmptyClipboard()'

      # https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclipboarddata
      # Return: NULL upon failure
      #
      # uFormat
      #   https://docs.microsoft.com/en-us/windows/win32/dataxchg/clipboard-formats
      #
      # HANDLE GetClipboardData(
      #   UINT uFormat
      # );
      extern 'HANDLE GetClipboardData(UINT)'

      # https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setclipboarddata
      # Return: If the function succeeds, the return value is the handle to the
      #         data.
      #
      #         If the function fails, the return value is NULL. To get extended
      #         error information, call GetLastError.
      #
      # HANDLE SetClipboardData(
      #   UINT   uFormat,
      #   HANDLE hMem
      # );
      extern 'HANDLE SetClipboardData(UINT, HANDLE)'


    end

  end

end
