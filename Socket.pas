Unit Socket;

{
Delphi Pascal 6 driver for TCP/IP or UDP/IP client API

John Nagy  B.N.L.  +1-631-344-2667  nagy@bnl.gov

v1.0  2009-09-27  Original paralleling Serial.pas v1.1 2008-04-03
v1.1  2009-10-28  Open: enable broadcasting
v1.2  2009-11-10  Open: ...but only if UDP
v1.3  2009-11-11  ReceiveString: in buffer needed a CHR(0)
v1.4  2009-11-12  TimeoutSet: NOOP if timeout < 0, i.e. no change
                  TimeoutGet: new function
v1.5  2011-04-05  Close: set handle to INVALID_SOCKET
v2.0  2011-04-06  MsgPeek: new function
v2.1  2011-04-07  SelectReadStatus(): new function
                  (Can't get MsgPeek() to work right)
v2.2  2011-04-10  SetTCPNODELAY: new function
                  Open/TCP: exert SetTCPNODELAY TRUE to
                    disable Nagle Algorithm
                  Close: make the correct (VAR handle
v2.3  2011-04-25  SetTCPNODELAY should not be called if mode is not TCP
v2.4  2012-01-10  ReceiveStringTO: new; uses hand-made timeout, not winsock
}

{$R+} {Range checking ON}

Interface

Uses Windows, WinSock, SysUtils, Forms;

VAR

  LastErrorFunction: STRING;
  LastErrorNumber:   INTEGER;
  LastErrorMessage:  STRING;

FUNCTION Open (
  VAR handle: TSocket;
  mode:       String;   {TCP or UDP}
  ip:         String;
  rport,
  lport:      INTEGER;  {used only for UDP}
  VAR Raddr:  TSockAddr;
  timeout:    INTEGER
  ):          BOOLEAN;
FUNCTION SetTCPNODELAY (handle: TSocket; state: BOOLEAN): BOOLEAN;
FUNCTION TimeoutSet (handle: TSocket; ms: INTEGER): BOOLEAN;
FUNCTION TimeoutGet (handle: TSocket; VAR ms: INTEGER): BOOLEAN;
FUNCTION Close (VAR handle: TSocket): BOOLEAN;
FUNCTION SendString (handle: TSocket; VAR Raddr: TSockAddr; msg: STRING): BOOLEAN;
FUNCTION ReceiveString (handle: TSocket; VAR Raddr: TSockAddr; VAR s: STRING): BOOLEAN;
FUNCTION ReceiveStringTO (handle: TSocket; VAR Raddr: TSockAddr;
                          VAR s: STRING; timeout: INTEGER): BOOLEAN;
FUNCTION MsgPeek (handle: TSocket): INTEGER;
FUNCTION SelectReadStatus (handle: TSocket): INTEGER;
PROCEDURE LastErrorWindow (msg: STRING);

Implementation

CONST

  buffer_size = 1440;

VAR

  WSAData: TWSAData;
  Laddr:   TSockAddr;  {local socket address structure for bind()}

  buffer: ARRAY [0..buffer_size] OF CHAR;

{----------------------------------------------------------}

PROCEDURE LastErrorProcess (func: STRING; fSuccess: BOOLEAN);

{If there was an error,
 set LastErrorFunction, ~Number, ~Message.
 }

BEGIN
  IF (NOT fSuccess) THEN BEGIN
    LastErrorFunction := func;
    LastErrorNumber   := WSAGetLastError;
    LastErrorMessage  := SysUtils.SysErrorMessage(LastErrorNumber);
    END;
  END;  {of procedure LastErrorProcess}

{----------------------------------------------------------}

PROCEDURE LastErrorWindow (msg: STRING);

{Socket error notification window}

CONST nl2 = CHR(13) + CHR(10) + CHR(10);
VAR title, body: STRING;
BEGIN
  body := msg + nl2;
  body := body + 'Func:   ' + LastErrorFunction + nl2;
  body := body + 'ErrNo:  ' + SysUtils.IntToStr(LastErrorNumber) + nl2;
  body := body + 'ErrMsg: ' + LastErrorMessage;
  title := 'Socket.pas error in function ' + LastErrorFunction;
  Windows.MessageBeep(MB_ICONEXCLAMATION);
  Application.MessageBox (PCHAR(body), PCHAR(title),
    MB_OK OR MB_ICONEXCLAMATION);
  END;  {of procedure LastErrorWindow'}

{----------------------------------------------------------}

PROCEDURE ShowSockAddr (where: String; sockaddr: TSockAddr);

{Show contents of a sockaddr_in record -- debugging only!}

CONST nl2 = CHR(13) + CHR(10) + CHR(10);
VAR title, body: STRING;
BEGIN
WITH sockaddr DO BEGIN
  body := body + 'sin_family:       ' + SysUtils.IntToStr(sin_family) + nl2;
  body := body + 'sin_port:         ' + SysUtils.IntToStr(sin_port  ) + nl2;
  body := body + 'sin_addr.s_addr:  ' + SysUtils.IntToStr(sin_addr.s_addr) + nl2;
  title := where;
  Application.MessageBox (PCHAR(body), PCHAR(title), MB_OK);
  END;  {with}
  END;  {of procedure ShowSockAddr'}

{----------------------------------------------------------}

{Open client socket.}

FUNCTION Open (
  VAR handle: TSocket;
  mode:       String;   {TCP or UDP}
  ip:         String;
  rport,
  lport:      INTEGER;  {used only for UDP}
  VAR Raddr:  TSockAddr;
  timeout:    INTEGER
  ):          BOOLEAN;

VAR errno:     INTEGER;
    fSuccess:  BOOLEAN;
    broadcast: INTEGER;

BEGIN

  fSuccess := FALSE;

  WITH Raddr DO BEGIN
    sin_family      := AF_INET;
    sin_addr.s_addr := inet_addr (PCHAR(ip));
    sin_port        := htons (rport);
    END;

  IF (UpperCase(mode) = 'TCP') THEN BEGIN
    handle := WinSock.socket (AF_INET, SOCK_STREAM, IPPROTO_TCP);
    fSuccess := (handle <> INVALID_SOCKET);
    LastErrorProcess ('Open/TCP/socket', fSuccess);
    IF fSuccess THEN BEGIN
      errno := WinSock.connect (handle, Raddr, SizeOf(Raddr));
      fSuccess := (errno = 0);
      LastErrorProcess ('Open/TCP/connect', fSuccess);
      END;
    END;

  IF (UpperCase(mode) = 'UDP') THEN BEGIN
    handle := WinSock.socket (AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    fSuccess := (handle <> INVALID_SOCKET);
    LastErrorProcess ('Open/UDP/socket', fSuccess);
    WITH Laddr DO BEGIN
      sin_family      := AF_INET;
      sin_port        := htons (lport);
      END;
    IF fSuccess THEN BEGIN
      errno := WinSock.bind (handle, Laddr, SizeOf(Laddr));
      fSuccess := (errno = 0);
      LastErrorProcess ('Open/UDP/bind', fSuccess);
      END;
    IF fSuccess THEN BEGIN
      broadcast := 1; {TRUE}
      errno := WinSock.setsockopt (handle,
        SOL_SOCKET, SO_BROADCAST, @broadcast, SizeOf(broadcast));
      fSuccess := (errno = 0);
      LastErrorProcess ('Open/setsockopt(SO_BROADCAST)', fSuccess);
      END;

    END;


  IF fSuccess THEN BEGIN
    fSuccess := TimeoutSet (handle, timeout);
    LastErrorProcess ('Open/TimeOutSet', fSuccess);
    END;

  IF fSuccess AND (UpperCase(mode) = 'TCP') THEN BEGIN
    fSuccess := SetTCPNODELAY (handle, TRUE);
    LastErrorProcess ('Open/SetTCPNODELAY', fSuccess);
    END;

  Open := fSuccess;
  END; {function Open}

{----------------------------------------------------------}

{Set TCT_NODELAY option on or off.
 Thus turning Nagle Algorithm off or on.
}

FUNCTION SetTCPNODELAY (handle: TSocket; state: BOOLEAN): BOOLEAN;

VAR errno:    INTEGER;
    fSuccess: BOOLEAN;
    bool:     DWORD;

BEGIN
  bool := ORD(state);
  errno := WinSock.setsockopt (handle,
    IPPROTO_TCP, TCP_NODELAY, @bool, SizeOf(bool));
  fSuccess := (errno = 0);
  LastErrorProcess ('SetTCPNODELAY/setsockopt', fSuccess);
  SetTCPNODELAY := fSuccess;
  END; {function SetTCPNODELAY}

{----------------------------------------------------------}

{Set read timeout for an open socket.

 This is the winsock read timeout, not J.N.'s
}

FUNCTION TimeoutSet (handle: TSocket; ms: INTEGER): BOOLEAN;

VAR errno:    INTEGER;
    fSuccess: BOOLEAN;

BEGIN
  fSuccess := TRUE;
  IF (ms >= 0) THEN BEGIN
    errno := WinSock.setsockopt (handle,
      SOL_SOCKET, SO_RCVTIMEO, @ms, SizeOf(ms));
    fSuccess := (errno = 0);
    LastErrorProcess ('TimeoutSet/setsockopt', fSuccess);
    END;
  TimeoutSet := fSuccess;
  END; {function TimeoutSet}

{----------------------------------------------------------}

{Get current read timeout for an open socket.}

FUNCTION TimeoutGet (handle: TSocket; VAR ms: INTEGER): BOOLEAN;

VAR errno:    INTEGER;
    fSuccess: BOOLEAN;
    optlen:   INTEGER;

BEGIN
  optlen := SizeOf(ms);
  errno := WinSock.getsockopt (handle,
    SOL_SOCKET, SO_RCVTIMEO, @ms, optlen);
  fSuccess := (errno = 0);
  LastErrorProcess ('TimeoutGet/getsockopt', fSuccess);
  TimeoutGet := fSuccess;
  END; {function TimeoutGet}

{----------------------------------------------------------}

FUNCTION Close (VAR handle: TSocket): BOOLEAN;

VAR errno:    INTEGER;
    fSuccess: BOOLEAN;

BEGIN
  errno := WinSock.closesocket (handle);
  handle := INVALID_SOCKET;
  fSuccess := (errno = 0);
  LastErrorProcess ('Close/closesocket', fSuccess);
  Close := fSuccess;
  END;  {procedure Close}

{----------------------------------------------------------}

FUNCTION SendString (handle: TSocket; VAR Raddr: TSockAddr; msg: STRING): BOOLEAN;

VAR errno:    INTEGER;
    fSuccess: BOOLEAN;

BEGIN

  SysUtils.StrPCopy (buffer, msg);
  errno := WinSock.sendto (handle, buffer, StrLen (buffer), 0, Raddr, SizeOf(Raddr));
  fSuccess := (errno > 0);
  LastErrorProcess ('SendString/sendto', fSuccess);
  SendString := fSuccess;
  END;  {procedure SendString}

{----------------------------------------------------------}

FUNCTION MsgPeek (handle: TSocket): INTEGER;

{Provide input data present capability of MSG_PEEK flag

 Returns: bytes of data in input buffer
          0 if no data available or connection was gracefully closed
          SOCKET_ERROR

 Thus this function is different from the others
}

VAR return: INTEGER;
    buffer: ARRAY [0..buffer_size] OF CHAR;

BEGIN
  buffer[0] := CHR(0);
  return := WinSock.recv (handle, buffer, buffer_size, MSG_PEEK);
  LastErrorProcess ('MsgPeek/recv', (return <> SOCKET_ERROR));
  MsgPeek := return;
  END;  {function MsgPeek}

{----------------------------------------------------------}

FUNCTION SelectReadStatus (handle: TSocket): INTEGER;

{Use select() to get read status of a single socket

 Returns: 1 if that socket has data ready to read
          0 if no data available
          SOCKET_ERROR (-1)

 Thus this function return is different from most of the others
}

VAR return:  INTEGER;
    readfds: TFDSet;
    timeout: TTimeVal;

BEGIN
  WITH readfds DO BEGIN
    fd_count    := 1;
    fd_array[0] := handle;
    END;
  WITH timeout DO BEGIN
    tv_sec  := 0;  {Not blocked and return immediately}
    tv_usec := 0;
    END;
  return := WinSock.select (0, @readfds, NIL, NIL, @timeout);
  LastErrorProcess ('SelectReadStatus/select', (return <> SOCKET_ERROR));
  SelectReadStatus := return;
  END;  {function SelectReadStatus}

{----------------------------------------------------------}

FUNCTION ReceiveString (handle: TSocket; VAR Raddr: TSockAddr; VAR s: STRING): BOOLEAN;

VAR errno:    INTEGER;
    fSuccess: BOOLEAN;
    Rlen:     INTEGER;

BEGIN

  Rlen := SizeOf(Raddr);
  buffer[0] := CHR(0);
  errno := WinSock.recvfrom (handle, buffer, buffer_size, 0, Raddr, Rlen);
  fSuccess := (errno > 0);
  IF fSuccess THEN buffer[errno] := CHR(0);
  LastErrorProcess ('ReceiveString/recvfrom', fSuccess);
  IF (errno = 0) THEN
    LastErrorMessage := '*** Remote gracefully closed connection';
  s := SysUtils.StrPas (@buffer[0]);
  ReceiveString := fSuccess;
  END;  {function ReceiveString}

{----------------------------------------------------------}

FUNCTION ReceiveStringTO (handle: TSocket; VAR Raddr: TSockAddr;
                          VAR s: STRING; timeout: INTEGER): BOOLEAN;

{Call this function instead of ReceiveString to use
 J.N. home-made timeout code instead of WinSock read timeout}

CONST wink = 10;  {sleep time during wait looping}

VAR fSuccess: BOOLEAN;
    bytesready,
    errnumber: INTEGER;
    dataready: BOOLEAN;

BEGIN

  s := '';
  errnumber := 0;

  REPEAT
    bytesready := SelectReadStatus (handle);
    dataready := (bytesready > 0);
    IF (bytesready = SOCKET_ERROR) THEN errnumber := 1;
    timeout := timeout - wink;
    IF (timeout <= 0) THEN errnumber := 2;
    IF (bytesready = 0) THEN Windows.Sleep (wink);
    UNTIL dataready OR (errnumber <> 0);
  fSuccess := (errnumber = 0);

  CASE errnumber OF
    0: BEGIN  {data ready}
       fSuccess := ReceiveString (handle, Raddr, s);
       END;
    1: BEGIN  {socket error}
       LastErrorProcess ('ReceiveStringTO', fSuccess);
       END;
    2: BEGIN  {timed out}
       LastErrorFunction := 'ReceiveStringTO';
       LastErrorNumber   := 0;
       LastErrorMessage  := 'SelectReadStatus timeout';
       END;
    END; {case}
  ReceiveStringTO := fSuccess;
  END;  {function ReceiveStringTO}

{----------------------------------------------------------}

PROCEDURE Startup;
VAR errno:    INTEGER;
    fSuccess: BOOLEAN;
BEGIN
  {Initialize for WinSock 1.1}
  errno := WSAStartup (1*16+1, WSAData);
  fSuccess := (errno = 0);
  LastErrorProcess ('Startup/WSAStartup', fSuccess);
  END;  {procedure Startup}

{----------------------------------------------------------}

PROCEDURE Cleanup;
BEGIN
  WSACleanup;
  END;  {procedure Cleanup}

{----------------------------------------------------------}

INITIALIZATION

Startup;

FINALIZATION

Cleanup;

{of unit Socket.pas...}
END.
