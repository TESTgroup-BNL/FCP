Unit Backup;
{$R+} {Range checking ON}
{
Form to set/reset rings that are logically disconnected

v01.01 2003-06-07 Original based on Connect v01.03
v01.02 2003-06-08 Material moved from comlog/datlog
v01.03 2003-06-13 OnCloseForm call to OnClickButton btnCancel added
v01.04 2003-06-13 Replace OnCloseClient, OnDestroyClient by OnCloseForm
v01.05 2003-06-14 MakeChildren: fixed cbRings[FTLAST] !!! bug
v01.06 2003-06-14 Hide the new btnRefresh inherited from TTemplate
}

INTERFACE

USES
{$IFDEF LINUX}
  QForms, QGraphics, QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, Graphics, StdCtrls,
{$ENDIF}
  SysUtils,
  comp, comu,
  Template, Globals;

TYPE
  TBackup = CLASS(TTemplate)
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnClickButton (Sender: TObject);
    PROCEDURE OnClickCheckBox (Sender: TObject);
    PRIVATE
      { Private declarations }
      lblError: TLabel;
      gbRings: TGroupBox;
        cbRings: ARRAY [1..MAXRINGS] OF TCheckBox;
      gbTypes: TGroupBox;
        cbTypes: ARRAY [FT1ST..FTLAST] OF TCheckBox;
      gbProgress: TGroupBox;
        lbProgress: TListBox;
      PROCEDURE MakeChildren;
      PROCEDURE Apply;
      PROCEDURE Refresh;
    PUBLIC
      { Public declarations }
    END;

PROCEDURE Select;

IMPLEMENTATION

VAR frmBackup: TBackup;

{Remember the previously checked boxes}
SRing: ARRAY [1..MAXRINGS] OF BOOLEAN;
SType: ARRAY [FT1ST..FTLAST] OF BOOLEAN;

{-------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmBackup) THEN BEGIN
    frmBackup := TBackup.Create (Application);
    frmBackup.MakeChildren;
    END;
  frmBackup.Show;
  frmBackup.SetFocus;
  frmBackup.WindowState := wsNormal;
  frmBackup.Refresh;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE TBackup.Apply;
{Apply check box values to the working static variables}
VAR ring,
    ftyp: INTEGER;
BEGIN
  FOR ring := 1 TO numrings    DO SRing[ring] := cbRings[ring].Checked;
  FOR ftyp := FT1ST TO FTLAST  DO SType[ftyp] := cbTypes[ftyp].Checked;
  Refresh;
  END;  {of procedure 'Apply'}
{-------------------------------------------------------------}

PROCEDURE TBackup.Refresh;
{Refresh the check boxes and free disk space}
VAR ring,
    ftyp: INTEGER;
BEGIN
  IF NOT Assigned (cbRings[1])
    THEN
      Application.MessageBox ('cbRings not assigned', 'Backup/Refresh', 0)
    ELSE
      FOR ring := 1 TO numrings DO WITH cbRings[ring] DO BEGIN
        Tag := 0;
        Checked := SRing[ring];
        Tag := 1;
        IF Checked THEN Font.Color := clGreen
                   Else Font.Color := clRed;
        END;
  IF NOT Assigned (cbTypes[1])
    THEN
      Application.MessageBox ('cbRings not assigned', 'Backup/Refresh', 0)
    ELSE
      FOR ftyp := FT1ST TO FTLAST DO WITH cbTypes[ftyp] DO BEGIN
        Tag := 0;
        Checked := SType[ftyp];
        Tag := 1;
        IF Checked THEN Font.Color := clGreen
                   Else Font.Color := clRed;
        END;
  END;  {of procedure 'Refresh'}
{-------------------------------------------------------------}

PROCEDURE TBackup.MakeChildren;
VAR ring,
    ftyp: INTEGER;
BEGIN
  {Form parameters}
  With Self DO BEGIN
    Caption :=
      'Backup binary data files to secondary storage with .BAC extension';
    Width := (Screen.Width * 4) DIV 5;
    OnClose := OnCloseForm;
    END;

  {Dynamically create error label}
  IF NOT Assigned (lblError) THEN BEGIN
    lblError := TLabel.Create (Self);
    With lblError DO BEGIN
      Parent := Self;
      Font.Color := clRed;
      Font.Style := [fsBold];
      Top := 15;
      Left := 15;
      Width := Self.Width - 2 * Left;
      END;
    END;

  {Dynamically create and fill the ring group and checkboxes}
  IF NOT Assigned (gbRings) THEN BEGIN
    gbRings := TGroupBox.Create (Self);
    With gbRings DO BEGIN
      Parent := Self;
      Caption := 'Ring selection';
      Top := lblError.Top + 2 * lblError.Height;
      Left := 15;
      Width := (Screen.Width * 3) DIV 8;
      {Height set later after check boxes}
      END;
    END;

  FOR ring := 1 TO numrings DO 
    IF NOT Assigned (cbRings[ring]) THEN BEGIN
      cbRings[ring] := TCheckBox.Create (Self);
      WITH cbRings[ring] DO BEGIN
        Parent := gbRings;
        AllowGrayed := FALSE;
        Left := 15;
        Height := 20;
        Top := 15 + (ring-1) * Height + Height DIV 2;
        Width := 200;
        Caption := 'Ring ' + rlabel[ring] + '  ' + backuppath[ring];
        OnClick := OnClickCheckBox;
        Tag := 1;  {Respond to click events}
        END;  {with}
      END;  {if}
  
  gbRings.Height := cbRings[numrings].Top + cbRings[numrings].Height + 10;

  {Dynamically create and fill the file type group and checkboxes}
  IF NOT Assigned (gbTypes) THEN BEGIN
    gbTypes := TGroupBox.Create (Self);
    With gbTypes DO BEGIN
      Parent := Self;
      Caption := 'File type selection';
      Top := gbRings.Top + gbRings.Height + 20;
      Left := 15;
      Width := gbRings.Width;
      {Height set later after check boxes}
      END;
    END;

  FOR ftyp := FT1ST TO FTLAST DO 
    IF NOT Assigned (cbTypes[ftyp]) THEN BEGIN
      cbTypes[ftyp] := TCheckBox.Create (Self);
      WITH cbTypes[ftyp] DO BEGIN
        Parent := gbTypes;
        AllowGrayed := FALSE;
        Left := 15;
        Height := 20;
        Top := 15 + (ftyp-1) * Height + Height DIV 2;
        Width := gbTypes.Width - 2 * Left;
        Visible := (ftyp <> FTSTAT);  {hide STAT}
        CASE ftyp OF
          1: Caption := 'LOGG  Measurements';
          3: Caption := 'VARR  Gas flow PID';
          4: Caption := 'PARR  Algorithm settings';
          END;  {case}
        OnClick := OnClickCheckBox;
        Tag := 1;  {Respond to click events}
        END;  {with}
      END;  {if}
  
  gbTypes.Height := cbTypes[FTLAST].Top + cbTypes[FTLAST].Height + 10;

  {Dynamically create progress list box}
  IF NOT Assigned (gbProgress) THEN BEGIN
    gbProgress := TGroupBox.Create (Self);
    With gbProgress DO BEGIN
      Parent := Self;
      Caption := 'Progress';
      Top := gbRings.Top;
      Left := gbRings.Left + gbRings.Width + 20;
      Width := Self.Width - Left - 20;
      Height := gbTypes.Top + gbTypes.Height - Top;
      END;
    IF NOT Assigned (lbProgress) THEN BEGIN
      lbProgress := TListBox.Create (Self);
      With lbProgress DO BEGIN
        Parent := gbProgress;
        Top := 20;
        Left := 15;
        Width := gbProgress.Width - 2 * Left;
        Height := gbprogress.Height - 2 * Top;
        Font.Height := -14;
        END;
      END;
    END;

  {Command buttons}
  WITH btnRefresh DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  WITH btnApply DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  WITH btnHelp DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  WITH btnOK DO BEGIN
    Top   := gbTypes.Top + gbTypes.Height + 20;
    Left  := gbTypes.Left;
    Width := gbTypes.Width;
    Caption := '&Go';
    OnClick := OnClickButton;
    END;
  WITH btnCancel DO BEGIN
    Top := btnOK.Top;
    Left := Self.Width - Width - 20;
    OnClick := OnClickButton;
    END;
  
  Self.Height := btnOK.Top + btnOK.Height + 50;

  END;  {of procedure MakeChildren}
{-------------------------------------------------------------}

PROCEDURE progress_item (s: String);
{Add an item to the progress list box}
BEGIN
  WITH frmBackup.lbProgress DO BEGIN
    AddItem (s, NIL);
    ItemIndex := Count - 1;
    END;
  END;  {of procedure 'progress_item'}
{-------------------------------------------------------------}

PROCEDURE miscback (ring: INTEGER);
{Backup current miscellaneous setting records}
BEGIN
  progress_item ('Rewriting DISP');
  REWRITE (dispb[ring]);
    WRITE (dispb[ring], disprecord^[ring]);
    CloseFile (dispb[ring]);
  progress_item ('Rewriting VALV');
  REWRITE (motob[ring]);
    WRITE (motob[ring], pv_motor^[ring]);
    CloseFile (motob[ring]);
  END;  {of procedure 'miscback'}
{-------------------------------------------------------------}

PROCEDURE databack (ring: INTEGER);
{Backup LOGG, VARR, PARR files}
VAR path: String;
    action: BOOLEAN;
    left: Int64;
    lll: Longint;
    sfilsave: BOOLEAN;
BEGIN
  path := backuppath[ring];

  {Test for presence of backup medium}
  action := (bytesleft (path) > 0);
  IF NOT action THEN BEGIN
    action := FALSE;
    SysUtils.Beep;
    frmBackup.lblError.Caption := 
      'Backup drive <'+path+'> not ready. Insert write-enabled. Try again.';
    END;

  IF action THEN BEGIN

    IF action AND SType[FTLOGG] AND (recnum[ring,FTLOGG]>0) THEN BEGIN
      progress_item ('Backing LOGG...');
      {$I-}  RESET(loggb[ring]);  {$I+}
      IF (IOresult<>0) THEN REWRITE(loggb[ring]);
      left := bytesleft (path);
      progress_item (FloatToStrF(left,ffNumber,15,0)+' bytes left');
      sfilsave:=sfil[ring,FTLOGG];  
      sfil[ring,FTLOGG]:=FALSE;  
      RESET(logg[ring]);
      lll:=FileSize(logg[ring]);
      Seek(logg[ring],lll-1);
      READ(logg[ring],loggrecord[ring]);
      WITH loggrecord[ring] DO BEGIN
        IF bback1<lll THEN BEGIN
          {$I-}  RESET(loggb[ring]);  {$I+}
          IF (IOresult<>0) THEN REWRITE(loggb[ring]);
          Seek(loggb[ring],FileSize(loggb[ring]));
          Seek(logg[ring],bback1);
          REPEAT
            tinter;
            READ(logg[ring],loggrecord[ring]);
            WRITE(loggb[ring],loggrecord[ring]);
            left:=left-SizeOf(logrec);
            UNTIL EOF(logg[ring]) or (left<SizeOf(logrec));
          CloseFile (loggb[ring]);
          lll:=FilePos(logg[ring]);
          bback1:=lll; back1[ring]:=lll;
          Seek(logg[ring],lll-1);
          WRITE(logg[ring],loggrecord[ring]);
          END;
        END;
      CloseFile (logg[ring]);  
      sfil[ring,FTLOGG]:=sfilsave;
      IF left<SizeOf(logrec)
        THEN BEGIN
          frmBackup.lblError.Caption := 
            'Disk full.  Backup not complete.  Restart with a new disk.';
          action := FALSE;
          END
        ELSE progress_item ('...backup complete');
      END;

    IF action AND SType[FTVARR] AND (recnum[ring,FTVARR]>0) THEN BEGIN
      progress_item ('Backing VARR...');
      {$I-}  RESET(varrb[ring]);  {$I+}
      IF (IOresult<>0) THEN REWRITE(varrb[ring]);
      left := bytesleft(path);
      progress_item (FloatToStrF(left,ffNumber,15,0)+' bytes left');
      sfilsave:=sfil[ring,FTVARR];  
      sfil[ring,FTVARR]:=FALSE;  
      RESET(varr[ring]);
      lll:=FileSize(varr[ring]);
      Seek(varr[ring],lll-1);
      READ(varr[ring],varrecord[ring]);
      WITH varrecord[ring] DO BEGIN
        IF bback3<lll THEN BEGIN
          {$I-}  RESET(varrb[ring]);  {$I+}
          IF (IOresult<>0) THEN REWRITE(varrb[ring]);
          Seek(varrb[ring],FileSize(varrb[ring]));
          Seek(varr[ring],bback3);
          REPEAT
            tinter;
            READ(varr[ring],varrecord[ring]);
            WRITE(varrb[ring],varrecord[ring]);
            left:=left-SizeOf(varrec);
            UNTIL EOF(varr[ring]) or (left<SizeOf(varrec));
          CloseFile (varrb[ring]);
          lll:=FilePos(varr[ring]);
          bback3:=lll; back3[ring]:=lll;
          Seek(varr[ring],lll-1);
          WRITE(varr[ring],varrecord[ring]);
          END;
        END;
      CloseFile (varr[ring]); 
      sfil[ring,FTVARR]:=sfilsave;
      IF left<SizeOf(varrec)
        THEN BEGIN
          frmBackup.lblError.Caption := 
            'Disk full.  Backup not complete.  Restart with a new disk.';
          action := FALSE;
          END
        ELSE progress_item ('...backup complete');
      END;

    IF action AND SType[FTPARR] AND (recnum[ring,FTPARR]>0) THEN BEGIN
      progress_item ('Backing PARR...');
      {$I-}  RESET(parrb[ring]);  {$I+}
      IF (IOresult<>0) THEN REWRITE(parrb[ring]);
      left := bytesleft(path);
      progress_item (FloatToStrF(left,ffNumber,15,0)+' bytes left');
      sfilsave:=sfil[ring,FTPARR];  
      sfil[ring,FTPARR]:=FALSE;  
      RESET(parr[ring]);
      lll:=FileSize(parr[ring]);
      Seek(parr[ring],lll-1);
      READ(parr[ring],parrecord[ring]);
      WITH parrecord[ring] DO BEGIN
        IF bback4<lll THEN BEGIN
          {$I-}  RESET(parrb[ring]);  {$I+}
          IF (IOresult<>0) THEN REWRITE(parrb[ring]);
          Seek(parrb[ring],FileSize(parrb[ring]));
          Seek(parr[ring],bback4);
          REPEAT
            tinter;
            READ(parr[ring],parrecord[ring]);
            WRITE(parrb[ring],parrecord[ring]);
            left:=left-SizeOf(parrec);
            UNTIL EOF(parr[ring]) or (left<SizeOf(parrec));
          CloseFile (parrb[ring]);
          lll:=FilePos(parr[ring]);
          bback4:=lll; back4[ring]:=lll;
          Seek(parr[ring],lll-1);
          WRITE(parr[ring],parrecord[ring]);
          END;
        END;
      CloseFile (parr[ring]);  sfil[ring,FTPARR]:=sfilsave;
      IF left<SizeOf(parrec)
        THEN BEGIN
          frmBackup.lblError.Caption := 
            'Disk full.  Backup not complete.  Restart with a new disk.';
          action := FALSE;
          END
        ELSE progress_item ('...backup complete');
      END;

    miscback (ring);  {line graph & proportional valve parameter files}
    progress_item (FloatToStrF(left,ffNumber,15,0)+' bytes left');
    END;  {of if action true}
  END;  {of procedure 'databack'}
{-------------------------------------------------------------}

PROCEDURE TBackup.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
BEGIN
  OnClickButton (TObject(btnCancel));
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TBackup.OnClickButton (Sender: TObject);
VAR ring: INTEGER;
BEGIN

  IF (Sender = btnOK) THEN BEGIN  {which is now the Go button}
    lbProgress.Clear;
    FOR ring := 1 TO numrings DO BEGIN
      IF SRing[ring] THEN BEGIN
        progress_item ('RING '+rlabel[ring]);
        databack (ring);  {LOGG, VARR, PARR files}
        END;  {ring is checked}
      END; {loop over rings}
    progress_item ('--------------------------');
    END;  {go button}

  IF (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmBackup := NIL;
    END;
  
  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

PROCEDURE TBackup.OnClickCheckBox (Sender: TObject);
BEGIN
  IF (TCheckBox(Sender).Tag <> 0) THEN Apply;
  END;  {of procedure OnClickCheckBox}
{-------------------------------------------------------------}

INITIALIZATION

BEGIN
  END;

FINALIZATION

BEGIN
  END;

{of unit Backup...} END.
