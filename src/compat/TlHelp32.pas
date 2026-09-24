unit TlHelp32;

interface

uses
  Windows;

const
  TH32CS_SNAPPROCESS = $00000002;

 type
  TProcessEntry32 = record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ProcessID: DWORD;
    th32DefaultHeapID: DWORD;
    th32ModuleID: DWORD;
    cntThreads: DWORD;
    th32ParentProcessID: DWORD;
    pcPriClassBase: Longint;
    dwFlags: DWORD;
    szExeFile: array[0..MAX_PATH - 1] of Char;
  end;

function CreateToolhelp32Snapshot(dwFlags, th32ProcessID: DWORD): THandle; stdcall;
function Process32First(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall;
function Process32Next(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall;

implementation

function CreateToolhelp32Snapshot(dwFlags, th32ProcessID: DWORD): THandle; stdcall; external 'kernel32.dll' name 'CreateToolhelp32Snapshot';
function Process32First(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall; external 'kernel32.dll' name 'Process32First';
function Process32Next(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall; external 'kernel32.dll' name 'Process32Next';

end.
