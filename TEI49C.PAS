Unit tei49c;
{$L-}
{$R+}    {Range checking on}
{$B+}    {Boolean complete evaluation on}
{$S+}    {Stack checking on}
{$I+}    {I/O checking on}
{$N+}    {Numeric coprocessor}
{$E-}    {Do not include emulation code}
{*E+}    {Include emulation code}
{$H-}    {Old Turbo-style strings are default}
{
  Read in data from a TEI 4xC UVGA using its RS232 communications port.

  v1.0  2001-09-20  Original for TEI 49C through duTec only
  v2.0  2002-03-25  Remove 16-bit Turbo Uses capability
  v3.0  2002-05-14  Change state to state[address] throughout
  v3.1  2002-05-21  tei49c_value_get: split off possible checksum field
  v3.2  2002-05-22  tei49c_value_get: post-flushing of dutec buffer
  v3.3  2002-05-23  Negate v3.2 change
                    Make use of the new DebugLog module
  v3.4  2002-05-26  _init, _value_get: tei49c complete reset on opto err
  v3.5  2002-06-05  _dutec_init: split off _data_reset
  v3.6  2002-07-10  _dutec_init: end purge repeat on error (#14 expected)
  v3.7  2004-08-04  edit for new optomux/dutec_in calling sequence
  v3.8  2006-03-17  Remove Uses tp5utils & add Uses COMU
  v3.9  2007-05-31  tei49c_value_get:
                      can find no code that v3.1 ever done
                      split using separator '*' that is in 49I checksums
                      additional debug output for fields and value

  John Nagy, Brookhaven National Lab, Upton NY 11973 U.S.A.  nagy@bnl.gov

}

Interface

Uses crt32, optomux, debuglog, comu;

FUNCTION tei_read (port, address, id, varno: Word): Single;

Implementation

CONST n_values = 3;

VAR state: ARRAY [0..$2F] OF INTEGER;

VAR savedata: ARRAY [0..$2F,1..n_values] OF Single;

VAR debuglog_handle: INTEGER;

PROCEDURE debuglog_output (fname: String; port, address: Word);
VAR s1, s2, s3, s4: String;
BEGIN
  IF DebugLogEnableGet (debuglog_handle) THEN BEGIN
    Str (port:1, s1);
    s2 := word2hex (address, 2, 2);
    Str (state[address]:1, s3);
    s4 := optomux_error_list[optomux_var.errno];
    DebugLogFileWrite (debuglog_handle, fname +
      '/' + 'port=' + s1 + ' address=' + s2 + ' ' +
      'state=' + s3 + ' ' + s4 + '/' +
      optomux_var.last_cmd + '/' + optomux_var.last_res + '/');
    END;
  END;  {of procedure 'debuglog_output'}

PROCEDURE debuglog_output_value (fname: String; f1, f2, f3: String; v: Single);
VAR s: String;
BEGIN
  IF DebugLogEnableGet (debuglog_handle) THEN BEGIN
    Str (v:4:3, s);
    DebugLogFileWrite (debuglog_handle, fname +
      '  field1=' + f1 +
      '  field2=' + f2 +
      '  field3=' + f3 +
      '  value='  + s);
    END;
  END;  {of procedure 'debuglog_output'}

PROCEDURE tei49c_data_reset (address: Word);
VAR value: INTEGER;
BEGIN
  state[address] := n_values;
  FOR value := 1 TO n_values DO savedata[address,value] := 9999;
  debuglog_output ('tei49c_data_reset', 0, address);
  END;  {module procedure 'tei49c_data_reset'}

PROCEDURE tei49c_dutec_init (port, address: Word; VAR error: INTEGER);
VAR buffer: String;
BEGIN
  dutec_speed (port, address, 9600);
  REPEAT
    buffer := '';
    dutec_in (port, address, 'P', buffer);
    {WRITELN ('tei49c_dutec_init: buffer=^', buffer, '^');}
    UNTIL (optomux_var.error{buffer = ''});
  debuglog_output ('tei49c_dutec_init', port, address);
  error := optomux_var.errno;
  END;  {module procedure 'tei49c_dutec_init'}

PROCEDURE tei49c_value_get (port, address, id: Word; VAR error: INTEGER);
VAR varstr,
    cmd,
    msg: String;
    column: INTEGER;
    field1, field2, field3: String;
    v: Single;
    code: Integer;
BEGIN
  {get the response from the previous sampling period command}
  msg := '';
  dutec_in (port, address, 'P', msg);
  debuglog_output ('tei49c_value_get dutec_in ', port, address);
  IF (optomux_var.errno > 0) THEN BEGIN
    msg := '';
    state[address] := n_values;
    tei49c_dutec_init (port, address, error);
    END;
  CASE state[address] OF
    1:   column := 2;
    2:   column := 6;
    3:   column := 7;
    Else column := 999;
    END;  {case}
  field1 := getfield (msg, ' ', column);
  field2 := getfield (field1, CHR(10), 1);
  field3 := getfield (field2, '*', 1); {split 49I checksum off}
  IF (field3 = '')
    THEN v := 9991.0
    ELSE BEGIN
      Val (field3, v, code);
      IF (code <> 0) THEN v := 9992.0;
      END;
  savedata[address,state[address]] := v;
  debuglog_output_value ('tei49c_value_get values   ',
    field1, field2, field3, v);

  INC (state[address]);
  IF (state[address] > n_values) THEN state[address] := 1;

  {issue the next command}
  CASE state[address] OF
    1: varstr := 'o3';
    2: varstr := 'pres';
    3: varstr := 'bench temp';
    END;  {case}
  cmd := CHR(128+(id And $FF)) + varstr + '\13';
  dutec_out (port, address, cmd);
  debuglog_output ('tei49c_value_get dutec_out', port, address);
  IF (optomux_var.errno > 0) THEN tei49c_dutec_init (port, address, error);

  error := optomux_var.errno;
  END;  {module procedure 'tei49c_value_get'}

FUNCTION tei_read (port, address, id, varno: Word): Single;
VAR error: INTEGER;
BEGIN
  IF (varno = 1) THEN tei49c_value_get (port, address, id, error);
  tei_read := savedata[address,varno];
  error := -2;  {do nothing for now}
  END;  {exported function 'tei_read'}

{initialization of unit}

VAR address: INTEGER;

BEGIN
  FOR address := 1 TO $2F DO tei49c_data_reset (address);

  debuglog_handle := DebugLogRegister ('TEI49C');
  {of unit 'tei49c'...}
  END.
