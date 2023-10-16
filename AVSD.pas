Unit AVSD;
{$N+}  {Use 80x87 coprocessor}
{$R+}  {Do range checking}
{$D+}
{$L+}
{
  Purpose:  Average and standard deviation package

  Usage:    Uses AVSD;  (in calling program source file)

  Author:   John Nagy

  Version:

  1.0  2006-04-30  AVSD sections copied from tp5utils v5.1 2003-06-01

}

Interface

{$IFDEF TURBO}
Uses Crt, Dos;
{$ENDIF}

{$IFDEF DELPHI}
{$H-}
Uses crt32, SysUtils;
{$ENDIF}

CONST outp_n    = 1;  {used externally for bit-mapped}
      outp_mean = 2;  {selection of variables-to-print}
      outp_sd   = 4;  {as an argument to 'stat_outp'}
      outp_se   = 8;  {and 'avsd_outp'}
      outp_var  = 16;
      outp_skew = 32;
      outp_kurt = 64;
      outp_min  = 128;
      outp_max  = 256;
      outp_rang = 512;


TYPE  avsd_rec = RECORD         {used by avsd_???? package}
                   n: Longint;  {number of data points}
                   mean,        {average}
                   stddev,      {standard deviation}
                   sw,          {sum of weights}
                   swx,         {sum of weighted data points}
                   swxx: REAL;  {sum of weighted squares}
                   END;

PROCEDURE avsd_init (VAR a: avsd_rec);
PROCEDURE avsd_proc (VAR a: avsd_rec; x,w: REAL);
PROCEDURE avsd_calc (VAR a: avsd_rec);
PROCEDURE avsd_outp (VAR a: avsd_rec; VAR f: TEXT; w,d,select: INTEGER);
PROCEDURE avsd_debg (VAR a: avsd_rec; VAR f: TEXT);

Implementation

{------------------------------------------------------------}

{This section is a package of procedures to do simpler
 statistics. The global record type 'avsd_rec' defined
 above is used.  The global constants 'outp_????' may
 be used to increase readability in main program.

   avsd_init  initializes a var of type avsd_rec
   avsd_proc  adds another data point to the accumulation
   avsd_calc  calculates average and standard deviation of
              data points accumulated so far
   avsd_outp  outputs variables selected to a text file
   avsd_debg  dumps intermediate variables to a text file
}

PROCEDURE avsd_init (VAR a: avsd_rec);
{initialize a simple statistics record}
BEGIN
  WITH a DO BEGIN
    n      := 0;
    mean   := 0.0;
    stddev := 0.0;
    sw     := 0.0;
    swx    := 0.0;
    swxx   := 0.0;
    END;
  END;  {of procedure 'avsd_init'}

PROCEDURE avsd_proc (VAR a: avsd_rec; x,w: REAL);
{process data point 'x' using weight 'w'}
VAR x2: REAL;
BEGIN
  WITH a DO BEGIN
    x2 := x*x;
    n  := n+1;
    sw     := sw    +w;
    swx    := swx   +w*x;
    swxx   := swxx  +w*x2;
    END;
  END;  {of procedure 'avsd_proc'}

PROCEDURE avsd_calc (VAR a: avsd_rec);
{Calculate average and standard deviation of points
 accumulated.  Source: SPSS}
VAR variance: REAL;
BEGIN
  WITH a DO IF sw>0.0 THEN BEGIN
    IF n>0 THEN mean := swx/sw;
    IF n>1 THEN BEGIN
     variance := (swxx-swx*swx/sw)/sw*n/(n-1);
     IF variance >= 0.0
       THEN stddev := SQRT(variance)
       ELSE stddev := -1.0;
     END;
    END;  {of WITH}
  END;  {of procedure 'avsd_calc'}

PROCEDURE avsd_outp (VAR a: avsd_rec; VAR f: TEXT; w,d,select: INTEGER);
{Put out results to file 'f' using 'w' field width
 and 'd' decimal points (d=-1 --> exponential format).
 Note that no <CR><LF>s are issued.  'select' is a bit-
 mapped variable which determines what variables are
 printed.}
VAR n_on, mean_on, sd_on: BOOLEAN;
BEGIN
  n_on     := ODD(select DIV outp_n);
  mean_on  := ODD(select DIV outp_mean);
  sd_on    := ODD(select DIV outp_sd);
  WITH a DO BEGIN
    IF n_on THEN WRITE (f,n:6);
    IF d<0
      THEN BEGIN
        IF mean_on  THEN WRITE (f,' ',mean    :w);
        IF sd_on    THEN WRITE (f,' ',stddev  :w);
        END
      ELSE BEGIN
        IF mean_on  THEN WRITE (f,' ',mean    :w:d);
        IF sd_on    THEN WRITE (f,' ',stddev  :w:d);
        END;
    END;
  END;  {of procedure 'avsd_outp'}

PROCEDURE avsd_debg (VAR a: avsd_rec; VAR f: TEXT);
{dump intermediate variables of a avsd_rec type var
 to text file 'f'}
BEGIN
  WITH a DO BEGIN
    WRITE (f,n);
    WRITE (f,sw);
    WRITE (f,swx);
    WRITE (f,swxx);
    WRITELN;
    END;
  END;  {of procedure 'avsd_debg'}
{------------------------------------------------------------}

BEGIN
{of unit AVSD...}
END.
