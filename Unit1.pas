unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, ComCtrls, ShellCtrls, Mask, sSkinManager,
  sSkinProvider, XPMan;

  
type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    Edit3: TEdit;
    Label3: TLabel;
    Button3: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    GroupBox3: TGroupBox;
    DriveComboBox1: TDriveComboBox;
    Button4: TButton;
    Button5: TButton;
    GroupBox4: TGroupBox;
    ListView1: TListView;
    GroupBox5: TGroupBox;
    Memo1: TMemo;
    ShellTreeView1: TShellTreeView;
    Edit4: TEdit;
    CheckBox3: TCheckBox;
    GroupBox6: TGroupBox;
    Edit5: TEdit;
    FileListBox1: TFileListBox;
    Label5: TLabel;
    Label6: TLabel;
    ListView2: TListView;
    sSkinManager1: TsSkinManager;
    sSkinProvider1: TsSkinProvider;
    XPManifest1: TXPManifest;
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure findword(loadfiledir:string;findword:string);
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure DriveComboBox1Change(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ListView2Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  i,l : integer;

implementation

{$R *.dfm}

function retext(a:string):string;
label rereplace;
begin
rereplace:
a := StringReplace(a, '\\', '\',[rfReplaceAll, rfIgnoreCase]);
if pos('\\',a) <> 0 then begin
goto rereplace;
end;
result := a;
end;

function ExtractFileNameEX(const AFileName:String): String;
 var
   I: integer;
 begin
    I := LastDelimiter('.'+PathDelim+DriveDelim,AFileName);
        if (I=0)  or  (AFileName[I] <> '.')
            then
                 I := MaxInt;
          Result := ExtractFileName(Copy(AFileName,1,I-1));
 end;

procedure tform1.findword(loadfiledir:string;findword:string);
var
t:TextFile ;
s:TStringlist ;
x:String ;
begin
application.ProcessMessages;
loadfiledir := retext(loadfiledir);
s:=TStringlist.Create;
AssignFile(t,loadfiledir);
{$I-} Reset(t);
while not eof(t)
do begin
Readln(t,x);
s.Add(x) ;
end;
CloseFile(t); {$I+}
memo1.Text := s.Text;
FreeAndNil(s) ;
for l := 0 to memo1.Lines.Count-1 do begin
if form1.button1.Caption = '찾기' then begin
exit;
end;
if checkbox2.Checked = false then begin
if pos(lowercase(findword),lowercase(memo1.Lines.Strings[l])) <> 0 then begin
if (listview1.Items.Count > 0) and (lowercase(listview1.Items.Item[listview1.Items.Count-1].SubItems[0]+ listview1.Items.Item[listview1.Items.count-1].caption) = lowercase(loadfiledir)) then begin
listview1.Items.Item[listview1.Items.Count-1].SubItems[1] := listview1.Items.Item[listview1.Items.Count-1].SubItems[1] +','+inttostr(l+1);
listview1.Items.Item[listview1.Items.Count-1].SubItems[2] := inttostr(strtoint(listview1.Items.Item[listview1.Items.Count-1].SubItems[2]) + 1);
end
else
with listview1.Items.Add do begin
Caption := extractfilename(loadfiledir);
subitems.Add(extractfilepath(loadfiledir));
subitems.Add(inttostr(l+1));
subitems.Add('1');
subitems.Add(extractfileext(loadfiledir));
end;
end;
end
else
if checkbox2.Checked = true then begin
if pos(findword,memo1.Lines.Strings[l]) <> 0 then begin
if (listview1.Items.Count > 0) and (listview1.Items.Item[listview1.Items.Count-1].SubItems[0]+listview1.Items.Item[listview1.Items.count-1].caption = loadfiledir) then begin
listview1.Items.Item[listview1.Items.Count-1].SubItems[1] := listview1.Items.Item[listview1.Items.Count-1].SubItems[1] +','+inttostr(l+1);
listview1.Items.Item[listview1.Items.Count-1].SubItems[2] := inttostr(strtoint(listview1.Items.Item[listview1.Items.Count-1].SubItems[2]) + 1);
end
else
with listview1.Items.Add do begin
Caption := extractfilename(loadfiledir);
subitems.Add(extractfilepath(loadfiledir));
subitems.Add(inttostr(l+1));
subitems.Add('1');
subitems.Add(extractfileext(loadfiledir));
end;
end;
end;
end;
if listview2.Items.Count = 0 then begin
with ListView2.Items.Add do begin
Caption := extractfilename(loadfiledir);
subitems.Add(extractfilepath(loadfiledir));
end;
end;
if (listview2.Items.Count > 0) and (listview2.Items.Item[listview2.Items.Count-1].SubItems[0]+listview2.Items.Item[listview2.Items.count-1].caption <> loadfiledir) then begin
with ListView2.Items.Add do begin
Caption := extractfilename(loadfiledir);
subitems.Add(extractfilepath(loadfiledir));
end;
end;
GroupBox4.Caption := '검색 결과(갯수:'+inttostr(listview1.Items.Count)+')';
end;

procedure findallfile(Dir: String;const Extensions: string);
const
  FileMask = '*.*';
 var
   SR: TSearchRec;
   path:string;
 label endsearch;
begin
 {faReadOnly:읽기전용
 faHidden:숨겨진 파일/폴더
 faSysFile:시스템파일
 faVolumeID:?
 faDirectory:폴더
 faArchive:일반파일
 faAnyFile:위에 전체 포함}
 //faVolumeID + faHidden + faReadOnly + faDirectory + faArchive
Path := IncludeTrailingBackslash(dir);
application.ProcessMessages;
dir := retext(dir);
   if (FindFirst(dir + '\'+ filemask ,  {faanyfile} faHidden + faReadOnly + faDirectory + faArchive, sr)) = 0 then
   begin
     repeat
      if form1.button1.Caption = '찾기' then begin
         exit;
          end;
       if (Sr.Name <> '.') and (Sr.Name <> '..') then
       begin
         if ((sr.Attr and faDirectory) = faDirectory ) then
         begin
           findallfile(Dir + '\' + sr.Name,ExtractFileExt(form1.FileListBox1.mask));
         end
         else
         if (sr.Attr = faArchive)  then
         if ExtractFilenameEX(sr.Name) <> '' then begin //파일이름이 안적혀있을때만 실행

         if extractfileext(form1.FileListBox1.Mask) = '.*' then begin// 조건이 없을때 *.*
         if ExtractFilenameEX(form1.FileListBox1.Mask) = '*' then begin
         form1.findword(Dir + '\' +sr.Name,form1.Edit1.text);
         end;
         end;

         if ExtractFilenameEX(form1.FileListBox1.Mask) <> '*' then begin // 이름만 조건 name.*
         if lowercase(ExtractFilenameEX(form1.FileListBox1.Mask)) = lowercase(ExtractFilenameEX(sr.Name)) then begin
         form1.findword(Dir + '\' +sr.Name,form1.Edit1.text);
         end;
         end;
         if extractfileext(sr.Name) <> '*' then begin
         if lowercase(ExtractFileExt(sr.Name)) = lowercase(Extensions) then begin
         if ExtractFilenameEX(form1.FileListBox1.Mask) <> '*' then begin // 둘다   name.name
         if lowercase(ExtractFilenameEX(form1.FileListBox1.Mask)) = lowercase(ExtractFilenameEX(sr.Name)) then begin
         form1.findword(Dir + '\' +sr.Name,form1.Edit1.text);
         end;
         end;
         end;
         end;
         if ExtractFilenameEX(form1.FileListBox1.Mask) = '*' then begin //확장자만 조건 *.name
         if extractfileext(sr.Name) <> '*' then begin
         if lowercase(ExtractFileExt(sr.Name)) = lowercase(Extensions) then begin
         form1.findword(Dir + '\' +sr.Name,form1.Edit1.text);
         end;
         end;
         end;
         form1.Edit4.text := Dir + '\' + sr.Name ;
         end;
         end;

     until FindNext(sr) <> 0;
   end;
   FindClose(sr);
 end;

procedure TForm1.Button2Click(Sender: TObject);
begin
if pos('.',edit2.text) <> 0 then begin
if (ExtractFileNameEX(form1.FileListBox1.Mask) = '') or (ExtractFileExt(edit2.text) = '.') then begin
showmessage('확장자 양식을 지켜주세요[ex)PreF.exe](현재:'+edit2.Text+')');
exit;
end;
filelistbox1.Mask := edit2.Text;
filelistbox1.Clear;
label2.Caption := '파일 확장자(현재 확장자:'+filelistbox1.Mask+')[예시1.*.exe,예시2:Programname.exe]:';
end
else
showmessage('확장자설정에 문제가 발생하였습니다.');
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
edit3.Text := ShellTreeView1.Path;
groupbox3.Visible := false;
groupbox1.Enabled := true;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
groupbox3.Visible := false;
groupbox1.Enabled := true;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
filelistbox1.Directory := edit3.text;
groupbox3.Visible := true;
groupbox1.Enabled := false;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
if (button1.Caption = '찾기') and (edit1.text <> '') then begin
filelistbox1.Directory := retext(edit3.Text+'\');
groupbox6.Enabled := false;
button1.Caption := '중지';
listview1.Clear;
listview2.clear;
if checkbox1.Checked = true then begin
findallfile(edit3.text+'\',ExtractFileExt(form1.FileListBox1.mask));
end;
if checkbox1.Checked = false then begin
for i := 0 to filelistbox1.Items.Count-1 do begin
findword(edit3.text+'\'+filelistbox1.Items.Strings[i],edit1.text);
end;
end;
end;
if button1.Caption = '중지' then begin
button1.Caption := '찾기';
groupbox6.Enabled := true;
showmessage('검색완료');
end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
DriveComboBox1.Drive := 'C';
end;

procedure TForm1.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
groupbox3.Caption := '('+ShellTreeView1.Path+')';
filelistbox1.Directory := shelltreeview1.Path + '\';
end;

procedure TForm1.DriveComboBox1Change(Sender: TObject);
begin
ShellTreeView1.Root := drivecombobox1.Drive + ':\';
end;

procedure TForm1.CheckBox3Click(Sender: TObject);
begin
if checkbox3.Checked = true then begin
ShellTreeView1.ObjectTypes := [otFolders,otHidden];
end
else
ShellTreeView1.ObjectTypes := [otFolders];
end;

procedure TForm1.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
if listview1.ItemIndex <> -1 then begin
edit5.Text := listview1.Selected.SubItems.Strings[0] + listview1.Selected.Caption;
end;
end;

procedure TForm1.ListView2Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
Label5.Caption := '검색했던 파일들('+inttostr(form1.listview2.Items.count)+')';
end;

end.

{function findallfile(SearchDir: string):Boolean; //폴더 삭제 함수 변형
var
 wfd: _WIN32_FIND_DATAA;
 hSrch: Cardinal;
 bResult: Boolean;
begin
 bResult := True;
 hSrch := FindFirstFile(PChar(SearchDir + '\*.*'), wfd);
 while bResult do
 begin
 if (string(wfd.cFileName) <> '.')
 and (string(wfd.cFileName) <> '..') then
 begin
 // 서브디렉토리 검색(재귀함수)
 if wfd.dwFileAttributes = FILE_ATTRIBUTE_DIRECTORY then
 // 폴더면 재귀호출(다시 검색)
 findallfile(SearchDir + '\' + wfd.cFileName)
 else
 // 파일이면 삭제.
 if pos('$',SearchDir + '\' + string(wfd.cFileName)) = 0 then begin
 form1.findword(SearchDir + '\' + string(wfd.cFileName),form1.Edit1.Text);
 end;
 end;
 bResult := FindNextFile(hSrch, wfd);
 end;
 Windows.FindClose(hSrch);
end;}

{procedure FileSearch(const PathName: string; const Extensions: string;
 var lstFiles: TStringList);
const
  FileMask = '*.*';
var
  Rec: TSearchRec;
  Path: string;
begin
  Path := IncludeTrailingBackslash(PathName);
  if FindFirst(Path + FileMask, faAnyFile - faDirectory, Rec) = 0 then
    try
      repeat
        if AnsiPos(ExtractFileExt(Rec.Name), Extensions) > 0 then
          lstFiles.Add(Path + Rec.Name);
      until FindNext(Rec) <> 0;
    finally
      SysUtils.FindClose(Rec);
    end;

  if FindFirst(Path + '*.*', faDirectory, Rec) = 0 then
    try
      repeat
        if ((Rec.Attr and faDirectory) <> 0) and (Rec.Name <> '.') and
          (Rec.Name <> '..') then
          FileSearch(Path + Rec.Name, Extensions, lstFiles);
      until FindNext(Rec) <> 0;
    finally
      FindClose(Rec);
    end;
end;

FileSearch('C:\Temp', '.txt;.tmp;.exe;.doc', FileList);}

