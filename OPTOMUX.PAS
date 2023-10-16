Unit optomux;
{$R+}  {Range checking ON}
{$H-}  {Use old Turbo "String"}

{  Unit to interface FACE real-time control programs 
   with Opto22 Optomux brains.

   v1.0  J.N.  92/11/04  Original -- TurboPascal 5; serial
   v1.1  J.N.  93/02/12  Add procedures comm_start() and comm_stop()
                         Add global constants speed_value[] and parity_value[]
   v1.3  J.N.  93/04/09  Fix mistake in "j" procedure
                         Add error statistics array and fill it
   v1.4  J.N.  93/04/12  COMPort, IRQNmbr are now variables in comm_tp4 unit
                           that can be changed here
   v1.5  J.N.  93/04/??  optomux_var.data_in[ch] array not being filled
                           correctly.  Fix it in recv().
   v1.6  J.N.  93/04/28  Must further modify recv() to handle case where
                           'positions' not used for input, i.e. one word.
   v1.7  J.N.  93/06/02  Changed optomux_errstats.lasterr_res
                           from String[20] to [80].
   v1.8  J.N.  93/08/05  Added variable optomux_errout: BOOLEAN.
                         This can be used to send error messages to a file.
                         Currently set up for printer (Uses Printer added).
                         optomux_errout must be enabled by main program.
   v1.9  J.N.  93/09/07  optomux_talk():  after certain errors, retry
                         command before giving up.
   v2.0  J.N.  93/09/24  optomux_talk():  implement "modifier" as a string
                         add three duTec local serial port procedures
   v2.1  J.N.  93/12/12  clear optomux_var in initialization section
   v2.2  J.N.  94/01/20  recv():  add code at beginning to detect and
                         skip over echoes by the communications equipment
   v2.3  J.N.  94/03/20  (1) makepr():  function used in setting last_res
                             so that unprintable characters are explicit
                         (2) optomux_errstats.n now a Longint
                         (3) optomux_errstats.retries added
                         (4) global procedure clear_errstats added
                         (5) fix timing problem with echoplex auto-detection
                         (6) 4-pass command echo need not produce error = 13!
   v2.4  J.N.  94/04/04  (1) Add global vars two_wire_enable and _delay
                         (2) Initialize above to FALSE and 0 ms
                         (3) Bracket procedure recv() code after the test
                             for an echo with Delay() Set_RTS(FALSE) ...
                             Set_RTS(TRUE) Delay() if two_wire_enable to
                             turn RS-485 transmitter OFF (at least Patton)
                         (4) Had to add Uses Crt because of Delay()
                         (5) Add global const ms_0, etc. for 'C' command
                         (6) dutec_in: delete checksum and <cr> from answer
   v2.5  J.N.  94/06/23  (1) Add digital latch, counting, time delay/pulse,
                             and pulse duration measurement commands.
                         (2) comm_stop(): make DTR_RTS = FALSE, not TRUE!
   v2.6  J.N.  94/09/28  (1) Cosmetic changes.
   v2.7  J.N.  95/06/29  (1) Add variables and code to record date/time
                             of last clearing of error statistics
   v2.8  J.N.  95/09/19  (1) dutec_in(): include optomux error number in
                                         error message returned as string.
   v2.9  J.N.  96/12/28  (1) add type 'optomux_err_byaddr_type'
                         (2) add var 'optomux_err_byaddr', pointer to above
                         (3) allocate storage for above in initialization
                         (4) add procedure 'optomux_err_byaddr_clear'
                         (5) optomux_talk: (a) move testing for the expected
                             error when command = P to BEFORE doing error
                             statistics; (b) on error, increment
                             optomux_err_byaddr^[address] regardless of
                             retry number
   v3.0  J.N.  97/06/13  (1) recv() use fields=99 as a duTec P-command flag
                             so that phoney error is not generated and
                             a checksum will be done.
   v3.1  J.N.  97/07/10  (1) put optomux_errstats in heap.  Allocate.  Clear.
   v3.2  J.N.  97/12/16  (1) analog k: change data,1,1 to data,1,4.
   v3.3  J.N.  99/03/01  Replace Crt by NewDelay in Uses statement.
   v3.4  J.N.  99/05/10  Define and use it in optomux_errlog optomux_talk.
   v3.5  J.N.  99/07/16  recv: debugging -- put port# before IN:.
   v3.6  J.N.  99/09/10  optomux_talk: needed additional optomux_errlog code.
               99/09/13  optomux_talk: don't do optomux_errlog Assign+ here.
               99/09/13  optomux_errstats[0.. changed to [-1.. & consequences
               99/09/29  adc_read_type: field select:Word added (positions).
               99/09/29  adc_select_clear: new procedure.
   v4.0  J.N.  00/01/12  changes for compilation under Turbo or Delphi.
                         hex2word: had to replace 'result' by 'value'.
                         send, recv: additional error info IFDEF DELPHI
               00/01/14  send, recv: remove above.
               00/01/19  comm_start: put a RemoveInt in front of InstallInt
               00/01/20  optomux_ports [1..MaxPorts] (was 1..8)
   v4.1  J.N.  02/01/12  optomux_talk: errlog -- add day and hour stamp
   v5.1  J.N.  02/03/25  Add $R+ to turn on range checking
                         Uses: remove Turbo capability    
   v5.2  J.N.  02/09/09  Add module var dutec_local_speed[00.$FF]
                         On dutec_in error, refresh dutec local speed
                         However, return original error & errno values
   v5.3  J.N.  02/12/06  optomux_errclear.date String[8] --> [10]
                         Get, Set of DebugEnable, ~Pause, ~Console
                         Get, Set ErrEnable; Set ErrName
                         send, recv: implement debug2console & debug2memo
   v5.4  J.N.  02/12/07  replace optomux_errclear.date/time by _err_whenclear
                         combine clearing of err stats by type and address
                         add last_dt to err stats by type record
   v5.5  J.N.  02/12/08  get debugging output to a TMemo working right
   v5.6  J.N.  03/01/08  replace Close by CloseFile
   v5.7  J.N.  03/01/24  replace USES IFDEF CLX by IFDEF LINUX | MSWINDOWS
   v6.0  J.N.  04/08/04  dutec_in: add command argument (P, PP, or PA)
                         optomux_talk: change cmd :CHAR to :String
   v6.1  J.N.  04/12/05  recv/checksum: empty PP response expected sometimes
   v7.0  J.N.  09/08/15  TYPE comm_parameters, VAR optomux_ports: delete
                         PROCEDURE comm_start, comm_stop: delete
                         USES comm_dp4: replaced by DataComm
                         send: move buffer emptying to DataComm.PortSend
                         recv: delete command echo detection and skipping code
                         recv: delete two_wire_enable, _delay vars and code
   v7.1  J.N.  09/10/07  recv: replace read char loop by read string
                         Uses: delete crt32; apparently not used!
                         delete debug2console, optomux_debug_console and related code
}

Interface

USES
{$IFDEF LINUX}
  QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  StdCtrls,
{$ENDIF}
  DataComm, SysUtils;

CONST  {These global constants can be used when calling program invokes
        functions and procedures in this unit.  The relevant
        Optomux command letter code is given for reference.}

  ms_0   = 0;        {'C', turn around delay}
  ms_10  = 1;
  ms_100 = 2;
  ms_500 = 3;

  two_pass  = 0;     {'E', set protocol}
  four_pass = 1;

  wd_disable = 0;    {'D', watchdog timer initialize, = disabled}

  sec_10 = 1;        {watchdog enabled, = 10 seconds}
  min_1  = 2;        {                  =  1 minute }
  min_10 = 3;        {                  = 10 minutes}

  all_off = 0;       {if digital board, action on time-out}
  ch0_on  = 4;

  zero_scale = 0;    {if analog board, output channels}
  full_scale = 4;

  digital_type = 0;  {'F', returned by identify}
  analog_type  = 1;

  no_probe = 0;  {'k', set temperature probe type, = no temperature probe}
  ictd     = 1;                                  { = ICTD probe}
  rtd_10   = 2;                                  { =  10 ohm RTD probe}
  rtd_100  = 3;                                  { = 100 ohm RTD probe}
  j_type   = 4;                                  { = Type J thermocouple}
  k_type   = 5;                                  { = Type K thermocouple}
  r_type   = 6;                                  { = Type R thermocouple}
  s_type   = 7;                                  { = Type S thermocouple}
  t_type   = 8;                                  { = Type T thermocouple}
  e_type   = 9;                                  { = Type E thermocouple}

  optomux_errno_max = 21;

  optomux_error_list: ARRAY [-1..optomux_errno_max] OF String[63] =
    { 0x -- errors returned by brain in "N" packet
      1x -- errors found by this unit's software
      2x -- errors found by communications unit}

      ('No error [-1]',
       'Power-up clear expected [00]',
       'Undefined command [01]',
       'Checksum error (outgoing) [02]',
       'Input buffer overrun [03]',
       'Non-printable ASCII character received [04]',
       'Not enough characters received (outgoing) [05]',
       'Communications link watchdog time-out error [06]',
       'Specified limits invalid [07]',
       '*** not used *** [08]',
       '*** not used *** [09]',
       'Returned string >= 255 [10]',
       'First returned character not A or N [11]',
       'Too few values returned [12]',
       'Too many values returned [13]',
       'Checksum error (incoming) [14]',
       'Invalid character [15]',
       'Echo not equal to command sent (4-pass protocol only) [16]',
       '*** not used *** [17]',
       '*** not used *** [18]',
       '*** not used *** [19]',
       'Transmit timeout [20]',
       'Receive timeout [21]'
       );

  speed_value: ARRAY [1..10] OF Word =
                 (110, 150, 300, 600, 1200, 2400, 4800, 9600, 19200, 38400);

  parity_value: ARRAY [1..5] OF String[5] =
                  ('None', 'Odd', 'Even', 'Mark', 'Space');

TYPE  optomux_rec = RECORD
                      error: BOOLEAN;
                      errno: INTEGER;
                      last_cmd,          {last command sent}
                      last_res: String;  {last response received}
                      data_out,          {<-- not used at this time}       
                      data_in: ARRAY [0..$F] OF Word;
                      END;  {of record}

      optomux_errstats_type = ARRAY [-1..optomux_errno_max] OF RECORD
                                n,
                                retries: Longint;
                                lasterr_dt : String[11];
                                lasterr_cmd: String[20];
                                lasterr_res: String[80];
                                END;
  
      optomux_err_byaddr_type = ARRAY [0..255] OF Longint;

      adc_read_type = ARRAY [0..255] OF RECORD
                                          flag:   BOOLEAN;
                                          select: Word;
                                          data:   ARRAY [0..15] OF Word;
                                          END;

VAR  {these are global variables either set or referenced by client programs}

  optomux_var: optomux_rec;  {results passed to calling program}

  optomux_protocol: Word;  {'two_pass' or 'four_pass'; set by set_protocol}

  optomux_errstats: ^optomux_errstats_type;

  optomux_err_byaddr: ^optomux_err_byaddr_type;
  
  adc_read: ^adc_read_type;

{Software interface to communications code}
PROCEDURE send (port: Word; command: String);
PROCEDURE recv (port, positions, fields: Word);
{Utilities}
FUNCTION word2hex (value: Word; mind, maxd: INTEGER): String;
FUNCTION hex2word (s: String; VAR code: INTEGER): Word;
FUNCTION checksum (s: String): Byte;
FUNCTION numbitson (mask: Word): INTEGER;
FUNCTION word2temp (raw: Word): REAL;
PROCEDURE adc_read_clear;
PROCEDURE adc_select_clear;
{Used for 4-pass protocol}
PROCEDURE execute (port: Word);
{Software interface between command procedures and send/recv}
PROCEDURE optomux_talk (cmd: String;
  port, address, positions, pmin, pmax, data, dmin, dmax: Word;
  modifier: String; values: INTEGER);
{*** Command procedures ***}
{Setup}
PROCEDURE power_up_clear (port, address: Word);                         {A}
PROCEDURE reset_optomux (port, address: Word);                          {B}
PROCEDURE set_turnaround_delay (port, address, data: Word);             {C}
PROCEDURE set_protocol (port, address, data: Word);                     {E}
PROCEDURE identify_type (port, address: Word);                          {F}
PROCEDURE set_watchdog_delay   (port, address, positions, data: Word);  {D}
PROCEDURE set_watchdog_digital (port, address, positions, data: Word);  {m}
PROCEDURE set_watchdog_analog  (port, address, positions, data: Word);  {m}
PROCEDURE set_temp_probe (port, address, positions, data: Word);        {k}
PROCEDURE set_timer_resolution (port, address, data: Word);             {n}
{Configuration}
PROCEDURE configure_positions (port, address, positions: Word);         {G}
PROCEDURE configure_inputs    (port, address, positions: Word);         {H}
PROCEDURE configure_outputs   (port, address, positions: Word);         {I}
PROCEDURE read_configuration  (port, address: Word);                    {j}
{Digital read/write}
PROCEDURE write_digital (port, address, positions: Word);               {J}
PROCEDURE activate_digital (port, address, positions: Word);            {K}
PROCEDURE deactivate_digital (port, address, positions: Word);          {L}
PROCEDURE read_onoff (port, address: Word);                             {M}
{Digital Latch}
PROCEDURE set_latch_edges (port, address, positions: Word);             {N}
PROCEDURE set_off_to_on_latches (port, address, positions: Word);       {O}
PROCEDURE set_on_to_off_latches (port, address, positions: Word);       {P}
PROCEDURE read_latches (port, address: Word);                           {Q}
PROCEDURE read_and_clear_latches (port, address, positions: Word);      {R}
PROCEDURE clear_latches (port, address, positions: Word);               {S}
{Digital Counting}
PROCEDURE start_stop_counters (port, address, positions: Word);         {T}
PROCEDURE start_counters (port, address, positions: Word);              {U}
PROCEDURE stop_counters (port, address, positions: Word);               {V}
PROCEDURE read_counters (port, address, positions: Word);               {W}
PROCEDURE read_and_clear_counters (port, address, positions: Word);     {X}
PROCEDURE clear_counters (port, address, positions: Word);              {Y}
{Digital Time Delay/Pulse}
PROCEDURE set_time_delay                                                {Z}
  (port, address, positions, data: Word; modifier: String);
PROCEDURE retrigger_time_delay (port, address, positions: Word);        {h}
PROCEDURE generate_n_pulses                                             {i}
  (port, address, positions, data: Word; modifier: String);
PROCEDURE start_on_pulse  (port, address, positions, data: Word);       {k}
PROCEDURE start_off_pulse (port, address, positions, data: Word);       {l}
{Digital Pulse Duration Measurement}
PROCEDURE set_pulse_trigger_polarity (port, address, positions: Word);  {a}
PROCEDURE trigger_on_positive_pulse (port, address, positions: Word);   {b}
PROCEDURE trigger_on_negative_pulse (port, address, positions: Word);   {c}
PROCEDURE read_pulse_complete_bits (port, address, positions: Word);    {d}
PROCEDURE read_pulse_duration_counters (port, address, positions: Word);{e}
PROCEDURE read_and_clear_duration_counters                              {f}
  (port, address, positions: Word);
PROCEDURE clear_duration_counters (port, address, positions: Word);     {g}
{Analog read/write}
PROCEDURE write_analog  (port, address, positions, data: Word);         {J}
PROCEDURE update_analog (port, address, positions, data: Word);         {S}
PROCEDURE read_analog_output (port, address, positions: Word);          {K}
PROCEDURE read_analog_input  (port, address, positions: Word);          {L}
PROCEDURE read_and_average   (port, address, positions, data: Word);    {M}
PROCEDURE start_input_averaging (port, address, positions, data: Word); {T}
PROCEDURE read_average_complete (port, address: Word);                  {i}
PROCEDURE read_average_data (port, address, positions: Word);           {U}
PROCEDURE read_temperature  (port, address, positions: Word);           {l}
PROCEDURE read_average_temp (port, address, positions: Word);           {o}
{No Analog Input Range
    Analog Gain/Offset
    Analog Waveform command procedures have been written}
{duTec Local RS232 Port (command PP not implemented)}
PROCEDURE dutec_speed (port, address, speed: Word);                     {N}
PROCEDURE dutec_out   (port, address: Word; message: String);           {O}
PROCEDURE dutec_in (port, address: Word; cmd: String; VAR message: String);
{Debugging}                                                     {P}{PP}{PA}
FUNCTION DebugEnableGet: BOOLEAN;
PROCEDURE DebugEnableSet (state: BOOLEAN);
FUNCTION DebugPauseGet: BOOLEAN;
PROCEDURE DebugPauseSet (state: BOOLEAN);
PROCEDURE DebugMemoSet (memo: TMemo);
{Error statistics}
FUNCTION ErrstatsClearWhenGet: String;
PROCEDURE ErrstatsClear;
{Error logging}
FUNCTION ErrlogEnableGet: BOOLEAN;
PROCEDURE ErrlogEnableSet (state: BOOLEAN);
PROCEDURE ErrlogNameSet (filename: String);

Implementation

CONST ack = 'A';     {flag for normal responses}
      nak = 'N';     {flag for abnormal responses}

VAR i: INTEGER;

VAR dutec_local_speed: ARRAY [00..$FF] OF Word;

VAR optomux_err_whenclear: String;

VAR memoDebug: TMemo;
    debug2memo: BOOLEAN;
    msg_buffer: String;
    optomux_debug_enable,            {stream screen display}
    optomux_debug_pause: BOOLEAN;    {pause display}

VAR optomux_errlog_enable: BOOLEAN;  {send error messages to a file}
    optomux_errlog_name:   String;   {the file drive:path/name}
    optomux_errlog_file:   TEXT;     {the handle}

{-------------------------------------------------------------------------}


FUNCTION makepr (original:String): String;
{Replace unprintable characters in string by (nnn)
 JN  94/03/19
}
VAR i: INTEGER;
    s: String;
    t: String[3];
    c: CHAR;
    o: INTEGER;
BEGIN
  s := '\';
  FOR i := 1 TO Length(original) DO BEGIN
    c := original[i];
    o := ORD(c);
    IF (o IN [32..126])
      THEN s := s + c
      ELSE BEGIN
        Str (o:1, t);
        s := s + '(' + t + ')';
        END;
    END;
  s := s + '\';
  makepr := s;
  END;  {of function 'makepr'}
{-------------------------------------------------------------------------}

PROCEDURE on_change_memo_debug;
BEGIN
  WITH memoDebug DO
    IF (SelStart > (MaxLength - 320))
      THEN Lines.Add ('*** Text buffer full -- use Clear button ***');
  END;  {of procedure on_change_memo_debug}
{---------------------------------------------------------------------}

PROCEDURE send (port: Word; command: String);
{This procedure actually sends the characters out the serial port.
 Its coding depends on the communications package being used.
 This version calls the Comm_TP4 unit by Kevin R. Bulgrien,
   LeTourneau University, Longview TX, v1.50 11-15-89,
   with modifications made by John Nagy.

      port:     index of logical port record in DataComm.Ports[]
      command:  character string to be sent out to brain
}
BEGIN
  WITH optomux_var DO BEGIN          {send out the information}
    error := FALSE;
    errno := -1;
    last_cmd := command;
    error := NOT DataComm.PortSend (port, command);
    IF error THEN errno := 20;
    IF debug2memo THEN BEGIN
      msg_buffer :=
        CHR(13)+CHR(10) + 'OUT: ' + Copy (command, 1, Length(command)-1);
      IF error THEN msg_buffer := msg_buffer +
        '  ERROR ' + optomux_error_list[errno];
      END;
    END;  {of with}
  END;  {of procedure 'send'}
{-------------------------------------------------------------------------}

PROCEDURE recv (port, positions, fields: Word);
{This procedure receives characters from serial communications port.
 See comments in send().

      port:       index of logical port record in DataComm.Ports[]
      positions:  bit pattern of channels whose values are in input string
      fields:     number of data fields in reply
}
CONST realstart = ORD('>');      {begins all transmissions (except execute)}
      execstart = ORD('E');      {begins execute transmissions}
      fakestart = ORD('<');      {needed when skipping communications echo}
VAR flag:       CHAR;
    s, results: String;
    len, size:  INTEGER;
    i, j, code: INTEGER;
    mask:       Word;
    {$H+} s_ansi: String; {$H-}
BEGIN
  WITH optomux_var DO BEGIN

    error := FALSE;
    errno := -1;

    {input a <CR> terminated string}
    error := NOT DataComm.PortRecv (port, s_ansi, CHR(13));
    s := ShortString(s_ansi);
    last_res := s;
    IF error THEN errno := 21;  {assume it is a timeout}
    len := Length(s_ansi);
    IF NOT error THEN BEGIN
      error := (len >= 255);        {retained for historical reasons}
      IF error THEN errno := 10     {too many characters}
      END;

    IF NOT error THEN BEGIN
      flag := s[1];
      CASE flag OF
        ack: BEGIN  {normal return}
          CASE last_cmd[4] OF
            'F': size := 2;  {only command with size = 2}
            'K': size := 3;  {analog command is only w/ values<>0 and size=3}
            Else size := 4;
            END;  {of case}
          results := Copy(s,2,len-4);  {body of result}
          {fields=99 is the flag for duTec P-command}
          error := (fields<>99) AND (Length(results) < fields*size);
          IF error THEN errno := 12;   {not enough}
          IF NOT error THEN BEGIN
            error := (Length(results) > fields*size);
            IF error THEN errno := 13;  {too much}
            END;
          IF NOT error THEN BEGIN
            IF fields > 0 THEN BEGIN      {checksum returned only with data}
              error := checksum(results) <> hex2word(s[len-2]+s[len-1],code);
              error := error OR (code <> 0);
              IF (Copy(last_cmd, 4, 2) = 'PP') AND (Length(results) = 0)
                THEN error := FALSE;
              END;
            IF error
              THEN errno := 14  {checksum error}
              ELSE BEGIN
                IF (fields=1) AND (positions=0)
                  THEN BEGIN     {this is input of a digital bit pattern}
                    j := 0;      {force pick up of input word as ch 0}
                    positions := $8000;
                    END
                  ELSE j := 15;  {analog data input top to bottom}
                i := 0;
                mask := $8000;
                WHILE (i<fields) AND (j>=0) AND (NOT error) DO BEGIN
                  IF (mask And positions) <> 0 THEN BEGIN
                    data_in[j] := hex2word(Copy(results,i*size+1,size),code);
                    error := (code > 1);                   {allow ?...}
                    IF error THEN errno := 15;             {invalid character}
                    INC(i);
                    END;  {fill this channel slot}
                  DEC(j);
                  mask := mask Shr 1;
                  END;  {loop over results}
                END;  {finished moving results to data_in}
            END;  {of there are results fields to process}
          END;  {ack response}
        nak: BEGIN
          error := TRUE;     
          errno := hex2word (s[3], code);          {error detected by brain}
          IF (NOT (errno IN [0..7])) OR (code <> 0)
            THEN errno := 15;      {invalid character (overrides N message)}
          END;
        Else BEGIN
          error := TRUE;
          errno := 11;   {flag character not A or N (incl. 4-pass cmd echo)}
          END;
        END;  {of case}
      END;
    IF debug2memo THEN BEGIN
      msg_buffer := msg_buffer +
        CHR(13)+CHR(10) + IntToStr(port) + 'IN: ' + makepr(last_res);
      IF error THEN msg_buffer := msg_buffer +
         '  ERROR ' + optomux_error_list[errno];
      END;

    END;  {of with}
  END;  {of procedure 'recv'}
{-------------------------------------------------------------------------}

FUNCTION word2hex (value: Word; mind, maxd: INTEGER): String;
{Return hexadecimal ascii string
   value:  input number
   mind:   minimum number of digits to return
   maxd:   maximum number of digits to return
 Note -- at least one digit is always returned!

 J.N.  92/08/04  original  TP5.0
}
CONST hx: ARRAY [0..15] OF CHAR 
  = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
VAR temp: String;
    count: INTEGER;
BEGIN
  temp := '';
  count := 0;
  REPEAT
    temp := hx[value And $F] + temp;
    value := value Shr 4;
    INC(count);
    UNTIL (count >= maxd) OR ((count >= mind) AND (value = 0));
  word2hex := temp;
  END;  {of function 'word2hex'}
{-------------------------------------------------------------------------}

FUNCTION hex2word (s: String; VAR code: INTEGER): Word;
{Hexadecimal string to word conversion function for optomux package.

   s         string (input)
   code      return code (output)
               = 0  conversion ok
               = 1  ?... string even if not ???? but e.g., ?a4Z
               = 2  string greater than 4 characters
               = 3  invalid character in string
   hex2word  returned function value
}
CONST ofs0   = ORD('0');
      ofsucA = ORD('A')-10;
      ofslcA = ORD('a')-10;
VAR value: Word;
    i: INTEGER;
BEGIN
  value := 0;
  code := 0;
  IF s[1] = '?'
    THEN code := 1
    ELSE IF Length(s) > 4
      THEN code := 2
      ELSE BEGIN
        i := 1;
        WHILE i <= Length(s) DO BEGIN
          CASE s[i] OF
            '0'..'9':  value := (value Shl 4) Or (ORD(s[i]) - ofs0  );
            'A'..'F':  value := (value Shl 4) Or (ORD(s[i]) - ofsucA);
            'a'..'f':  value := (value Shl 4) Or (ORD(s[i]) - ofslcA);
            Else code := 3;
            END;  {of case}
          INC(i);
          END;
        END;
  hex2word := value;
  END;  {of function 'hex2word'}
{-------------------------------------------------------------------------}

FUNCTION checksum (s: String): Byte;
{Calculate 8-bit check sum of a string.}
VAR sum: Word;
    i: INTEGER;
BEGIN
  sum := 0;
  FOR i := 1 TO Length(s) DO sum := sum + ORD(s[i]);
  checksum := sum And $00FF;
  END;  {of function 'checksum'}
{-------------------------------------------------------------------------}

FUNCTION numbitson (mask: Word): INTEGER;
{Count number of set bits in the word 'mask'.}
VAR i, temp: INTEGER;
BEGIN  
  temp := 0;
  i := 0;
  WHILE (mask>0) AND (i<=15) DO BEGIN
    temp := temp + (mask And 1);
    mask := mask Shr 1;
    INC(i);
    END;
  numbitson := temp;
  END;  {of function 'numbitson'}
{-------------------------------------------------------------------------}

FUNCTION word2temp (raw: Word): REAL;
{Convert data returned from brain to degrees Celsius.
 This function is not used in this package but must be applied
 by the routine which calls temperature reads.
 I think this is the only floating point routine in the unit!
}
BEGIN  
  IF (raw And $8000) = 0
    THEN {is positive} word2temp := raw/16.0
    ELSE {is negative} word2temp := -(raw Xor $FFFF)/16.0;
  END;  {of function 'word2temp'}
{-------------------------------------------------------------------------}

PROCEDURE execute (port: Word);
{This is the 3rd pass when using 4-pass protocol.
 It should be the only call to 'send' that by-passes 'optomux_talk'
 }
CONST code = 'E';
      cr = CHR(13);
BEGIN
  send (port, code+cr);
  END;  {of procedure 'execute'}
{-------------------------------------------------------------------------}

PROCEDURE optomux_talk (cmd: String;
  port, address, positions, pmin, pmax, data, dmin, dmax: Word;
  modifier: String; values: INTEGER);
{Construct and send out an Optomux command string.
 Handle echo by brain if using 4-pass protocol.
 (Comm system echoes handled by 'recv'.)
 Get reply to command.

 cmd        command (single letter except for PP and PA)
 port       communications port number [1..4]
 address    address of brain board
 positions  positions field value and,
 pmin         minimum and maximum number of
 pmax         hexadecimal digits to send
 data       data field value and,
 dmin         minimum and maximum number of
 dmax         hexadecimal digits to send
 modifier   string inserted after position, before data
 values     number of value fields expected to be in reply

 ***This routine can not block output more than one "data" item which would
    be useful if a lot of different analog outputs had to be set.

 If pmax|dmax <=0, corresponding field is not used.

 J.N.  92/08/04  Original  TP5.0
 J.N.  93/09/07  Command retried after certain errors
 J.N.  93/09/24  Modifier field now included as a string
 J.N.  04/08/04  cmd changed from CHAR to String for PP and PA
}
CONST start = '>';      {begins all transmissions to brains (except execute)}
      stop  = CHR(13);  {carriage return}
      attempts_max = 2; {number of times to attempt to execute command}
VAR hex_addr,
    hex_pos,
    hex_data,
    hex_chksum,
    body,
    sout: String;
    attempts_count: INTEGER;
BEGIN
  {Determine if there is to be any debugging output to screen}
  debug2memo :=    optomux_debug_enable AND
                   (NOT (optomux_debug_pause));

  hex_addr := word2hex (address,2,2);
  IF pmax > 0 THEN hex_pos  := word2hex (positions,pmin,pmax)
              ELSE hex_pos  := '';
  IF dmax > 0 THEN hex_data := word2hex (data,dmin,dmax)
              ELSE hex_data := '';
  body := hex_addr + cmd + hex_pos + modifier + hex_data;
  hex_chksum := word2hex (checksum(body),2,2);
  sout := start + body + hex_chksum + stop;

  attempts_count := attempts_max;  {this begins the retry loop}
  WHILE attempts_count > 0 DO WITH optomux_var DO BEGIN

    send (port, sout);

    IF (NOT error) AND (optomux_protocol = four_pass) THEN BEGIN
      recv (port,0,0);
      last_res[1] := start;  {see Form 203.5, p. 31}
      IF (NOT error) OR (errno = 13) THEN  {this "error" is expected}
        IF last_res = last_cmd
          THEN execute (port)
          ELSE BEGIN
            error := TRUE;
            errno := 16;  {echo did not match command}
            END;
      END;

    {now get the actual reply to the command}
    IF NOT error THEN recv (port, positions, values);

    {"Too many values" error is expected from duTec local RS232 read}
    IF ((cmd[1]='P') AND (errno=13)) THEN error := FALSE;

    IF debug2memo THEN BEGIN
      memoDebug.Lines.Add (msg_buffer);
      on_change_memo_debug;
      END;

    IF error THEN WITH optomux_errstats^[errno] DO BEGIN
      {error statistics by address}
      IF error THEN INC (optomux_err_byaddr^[address]);
      {error statistics by type (code)}
      INC(n);
      lasterr_dt  := FormatDateTime ('yyyy-mm-dd@hh:nn:ss', Now);
      lasterr_cmd := Copy (last_cmd, 1, Length(last_cmd)-1);
      lasterr_res := makepr(last_res);
      {error logging}
      IF optomux_errlog_enable THEN BEGIN
        {$I-}
        WRITE   (optomux_errlog_file, lasterr_dt);
        WRITE   (optomux_errlog_file, ' ' +optomux_error_list[errno]);
        WRITE   (optomux_errlog_file, ' #',n:1);
        WRITE   (optomux_errlog_file, ' ', lasterr_cmd);
        WRITELN (optomux_errlog_file, ' ', lasterr_res);
        i := IOResult;
        {$I+}
        END;
      END;

    IF error AND (errno IN [01..05,07,10..19])
      THEN BEGIN
             DEC(attempts_count);
             IF attempts_count > 0 
               THEN INC(optomux_errstats^[errno].retries);
             END
           ELSE attempts_count := 0;  {either OK or system needs resetting}
    END;  {of retry loop}

  END;  {of procedure 'optomux_talk'}
{-------------------------------------------------------------------------}

PROCEDURE power_up_clear (port, address: Word);                         {A}
{Opto22 Optomux Form 203.5, p. 51
 Digital, Analog
 J.N.  92/08/04  Original
 J.N.  93/09/24  Modifier field now included as a string
                 Calls to optomux_talk changed but not commented below
}
CONST cmd = 'A';
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, 0,0,0, '', 0);
  END;  {of procedure 'power_up_clear'}
{-------------------------------------------------------------------------}

PROCEDURE reset_optomux (port, address: Word);                          {B}
{Opto22 Optomux Form 203.5, p. 52
 Digital, Analog
 J.N.  92/08/04  Original
}
CONST cmd = 'B';
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, 0,0,0, '', 0);
  END;  {of procedure 'reset_optomux'}
{-------------------------------------------------------------------------}

PROCEDURE set_turnaround_delay (port, address, data: Word);             {C}
{Opto22 Optomux Form 203.5, p. 53
 Digital, Analog
 J.N.  92/08/04  Original
}
CONST cmd = 'C';
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, data,1,1, '', 0);
  END;  {of procedure 'set_turnaround_delay'}
{-------------------------------------------------------------------------}

PROCEDURE set_protocol (port, address, data: Word);                     {E}
{Opto22 Optomux Form 203.5, p. 56
 Digital, Analog
 data:  0 = two-pass protocol  [see global constants]
        1 = four-pass protocol
 NOTE -- This protocol stuff is very tricky.  'optomux_protocol' value
         may not even be correct for last address whose protocol was
         switched since an error may have occurred after change.  For a
         production multiboard system it is best to set protocol
         jumpers on the boards, set 'optomux_protocol' in the application
         program, and then not use this procedure.  Use should be limited
         to single board debugging programs.  (Or I could look into
         autodetection of protocol.)
 J.N.  92/08/04  Original
}
CONST cmd = 'E';
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, data,1,1, '', 0);
  IF NOT optomux_var.error THEN optomux_protocol := data;
  END;  {of procedure 'set_protocol'}
{-------------------------------------------------------------------------}

PROCEDURE identify_type (port, address: Word);                          {F}
{Opto22 Optomux Form 203.5, p. 57
 Digital, Analog
 1 2-digit reply: 00=digital, 01=analog  [see global constants]
 J.N.  92/08/04  Original
}
CONST cmd = 'F';
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, 0,0,0, '', 1);
  END;  {of procedure 'identify_type'}
{-------------------------------------------------------------------------}

PROCEDURE set_watchdog_delay   (port, address, positions, data: Word);  {D}
{Opto22 Optomux Form 203.5, pp. 54, 55
 Digital -- No positions, i.e. = 0
 Analog  -- Positions (channels) specified
 J.N.  92/08/04  Original
}
CONST cmd = 'D';
VAR pmax: Word;
BEGIN
  IF positions <= 0 THEN pmax := 0
                    ELSE pmax := 4;
  optomux_talk (cmd, port, address, positions,4,pmax, data,1,1, '', 0);
  END;  {of procedure 'set_watchdog_delay'}
{-------------------------------------------------------------------------}

PROCEDURE set_watchdog_digital (port, address, positions, data: Word);  {m}
{Opto22 Optomux Form 203.5, p. 58
 Digital
   positions: 1 = set ON;  0 = set OFF  [see global constants]
   data:      delay in 10 ms units (0, or >= 200 ms)
 J.N.  92/08/04  Original
}
CONST cmd = 'm';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, data,1,4, '', 0);
  END;  {of procedure 'set_watchdog_digital'}
{-------------------------------------------------------------------------}

PROCEDURE set_watchdog_analog  (port, address, positions, data: Word);  {m}
{Opto22 Optomux Form 203.5, p. 59
 Analog
   positions: channel bit mask (THERE MUST BE ONLY ONE BIT ON !!!)
   data:      output value     (ONLY ONE VALUE CAN BE OUTPUT AT A TIME)
 J.N.  92/08/04  Original
}
CONST cmd = 'm';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, data,3,3, '', 0);
  END;  {of procedure 'set_watchdog_analog'}
{-------------------------------------------------------------------------}

PROCEDURE set_temp_probe (port, address, positions, data: Word);        {k}
{Opto22 Optomux Form 203.5, p. 61
 Analog
   positions: channel bit mask
   data:      probe type    [see global constants]
 J.N.  92/08/04  Original
}
CONST cmd = 'k';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, data,1,4, '', 0);
  END;  {of procedure 'set_temp_probe'}
{-------------------------------------------------------------------------}

PROCEDURE set_timer_resolution (port, address, data: Word);             {n}
{Opto22 Optomux Form 203.5, p. 60
 Digital
   data:      resolution = [data] x 10 ms  (or, 2.56 s if [data]=0)
 J.N.  92/08/04  Original
}
CONST cmd = 'n';
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, data,2,2, '', 0);
  END;  {of procedure 'set_timer_resolution'}
{-------------------------------------------------------------------------}

PROCEDURE configure_positions (port, address, positions: Word);         {G}
{Opto22 Optomux Form 203.5, p. 65
 Digital, Analog
   positions: configure this channel as 0=input, 1=output
 J.N.  92/08/04  Original
}
CONST cmd = 'G';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'configure_positions'}
{-------------------------------------------------------------------------}

PROCEDURE configure_inputs    (port, address, positions: Word);         {H}
{Opto22 Optomux Form 203.5, p. 66
 Digital, Analog
   positions: configure specified channels as inputs
 J.N.  92/08/04  Original
}
CONST cmd = 'H';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'configure_inputs'}
{-------------------------------------------------------------------------}

PROCEDURE configure_outputs   (port, address, positions: Word);         {I}
{Opto22 Optomux Form 203.5, p. 67
 Digital, Analog
   positions: configure specified channels as outputs
 J.N.  92/08/04  Original
}
CONST cmd = 'I';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'configure_outputs'}
{-------------------------------------------------------------------------}

PROCEDURE read_configuration  (port, address: Word);                    {j}
{Opto22 Optomux Form 203.5, p. 68
 Digital, Analog
   response bits:  input (0) or output (1) channel
 J.N.  92/08/04  Original
}
CONST cmd = 'j';
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, 0,0,0, '', 1);
  END;  {of procedure 'read_configuration'}
{-------------------------------------------------------------------------}

PROCEDURE write_digital (port, address, positions: Word);               {J}
{Opto22 Optomux Form 203.5, p. 71
 Digital
   positions: turn channel on (1), or off (0)
   ALL positions are affected by this procedure
   See K and L digital commands for manipulation of individual bits
 J.N.  92/08/04  Original
       93/04/14  Force affecting all bit positions
}
CONST cmd = 'J';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, 0,0,0, '', 0);
  END;  {of procedure 'write_digital'}
{-------------------------------------------------------------------------}

PROCEDURE activate_digital (port, address, positions: Word);            {K}
{Opto22 Optomux Form 203.5, p. 72
 Digital
   positions: 1 --> turn this channel ON, 0 --> leave this channel alone
 J.N.  92/08/04  Original
}
CONST cmd = 'K';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'activate_digital'}
{-------------------------------------------------------------------------}

PROCEDURE deactivate_digital (port, address, positions: Word);          {L}
{Opto22 Optomux Form 203.5, p. 73
 Digital
   positions: 1 --> turn this channel OFF, 0 --> leave this channel alone
 J.N.  92/08/04  Original
}
CONST cmd = 'L';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'deactivate_digital'}
{-------------------------------------------------------------------------}

PROCEDURE read_onoff (port, address: Word);                             {M}
{Opto22 Optomux Form 203.5, p. 74
 Digital
   response bits: 0 --> this channel OFF, 1 --> this channel ON
 J.N.  92/08/04  Original
}
CONST cmd = 'M';
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, 0,0,0, '', 1);
  END;  {of procedure 'read_onoff'}
{-------------------------------------------------------------------------}

PROCEDURE set_latch_edges (port, address, positions: Word);             {N}
{Opto22 Optomux Form 203.5, p. 77
 Digital
   position bits: 0 --> OFF-to-ON, 1 --> ON-to-OFF latching
 J.N.  94/06/23  Original
}
CONST cmd = 'N';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, 0,0,0, '', 0);
  END;  {of procedure 'set_latch_edges'}
{-------------------------------------------------------------------------}

PROCEDURE set_off_to_on_latches (port, address, positions: Word);       {O}
{Opto22 Optomux Form 203.5, p. 78
 Digital
   position bits: 0 --> no effect, 1 --> OFF-to-ON latching
 J.N.  94/06/23  Original
}
CONST cmd = 'O';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'set_off_to_on_latches'}
{-------------------------------------------------------------------------}

PROCEDURE set_on_to_off_latches (port, address, positions: Word);       {P}
{Opto22 Optomux Form 203.5, p. 79
 Digital
   position bits: 0 --> no effect, 1 --> ON-to-OFF latching
 J.N.  94/06/23  Original
}
CONST cmd = 'P';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'set_on_to_off_latches'}
{-------------------------------------------------------------------------}

PROCEDURE read_latches (port, address: Word);                           {Q}
{Opto22 Optomux Form 203.5, p. 80
 Digital
   response bits: 0 --> this channel not latched, 1 --> channel latched
 J.N.  94/06/23  Original
}
CONST cmd = 'Q';
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, 0,0,0, '', 1);
  END;  {of procedure 'read_latches'}
{-------------------------------------------------------------------------}

PROCEDURE read_and_clear_latches (port, address, positions: Word);      {R}
{Opto22 Optomux Form 203.5, p. 81
 Digital
   response bits: 0 --> this channel not latched, 1 --> channel latched
   position bits: 0 --> no effect, 1 --> cleared
 J.N.  94/06/23  Original
}
CONST cmd = 'R';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 1);
  END;  {of procedure 'read_and_clear_latches'}
{-------------------------------------------------------------------------}

PROCEDURE clear_latches (port, address, positions: Word);               {S}
{Opto22 Optomux Form 203.5, p. 82
 Digital
   position bits: 0 --> no effect, 1 --> cleared
 J.N.  94/06/23  Original
}
CONST cmd = 'S';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'clear_latches'}
{-------------------------------------------------------------------------}

PROCEDURE start_stop_counters (port, address, positions: Word);         {T}
{Opto22 Optomux Form 203.5, p. 85
 Digital
   position bits: 0 --> stop counting, 1 --> start counting
 J.N.  94/06/23  Original
}
CONST cmd = 'T';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, 0,0,0, '', 0);
  END;  {of procedure 'start_stop_counters'}
{-------------------------------------------------------------------------}

PROCEDURE start_counters (port, address, positions: Word);              {U}
{Opto22 Optomux Form 203.5, p. 86
 Digital
   position bits: 0 --> no effect, 1 --> start counting OFF-to-ON edges
   counters are NOT cleared
   counters wrap at 65,535
   f < 400 Hz  T > 1.25 ms
 J.N.  94/06/23  Original
}
CONST cmd = 'U';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'start_counters'}
{-------------------------------------------------------------------------}

PROCEDURE stop_counters (port, address, positions: Word);               {V}
{Opto22 Optomux Form 203.5, p. 87
 Digital
   position bits: 0 --> no effect, 1 --> stop counting OFF-to-ON edges
   counters are NOT cleared
 J.N.  94/06/23  Original
}
CONST cmd = 'M';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'stop_counters'}
{-------------------------------------------------------------------------}

PROCEDURE read_counters (port, address, positions: Word);               {W}
{Opto22 Optomux Form 203.5, p. 88
 Digital
   position bits: 1 --> read the counts in this channel
 J.N.  94/06/23  Original
}
CONST cmd = 'W';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '',
                numbitson(positions));
  END;  {of procedure 'read_counters'}
{-------------------------------------------------------------------------}

PROCEDURE read_and_clear_counters (port, address, positions: Word);     {X}
{Opto22 Optomux Form 203.5, p. 89
 Digital
   position bits: 1 --> read and clear the counts in this channel
 J.N.  94/06/23  Original
}
CONST cmd = 'X';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '',
                numbitson(positions));
  END;  {of procedure 'read_and_clear_counters'}
{-------------------------------------------------------------------------}

PROCEDURE clear_counters (port, address, positions: Word);              {Y}
{Opto22 Optomux Form 203.5, p. 90
 Digital
   position bits: 0 --> no effect, 1 --> clear the counts in this channel
 J.N.  94/06/23  Original
}
CONST cmd = 'Y';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'clear_counters'}
{-------------------------------------------------------------------------}

PROCEDURE set_time_delay                                                {Z}
  (port, address, positions, data: Word; modifier: String);
{Opto22 Optomux Form 203.5, pp. 93-95
 Digital
   position bits: 0 --> no effect, 1 --> set to selected delay or pulse
   data = desired time / (TRS * 10 ms)
   modifier = see manual
 J.N.  94/06/23  Original
}
CONST cmd = 'Z';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, data,1,4, modifier, 0);
  END;  {of procedure 'set_time_delay'}
{-------------------------------------------------------------------------}

PROCEDURE retrigger_time_delay (port, address, positions: Word);        {h}
{Opto22 Optomux Form 203.5, p. 96
 Digital
   position bits: 0 --> no effect, 1 --> retrigger this channel
 J.N.  94/06/23  Original
}
CONST cmd = 'h';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'retrigger_time_delay'}
{-------------------------------------------------------------------------}

PROCEDURE generate_n_pulses                                             {i}
  (port, address, positions, data: Word; modifier: String);
{Opto22 Optomux Form 203.5, p. 97
 Digital
   position bits: 0 --> no effect, 1 --> send 50% duty factor pulse train
   data     = number of pulses
   modifier = 1/2 period in units of TRS * 10 ms (01..FF ascii string).  
              00 turns off pulse train.
 J.N.  94/06/23  Original
}
CONST cmd = 'i';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, data,1,4, modifier, 0);
  END;  {of procedure 'generate_n_pulses'}
{-------------------------------------------------------------------------}

PROCEDURE start_on_pulse (port, address, positions, data: Word);        {k}
{Opto22 Optomux Form 203.5, p. 98
 Digital
   position bits: 0 --> no effect, 1 --> ON (re)trigger this channel
   data = pulse length in units of TRS * 10 ms
 J.N.  94/06/23  Original
}
CONST cmd = 'k';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, data,1,4, '', 0);
  END;  {of procedure 'start_on_pulse'}
{-------------------------------------------------------------------------}

PROCEDURE start_off_pulse  (port, address, positions, data: Word);      {l}
{Opto22 Optomux Form 203.5, p. 99
 Digital
   position bits: 0 --> no effect, 1 --> OFF (re)trigger this channel
   data = pulse length in units of TRS * 10 ms
 J.N.  94/06/23  Original
}
CONST cmd = 'l';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, data,1,4, '', 0);
  END;  {of procedure 'start_off_pulse'}
{-------------------------------------------------------------------------}

PROCEDURE set_pulse_trigger_polarity (port, address, positions: Word);  {a}
{Opto22 Optomux Form 203.5, p. 103
 Digital
   position bits: 0 --> measure OFF duration, 1 --> measure ON duration
 J.N.  94/06/23  Original
}
CONST cmd = 'a';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, 0,0,0, '', 0);
  END;  {of procedure 'set_pulse_trigger_polarity'}
{-------------------------------------------------------------------------}

PROCEDURE trigger_on_positive_pulse (port, address, positions: Word);   {b}
{Opto22 Optomux Form 203.5, p. 104
 Digital
   position bits: 0 --> no effect, 1 --> measure ON duration
 J.N.  94/06/23  Original
}
CONST cmd = 'b';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'trigger_on_positive_pulse'}
{-------------------------------------------------------------------------}

PROCEDURE trigger_on_negative_pulse (port, address, positions: Word);   {c}
{Opto22 Optomux Form 203.5, p. 105
 Digital
   position bits: 0 --> no effect, 1 --> measure OFF duration
 J.N.  94/06/23  Original
}
CONST cmd = 'c';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'trigger_on_negative_pulse'}
{-------------------------------------------------------------------------}

PROCEDURE read_pulse_complete_bits (port, address, positions: Word);    {d}
{Opto22 Optomux Form 203.5, p. 106
 Digital
   response bits: 0 --> pulse not complete, 1 --> pulse complete
 J.N.  94/06/23  Original
}
CONST cmd = 'd';
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, 0,0,0, '', 1);
  END;  {of procedure 'read_pulse_complete_bits'}
{-------------------------------------------------------------------------}

PROCEDURE read_pulse_duration_counters (port, address, positions: Word);{e}
{Opto22 Optomux Form 203.5, p. 107
 Digital
   position bits: 0 --> do not read channel, 1 --> read this channel
 J.N.  94/06/23  Original
}
CONST cmd = 'e';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '',
                numbitson(positions));
  END;  {of procedure 'read_pulse_duration_counters'}
{-------------------------------------------------------------------------}

PROCEDURE read_and_clear_duration_counters                              {f}
  (port, address, positions: Word);
{Opto22 Optomux Form 203.5, p. 108
 Digital
   position bits: 0 --> ignore this channel, 1 --> read and clear this channel
 J.N.  94/06/23  Original
}
CONST cmd = 'f';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '',
                numbitson(positions));
  END;  {of procedure 'read_and_clear_duration_counters'}
{-------------------------------------------------------------------------}

PROCEDURE clear_duration_counters (port, address, positions: Word);     {g}
{Opto22 Optomux Form 203.5, p. 109
 Digital
   position bits: 0 --> no effect, 1 --> clear this channel
 J.N.  94/06/23  Original
}
CONST cmd = 'g';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 0);
  END;  {of procedure 'clear_duration_counters'}
{-------------------------------------------------------------------------}

PROCEDURE write_analog  (port, address, positions, data: Word);         {J}
{Opto22 Optomux Form 203.5, p. 113
 Analog
   positions: 1 --> these channels to be set to [data], 0 --> no effect
   data:      12-bit value
 J.N.  92/08/04  Original
}
CONST cmd = 'J';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, data,3,3, '', 0);
  END;  {of procedure 'write_analog'}
{-------------------------------------------------------------------------}

PROCEDURE update_analog (port, address, positions, data: Word);         {S}
{Opto22 Optomux Form 203.5, p. 114
 Analog
   positions: 1 --> these channels to be set to data[i], 0 --> no effect
   data[i]:   12-bit values
 J.N.  92/08/04  Original -- only works for a single channel at this time.
}
CONST cmd = 'S';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, data,3,3, '', 0);
  END;  {of procedure 'update_analog'}
{-------------------------------------------------------------------------}

PROCEDURE read_analog_output (port, address, positions: Word);          {K}
{Opto22 Optomux Form 203.5, p. 115
 Analog
   positions: 1 --> channels to be read
   responses: 12-bit values as 3 hexadecimal digits each
 J.N.  92/08/04  Original
}
CONST cmd = 'K';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 
                numbitson(positions));
  END;  {of procedure 'read_analog_output'}
{-------------------------------------------------------------------------}

PROCEDURE read_analog_input  (port, address, positions: Word);          {L}
{Opto22 Optomux Form 203.5, p. 116
 Analog
   positions: 1 --> channels to be read
   responses: 16-bit values as 4 hexadecimal digits each
 J.N.  92/08/04  Original
}
CONST cmd = 'L';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '', 
                numbitson(positions));
  END;  {of procedure 'read_analog_input'}
{-------------------------------------------------------------------------}

PROCEDURE read_and_average   (port, address, positions, data: Word);    {M}
{Opto22 Optomux Form 203.5, p. 117
 Analog
   positions: channel to be read, 0..F (SINGLE HEX DIGIT ONLY!!!)
   data:      number of samples to average,  1..255 = 00..FF
   response:  16-bit value as 4 hexadecimal digits

   Note -- This command does not return until averaging is finished.
           See commands T, i, and U below.
 J.N.  92/08/04  Original
}
CONST cmd = 'M';
BEGIN
  optomux_talk (cmd, port, address, positions,1,1, data,2,2, '', 1);
  END;  {of procedure 'read_and_average'}
{-------------------------------------------------------------------------}

PROCEDURE start_input_averaging (port, address, positions, data: Word); {T}
{Opto22 Optomux Form 203.5, p. 118
 Analog
   positions: 1 --> channels for which consecutive readings are averaged
   data:      number of samples to average at 100 ms rate
 J.N.  92/08/04  Original
}
CONST cmd = 'T';
BEGIN
  optomux_talk (cmd, port, address, positions,4,4, data,1,4, '', 0);
  END;  {of procedure 'start_input_averaging'}
{-------------------------------------------------------------------------}

PROCEDURE read_average_complete (port, address: Word);                  {i}
{Opto22 Optomux Form 203.5, p. 119
 Analog
   response bits: 1 --> averaging is complete for this channel
 J.N.  92/08/04  Original
}
CONST cmd = 'i';
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, 0,0,0, '', 1);
  END;  {of procedure 'read_average_complete'}
{-------------------------------------------------------------------------}

PROCEDURE read_average_data (port, address, positions: Word);           {U}
{Opto22 Optomux Form 203.5, p. 120
 Analog
   positions: 1 --> read current averaged value for this channel
   responses: 16-bit values as 4 hex digits for each channel selected
 J.N.  92/08/04  Original
}
CONST cmd = 'U';
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '',
                numbitson(positions));
  END;  {of procedure 'read_average_data'}
{-------------------------------------------------------------------------}

PROCEDURE read_temperature  (port, address, positions: Word);           {l}
{Opto22 Optomux Form 203.5, p. 121-122
 Analog
   positions: 1 --> read temperature for this channel
   responses: signed 16-bit values as 4 hex digits for each channel selected
              representing +- T * 16.0 (caller should then use word2temp()).
 NOTE -- It is easier (at least for ICTD sensors) to just include temperature
         inputs in a block read of all analog inputs.  The application can
         just include temperature calculation as part of its general
         engineering conversion scheme.  This procedure and word2temp()
         are then not needed.
 J.N.  92/08/04  Original
}
CONST cmd = 'l';  {lower case L}
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '',
                numbitson(positions));
  END;  {of procedure 'read_temperature'}
{-------------------------------------------------------------------------}

PROCEDURE read_average_temp (port, address, positions: Word);           {o}
{Opto22 Optomux Form 203.5, p. 123-124
 Analog
   positions: 1 --> read temperature for this channel
   responses: signed 16-bit values as 4 hex digits for each channel selected
              representing +- T * 16.0 (caller should then use word2temp()).
 J.N.  92/08/04  Original
}
CONST cmd = 'o';  {lower case O}
BEGIN
  optomux_talk (cmd, port, address, positions,1,4, 0,0,0, '',
                numbitson(positions));
  END;  {of procedure 'read_average_temp'}
{-------------------------------------------------------------------------}

{********** duTec Local RS232 Port (command PP not implemented) **********}

{User's Manual, I/OPlexer, duTec, September 1990, pp. 3-157 to 163}

PROCEDURE dutec_speed (port, address, speed: Word);                     {N}
CONST cmd = 'N';
VAR message: String;
BEGIN
  CASE speed OF
     300: message := 'e';
     600: message := 'f';
    1200: message := 'h';
    2400: message := 'j';
    4800: message := 'l';
    9600: message := 'm';
   19200: message := 'n';
   Else   message := 'm';  {default to 9600; no error notification!!!}
   END; {case}
  dutec_local_speed[address] := speed;  {save it}
  optomux_talk (cmd, port, address, 0,0,0, 0,0,0, message, 0);
  END;  {of procedure 'dutec_speed'}

PROCEDURE dutec_out   (port, address: Word; message: String);           {O}
CONST cmd = 'O';  {upper case O}
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, 0,0,0, message, 0);
  END;  {of procedure 'dutec_out'}

PROCEDURE dutec_in (port, address: Word; cmd: String; VAR message: String);
                                                                {P}{PP}{PA}
VAR errno_save: INTEGER;
BEGIN
  optomux_talk (cmd, port, address, 0,0,0, 0,0,0, '', 99);
  WITH optomux_var DO IF error
    THEN BEGIN
      Str (errno:2, message);
      message := '***RS232 DUTEC_IN ERROR ' + message + ' ***';
      errno_save := errno;
      dutec_speed (port, address, dutec_local_speed[address]);
      error := TRUE;
      errno := errno_save;
      END
    ELSE message := Copy(last_res,1,Length(last_res)-3);
  END;  {of procedure 'dutec_in'}
{-------------------------------------------------------------------------}

PROCEDURE ErrstatsClear;
VAR i: INTEGER;
BEGIN
  optomux_err_whenclear := FormatDateTime ('yyyy-mm-dd hh:nn:ss', Now);
  FOR i := 0 TO 255 DO optomux_err_byaddr^[i] := 0;
  FOR i := -1 TO optomux_errno_max DO WITH optomux_errstats^[i] DO BEGIN
    n := 0;
    retries := 0;
    lasterr_cmd := '';
    lasterr_res := '';
    END;
  END;  {of procedure ErrstatsClear}
{-------------------------------------------------------------------------}

FUNCTION ErrstatsClearWhenGet: String;
BEGIN
  ErrstatsClearWhenGet := optomux_err_whenclear;
  END;  {of procedure ErrstatsClearWhenGet}
{-------------------------------------------------------------------------}

PROCEDURE adc_read_clear;
VAR i: INTEGER;
BEGIN
  FOR i := 0 TO 255 DO adc_read^[i].flag := FALSE;
  END;  {of procedure 'adc_read_clear'}
{-------------------------------------------------------------------------}

PROCEDURE adc_select_clear;
VAR i: INTEGER;
BEGIN
  FOR i := 0 TO 255 DO adc_read^[i].select := 0;
  END;  {of procedure 'adc_select_clear'}
{-------------------------------------------------------------------------}

FUNCTION DebugEnableGet: BOOLEAN;
BEGIN
  DebugEnableGet := optomux_debug_enable;
  END;  {of function 'DebugEnableGet'}
{-------------------------------------------------------------------------}

PROCEDURE DebugEnableSet (state: BOOLEAN);
BEGIN
  optomux_debug_enable := state;
  END;  {of procedure 'DebugEnableSet'}
{-------------------------------------------------------------------------}

FUNCTION DebugPauseGet: BOOLEAN;
BEGIN
  DebugPauseGet := optomux_debug_pause;
  END;  {of function 'DebugPauseGet'}
{-------------------------------------------------------------------------}

PROCEDURE DebugPauseSet (state: BOOLEAN);
BEGIN
  optomux_debug_pause := state;
  END;  {of procedure 'DebugPauseSet'}
{-------------------------------------------------------------------------}

PROCEDURE DebugMemoSet (memo: TMemo);
BEGIN
  memoDebug := memo;
  END;  {of procedure 'DebugMemoSet'}
{-------------------------------------------------------------------------}

FUNCTION ErrlogEnableGet: BOOLEAN;
BEGIN
  ErrlogEnableGet := optomux_errlog_enable;
  END;  {of function 'ErrlogEnableGet'}
{-------------------------------------------------------------------------}

PROCEDURE ErrlogEnableSet (state: BOOLEAN);
{Set/reset error logging to disk and open/close file}
BEGIN
  optomux_errlog_enable := state;
  IF optomux_errlog_enable
    THEN BEGIN
      {$I-}
      Assign  (optomux_errlog_file, optomux_errlog_name);
      Append  (optomux_errlog_file);
      IF (IOResult = 2) THEN REWRITE (optomux_errlog_file);
      WRITELN (optomux_errlog_file,
        FormatDateTime ('yyyy-mm-dd hh:nn:ss', Now) + ' Logging ON');
      IOResult;
      {$I+}
    END
    ELSE BEGIN
      {$I-}
      WRITELN (optomux_errlog_file,
        FormatDateTime ('yyyy-mm-dd hh:nn:ss', Now) + ' Logging OFF');
      CloseFile (optomux_errlog_file);
      IOResult;
      {$I+}
    END;
  END;  {of procedure 'ErrlogEnableSet'}
{-------------------------------------------------------------------------}

PROCEDURE ErrlogNameSet (filename: String);
BEGIN
  optomux_errlog_name := filename;
  END;  {of procedure 'ErrlogNameSet'}
{-------------------------------------------------------------------------}

BEGIN  {initialization at load time}
  memoDebug := NIL;
  optomux_debug_enable  := FALSE;
  optomux_debug_pause   := FALSE;

  optomux_errlog_enable := FALSE;

  optomux_protocol := two_pass;

  WITH optomux_var DO BEGIN
    error := FALSE;
    errno := -1;
    last_cmd := '';
    last_res := '';
    FOR i := 0 TO $F DO data_in[i] := 0;
    END;

  NEW (optomux_errstats);
  NEW (optomux_err_byaddr);
  ErrstatsClear;
  optomux_err_whenclear := optomux_err_whenclear + ' (at program load)';

  NEW (adc_read);
  adc_read_clear;
  adc_select_clear;

  {of unit 'optomux'...} END.
