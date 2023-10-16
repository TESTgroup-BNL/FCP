unit CalLi840;
{$R+}

{
  v1.0  2012-09-19  For inclusion as a FCP unit
  v2.0  2012-09-21  Select/Create: change parent from frmCalibMan
                      to Application so that this unit can be used
                      in a stand-alone project independent of FCP or
                      CalibMan.  But now when CalibMan page closed,
                      CalLi840 page will not close automatically.
                    Implementation/Uses: remove CalibMan
                    Add S/N and factory calibration date edit box to be filled
                      in using <POLY><DATE> in GetSN procedure.
  v3.0  2012-09-22  Use an XML unit to decode <POLY>? response
                    Add Implementaion Uses NativeXML
                    Must also have in direcctory general DCUs and a .inc
                    GetSN: Use XML instead of Pos, Copy, etc.
  v3.1  2012-09-24  GetSN: Correct typo (missing brackets around LI820&LI840)

  *** change version number and date in immediately below ***
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

const version = 'CalLi840.pas  version 3.1  2012-09-24';

type
  TCalLi840Form = class(TForm)
    gbIRGA: TGroupBox;
    rb820: TRadioButton;
    rb840: TRadioButton;
	  rb850: TRadioButton;
    cbWhich: TComboBox;
    lblPlot: TLabel;
    lblWhich: TLabel;
    editVPI: TEdit;
    lblVPI: TLabel;
    editCO2Span: TEdit;
    lblCO2Span: TLabel;
    editCO2Span2: TEdit;
    lblCO2Span2: TLabel;
    editH2OSpan: TEdit;
    lblDewpointSpan: TLabel;
    btnCO2Zero: TButton;
    btnCO2Span: TButton;
    btnCO2Span2: TButton;
    btnH2OZero: TButton;
    btnH2OSpan: TButton;
    btnDump: TButton;
    lblDump: TLabel;
    chkAutoDump: TCheckBox;
    memoComm: TMemo;
    btnClear: TButton;
    btnExit: TButton;
    btnGetData: TButton;
    chkLogging: TCheckBox;
    lblSN: TLabel;
    editSN: TEdit;
    procedure OnClickButton(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CalLi840Form: TCalLi840Form;

PROCEDURE Select (r: String);

implementation

uses DataComm, NativeXML;

{$R *.dfm}

const term = CHR(10);

var ringlabel:  String;
    func:       String;
    snfull,
    sn:         String;
    vp:         INTEGER;
    XMLbegin,
    XMLend:     String;
    spanCO2,
    span2CO2,
    spanH2O:    String;
    dateISO,
    timeISO:    String;
    dt_element: String;
    verb,
    command,
    response:   String;

{--------------------------------------------------------}

PROCEDURE Select (r: String);
{Come here when button pushed on CalibMan form}
BEGIN
  IF NOT Assigned (CalLi840Form)
    THEN CalLi840Form := TCalLi840Form.Create (Application);
  ringlabel := r;
  CalLi840Form.lblPlot.Caption := 'Plot ' + ringlabel;
  CalLi840Form.Show;
  CalLi840Form.SetFocus;
  CalLi840Form.WindowState := wsNormal;
  CalLi840Form.Caption := version;
  END;  {of procedure 'Select'}

{--------------------------------------------------------}

procedure GetSN;
var fSuccess: BOOLEAN;
    ADoc:  TNativeXML;
    ANode: TXMLNode;
    node:  String;
begin
  command := XMLbegin + '<POLY>?</POLY>' + XMLend;
  fSuccess := DataComm.PortSend (vp, command + term);
  IF NOT fSuccess
    THEN DataComm.PortErrorWindow (vp, 'GetSN/PortSend')
    ELSE BEGIN
      Windows.Sleep (100);
      fSuccess := DataComm.PortRecv (vp, response, term);
      IF NOT fSuccess
        THEN DataComm.PortErrorWindow (vp, 'GetSN/PortRecv')
        ELSE BEGIN
          ADoc  := TNativeXml.Create (CalLi840Form);
          ANode := TXMLNode.Create;
          try
            ADoc.ReadFromString (response);
            ADoc.XmlFormat := xfReadable;
            IF (XMLBegin = '<LI820>') THEN node := '/LI820/POLY/DATE';
            IF (XMLBegin = '<LI840>') THEN node := '/LI840/POLY/DATE';
			      IF (XMLBegin = '<LI850>') THEN node := '/LI850/POLY/DATE';
            ANode := ADoc.Root.FindNode (node);
            IF (ANode <> NIL)
              THEN CalLi840Form.editSN.Text := ANode.Value
              ELSE CalLi840Form.memoComm.Lines.Add
                ('GetSN: ' + node + ' node not found');
          finally
           {ANode.Free;}
            ADoc.Free;
          end; {of try..finally}
          END;
      END;
  end;  {of GetSN}
{--------------------------------------------------------}

procedure logging (command, response: String);
const filenamebase = 'C:\CalLi840\CalLi840';
const filenameext  = '.log';
var filename: String;
    handle:   TEXT;
    ior:      INTEGER;
begin
  {$I-}
  filename := filenamebase + '_' + sn + filenameext;
  AssignFile (handle, filename);
  RESET (handle);
  ior := IOResult;
  IF (ior <> 0)
    THEN BEGIN
      REWRITE (handle);
      IF (IOResult <> 0) THEN CalLi840Form.memoComm.Lines.Add
        ('Can not create ' + filename + '. Path probably invalid.');
      END;
  CloseFile (handle);

  IF (ior = 0) THEN BEGIN
    APPEND (handle);
    WRITELN (handle, 'Plot ' + ringlabel + '  ' + func + '  ' +
      'S/N ' + snfull + '  ' + dateISO + ' ' + timeISO);
    WRITELN (handle, 'COMMAND: ', command);
    WRITELN (handle, 'RESPONSE: ', response);
    CloseFile (handle);
    END;
  {$I+}
  end;  {of procedure logging}

{--------------------------------------------------------}

procedure talk (vp: INTEGER; verb: String; VAR response: String; sleepms: INTEGER);
var fSuccess: BOOLEAN;
begin
  command := XMLbegin + verb + XMLend;
  fSuccess := DataComm.PortSend (vp, command + term);
  IF NOT fSuccess
    THEN DataComm.PortErrorWindow (vp, 'PortSend')
    ELSE BEGIN
      IF (sleepms > 0) THEN BEGIN
        CalLi840Form.memoComm.Lines.Add
          ('Waiting ' + IntToStr(sleepms) + ' ms ...');
        Windows.Sleep(sleepms);
        END;
      fSuccess := DataComm.PortRecv (vp, response, term);
      IF NOT fSuccess
        THEN DataComm.PortErrorWindow (vp, 'PortRecv')
        ELSE BEGIN
          CalLi840Form.memoComm.Lines.Add (response);
          IF CalLi840Form.chkLogging.Checked THEN logging (command, response);
          END;
      END;
  end;  {of procedure talk}

{--------------------------------------------------------}

procedure TCalLi840Form.OnClickButton(Sender: TObject);
const sleeptime_long  = 10000;  {"calibration can take several seconds"}
      sleeptime_short =  1000;
var answer: INTEGER;
begin

WITH CalLi840Form DO BEGIN

{Get parameters}

func := cbWhich.Text;
vp := StrToInt(editVPI.Text);
IF rb820.Checked THEN BEGIN XMLbegin := '<LI820>'; XMLend := '</LI820>'; END;
IF rb840.Checked THEN BEGIN XMLbegin := '<LI840>'; XMLend := '</LI840>'; END;
IF rb850.Checked THEN BEGIN XMLbegin := '<LI850>'; XMLend := '</LI850>'; END;
spanCO2    := editCO2Span.Text;
span2CO2   := editCO2Span2.Text;
spanH2O    := editH2OSpan.Text;
dateISO    := FormatDateTime ('yyyy-mm-dd', Now);
timeISO    := FormatDateTime ('hh:nn:ss', Now);
dt_element := dateISO + ' ' + timeISO;

{Get the serial number each time a calibration button pressed}

IF (Sender <> btnClear) AND (Sender <> btnExit) THEN BEGIN
GetSN;
snfull := editSN.Text;
sn := Trim (Copy (snfull, 1, Pos(' ',snfull)-1));
END;

{Process button pushes}

IF Sender = btnDump THEN BEGIN
  verb := '<CAL>?</CAL>';
  talk (vp, verb, response, sleeptime_short);
  verb := '<POLY>?</POLY>';
  talk (vp, verb, response, sleeptime_short);
  END;  {btnDump}

IF Sender = btnCO2Zero THEN BEGIN
  answer := Application.MessageBox (
    'Do you really want to CO2 ZERO?', 'btnCO2Zero', MB_YESNO);
  IF (answer = ID_YES) THEN BEGIN
    OnClickButton (btnGetData);
    IF chkAutoDump.Checked THEN OnClickButton (btnDump);
    verb := '<CAL><DATE>' + dt_element + '</DATE>' +
            '<CO2ZERO>TRUE</CO2ZERO>' + '</CAL>';
    talk (vp, verb, response, sleeptime_long);
    IF chkAutoDump.Checked THEN OnClickButton (btnDump);
    OnClickButton (btnGetData);
    END;
  END;  {btnCO2Zero}

IF Sender = btnCO2Span THEN BEGIN
  answer := Application.MessageBox (
    'Do you really want to CO2 SPAN?', 'btnCO2Span', MB_YESNO);
  IF (answer = ID_YES) THEN BEGIN
    OnClickButton (btnGetData);
    IF chkAutoDump.Checked THEN OnClickButton (btnDump);
    verb := '<CAL><DATE>' + dt_element + '</DATE>' +
            '<CO2SPAN>' + spanCO2 + '</CO2SPAN>' + '</CAL>';
    talk (vp, verb, response, sleeptime_long);
    IF chkAutoDump.Checked THEN OnClickButton (btnDump);
    OnClickButton (btnGetData);
    END;
  END;  {btnCO2Span}

IF Sender = btnCO2Span2 THEN BEGIN
  answer := Application.MessageBox (
    'Do you really want to CO2 SPAN SECONDARY?', 'btnCO2Span2', MB_YESNO);
  IF (answer = ID_YES) THEN BEGIN
    OnClickButton (btnGetData);
    IF chkAutoDump.Checked THEN OnClickButton (btnDump);
    verb := '<CAL><DATE>' + dt_element + '</DATE>' +
            '<CO2SPAN2>' + span2CO2 + '</CO2SPAN2>' + '</CAL>';
    talk (vp, verb, response, sleeptime_long);
    IF chkAutoDump.Checked THEN OnClickButton (btnDump);
    OnClickButton (btnGetData);
    END;
  END;  {btnCO2Span2}

IF Sender = btnH2OZero THEN BEGIN
  answer := Application.MessageBox (
    'Do you really want to H2O ZERO?', 'btnH2OZero', MB_YESNO);
  IF (answer = ID_YES) THEN BEGIN
    OnClickButton (btnGetData);
    IF chkAutoDump.Checked THEN OnClickButton (btnDump);
    verb := '<CAL><DATE>' + dt_element + '</DATE>' +
            '<H2OZERO>TRUE</H2OZERO>' + '</CAL>';
    talk (vp, verb, response, sleeptime_long);
    IF chkAutoDump.Checked THEN OnClickButton (btnDump);
    OnClickButton (btnGetData);
    END;
  END;  {btnH2OZero}

IF Sender = btnH2OSpan THEN BEGIN
  answer := Application.MessageBox (
    'Do you really want to H2O SPAN?', 'btnH2OSpan', MB_YESNO);
  IF (answer = ID_YES) THEN BEGIN
    OnClickButton (btnGetData);
    IF chkAutoDump.Checked THEN OnClickButton (btnDump);
    verb := '<CAL><DATE>' + dt_element + '</DATE>' +
            '<H2OSPAN>' + spanH2O + '</H2OSPAN>' + '</CAL>';
    talk (vp, verb, response, sleeptime_long);
    IF chkAutoDump.Checked THEN OnClickButton (btnDump);
    OnClickButton (btnGetData);
    END;
  END;  {btnH2OSpan}

IF Sender = btnGetData THEN BEGIN
  verb := '<DATA>?</DATA>';
  talk (vp, verb, response, sleeptime_short);
  END;  {btnGetData}

IF Sender = btnClear THEN memoComm.Clear;

IF Sender = btnExit THEN Hide;

end;  {with}
end;  {procedure btnClick}

{of unit CalLi840...}
end.
