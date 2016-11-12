Program MakeM3u;

Uses Crt, SysUtils, StrUtils;

Function DirectoryLevel (Path: String): Integer;
Var Result: Integer;
Begin
 Result:=0;
 While Pos (DirectorySeparator, Path)>0 do
 Begin
  Inc (Result);
  Delete (Path, 1, Pos (DirectorySeparator, Path));
 End;
 DirectoryLevel:=Result;
End;

Function M3uFileName (Path: String; Depth: Byte): String;
Var PathString: String;
Begin
 PathString:=Copy (Path, 1, LastDelimiter (DirectorySeparator, Path)-1);
 If DirectoryLevel (PathString)<Depth Then M3uFileName:= 'Error.m3u' Else
 Begin
  M3uFileName:= AnsiReplaceStr (ReverseString(Copy (ReverseString (PathString), 1, NPos (DirectorySeparator, ReverseString (PathString), Depth)-1)) + '.m3u',DirectorySeparator,' - ');
 End;
End;

Procedure WriteM3u (M3u, Entry: string);
Var M3uFile:Text;
Begin
 If FileExists (M3u) Then
 Begin
  Assign (M3uFile, M3u);
  Append (M3uFile);
  Writeln (M3uFile, Entry);
  Close (M3uFile);
  Writeln ('create: ', M3u);
  Writeln ('append: ', Entry);
 End
 Else Begin
       Assign (M3uFile, M3u);
       ReWrite (M3uFile);
       Writeln (M3uFile, Entry);
       Close (M3uFile);
       Writeln ('open:  ', M3u);
       Writeln ('write: ', Entry);
      End;
End;

Procedure CleanM3uDirectory (Path: string);
Var Found: Integer;
    SearchResult: TSearchRec;
Begin
 Found := FindFirst(Path+DirectorySeparator+'*.m3u', faAnyFile, SearchResult);
 While Found = 0 Do
 Begin
  If (SearchResult.Attr And faDirectory = 0) Then
   DeleteFile (Path+DirectorySeparator+SearchResult.Name);
  Found := FindNext(SearchResult);
 End;
End;

Procedure GetFiles (Path: string);
Var
  Found: Integer;
  SearchResult: TSearchRec;
Begin
 Found := FindFirst(Path+DirectorySeparator+'*', faAnyFile, SearchResult);
 While Found = 0 Do
 Begin
  If (SearchResult.Attr And faDirectory = 0) Then
   Begin
    If AnsiEndsStr ('.mp3', SearchResult.Name)=True then
    Begin
     //Writeln ('m3u: ', M3uFileName (Path+DirectorySeparator+SearchResult.Name,2));
     Writeln ('found mp3: ', Path+DirectorySeparator+SearchResult.Name);
     WriteM3u ('E:\Server\Audio\mp3\m3u\' + M3uFileName (Path+DirectorySeparator+SearchResult.Name,2), Path+DirectorySeparator+SearchResult.Name);
    End;
   End
   Else
    begin
     If Not ((SearchResult.Name = '.') Or (SearchResult.Name = '..')) Then
      Begin
       writeln ('open Dir: ', Path+DirectorySeparator+SearchResult.Name);
       GetFiles (Path+DirectorySeparator+SearchResult.Name);
      End;
    End;
   Found := FindNext(SearchResult);
 End;
End;

Begin
 CleanM3uDirectory ('E:\Server\Audio\mp3\m3u');
 GetFiles ('E:\Server\Audio\mp3');
End.
