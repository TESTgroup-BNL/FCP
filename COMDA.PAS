Unit comda;
{$R+}
{$H-}

{*
 * Name:     COMDAyy.PAS
 *
 * Purpose:  BNL FACE Project
 *           On-line data acquisition, control, and monitoring
 *           Declarations used in COMDISyy.PAS graphs
 *
 * Version:     1
 * Date:        04-04-90
 * Programmer:  Z. Kolber
 * Language:    TurboPascal 5.0
 * Hardware:    Dell 310 20Mhz 80386 AT
 * O/S:         MS-DOS 3.3
 * Changes:
 *   (1) As developed to this point by Z. Kolber
 *
 * Version:     2
 * Date:        04-19-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) TYPE Single (IEEE 4-byte representation) used
 *       rather than REAL (TP 6-byte representation)
 *
 * Version:     3
 * Date:        11-15-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Define CONST 'raysize'.
 *
 * Version:     4
 * Date:        02-26-92
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Add 'sd13' and 'sd14' for compatibility with DAT program.
 *
 * Version:     5
 * Date:        11-25-92
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Make ssdate String[8] and ssdir INTEGER to match 1992 LOGG record.
 *
 * Version:     6
 * Date:        12-10-93
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin use as COMDA94.  Apparently never noted change to 93!
 *
 * Version:     7
 * Date:        03-14-94
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Change sdir to array of real types.
 *
 * Version:     8
 * Date:        02-21-95
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes COMDA95.PAS
 *
 * Version:     9
 * Date:        10-14-95
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes COMDA96.PAS
 *
 * Version:     10
 * Date:        12-22-96
 * Changes:
 *   (1) Becomes COMDA97.PAS
 *
 * Version:     11
 * Date:        12-23-97
 * Changes:
 *   (1) Becomes COMDA98.PAS
 *
 * Version:     12
 * Date:        11-15-99
 * Changes:
 *   (1) Add sd15.  Intention is to use sd14 for water vapor
 *       pressure and sd15 for wind direction -90 to 450 graphing.
 *
 * Version:     13
 * Date:        Dec 1999 - 31 Dec 2000
 * Changes:
 *   (1) Becomes COMDA99.PAS  12-13-99
 *   (2) $H- directive added  02-14-00
 *
 * Version:     14
 * Date:        2001
 * Changes:
 *   (1) ssdate: change from String[8] to String[10]
 *   (2) Move the comment after END. to suppress compile warning  2001-10-03
 *
 * Version:     15
 * Date:        2002
 * Changes:
 *   (1) Unit renamed comda                                      [2002-03-21]
 *   (2) Remove $IFDEF DELPHI and $ENDIF                         [2002-03-24]
 *   (3) Add and initialize vars cursor_save_1 & _2              [2002-03-27]
 *}

Interface

CONST raysize = 200;

TYPE ray     = ARRAY[1..raysize] OF Single;
     ssdate  = ARRAY[1..raysize] OF String[10];
     sstime  = ARRAY[1..raysize] OF String[8];
     rayptr  = ^ray;
     dateptr = ^ssdate;
     timeptr = ^sstime;

VAR  sd1,  sd2,  sd3,  sd4,  sd5,  sd6,  sd7,  sd8,  sd9, sd10,
    sd11, sd12, sd13, sd14, sd15, sd16: rayptr;
     sdate: dateptr;
     stime: timeptr;
     sdir:  rayptr;

VAR cursor_save_1,
    cursor_save_2: Longint;  {used by zoom feature}

Implementation

BEGIN
  cursor_save_1 := 1;
  cursor_save_2 := 2;

{of unit COMDA.PAS ...}
END.
