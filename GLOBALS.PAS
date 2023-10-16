Unit Globals;
{
Constants, types, and variables global to FCP application

v01.01 2003-05-28 Original. Begin moving stuff from comd.
v01.02 2003-06-08 FTLOGG, etc. symbolic constants.
v01.03 2003-06-08 Move logg .. motob arrays here from comd.
v01.04 2003-06-08 Move loggrecord .. disprecord also.
v01.05 2003-06-08 Move types pittman and pv_motor_ray also.
v01.06 2003-06-08 Move type daqc_addr also.
v01.07 2003-06-08 Now must Uses faced.
v01.08 2003-06-08 Move back?, recnum[,] here from comd.
v02.00 2006-09-22 Add USES SysUtils
                  Add searchrec_exe, _cfg, and _def.
v03.00 2009-08-15 Add virtual port macros for devices (PORT_*)
v03.01 2011-10-17 Add _GA=27, _WIND=28 virtual port macros to PORT_ list
v03.02 2011-12-01 Add _LOGGER_1, _2, _3 = 41, 42, 43
v03.03 2012-07-30 Add _FCPLINK_1 to _FCPLINK_6 = 31..36
v03.04 2012-08-22 Change _FCPLINK_1 to _FCPLINK_6  to _BASE = 30
v03.05 2012-08-22 Change PORT_LOGGER_1 = 41 to PORT_LOGGER_BASE = 40
}

INTERFACE

USES SysUtils, faced;

CONST

  {mathematical and physical constants}
  pi       = 3.141592654;
  abs_zero = -273.15;        {oC}
  atm_si   = 101325.0;       {Pa}
  atm_mmHg = 760.0;          {mm mercury}
  atm_inHg = 29.92;          {inches mercury}
  r_si     = 8.31441;        {1/m*K (LWCVI toolkit)}
  mw_co2   = 44.01;          {g/mol}

  MAXRINGS = 15;  {maximum number of rings supported by compilation}

  MAXVALVS = 32;  {maximum valves per ring -- make divisible by 16}

  FTLOGG = 1;  {data file types}
  FTSTAT = 2;  {haven't killed it completely yet!}
  FTVARR = 3;
  FTPARR = 4;
  FT1ST  = FTLOGG;
  FTLAST = FTPARR;

  {Index of devices in the port record array of DataComm}

  PORT_RINGS         = 1;
  PORT_EMB_MP        = 21;
  PORT_GAS_SUPPLY    = 22;
  PORT_MODEM         = 23;
  PORT_TIMESERV      = 24;
  PORT_WATCHDOG      = 25;
  PORT_MPLINK        = 26;
  PORT_GA            = 27;
  PORT_WIND          = 28;
  PORT_FCPLINK_BASE  = 30;
  PORT_LOGGER_BASE   = 40;
  PORT_WASTE_BIN     = 64;

TYPE

  logrec        = logrec99;  {see unit 'faced.pas'}
  varrec        = varrec99;
  parrec        = parrec99;
  displayrecord = displrec32;

  daqc_addr = RECORD  {data acquisition system address/channel and eng. conv.}
    exists: BOOLEAN;
    bdtype: SmallInt;                      {0-->D, 1-->A}
    address, channel: Word;                {NOTE: cf. daqc_port}
    invert: BOOLEAN;                       {for Digital}
    range, gain, offset, offscale: Single; {for Analog}
    unit_name, label_name: String[16];
    END;

  pittman = RECORD
              date_last_access,
              time_last_access: String[8];
              mode:          SmallInt;      {1 of 3}
              screen_active: BOOLEAN;       {will be in Utility Menu}
              first_relay:   daqc_addr;     {of 2 sequential needed}
              kp,                           {process gain}
              f,                            {aggressiveness factor}
              tolerance,                    {fraction of full scale flow}
              learning_period,  {sec}       {these 4 vars used to learn gain}
              old_response,
              int_change,
              int_dt,
              old_dt,                       {signed sec}
              tmin,                         {milliseconds}
              tmax,
              tbacklash,
              tcalc,                        {correction / kp}
              tstep,                        {f * tcalc}
              tlimit,                       {tstep subject to tmax}
              tstep_manual,
              cont_use,                     {these 2 needed for special modes}
              resp_use,
              correction:     Single;       {control - response}
              cont_history:   ARRAY [-1..+1] of Single;
              direction,
              last_direction: SmallInt;     {+ or -}
              digitime:       Word;         {dacq equivalent of tlimit}
              blflag:         BOOLEAN;      {have changed direction}
              flow_meter: RECORD
                code: Byte;                 {0: linear, 1: Kurz nonlinear}
                serial_no,                  {serial number}
                calib_date: String[8];      {calibration date}
                t_ref,                      {Kurz std. temperature}
                p_ref,                      {Kurz std. pressure}
                r_ref,                      {Kurz std. resistor}
                r_face,                     {FACE ring sensing resistor}
                pipe_id: Single;            {flow meter pipe inner diameter}
                t_unit,                     {Kurz std. temperature unit}
                p_unit,                     {Kurz std. pressure unit}
                v_unit,                     {Kurz calibration velocity unit}
                pipe_type: Byte;            {pipe type code}
                velocity_calib,             {Kurz calibration velocities}
                velocity_si,                {converted to S.I.}
                volume,                     {S.I. volume flow rate}
                mass_flow,                  {mass flow rate}
                csrvdc_calib,               {Kurz current sensing voltage}
                csrvdc_face,                {FACE current sensing voltage}
                ln_vz,                          {ln of csrvdc_face}
                ln_mf: ARRAY [1..12] OF Single; {ln of mass_flow}
                errvalue: Single;           {flow returned if V out of range}
                add_to,                     {possible correction of input V}
                multiply_by: Single;
                END;
             END;
  pv_motor_ray = ARRAY [1..MAXRINGS] OF pittman;

VAR
  {For control of proportional valve motor by COM directly}
  pv_motor: ^pv_motor_ray;

VAR

  {variables for or in FACE configuration file}
  cfgname: String;
  site_id: String[3];     {site identification}
  site_lat,               {site latitude, degrees, + North}
  site_lon,               {site longitude, degrees, + East}
  site_alt,               {site altitude, meters}
  site_zd: Single;        {site zone descriptor, hours, e.g. EST = -5.0}
  site_tz: String[4];     {site timezone descriptor, e.g. EST, MESZ}
  numrings: INTEGER;      {number of rings at this site}
  numvalvs: INTEGER;      {number of vertical vent pipes per ring}
  rlabel: ARRAY [1..MAXRINGS] OF CHAR;
  rhex:   ARRAY [1..MAXRINGS] OF INTEGER;
  datapath: String;       {data logging path -- see also net_logg object}
  backuppath: 
    ARRAY [1..MAXRINGS] OF String;  {data backup path}
  descriptor: ARRAY [1..MAXRINGS] OF String[16];

  logg, loggb: ARRAY[1..MAXRINGS] OF FILE OF logrec;
  varr, varrb: ARRAY[1..MAXRINGS] OF FILE OF varrec;
  parr, parrb: ARRAY[1..MAXRINGS] OF FILE OF parrec;
  disp, dispb: ARRAY[1..MAXRINGS] OF FILE OF displayrecord;
  moto, motob: ARRAY[1..MAXRINGS] OF FILE OF pittman;

  loggrecord: ARRAY[1..MAXRINGS] OF logrec;
  varrecord:  ARRAY[1..MAXRINGS] OF varrec;
  parrecord:  ARRAY[1..MAXRINGS] OF parrec;

  recnum: ARRAY [1..MAXRINGS, FT1ST..FTLAST+1] of Longint;

  sfil: ARRAY [1..MAXRINGS, FT1ST..FTLAST] OF BOOLEAN;

  back1, back2, back3, back4: ARRAY[1..MAXRINGS] OF Longint;

TYPE  
  disprecord_type = ARRAY[1..MAXRINGS] OF displrec32;
VAR
  disprecord: ^disprecord_type;  {note now different from other ????records}

{At program startup FindFirst will be called for the executable,
 configuration, and imbedded multiport definition (if any) files.
 The file information obtained is stored in these variables for
 reference later within the program.
}
VAR searchrec_exe,
    searchrec_cfg,
    searchrec_def: TSearchRec;

IMPLEMENTATION

INITIALIZATION

BEGIN
  NEW (disprecord);
  NEW (pv_motor);
  END;

FINALIZATION

BEGIN
  END;

{of unit Globals.pas...} END.
