//------------------------------------------------------------------------------//
//                                                                              //
//      ������ ��� ������ � ���                                                 //
//      (c) DimaGVRH, Dnepr city, 2019 - 2025                                   //
//                                                                              //
//------------------------------------------------------------------------------//
unit RAMMemModule;

interface

   procedure GetStartSettingParamsFromRAM();
   procedure InitializeStartParams(VersionID: Integer);
   procedure ConnectSimulatorRAM();
   function ReadKeyFromMemoryString(readAddr: PByte; Key: String; SearchRadius: Integer) : String;
   function ReadStringFromMemory(readAddr: PByte; Len: Byte) : String;
   procedure ReadVarsFromRAM();
   procedure ReadDataMemory2TE10U();
   procedure ReadDataMemoryM62();
   procedure ReadDataMemoryTEP70();
   procedure ReadDataMemoryTEP70BS();
   procedure ReadDataMemoryTEM18dm();
   procedure ReadDataMemoryVL11m();
   procedure ReadDataMemoryVL80t();
   procedure ReadDataMemoryVL82m();
   procedure ReadDataMemoryVL85();
   procedure ReadDataMemoryCHS2k();
   procedure ReadDataMemoryCHS4();
   procedure ReadDataMemoryCHS4t();
   procedure ReadDataMemoryCHS4kvr();
   procedure ReadDataMemoryCHS7();
   procedure ReadDataMemoryCHS8();
   procedure ReadDataMemoryEP1m();
   procedure ReadDataMemory2ES5k();
   procedure ReadDataMemoryED4M();
   procedure ReadDataMemoryED9M();
var
   ADDR_ZDS_EXE_LABEL:                      PByte;
   ADDR_WAGS_NUM:                           Pointer;
   ADDR_CAMERA_LAST_WAGON_OFFSET:           Pointer;
   ADDR_LAST_WAGON_SHADOW_OFF:              Pointer;
   ADDR_EXTRA_CODE_ZDS1:                    Pointer;

implementation

uses UnitMain, Windows, SysUtils, SoundManager, Math, TlHelp32, ExtraUtils, Dialogs, IniFiles, Classes;

var
   ProcReadDataMemoryAddr: ProcReadDataMemoryType;

   ADDR_Speed, ADDR_Svetofor:  		    Pointer;
   ADDR_Track, ADDR_KLUB_OPEN:    	    Pointer;
   ADDR_TRACK_TAIL:                         Pointer;
   ADDR_COUPLE_STATUS:                      Pointer;
   ADDR_RB, ADDR_RBS:                       Pointer;
   ADDR_KM_POS, ADDR_OP_POS, ADDR_REVERSOR: Pointer;
   ADDR_KM_POS_2:                           Pointer;
   ADDR_395, ADDR_254, ADDR_ACCLRT:    	    Pointer;
   ADDR_VSTR_TRACK, ADDR_VSTR_NW:           Pointer;
   ADDR_SVETOFOR_DISTANCE:                  Pointer;
   ADDR_TP_ED4M, ADDR_TP_ED9M:              Pointer;
   ADDR_BV_ED4M, ADDR_BV_ED9M:              Pointer;
   ADDR_KME_ED4M, ADDR_KME_ED9M:            Pointer;
   ADDR_VIGILANCE_CHECK:                    Pointer; // ����� ��������� �������� ������������ (����� ��� ����-�)
   ADDR_SPEED_VSTRECHA:                     Pointer; // ����� �������� �������� � ��
   ADDR_VSTRECH_STATUS:                     Pointer;
   ADDR_OGRANICH:                           Pointer;
   ADDR_NEXT_OGRANICH:                      Pointer;
   ADDR_CAMERA:                             Pointer;
   ADDR_CAMERA_X:                           Pointer; // ����� �������� ��������� ������ �� ��� � � ������ ���������
   ADDR_AMPERAGE1:                          Pointer; // ����� �������� ��� ��� 1
   ADDR_AMPERAGE2:                          Pointer; // ����� �������� ��� ��� 2
   ADDR_AMPERAGE3:                          Pointer; // ����� �������� ��� ��� 3
   ADDR_AMPERAGE4:                          Pointer; // ����� �������� ��� ��� 4
   ADDR_BOKSOVANIE:                         Pointer;
   ADDR_AB_ZB_1:                            Pointer;
   ADDR_AB_ZB_2:                            Pointer;
   ADDR_RAIN:                               Pointer;
   ADDR_STOCHIST:                           Pointer; // ����� ��������� ���������
   ADDR_STCHSTDGR:                          Pointer; // ����� ��� ���� �������� ���������
   ADDR_CHS7_COMPRESSOR:                    Pointer; // ����� ��������� ������������ �� ��7
   ADDR_CHS7_VENT:                          Pointer; // ����� ��������� ������������ �� ��7 (�������, ���������)
   ADDR_CHS7_VOLTAGE:                       Pointer; // ����� ���������� �� ��7
   ADDR_CHS7_BV:                            Pointer; // ����� ��������� �� �� ��7
   ADDR_CHS7_BV_PAKETNIK:                   Pointer; // ����� ��������� ��������� �� �� ��7
   ADDR_CHS7_REVERSOR:                      Pointer;
   ADDR_CHS7_FTP:                           Pointer;
   ADDR_CHS7_BTP:                           Pointer;
   ADDR_CHS7_ZHALUZI:                       Pointer;
   ADDR_CHS8_FTP:                           Pointer;
   ADDR_CHS8_BTP:                           Pointer;
   ADDR_CHS8_REOSTAT:                       Pointer;
   ADDR_CHS8_VENT_VOLUME:                   Pointer;
   ADDR_CHS8_VENT_VOLUME_INCREMENTER:       Pointer;
   ADDR_CHS8_COMPRESSOR:                    Pointer; // ����� ��������� ������������ �� ��8
   ADDR_CHS8_GV_1:                          Pointer;
   ADDR_CHS8_GV_2:                          Pointer;
   ADDR_CHS8_GV_PAKETNIK_OFFSET:            Pointer; // ����� ��������� ��������� �� �� ��8 (���������!!)
   ADDR_CHS8_GV_PAKETNIK:                   PByte;   // ����� ��������� ��������� �� �� ��8 (���������!!)
   ADDR_CHS4T_VENT:                         Pointer; // ����� ��������� ������������ �� ��4�
   ADDR_CHS4T_COMPRESSOR:                   Pointer;
   ADDR_CHS4T_FTP:                          Pointer;
   ADDR_CHS4T_BTP:                          Pointer;
   ADDR_CHS4T_GV_PAKETNIK_OFFSET:           Pointer; // ����� ��������� ��������� �� �� ��4�, ��4, ��4��� (���������!!)
   ADDR_CHS4T_GV_PAKETNIK:                  PByte;   // ����� ��������� ��������� �� �� ��4�, ��4, ��4��� (���������!!)
   ADDR_CHS4KVR_FTP:                        Pointer;
   ADDR_CHS4KVR_BTP:                        Pointer;
   ADDR_CHS4KVR_REVERSOR:                   Pointer;
   ADDR_CHS2K_COMPRESSOR:                   Pointer;
   ADDR_CHS2K_BV:                           Pointer;
   ADDR_CHS2K_VENT:                         Pointer;
   ADDR_CHS2K_FTP:                          Pointer;
   ADDR_CHS2K_BTP:                          Pointer;
   ADDR_EP1M_COMPRESSOR:                    Pointer;
   ADDR_EP1M_FTP:                           Pointer;
   ADDR_EP1M_BTP:                           Pointer;
   ADDR_KVR_VENTS:                          Pointer;
   ADDR_ED4M_COMPRESSOR:                    Pointer;
   ADDR_ED4M_REVERSOR:                      Pointer;
   ADDR_HIGHLIGHTS:                         Pointer;
   ADDR_ED9M_COMPRESSOR:                    Pointer;
   ADDR_ED9M_REVERS:                        Pointer;
   ADDR_EDT_AMPERAGE:                       Pointer; // ����� �������� ���� ��� (��8)
   ADDR_NM:                                 Pointer; // ����� �������� ��������� �������� ����������
   ADDR_BRAKE_CYLINDERS:                    Pointer; // ����� �������� �������� � ��������� ���������
   ADDR_2TE10U_DIESEL1:                     Pointer; // ����� ��������� ������ �� 2��10�
   ADDR_2TE10U_DIESEL2:                     Pointer; // ����� ��������� ������ �� 2��10�
   ADDR_TEP70_RPM:                          Pointer; // ����� ����� �������� � ������ ������ �� ���70
   ADDR_TEP70_TED:                          Pointer; // ����� ���� ��� ��� ���70
   ADDR_TEP70BS_RPM:                        Pointer;
   ADDR_TEP70BS_KMPOS:                      Pointer;
   ADDR_M62_RPM_1:                          Pointer; // ����� ����� �������� � ������ ��� ������ �� �62
   ADDR_M62_RPM_2:                          Pointer; // ����� ����� �������� � ������ ��� ������ �� �62
   ADDR_M62_KMPOS_1:                        Pointer;
   ADDR_M62_KMPOS_2:                        Pointer;
   ADDR_EPT:                                Pointer;
   ADDR_VL11M_FTP, ADDR_VL11M_BTP:          Pointer;
   ADDR_VL11M_COMPRESSOR:                   Pointer;
   ADDR_VL80TVent1:                         Pointer;
   ADDR_VL80TVent2:                         Pointer;
   ADDR_VL80TVent3:                         Pointer;
   ADDR_VL80TVent4:                         Pointer;
   ADDR_VL80TComp:                          Pointer;
   ADDR_VL80TFazan:                         Pointer;
   ADDR_VL82_COMPRESSOR:                    Pointer;
   ADDR_VL82_VENT:                          Pointer;
   ADDR_VL85_FTP, ADDR_VL85_BTP:            Pointer;
   ADDR_2ES5K_FTP, ADDR_2ES5K_BTP:          Pointer;
   ADDR_LDOORED4M:                          Pointer;
   ADDR_RDOORED4M:                          Pointer;
   ADDR_SVISTOK:                            Pointer;
   ADDR_TIFON:                              Pointer;
   ADDR_VSTRECHA_WAGON_DLINA:               PDouble;
   ADDR_VSTRECHA_WAG_ORDINATA:	            PDouble;
   ADDR_SETTINGS_INI_POINTER:               Pointer;
   ADDR_ED4M_KONTROLLER:                    Pointer;
   ADDR_ED9M_KONTROLLER:                    Pointer;
   ADDR_VL11m_VENT:                         Pointer;
   ADDR_ORDINATA:                           Pointer;
   ADDR_OUTSIDE_LOCO_STATUS:                Pointer;
   ADDR_2ES5K_BV:                           Pointer;
   ADDR_CHS8_UNIPULS_AVARIA:                Pointer;
   ADDR_PNEVM_SIGNAL:                       Pointer;
   ADDR_PNEVM:                              PByte;
   ADDR_VR242:                              Pointer;

   // STEAM
   ADDR_LOCOMOTIVE_TYPE:                    Pointer;
   ADDR_LOC_NUMBER_POINTER:                 Pointer;
   ADDR_LOC_NUMBER:                         PByte;
   ADDR_ROUTE:                              Pointer;
   ADDR_ROUTE_PATH_POINTER:                 Pointer;
   ADDR_ROUTE_PATH:                         PByte;
   ADDR_WAGONS_AMOUNT:                      Pointer;
   ADDR_FREIGHT:                            Pointer;

   CHS8VentVolumePrev:                      Single;
   CHS8VentTempCounter:                     Byte;

//------------------------------------------------------------------------------//
//            ������������ ��� ������ ��������� �� ���������� ������            //
//------------------------------------------------------------------------------//
function ReadPointer(Addr: Pointer): PByte;
var
    tempAddr: PByte;
    b: Byte;
    i: Integer;
    str: String;
begin
    tempAddr := Addr;
    Inc(tempAddr, 3);
    for i:=4 downto 1 do begin
       ReadProcessMemory(UnitMain.pHandle, tempAddr, @b, 1, temp);
       str := str + IntToHex(b, 2);
       Dec(tempAddr);
    end;
    Result := PByte(StrToInt('$'+str));
end;

//------------------------------------------------------------------------------//
//          ������������ ��� ������ �� ��� ������ ������������� ������          //
//------------------------------------------------------------------------------//
function ReadStringFromMemory(readAddr: PByte; Len: Byte) : String;
var
   I: Byte;
   readByte: Byte;
   resStr: String;
   str: String;
begin
   for I := 0 to Len do begin
      ReadProcessMemory(UnitMain.pHandle, readAddr, @readByte, 1, temp);
      SetString(str, PChar(@readByte), 1);
      resStr := resStr + str;
      Inc(readAddr);
   end;
   Result := resStr;
end;

//------------------------------------------------------------------------------//
//          ������������ ��� ������ �� ��� ������ ������������� ������          //
//------------------------------------------------------------------------------//
function ReadStringFromMemoryToZero(readAddr: PByte) : String;
var
   I: Byte;
   readByte: Byte;
   resStr: String;
   str: String;
begin
   while 1 = 1 do begin
      ReadProcessMemory(UnitMain.pHandle, readAddr, @readByte, 1, temp);
      if readByte = 0 then Break;
      SetString(str, PChar(@readByte), 1);
      resStr := resStr + str;
      Inc(readAddr);
   end;
   Result := resStr;
end;

//------------------------------------------------------------------------------//
//          ������������ ��� ������ �� ��� ������ �� ���������� �������         //
//------------------------------------------------------------------------------//
function ReadKeyFromMemoryString(readAddr: PByte; Key: String; SearchRadius: Integer) : String;
var
   strKey: String;
   retStr, str: String;
   readByte: Byte;
   keyFound, firstDataByte: Boolean;
   i: Integer;
begin
   KeyFound := False; firstDataByte := False;
   i := 0;
   while True do begin
      if i > SearchRadius then Break;

      ReadProcessMemory(UnitMain.pHandle, readAddr, @readByte, 1, temp);

      if readByte <> 0 then begin
         SetString(str, PChar(@readByte), 1);
         if firstDataByte = False then
            strKey := strKey + str
         else
            firstDataByte := False;
      end else begin
         if strKey <> '' then begin
            if KeyFound = False then begin
               if Pos(Key, strKey) <> 0 then begin
                  keyFound := True; firstDataByte := True; strKey := '';
               end else begin
                  strKey := '';
               end;
            end else begin
               retStr := strKey; Break;
            end;
         end;
      end;

      Inc(readAddr); Inc(i);
   end;
   Result := retStr;
end;

procedure FindPnevm();
begin
   ADDR_PNEVM := ReadPointer(ADDR_PNEVM_SIGNAL);
   Inc(ADDR_PNEVM, 48);
end;

//------------------------------------------------------------------------------//
//  ������������ ��� ������ ��������� ���������� �� ������������ 'settings.ini' //
//------------------------------------------------------------------------------//
procedure ConnectSimulatorRAM();
var
   I: Integer;
begin
   isConnectedMemory := FindSimulatorWindow(wHandle, GameWindowName);
   if isConnectedMemory = True then begin
      isGameOnPause := Pos('[PAUSED]', UpperCase(GameWindowName)) > 0;
      FormMain.lblSimulatorLaunchStatus.Caption := 'ZDSimulator';
      if Pos('ZDSIMULATOR V', UpperCase(GameWindowName)) > 0 then
         FormMain.lblSimulatorLaunchStatus.Caption :=
            Copy(StringReplace(GameWindowName, ' [Paused]', '', [rfIgnoreCase]), 1, 30);
      if Pos('ZDSIMULATOR V', UpperCase(GameWindowName)) > 0 then
         I := 3
      else if Pos('ZDSIMULATOR55.008', UpperCase(GameWindowName)) > 0 then
         I := 0
      else if Pos('ZDSIMULATOR54.006', UpperCase(GameWindowName)) > 0 then
         I := 1
      else if Pos('ZDSIMULATOR55.009', UpperCase(GameWindowName)) > 0 then
         I := 2
      else
         I := 3;
   end else begin
      isGameOnPause := True;
      if PrevConMem = True then begin
         FormMain.lblSimulatorLaunchStatus.Caption:='��������� ��� ������';
      end;
      I := 3;
   end;
   if I = 3 then begin
         ZDSimSteamVersion := True;
         UnitMain.Log_.DebugWriteErrorToErrorList('STEAM version');
   end else begin
         ZDSimSteamVersion := False;
         UnitMain.Log_.DebugWriteErrorToErrorList('NOT STEAM version');
   end;
      InitializeStartParams(I);

	RefreshSnd:=True;
        VersionID := I;
end;

//------------------------------------------------------------------------------//
//  ������������ ��� ������ ��������� ���������� �� ������������ 'settings.ini' //
//------------------------------------------------------------------------------//
procedure GetStartSettingParamsFromRAM();
var
    addr_settings_ini: PByte;
    TF: TextFile;
    _pByte: PByte;
    _int: Integer;
    _Byte: Byte;
    St: string;
    TSt: TStringList;
begin
     With FormMain do begin
        if ZDSimSteamVersion = False then begin
           // �������� ����� �������� ZDSimulator
           UnitMain.tHandle := GetWindowThreadProcessId(wHandle, @ProcessID);
           UnitMain.pHandle := OpenProcess(PROCESS_ALL_ACCESS, FALSE, ProcessID);

           addr_settings_ini := ReadPointer(ADDR_SETTINGS_INI_POINTER);

           WagonsAmount := StrToInt(ReadKeyFromMemoryString(addr_settings_ini, 'WagonsAmount', 6666));
           LocoGlobal := ReadKeyFromMemoryString(addr_settings_ini, 'LocomotiveType',6666);
           naprav:= ReadKeyFromMemoryString(addr_settings_ini, 'Route', 6666);
           try Route := ReadKeyFromMemoryString(addr_settings_ini, 'RoutePath', 6666); except Route:='error'; end;
           // ��������� ������ ����������
           try
              St := ReadKeyFromMemoryString(addr_settings_ini, 'LocNum', 6666);

              // !!! ���� ��� ������� ���� 33_006 ��� 1155_0976 !!! //
              if Pos('_', St)>0 then St := GetStrToSep(St, '_');

              LocoNum := StrToInt(St);
           except LocoNum:=-1; end;
           MP := StrToInt(ReadKeyFromMemoryString(addr_settings_ini, 'MultiPlayer', 6666));
           try ConName := ReadKeyFromMemoryString(addr_settings_ini, 'WagsName', 6666); except ConName:='error'; end;
           Winter := StrToInt(ReadKeyFromMemoryString(addr_settings_ini, 'Winter', 6666));
           Freight := StrToInt(ReadKeyFromMemoryString(addr_settings_ini, 'Freight', 6666));
           try SceneryName:=ReadKeyFromMemoryString(addr_settings_ini, 'SceneryName', 6666); except SceneryName:='error'; end;
           try
              St:=ReadKeyFromMemoryString(addr_settings_ini, 'CompoundPercent', 6666);
              CompoundPercent := StrToFloat(St);
           except
              St:=StringReplace(St, '.', ',', [rfReplaceAll, rfIgnoreCase]);
              //MessageDLG(St, mterror, mbOKCancel, 0);
              CompoundPercent := StrToFloat(St);
           end;
           //MessageDLG('!'+ReadKeyFromMemoryString(addr_settings_ini, 'CompoundPercent', 6666)+'!', mterror, mbOKCancel, 0);

           UnitMain.Log_.DebugWriteErrorToErrorList('settings.ini data: ');
           UnitMain.Log_.DebugWriteErrorToErrorList('Route: ' + Route);
           UnitMain.Log_.DebugWriteErrorToErrorList('RoutePath: ' + Naprav);
           UnitMain.Log_.DebugWriteErrorToErrorList('Loco: ' + LocoGlobal);
           UnitMain.Log_.DebugWriteErrorToErrorList('WagonsAmount: ' + IntToStr(WagonsAmount));
           UnitMain.Log_.DebugWriteErrorToErrorList('LocoNum: ' + IntToStr(LocoNum));
           UnitMain.Log_.DebugWriteErrorToErrorList('Freight: ' + IntToStr(Freight));
           UnitMain.Log_.DebugWriteErrorToErrorList('WagsName: ' + ConName);
           UnitMain.Log_.DebugWriteErrorToErrorList('Winter: ' + IntToStr(Winter));
           UnitMain.Log_.DebugWriteErrorToErrorList('SceneryName: ' + SceneryName);
           UnitMain.Log_.DebugWriteErrorToErrorList('MultiPlayer: ' + IntToStr(MP));
           UnitMain.Log_.DebugWriteErrorToErrorList('CompoundPercent: ' + FloatToStr(CompoundPercent));

           try CloseHandle(UnitMain.pHandle); except end;
        end else begin
           // STEAM
           // �������� ����� �������� ZDSimulator
           try
              UnitMain.tHandle := GetWindowThreadProcessId(wHandle, @ProcessID);
              UnitMain.pHandle := OpenProcess(PROCESS_ALL_ACCESS, FALSE, ProcessID);
           except
              UnitMain.Log_.DebugWriteErrorToErrorList('Error opening pHandle in read settings.ini');
           end;

           // ��� ����������
           ReadProcessMemory(UnitMain.pHandle, ADDR_LOCOMOTIVE_TYPE, @_int, 4, temp);
           LocoGlobal := IntToStr(_int);
           // ��� ��������
           ADDR_ROUTE_PATH := ReadPointer(ADDR_ROUTE_PATH_POINTER);
           Route := ReadStringFromMemoryToZero(ADDR_ROUTE_PATH);
           //_pByte := ADDR_ROUTE_PATH; Inc(_pByte, 1);
           //ReadProcessMemory(UnitMain.pHandle, ADDR_ROUTE_PATH, @_Byte, 1, temp);
           //ReadProcessMemory(UnitMain.pHandle, _pByte, @Route, _Byte, temp);
           // ����������� �������� �� ��������
           ReadProcessMemory(UnitMain.pHandle, ADDR_ROUTE, @_Byte, 1, temp);
           Naprav := IntToStr(_Byte);
           // ���������� �������
           ReadProcessMemory(UnitMain.pHandle, ADDR_WAGONS_AMOUNT, @WagonsAmount, 1, temp);
           // ����� ����������
           try
              ADDR_LOC_NUMBER := ReadPointer(ADDR_LOC_NUMBER_POINTER);
              LocoNum := StrToInt(ReadStringFromMemoryToZero(ADDR_LOC_NUMBER));
           except
              UnitMain.Log_.DebugWriteErrorToErrorList('Error read LocoNum in read settings.ini');
           end;
           // ��� ������ (������������/��������)
           ReadProcessMemory(UnitMain.pHandle, ADDR_FREIGHT, @Freight, 1, temp);

           AssignFile(TF, extractfilepath(ParamStr(0))+'settings.ini');
           Reset(TF);
           while Not EoF(TF) do begin
              Readln(TF, St);
              if (st<>'') AND (st[1]<>';') then begin
                 try TSt := ExtractWordList(St, '='); except end;

                 //try if TSt[0] = 'LocomotiveType' then LocoGlobal := TSt[1]; except end;
                 //try if TSt[0] = 'RoutePath' then Route := TSt[1]; except end;
                 //try if TSt[0] = 'Route' then Naprav := TSt[1]; except end;
                 //try if TSt[0] = 'WagonsAmount' then WagonsAmount := StrToInt(TSt[1]); except end;
                 //try if TSt[0] = 'LocNum' then LocoNum := StrToInt(TSt[1]); except end;
                 //try if TSt[0] = 'Freight' then Freight := StrToInt(TSt[1]); except end;
                 try if TSt[0] = 'WagsName' then ConName := TSt[1]; except end;
                 try if TSt[0] = 'Winter' then Winter := StrToInt(TSt[1]); except end;
                 try if TSt[0] = 'SceneryName' then SceneryName := TSt[1]; except end;
                 try if TSt[0] = 'MultiPlayer' then MP := StrToInt(TSt[1]); except end;
                 try if TSt[0] = 'CompoundPercent' then CompoundPercent := StrToFloat(TSt[1]); except end;
              end;
           end;
           CloseFile(TF);

           UnitMain.Log_.DebugWriteErrorToErrorList('settings.ini data [STEAM version]: ');
           UnitMain.Log_.DebugWriteErrorToErrorList('Loco: ' + LocoGlobal);
           UnitMain.Log_.DebugWriteErrorToErrorList('LocoNum: ' + IntToStr(LocoNum));
           UnitMain.Log_.DebugWriteErrorToErrorList('Route: ' + Route);
           UnitMain.Log_.DebugWriteErrorToErrorList('RoutePath: ' + Naprav);
           UnitMain.Log_.DebugWriteErrorToErrorList('WagonsAmount: ' + IntToStr(WagonsAmount));
           UnitMain.Log_.DebugWriteErrorToErrorList('Freight: ' + IntToStr(Freight));
           UnitMain.Log_.DebugWriteErrorToErrorList('WagsName: ' + ConName);
           UnitMain.Log_.DebugWriteErrorToErrorList('Winter: ' + IntToStr(Winter));
           UnitMain.Log_.DebugWriteErrorToErrorList('SceneryName: ' + SceneryName);
           UnitMain.Log_.DebugWriteErrorToErrorList('MultiPlayer: ' + IntToStr(MP));
           UnitMain.Log_.DebugWriteErrorToErrorList('CompoundPercent: ' + FloatToStr(CompoundPercent));

           try CloseHandle(UnitMain.pHandle); except end;
        end;
     end;
end;

//------------------------------------------------------------------------------//
//        ������������ ��� ������ ��������� ���������� ���������� 2��10�        //
//------------------------------------------------------------------------------//
procedure ReadDataMemory2TE10U();
var
    wDisel:    Single;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_2TE10U_DIESEL1, @wDisel, 4, temp); BV:=Trunc(wDisel);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_2TE10U_DIESEL2, @diesel2, 4, temp);  except end;
end;

//------------------------------------------------------------------------------//
//         ������������ ��� ������ ��������� ���������� ���������� �62          //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryM62();
var
    wDisel:    Single;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_M62_RPM_1, @wDisel, 4, temp); if wDisel<400 then BV:=0 else BV:=1;  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_M62_RPM_2, @diesel2, 4, temp); if diesel2<400 then diesel2:=0 else diesel2:=1;  except end;
    if VersionID<1 then begin
       try ReadProcessMemory(UnitMain.pHandle, ADDR_M62_KMPOS_1, @KM_POS_1, 2, temp); except end;
       try ReadProcessMemory(UnitMain.pHandle, ADDR_M62_KMPOS_2, @KM_POS_2, 2, temp); except end;
    end;
end;

//------------------------------------------------------------------------------//
//        ������������ ��� ������ ��������� ���������� ���������� ���70         //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryTEP70();
var
    wDisel:    Single;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_TEP70_RPM, @wDisel, 4, temp); if wDisel<350 then BV:=0 else BV:=1;  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_TEP70_TED, @wDisel, 4, temp); TEDAmperage := wDisel * 100;  except end;
end;

//------------------------------------------------------------------------------//
//       ������������ ��� ������ ��������� ���������� ���������� ���70��        //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryTEP70BS();
var
TempKM: Byte;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_TEP70BS_RPM, @BV, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_TEP70BS_KMPOS, @TempKM, 1, temp); KM_Pos_1:=TempKM; except end;
end;

//------------------------------------------------------------------------------//
//       ������������ ��� ������ ��������� ���������� ���������� ���18��        //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryTEM18dm();
begin
    ;
end;

//------------------------------------------------------------------------------//
//        ������������ ��� ������ ��������� ���������� ���������� ��11�         //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryVL11m();
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL11M_FTP, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL11M_BTP, @BackTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL11M_COMPRESSOR, @Compressor, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL11m_VENT, @Vent, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_VOLTAGE, @Voltage, 4, temp);  except end;
end;

//------------------------------------------------------------------------------//
//        ������������ ��� ������ ��������� ���������� ���������� ��80�         //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryVL80t();
var
    wDisel:    Single;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_FTP, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_BTP, @BackTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_REOSTAT, @Reostat, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL80TVent1, @wDisel, 4, temp); Vent:=Trunc(wDisel); except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL80TVent2, @Vent2, 4, temp); Vent2:=Trunc(Vent2); except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL80TVent3, @Vent3, 4, temp); Vent3:=Trunc(Vent3); except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL80TVent4, @Vent4, 4, temp); Vent4:=Trunc(Vent4); except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL80TComp,  @Compressor, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL80TFazan, @Fazan, 1, temp);  except end;
end;

//------------------------------------------------------------------------------//
//        ������������ ��� ������ ��������� ���������� ���������� ��82�         //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryVL82m();
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_FTP, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_BTP, @BackTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_REOSTAT, @Reostat, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL82_COMPRESSOR, @Compressor, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL82_VENT, @Vent, 4, temp);  except end;
end;

//------------------------------------------------------------------------------//
//         ������������ ��� ������ ��������� ���������� ���������� ��85         //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryVL85();
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL85_FTP, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_VL85_BTP, @BackTP, 1, temp);  except end;
end;

//------------------------------------------------------------------------------//
//         ������������ ��� ������ ��������� ���������� ���������� ��2�         //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryCHS2k();
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS2K_FTP, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS2K_COMPRESSOR, @Compressor, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS2K_VENT, @Vent, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS2K_BV, @BV, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS2K_BTP, @BackTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_VOLTAGE, @Voltage, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_REVERSOR, @ReversorPos, 1, temp);  except end;         // ��������
    if ((BV=0) Or (Voltage<1.5)) and (Vent<>0) then Vent := 0 else Vent := Vent;
end;

//------------------------------------------------------------------------------//
//          ������������ ��� ������ ��������� ���������� ���������� ��4         //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryCHS4();
var
    tpByte: PByte;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4T_FTP, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4T_BTP, @BackTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, Pointer($0536FA2F), @ReversorPos, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4T_VENT, @Vent, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4T_COMPRESSOR, @Compressor, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_VOLTAGE, @Voltage, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4KVR_REVERSOR, @ReversorPos, 1, temp);  except end;

    tpByte := ADDR_PNEVM;
    try ReadProcessMemory(UnitMain.pHandle, tpByte, @GR, 8, temp); except end;
    GR := RoundTo(GR, -2);
    Inc(tpByte, 40);
    try ReadProcessMemory(UnitMain.pHandle, tpByte, @TC, 8, temp); except end;
    ADDR_CHS4T_GV_PAKETNIK := ReadPointer(ADDR_CHS4T_GV_PAKETNIK_OFFSET);
    Inc(ADDR_CHS4T_GV_PAKETNIK, 56);
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4T_GV_PAKETNIK, @BV_Paketnik, 4, temp);  except end;
end;

//------------------------------------------------------------------------------//
//          ������������ ��� ������ ��������� ���������� ���������� ��4�        //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryCHS4t();
var
    tpByte: PByte;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4T_FTP, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4T_BTP, @BackTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, Pointer($0536FA2F), @ReversorPos, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4T_VENT, @Vent, 1, temp);  except end;
    //try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4T_COMPRESSOR, @Compressor, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_VOLTAGE, @Voltage, 4, temp);  except end;

    tpByte := ADDR_PNEVM;
    //Inc(tpByte, 40);
    try ReadProcessMemory(UnitMain.pHandle, tpByte, @GR, 8, temp); except end;
    GR := RoundTo(GR, -3);
    Inc(tpByte, 40);
    try ReadProcessMemory(UnitMain.pHandle, tpByte, @TC, 8, temp); except end;
    ADDR_CHS4T_GV_PAKETNIK := ReadPointer(ADDR_CHS4T_GV_PAKETNIK_OFFSET);
    Inc(ADDR_CHS4T_GV_PAKETNIK, 56);
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4T_GV_PAKETNIK, @BV_Paketnik, 4, temp);  except end;
end;

//------------------------------------------------------------------------------//
//         ������������ ��� ������ ��������� ���������� ���������� ��4���       //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryCHS4kvr();
var
    tpByte: PByte;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4KVR_FTP, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4KVR_BTP, @BackTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4KVR_REVERSOR, @ReversorPos, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_KVR_VENTS, @Vent, 4, temp); except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_VOLTAGE, @Voltage, 4, temp);  except end;

    tpByte := ADDR_PNEVM;
    //Inc(tpByte, 40);
    try ReadProcessMemory(UnitMain.pHandle, tpByte, @GR, 8, temp); except end;
    GR := RoundTo(GR, -2);
    Inc(tpByte, 40);
    try ReadProcessMemory(UnitMain.pHandle, tpByte, @TC, 8, temp); except end;
    ADDR_CHS4T_GV_PAKETNIK := ReadPointer(ADDR_CHS4T_GV_PAKETNIK_OFFSET);
    Inc(ADDR_CHS4T_GV_PAKETNIK, 56);
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS4T_GV_PAKETNIK, @BV_Paketnik, 4, temp);  except end;
end;

//------------------------------------------------------------------------------//
//          ������������ ��� ������ ��������� ���������� ���������� ��7         //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryCHS7();
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_FTP, @FrontTP, 1, temp);  except end; 	    // �������� ��
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_BTP, @BackTP, 1, temp);  except end;              // ������ ��
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_REVERSOR, @ReversorPos, 1, temp);  except end;         // ��������
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_COMPRESSOR, @Compressor, 4, temp);  except end;    // ����������
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_VOLTAGE, @Voltage, 4, temp);  except end;          // ���������� �� ��-����
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_BV, @BV, 1, temp);  except end;		    // ��
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_VENT, @Vent, 1, temp);  except end;                // ���������� (��������� ��������)
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_ZHALUZI, @Zhaluzi, 1, temp); except end;       // ������
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_BV_PAKETNIK, @BV_Paketnik, 4, temp);  except end;          // ���������� �� ��-����
    if ((BV=0) Or (Voltage<1.5)) and (Vent<>0) then Vent := 0 else Vent := Vent;
end;

//------------------------------------------------------------------------------//
//          ������������ ��� ������ ��������� ���������� ���������� ��8         //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryCHS8();
var
    VentSingleVolumeIncrementerTemp: Single;
    VentUnipulsAvaria: Byte;
    BV_temp: double;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_FTP, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_BTP, @BackTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_REOSTAT, @Reostat, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_VOLTAGE, @Voltage, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_COMPRESSOR, @Compressor, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_VENT_VOLUME, @VentSingleVolume, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_VENT_VOLUME_INCREMENTER, @VentSingleVolumeIncrementerTemp, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_UNIPULS_AVARIA, @VentUnipulsAvaria, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_GV_1, @BV_temp, 8, temp);  except end;

    if (BV_temp > 0) then BV := Trunc(BV_temp) else BV := 0;
    VentSingleVolumeIncrementer := RoundTo(VentSingleVolumeIncrementerTemp, -2) * 100;

    if ((Trunc(VentSingleVolumeIncrementer) = 33) and (VentSingleVolume > 0.1) and (VentSingleVolume < 0.34))
       and ((CHS8VentVolumePrev < VentSingleVolume) Or (CHS8VentTempCounter > 30))
       then Vent := 2;
    if ((Trunc(VentSingleVolumeIncrementer) = 33) and (VentSingleVolume > 0.34) and (VentSingleVolume < 0.68))
       and ((CHS8VentVolumePrev < VentSingleVolume) Or (CHS8VentTempCounter > 30))
       then Vent := 3;
    if ((Trunc(VentSingleVolumeIncrementer) = 33) and (VentSingleVolume > 0.68) and (VentSingleVolume <= 1))
       and ((CHS8VentVolumePrev < VentSingleVolume) Or (CHS8VentTempCounter > 30))
       then Vent := 4;

    if ((Trunc(VentSingleVolumeIncrementer) = 33) and (VentSingleVolume > 0) and (VentSingleVolume < 0.32))
       and ((CHS8VentVolumePrev > VentSingleVolume) Or (CHS8VentTempCounter > 30)) then Vent := 0;
    if ((Trunc(VentSingleVolumeIncrementer) = 33) and (VentSingleVolume > 0.34) and (VentSingleVolume < 0.66))
       and ((CHS8VentVolumePrev > VentSingleVolume) Or (CHS8VentTempCounter > 30)) then Vent := 2;
    if ((Trunc(VentSingleVolumeIncrementer) = 33) and (VentSingleVolume > 0.68) and (VentSingleVolume < 0.95))
       and ((CHS8VentVolumePrev > VentSingleVolume) Or (CHS8VentTempCounter > 30)) then Vent := 3;

    if ((VentSingleVolumeIncrementer < 33) and (VentSingleVolumeIncrementer > 0)) Or (EDTAmperage > 0) then Vent := 1;
    //if ((VentSingleVolumeIncrementer < 33) and (VentSingleVolumeIncrementer > 0)) then Vent := 1;
    //if (Vent = 0) And (TEDAmperage+EDTAmperage > 0) then Vent := 1;
    //if (VentSingleVolumeIncrementer = 0) and (VentSingleVolume = 1) and (KM_Pos_1 = 0) then Vent := 5;
    if (VentUnipulsAvaria = 0) then Vent := 5;
    if ((VentSingleVolumeIncrementer = 33) and (VentSingleVolume < 0.1)) Or (Voltage < 15)
       Or (((TEDAmperage=0)And(EDTAmperage=0))And(Vent=1)) then Vent := 0;

    if (CHS8VentVolumePrev = VentSingleVolume) and (CHS8VentTempCounter < 100) then Inc(CHS8VentTempCounter) else CHS8VentTempCounter := 0;
    CHS8VentVolumePrev := VentSingleVolume;

    ADDR_CHS8_GV_PAKETNIK := ReadPointer(ADDR_CHS8_GV_PAKETNIK_OFFSET);
    Inc(ADDR_CHS8_GV_PAKETNIK, 3303);
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS8_GV_PAKETNIK, @VentUnipulsAvaria, 1, temp);  except end;
    BV_Paketnik := VentUnipulsAvaria;
end;

//------------------------------------------------------------------------------//
//         ������������ ��� ������ ��������� ���������� ���������� ��1�         //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryEP1m();
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_EP1M_FTP, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_EP1M_BTP, @BackTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_EP1M_COMPRESSOR, @Compressor, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_VOLTAGE, @Voltage, 4, temp);  except end;
end;

//------------------------------------------------------------------------------//
//         ������������ ��� ������ ��������� ���������� ���������� 2��5�        //
//------------------------------------------------------------------------------//
procedure ReadDataMemory2ES5k();
var
    SingleTemp: Single;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_2ES5K_FTP, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_2ES5K_BTP, @BackTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_EP1M_COMPRESSOR, @Compressor, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_CHS7_VOLTAGE, @Voltage, 4, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_2ES5K_BV, @SingleTemp, 4, temp);  except end;
    BV := Trunc(SingleTemp);
end;

//------------------------------------------------------------------------------//
//       ������������ ��� ������ ��������� ���������� ������������� ��4�        //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryED4M();
var
    wCompEd4m: Byte;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_TP_ED4M, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_BV_ED4M, @BV, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_KME_ED4M, @KME_ED, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_ED4M_REVERSOR, @ReversorPos, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_LDOORED4M, @LDOOR, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_RDOORED4M, @RDOOR, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_ED4M_COMPRESSOR, @wCompEd4m, 1, temp); Compressor:=wCompEd4m;  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_ED4M_KONTROLLER, @KM_Pos_1, 2, temp); except end;
    Vent:=FrontTP; if BV+Vent=2 then Vent:=1 else Vent:=0;
end;

//------------------------------------------------------------------------------//
//       ������������ ��� ������ ��������� ���������� ������������� ��9�        //
//------------------------------------------------------------------------------//
procedure ReadDataMemoryED9M();
var
    wCompEd4m: Byte;
begin
    try ReadProcessMemory(UnitMain.pHandle, ADDR_TP_ED9M, @FrontTP, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_BV_ED9M, @BV, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_KME_ED9M, @KME_ED, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_ED9M_REVERS, @ReversorPos, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_LDOORED4M, @LDOOR, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_RDOORED4M, @RDOOR, 1, temp);  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_ED9M_COMPRESSOR, @wCompEd4m, 1, temp); Compressor:=wCompEd4m;  except end;
    try ReadProcessMemory(UnitMain.pHandle, ADDR_ED9M_KONTROLLER, @KM_Pos_1, 1, temp);  except end;
    Vent:=FrontTP; if BV+Vent=2 then Vent:=1 else Vent:=0;
end;

//------------------------------------------------------------------------------//
//             ������������ ��� ������ ���������� ZDSimulator � ���             //
//------------------------------------------------------------------------------//
procedure ReadVarsFromRAM;
var
     wSpeed:         Double;
     wVstrDl:        Double;
     wPos_1:         Single;
     wVstrSpeed:     Single; // [�/c]
     addr_waglength: PDouble;
     I:              Integer;
begin
   With FormMain do begin
     // �������� ����� �������� ZDSimulator
     UnitMain.tHandle := GetWindowThreadProcessId(wHandle, @ProcessID);
     UnitMain.pHandle := OpenProcess(PROCESS_ALL_ACCESS, FALSE, ProcessID);

     // --- ������ ��������� �� ����� ������� ������ �������� --- //
     addr_waglength := ADDR_VSTRECHA_WAGON_DLINA;
     Vstrecha_dlina:=0;

     FindPnevm();

     // ----- ������ ��������(�����) ���������� ZDSimulator ----- //
     try ReadProcessMemory(UnitMain.pHandle, ADDR_Track, @Track, 4, temp); except end;          // �������� ����� �����
     try ReadProcessMemory(UnitMain.pHandle, ADDR_TRACK_TAIL, @TrackTail, 4, temp); except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_Speed, @wSpeed, 8, temp); except end;         // �������� �������� 32CB38
     try ReadProcessMemory(UnitMain.pHandle, ADDR_Svetofor, @Svetofor, 1, temp); except end;   // �������� ��������� ���������
     try ReadProcessMemory(UnitMain.pHandle, ADDR_KM_POS, @wPos_1, 4, temp); except end;	    // �������� ������� 1-�� ������
     try ReadProcessMemory(UnitMain.pHandle, ADDR_KM_POS_2, @KM_Pos_2, 1, temp); except end;	    // �������� ������� 2-�� ������
     try ReadProcessMemory(UnitMain.pHandle, ADDR_OP_POS, @KM_OP, 4, temp); except end;           // �������� ������� ������
     try ReadProcessMemory(UnitMain.pHandle, ADDR_395, @KM_395, 1, temp); except end;         // �������� ������� 394(395) �����
     try ReadProcessMemory(UnitMain.pHandle, ADDR_254, @KM_294, 4, temp); except end;         // �������� ������� ���. �����
     try ReadProcessMemory(UnitMain.pHandle, ADDR_VSTR_NW, @WagNum_Vstr, 1, temp);  except end;     // �������� ���������� ������� ��������
     //try ReadProcessMemory(UnitMain.pHandle, ADDR_VSTR_TRACK, @wTrVstr, 2, temp);  except end;  // �������� ���� ��������
     try ReadProcessMemory(UnitMain.pHandle, ADDR_KLUB_OPEN, @KLUBOpen, 1, temp);  except end; // �������� ���� �������� ���������� ����-�
     try ReadProcessMemory(UnitMain.pHandle, ADDR_ACCLRT, @Acceleretion, 8, temp);  except end;// �������� ���������
     try ReadProcessMemory(UnitMain.pHandle, ADDR_VSTRECHA_WAG_ORDINATA, @VstrTrack, 2, temp);  except end;// �������� ���������
     try ReadProcessMemory(UnitMain.pHandle, ADDR_OGRANICH, @OgrSpeed, 2, temp);  except end; // �������� ����������� �������� � ����-�
     try ReadProcessMemory(UnitMain.pHandle, ADDR_NEXT_OGRANICH, @NextOgrSpeed, 1, temp);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_SVETOFOR_DISTANCE, @SvetoforDist, 2, temp);  except end; // �������� ���������� �� ���������
     try ReadProcessMemory(UnitMain.pHandle, ADDR_RAIN, @Rain, 1, temp);  except end;     // �������� ������������� �����
     try ReadProcessMemory(UnitMain.pHandle, ADDR_CAMERA, @UnitMain.CameraMode, 1, temp);  except end;   // �������� ��������� ������
     try ReadProcessMemory(UnitMain.pHandle, ADDR_VIGILANCE_CHECK, @VCheck, 1, temp);  except end;   // �������� ��������� �������� ������������
     try ReadProcessMemory(UnitMain.pHandle, ADDR_SPEED_VSTRECHA, @wVstrSpeed, 4, temp);  except end;   // �������� ��������� �������� ������������
     if ZDSimSteamVersion = False then begin
        try ReadProcessMemory(UnitMain.pHandle, ADDR_CAMERA_X, @CameraX, 2, temp);  except end;
     end else begin
        try ReadProcessMemory(UnitMain.pHandle, ADDR_CAMERA_X, @CameraX_Steam, 8, temp);  except end;
     end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_AMPERAGE1, @TEDAmperage, 4, temp);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_EDT_AMPERAGE, @EDTAmperage, 4, temp);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_BRAKE_CYLINDERS, @BrakeCylinders, 4, temp);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_RB, @RB, 1, temp);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_RBS, @RBS, 1, temp);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_STOCHIST, @Stochist, 4, temp); Stochist := ABS(Stochist);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_STCHSTDGR, @StochistDGR, 8, temp);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_BOKSOVANIE, @Boks_Stat, 1, temp);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_AB_ZB_1, @AB_ZB_1, 1, temp);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_AB_ZB_2, @AB_ZB_2, 1, temp);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_COUPLE_STATUS, @CoupleStat, 1, temp); except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_HIGHLIGHTS, @HighLights, 1, temp); except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_SVISTOK, @Svistok, 1, temp); except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_TIFON, @Tifon, 1, temp); except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_VSTRECH_STATUS, @VstrechStatus, 1, temp); except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_EPT, @EPT, 1, temp);  except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_ORDINATA, @Ordinata, 8, temp); except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_OUTSIDE_LOCO_STATUS, @OutsideLocoStatus, 2, temp); except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_VR242, @VR242, 4, temp); except end;
     try ReadProcessMemory(UnitMain.pHandle, ADDR_WAGS_NUM, @WagsNum, 4, temp); except end;

     if SimpleHorn = True then begin
        if GetAsyncKeyState(32) <> 0 then Svistok := 1 else Svistok := 0;
        if GetAsyncKeyState(66) <> 0 then Tifon := 1 else Tifon := 0;
     end;

     if Ordinata<>PrevOrdinata then OrdinataEstimate := Ordinata;

     try
           //if (LocoGlobal<>'M62') and (LocoGlobal<>'TEP70bs') then
           //   wPos_1 := wPos_1 + 0.25;
           KM_Pos_1 := Round(wPos_1)
      except end;

     // --- ��������� ����� ���������� ����� � ������ ---- //
     try
        ReadProcessMemory(UnitMain.pHandle, addr_waglength, @wVstrDl, 8, temp); // �������� ����� ������� ������
        Vstrecha_dlina := Vstrecha_dlina + Trunc(wVstrDl);
        Inc(addr_waglength, 18);
        for I:=1 to WagNum_Vstr do begin
           try
              ReadProcessMemory(UnitMain.pHandle, addr_waglength, @wVstrDl, 8, temp); // �������� ����� �������� � �����
              Vstrecha_dlina := Vstrecha_dlina + Trunc(wVstrDl);
              Inc(addr_waglength, 18);
           except end;
        end;
     except end;

     // --- ��������� ��������������� ����� ����� � �. --- //
     if CoupleStat = 1 then begin
        try TrackLength := ConsistLength/(abs(Track-TrackTail)); except TrackLength := 100; end;
     end else begin
        TrackLength := 100;
     end;

     // ------ ������ ���������� ���������� �� ��� ------- //
     if LocoGlobal <> '' then
         try ProcReadDataMemoryAddr(); except end;

     // --- ������� ��������� ���������� � ���������� ---- //
     try Speed      := Trunc(wSpeed);         except end;
     try Vstr_Speed := Trunc(wVstrSpeed * 4); except end;

     try CloseHandle(UnitMain.pHandle); except end;
   end;
end;

//------------------------------------------------------------------------------//
//   ������������ ��� ������� ��������� ������� � ��� � ���������� ����������   //
//------------------------------------------------------------------------------//
procedure InitializeStartParams(VersionID: Integer);
var
   Ini: TIniFile;
begin
    With FormMain do begin
       if versionID = 0 then begin
          ADDR_254   :=   Pointer($007499E4);     ADDR_395        :=     Pointer($090043A0); ADDR_Speed      :=   Pointer($00749958);
          ADDR_ACCLRT:=   Pointer($007498B8);     ADDR_Track      :=     Pointer($00749A0C); ADDR_KM_POS     :=   Pointer($0911072C);
          ADDR_OP_POS:=   Pointer($0911081C);     ADDR_Svetofor   :=     Pointer($09007ECC); ADDR_AMPERAGE1  :=   Pointer($0538BFDC);
          ADDR_KLUB_OPEN:=Pointer($0538D915);     ADDR_CAMERA     :=     Pointer($09008024); ADDR_CAMERA_X   :=   Pointer($007499EE);
          ADDR_RB    :=   Pointer($00749914);  ADDR_CHS7_REVERSOR :=     Pointer($0538BFD6); ADDR_RBS        :=   Pointer($00749910);
          ADDR_OGRANICH:= Pointer($0074987C); ADDR_SVETOFOR_DISTANCE:=   Pointer($09007EB8);ADDR_VIGILANCE_CHECK:=Pointer($007499D0);
          ADDR_CHS7_BV := Pointer($091D5B9E); ADDR_BRAKE_CYLINDERS:=     Pointer($0538C268); ADDR_CHS7_VOLTAGE:=  Pointer($091106B8);
          ADDR_CHS7_VENT:=Pointer($091D5BA0); ADDR_CHS7_COMPRESSOR:=     Pointer($091D48C8); ADDR_CHS7_FTP   :=   Pointer($091D5BAF);
          ADDR_CHS7_BTP:= Pointer($091D5BB3);       ADDR_STOCHIST :=     Pointer($007497CC); ADDR_STCHSTDGR  :=   Pointer($007497BC);
          ADDR_RAIN  :=   Pointer($00803D56);       ADDR_CHS8_FTP :=     Pointer($09110707); ADDR_CHS8_BTP   :=   Pointer($091108B7);
          ADDR_KVR_VENTS:=Pointer($091D48BD);    ADDR_CHS4KVR_BTP :=     Pointer($0911070F); ADDR_CHS4KVR_FTP:=   Pointer($09110707);
          ADDR_VL80TComp:=Pointer($091D48B8);ADDR_CHS4KVR_REVERSOR:=     Pointer($0538BFD7); ADDR_CHS8_REOSTAT:=  Pointer($0538BFD8);
          ADDR_AB_ZB_1:=  Pointer($091106D7);     ADDR_VL80TFazan :=     Pointer($091D48D3); ADDR_VL80TVent1 :=   Pointer($091D506C);
          ADDR_AB_ZB_2:=  Pointer($09110887);  ADDR_VL80TVent2    :=     Pointer($091D5074); ADDR_VL80TVent3 :=   Pointer($091D507C);
          ADDR_BV_ED4M:=  Pointer($091D5B06);ADDR_VSTRECHA_WAG_ORDINATA:=Pointer($09005FE4); ADDR_TEP70BS_RPM:=   Pointer($091D5C9A);
          ADDR_BV_ED9M:=  Pointer($091D5B16);     ADDR_VL80TVent4 :=     Pointer($091D5084); ADDR_TEP70BS_KMPOS:= Pointer($091D5C7D);
          ADDR_TP_ED4M:=  Pointer($091D5B07);        ADDR_TP_ED9M :=     Pointer($091D5B17);ADDR_CHS8_COMPRESSOR:=Pointer($091D48DC);
          ADDR_VL85_FTP:= Pointer($091D5C47); ADDR_ED4M_COMPRESSOR:=     Pointer($091D48C6); ADDR_ED9M_COMPRESSOR:=ADDR_ED4M_COMPRESSOR;
          ADDR_CHS4T_FTP:=Pointer($09110707);  ADDR_ED4M_REVERSOR :=     Pointer($0538BFD6); ADDR_ED9M_REVERS:=ADDR_ED4M_REVERSOR;
          ADDR_CHS4T_BTP:=Pointer($0911070F); ADDR_VL85_BTP       :=     Pointer($091D5C4B); ADDR_TEP70_RPM  :=   Pointer($091D5BDC);
          ADDR_CHS2K_FTP:=Pointer($091D5BEF); ADDR_CHS2K_COMPRESSOR:=    Pointer($091D48C8); ADDR_CHS4T_VENT :=   Pointer($091D48BB);
          ADDR_CHS2K_BTP:=Pointer($091D5BF3); ADDR_EP1M_COMPRESSOR:=     Pointer($091D48B8); ADDR_2ES5K_FTP  :=   Pointer($091D5B5F);
          ADDR_EP1M_FTP:= Pointer($091D5C17); ADDR_2ES5K_BTP      :=     Pointer($091D5B63); ADDR_KM_POS_2   :=   Pointer($091D5AA9);
          ADDR_EP1M_BTP:= Pointer($091D5C1B); ADDR_2TE10U_DIESEL2 :=     Pointer($091D5AB0); ADDR_M62_RPM_1  :=   Pointer($091D5A00);
          ADDR_VL11M_FTP:=Pointer($091D5C2F); ADDR_2TE10U_DIESEL1 :=     Pointer($091D5AAC); ADDR_M62_RPM_2  :=   Pointer($091D5A24);
          ADDR_VL11M_BTP:=Pointer($091D5C33); ADDR_M62_KMPOS_1    :=     Pointer($091D5A14); ADDR_M62_KMPOS_2:= ADDR_M62_KMPOS_1;
          ADDR_VSTR_NW  :=Pointer($09005FE0); ADDR_VSTRECHA_WAGON_DLINA:=Pointer($090043D0); ADDR_BOKSOVANIE :=   Pointer($0538C29C);
          ADDR_LDOORED4M:=Pointer($090043B0); ADDR_VL11M_COMPRESSOR:=    Pointer($091D48C8); ADDR_SPEED_VSTRECHA:=Pointer($00791FB8);
          ADDR_RDOORED4M:=Pointer($090043B1); ADDR_EDT_AMPERAGE   :=     Pointer($0538C274); ADDR_CHS7_ZHALUZI:=  Pointer($091D5BA7);
          ADDR_EPT      :=Pointer($09007C59); ADDR_COUPLE_STATUS  :=     Pointer($00749788); ADDR_CHS2K_VENT :=   Pointer($091D5BE3);
          ADDR_CHS2K_BV :=Pointer($091D5BE2); ADDR_HIGHLIGHTS     :=     Pointer($09007C7A); ADDR_TRACK_TAIL :=   Pointer($09008054);
          ADDR_SVISTOK  :=Pointer($007499D8); ADDR_TIFON          :=     Pointer($007499DC); ADDR_NEXT_OGRANICH:= Pointer($00749880);
          ADDR_ED9M_KONTROLLER:=Pointer($091D5B15); ADDR_VSTRECH_STATUS:=Pointer($090043F8); ADDR_SETTINGS_INI_POINTER:=Pointer($00803F48);
          ADDR_ED4M_KONTROLLER:=Pointer($091D5B04); ADDR_VL11m_VENT:=    Pointer($091D5C25); ADDR_ORDINATA   :=   Pointer($00803F50);
          ADDR_OUTSIDE_LOCO_STATUS:=Pointer($00749865);ADDR_CHS8_VENT_VOLUME:=Pointer($091D48BC); ADDR_CHS8_VENT_VOLUME_INCREMENTER:=Pointer($091D48CC);
          ADDR_2ES5K_BV :=Pointer($091D48CC); ADDR_CHS8_UNIPULS_AVARIA:= Pointer($091D5024); ADDR_CHS8_GV_1  :=   Pointer($09007FB4);
          ADDR_VR242    :=Pointer($0911080C); ADDR_PNEVM_SIGNAL   :=     Pointer($0538D8D4); ADDR_TEP70_TED  :=   Pointer($091D5BD8);
          ADDR_VL82_VENT:=Pointer($091D48BC);      ADDR_VL82_COMPRESSOR:=Pointer($091D48B8); ADDR_WAGS_NUM   :=   Pointer($00749990);
          ADDR_CAMERA_LAST_WAGON_OFFSET:=Pointer($0910CE48);
          ADDR_LAST_WAGON_SHADOW_OFF:=Pointer($0048A6BE);
          // ����� �� ������� ��� ��������� ��������� ���������� �� ��-��, ����� ��2� (��������� ������ 5.5.008)
          ADDR_CHS7_BV_PAKETNIK:=Pointer($091D5B9C);ADDR_CHS4T_GV_PAKETNIK_OFFSET:=Pointer($07D22254);
          ADDR_CHS8_GV_PAKETNIK_OFFSET:=Pointer($00803F78);
          ADDR_EXTRA_CODE_ZDS1:=Pointer($0040438C);
       end;
       if versionID = 1 then begin
          ADDR_Speed :=   Pointer($0072CB38);       ADDR_Track    :=     Pointer($0072CBFC); ADDR_KM_POS     :=   Pointer($090F3F9C);
          ADDR_KM_POS_2 :=Pointer($091B9251);
          ADDR_OP_POS:=   Pointer($090F408C);             ADDR_REVERSOR:=Pointer($0536FA2E);ADDR_KLUB_OPEN   :=   Pointer($0537118D);
          ADDR_395  :=    Pointer($08FE7C18);              ADDR_254  :=  Pointer($0072CBD4); ADDR_Svetofor   :=   Pointer($08FEB744);
          ADDR_VSTR_NW := Pointer($08FE9858);           ADDR_VSTR_TRACK:=Pointer($08FE985C); ADDR_ACCLRT     :=   Pointer($0072CAAC);
          ADDR_TP_ED4M := Pointer($091B92AF);       ADDR_SPEED_VSTRECHA:=Pointer($007759C0); ADDR_BV_ED4M    :=   Pointer($091B92AE);
          ADDR_BV_ED9M := Pointer($091B92BE);ADDR_VSTRECHA_WAG_ORDINATA:=Pointer($08FE985C); ADDR_KME_ED4M   :=   Pointer($091B92AD);
          ADDR_KME_ED9M:= Pointer($091B92AD);      ADDR_VIGILANCE_CHECK:=Pointer($0072CBC0);  ADDR_TP_ED9M   :=   Pointer($091B92BF);
          ADDR_CAMERA_X:= Pointer($0072CBDE);         ADDR_EDT_AMPERAGE:=Pointer($0536FA3C);ADDR_AMPERAGE1   :=   Pointer($0536FA34);
          ADDR_AMPERAGE2:=Pointer($0536FA54);      ADDR_CHS7_COMPRESSOR:=Pointer($091B8120);ADDR_BRAKE_CYLINDERS:=Pointer($0536FD18);
          ADDR_CHS7_VENT:=Pointer($091B934C);      ADDR_CHS8_COMPRESSOR:=Pointer($091B8134);ADDR_CHS4T_VENT  :=   Pointer($091B8113);
          ADDR_NM   :=    Pointer($0072CA6C);     ADDR_CHS4T_COMPRESSOR:=Pointer($091B9208);ADDR_ED4M_COMPRESSOR:=Pointer($091B92AC);
          ADDR_KVR_VENTS:=Pointer($091B8115);     ADDR_CHS2K_COMPRESSOR:=Pointer($091B8120);ADDR_ED9M_COMPRESSOR:=Pointer($091B811F);
          ADDR_CHS7_BV := Pointer($08FEB779);         ADDR_CHS7_VOLTAGE:=Pointer($090F3F30);ADDR_2TE10U_DIESEL1:= Pointer($091B9254);
          ADDR_TEP70_RPM:=Pointer($091B9388);		   ADDR_EPT:=Pointer($08FEB4D1);ADDR_2TE10U_DIESEL2:= Pointer($091B9258);
          ADDR_VL80TVent1  :=   Pointer($091B8860);
          ADDR_VL80TVent2:=Pointer($091B8868);          ADDR_VL80TVent4:=Pointer($091B8870);ADDR_VL80TVent3  :=   Pointer($091B8878);
          ADDR_VL80TComp:=Pointer($091B8110);            ADDR_M62_RPM_1:= Pointer($091B91E4);ADDR_STOCHIST    :=   Pointer($0072C9C8);
          ADDR_STCHSTDGR:=Pointer($0072C9C0);      ADDR_EP1M_COMPRESSOR:=Pointer($091B8110);ADDR_CHS7_REVERSOR:=  Pointer($0536FA2E);
          ADDR_CAMERA   :=Pointer($08FEB89C);      ADDR_ED4M_REVERSOR := Pointer($0536FA2E); ADDR_RB         :=   Pointer($0072CB08);
          ADDR_RBS      :=Pointer($0072CB04);    ADDR_SVETOFOR_DISTANCE:=Pointer($08FEB730);ADDR_OGRANICH    :=   Pointer($0072CA78);
          ADDR_CHS7_FTP :=Pointer($091B935B);             ADDR_CHS7_BTP:=Pointer($091B935F);ADDR_CHS8_FTP    :=   Pointer($090F3F77);
          ADDR_CHS8_BTP :=Pointer($090F411F);         ADDR_CHS8_REOSTAT:=Pointer($0536FA30);ADDR_CHS4KVR_FTP :=   Pointer($090F3F77);
          ADDR_VL80TFazan:=Pointer($091B812A);         ADDR_CHS4KVR_BTP:=Pointer($090F3F7F);ADDR_CHS4KVR_REVERSOR:=Pointer($0536FA2F);
          ADDR_ED9M_REVERS:=Pointer($0536FA2E);          ADDR_CHS2K_FTP:=Pointer($091B939F);ADDR_CHS2K_BTP   :=   Pointer($091B939B);
          ADDR_CHS4T_FTP:=Pointer($090F3F77);            ADDR_CHS4T_BTP:=Pointer($090F3F7F);ADDR_EP1M_FTP    :=   Pointer($091B93C3);
          ADDR_EP1M_BTP :=Pointer($091B93C7);                 ADDR_RAIN:=Pointer($007E77AC);ADDR_2ES5K_BTP   :=   Pointer($091B930B);
          ADDR_2ES5K_FTP:=Pointer($091B9307); ADDR_VSTRECHA_WAGON_DLINA:=Pointer($08FE7C48);ADDR_VL11M_FTP   :=   Pointer($091B93D7);
          ADDR_VL11M_BTP:=Pointer($091B93DB);             ADDR_VL85_FTP:=Pointer($091B93F3);ADDR_VL85_BTP    :=   Pointer($091B93F7);
          ADDR_AB_ZB_1  :=Pointer($090F3F4F);           ADDR_BOKSOVANIE:=Pointer($0536FDF8);ADDR_AB_ZB_2     :=   Pointer($090F40F7);
          ADDR_LDOORED4M  := Pointer($08FE7C28);      ADDR_RDOORED4M  := Pointer($08FE7C29);ADDR_M62_RPM_2   :=   Pointer($00000000);
          ADDR_COUPLE_STATUS:=Pointer($0072C984);     ADDR_CHS7_ZHALUZI:=Pointer($091B9353); ADDR_CHS2K_VENT :=   Pointer($091B938F);
          ADDR_CHS2K_BV :=Pointer($091B938E);           ADDR_HIGHLIGHTS:=Pointer($08FEB4F2);ADDR_TRACK_TAIL  :=   Pointer($08FEB8CC);
          ADDR_SVISTOK  :=Pointer($0072CBC8);                ADDR_TIFON:=Pointer($0072CBCC);ADDR_VL11m_VENT  :=   Pointer($091B93D1);
          ADDR_VSTRECH_STATUS:=Pointer($08FE7C70); ADDR_SETTINGS_INI_POINTER:=Pointer($007E79A0); ADDR_ORDINATA:= Pointer($007E79A8);
          ADDR_ED4M_KONTROLLER:=Pointer($091B92AC);ADDR_OUTSIDE_LOCO_STATUS:=Pointer($0072CA62);
          ADDR_ED9M_KONTROLLER:=Pointer($091B92BD);ADDR_CHS8_VENT_VOLUME:=Pointer($091B8114);ADDR_CHS8_VENT_VOLUME_INCREMENTER:=Pointer($091B8124);
          ADDR_2ES5K_BV :=Pointer($091B8124); ADDR_CHS8_UNIPULS_AVARIA:= Pointer($091B8818);ADDR_PNEVM_SIGNAL:=   Pointer($0537114C);
          ADDR_TEP70_TED:=Pointer($091B9384);      ADDR_VL82_COMPRESSOR:=Pointer($091B8110);    ADDR_VL82_VENT := Pointer($091B8114);
          ADDR_CAMERA_LAST_WAGON_OFFSET:=Pointer($090F06C0);ADDR_WAGS_NUM:=Pointer($0072CB80); ADDR_CHS8_GV_1  :=   Pointer($08FEB82C);
       end;

       // ������ 5.6
       if VersionID = 3 then begin
          Ini:=TiniFile.Create(extractfilepath(ParamStr(0))+'tws.ini');

          // ������ settings.ini �� ��� ZDSimulator
          ADDR_LOCOMOTIVE_TYPE    := Pointer(strToInt('$' + Ini.ReadString('global', 'LocomotiveType', '0')));   // OK
          ADDR_ROUTE              := Pointer(strToInt('$' + Ini.ReadString('global', 'Route', '0')));            // OK
          ADDR_ROUTE_PATH_POINTER := Pointer(strToInt('$' + Ini.ReadString('global', 'RoutePath', '0')));        // OK [POINTER]
          ADDR_WAGONS_AMOUNT      := Pointer(strToInt('$' + Ini.ReadString('global', 'NumberOfWags', '0')));     // OK
          ADDR_LOC_NUMBER_POINTER := Pointer(strToInt('$' + Ini.ReadString('global', 'LocNum', '0')));           // OK [POINTER]
          ADDR_FREIGHT            := Pointer(strToInt('$' + Ini.ReadString('global', 'FreightConsist', '0')));   // OK

          ADDR_Track              := Pointer(strToInt('$' + Ini.ReadString('global', 'MyTrack', '0')));          // OK
          ADDR_SVISTOK            := Pointer(strToInt('$' + Ini.ReadString('global', 'Svistok', '0')));          // OK
          ADDR_TIFON              := Pointer(strToInt('$' + Ini.ReadString('global', 'Tifon', '0')));            // OK
          ADDR_Speed              := Pointer(strToInt('$' + Ini.ReadString('global', 'SpeedKpH', '0')));         // OK
          ADDR_AMPERAGE1          := Pointer(strToInt('$' + Ini.ReadString('chs7', 'tok1', '0')));               // NOT OK
          ADDR_CAMERA             := Pointer(strToInt('$' + Ini.ReadString('global', 'CameraMode', '0')));       // OK
          ADDR_CAMERA_X           := Pointer(strToInt('$' + Ini.ReadString('global', 'MoveInCab', '0')));        // OK
          ADDR_ACCLRT             := Pointer(strToInt('$' + Ini.ReadString('global', 'Acceleration', '0')));     // OK
          ADDR_COUPLE_STATUS      := Pointer(strToInt('$' + Ini.ReadString('global', 'IsCoupled', '0')));        // OK
          

          Ini.Free;
       end;

        // -/- ��80� (VL80t) -/- //
        if LocoGlobal='VL80t' then begin
           LocoWorkDir         := 'TWS/VL80t/';
           UltimateTEDAmperage := 1000;		// ������ ���������� ��� �������� ���
           LocoSectionsNum     := 2;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 25;           // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := False;        // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentStartF          := PChar('TWS/VL80t/MV-start.wav');
           VentCycleF          := PChar('TWS/VL80t/MV-loop.wav');
           VentStopF           := PChar('TWS/VL80t/MV-stop.wav');
           XVentStartF         := PChar('TWS/VL80t/x_MV-start.wav');
           XVentCycleF         := PChar('TWS/VL80t/x_MV-loop.wav');
           XVentStopF          := PChar('TWS/VL80t/x_MV-stop.wav');
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'VL_TED';     // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           UnitMain.LocoLength := 17;
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryVL80t;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��85 (VL85) -/- //
        if LocoGlobal='VL85' then begin
           LocoWorkDir         := 'TWS/VL85/';
           UltimateTEDAmperage := 1000;		// ������ ���������� ��� �������� ���
           LocoSectionsNum     := 2;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 25;           // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := False;        // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'VL_TED';     // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           UnitMain.LocoLength := 24;
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryVL85;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��82� (VL82m) -/- //
        if LocoGlobal='VL82m' then begin
           LocoWorkDir         := 'TWS/VL82m/';
           UltimateTEDAmperage := 650;          // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 2;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 3;            // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := False;        // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentStartF          := PChar('TWS/VL82m/MV-start.wav');
           VentCycleF          := PChar('TWS/VL82m/MV-loop.wav');
           VentStopF           := PChar('TWS/VL82m/MV-stop.wav');
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'VL_TED';     // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           UnitMain.LocoLength := 17;
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryVL82m;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��11� (VL11m) -/- //
        if LocoGlobal='VL11m' then begin
           LocoWorkDir         := 'TWS/VL11m/';
           UltimateTEDAmperage := 650;          // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 2;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 3;            // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := False;        // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := True;         // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0.001;        // ������ �������� ��� ������������ ����������� ��
           VentStartF          := PChar('TWS/VL11m/MV-start.wav');
           VentCycleF          := PChar('TWS/VL11m/MV-loop.wav');
           VentStopF           := PChar('TWS/VL11m/MV-stop.wav');
           XVentStartF         := PChar('TWS/VL11m/x_MV-start.wav');
           XVentCycleF         := PChar('TWS/VL11m/x_MV-loop.wav');
           XVentStopF          := PChar('TWS/VL11m/x_MV-stop.wav');
           LocoTEDNamePrefiks  := 'VL_TED';     // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           UnitMain.LocoLength := 17;
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryVL11m;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- 2��5� (2ES5K) -/- //
        if LocoGlobal='2ES5K' then begin
           LocoWorkDir         := 'TWS/2ES5K/';
           UltimateTEDAmperage := 1000;         // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 2;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 25;           // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := False;        // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentStartF          := PChar('TWS/EP1m/MV-start.wav');
           VentCycleF          := PChar('TWS/EP1m/MV-loop.wav');
           VentStopF           := PChar('TWS/EP1m/MV-stop.wav');
           XVentStartF         := PChar('TWS/EP1m/MV-start.wav');
           XVentCycleF         := PChar('TWS/EP1m/MV-loop.wav');
           XVentStopF          := PChar('TWS/EP1m/MV-stop.wav');
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'VL_TED';     // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           UnitMain.LocoLength := 17;
           ProcReadDataMemoryAddr :=
              @ReadDataMemory2ES5k;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��1� (EP1m) -/- //
        if LocoGlobal='EP1m' then begin
           LocoWorkDir         := 'TWS/EP1m/';
           UltimateTEDAmperage := 1500;
           LocoSectionsNum     := 1;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 25;           // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := True;         // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := False;        // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentStartF          := PChar('TWS/EP1m/MV-start.wav');
           VentCycleF          := PChar('TWS/EP1m/MV-loop.wav');
           VentStopF           := PChar('TWS/EP1m/MV-stop.wav');
           XVentStartF         := PChar('TWS/EP1m/MV-start.wav');
           XVentCycleF         := PChar('TWS/EP1m/MV-loop.wav');
           XVentStopF          := PChar('TWS/EP1m/MV-stop.wav');
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'EP_TED';     // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := 'EP_TED'; // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryEP1m;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��2� (CHS2K) -/- //
        if LocoGlobal='CHS2K' then begin
           LocoWorkDir         := 'TWS/CHS2K/';
           UltimateTEDAmperage := 600;          // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 1;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 3;            // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := False;        // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := True;         // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentStartF          := PChar('TWS/CHS2K/vent-start.wav');
           VentCycleF          := PChar('TWS/CHS2K/vent.wav');
           VentStopF           := PChar('TWS/CHS2K/vent-stop.wav');
           XVentStartF         := PChar('TWS/CHS2K/vent-start.wav');
           XVentCycleF         := PChar('TWS/CHS2K/vent.wav');
           XVentStopF          := PChar('TWS/CHS2K/vent-stop.wav');
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0.001;        // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'CHS_TED';    // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryCHS2k;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��4 (CHS4) -/- //
        if LocoGlobal='CHS4' then begin
           LocoWorkDir         := 'TWS/CHS4/';
           UltimateTEDAmperage := 1500;         // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 1;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 25;           // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := True;         // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := True;         // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := True;         // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentStartF          := PChar('TWS/CHS4KVR/ventVU-start.wav');
           VentCycleF          := PChar('TWS/CHS4KVR/ventVU.wav');
           VentStopF           := PChar('TWS/CHS4KVR/ventVU-stop.wav');
           XVentStartF         := PChar('TWS/CHS4/x_ventVU-start.wav');
           XVentCycleF         := PChar('TWS/CHS4/x_ventVU.wav');
           XVentStopF          := PChar('TWS/CHS4/x_ventVU-stop.wav');
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'CHS_TED';    // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryCHS4;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��4��� (CHS4 KVR) -/- //
        if LocoGlobal='CHS4 KVR' then begin
           LocoWorkDir         := 'TWS/CHS4KVR/';
           UltimateTEDAmperage := 1500;         // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 1;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 25;           // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := True;         // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := True;         // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := True;         // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentStartF          := PChar('TWS/CHS4KVR/ventVU-start.wav');
           VentCycleF          := PChar('TWS/CHS4KVR/ventVU.wav');
           VentStopF           := PChar('TWS/CHS4KVR/ventVU-stop.wav');
           XVentStartF         := PChar('TWS/CHS4KVR/x_ventVU-start.wav');
           XVentCycleF         := PChar('TWS/CHS4KVR/x_ventVU.wav');
           XVentStopF          := PChar('TWS/CHS4KVR/x_ventVU-stop.wav');
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0.004;        // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'CHS_TED';    // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryCHS4kvr;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��4� (CHS4t) -/- //
        if LocoGlobal='CHS4t' then begin
           LocoWorkDir         := 'TWS/CHS4t/';
           UltimateTEDAmperage := 1500;         // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 1;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 25;           // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := True;         // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := True;         // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := True;         // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentTDPitchIncrementer:=0.0025;      // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0.0025;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'CHS_TED';    // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryCHS4t;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��8 (CHS8) -/- //
        if LocoGlobal='CHS8' then begin
           LocoWorkDir         := 'TWS/CHS8/';
           UltimateTEDAmperage := 1500;         // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 2;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 25;           // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := True;         // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := True;         // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := True;         // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentTDPitchIncrementer:=0.0027;        // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0.0025;       // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'CHS_TED';    // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           UnitMain.LocoLength := 17;
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryCHS8;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��7 (CHS7) -/- //
        if LocoGlobal='CHS7' then begin
           LocoWorkDir         := 'TWS/CHS7/';
           UltimateTEDAmperage := 800;          // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 2;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 3;            // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := True;         // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := True;         // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := True;         // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := True;         // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := True;         // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentStartF          := PChar('TWS/CHS7/mv-start.wav');
           VentCycleF          := PChar('TWS/CHS7/mv-loop.wav');
           VentStopF           := PChar('TWS/CHS7/mv-stop.wav');
           XVentStartF         := PChar('TWS/CHS7/x_mv-start.wav');
           XVentCycleF         := PChar('TWS/CHS7/x_mv-loop.wav');
           XVentStopF          := Pchar('TWS/CHS7/x_mv-stop.wav');
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0.001;        // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'CHS_TED';    // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           UnitMain.LocoLength := 17;
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryCHS7;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ���70 (TEP70) -/- //
        if LocoGlobal='TEP70' then begin
           LocoWorkDir         := 'TWS/TEP70/';
           UltimateTEDAmperage := 800;          // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 1;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 0;            // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := True;         // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := False;        // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := False;        // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'VL_TED';     // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := 'TEP70';      // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryTEP70;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ���70�� (TEP70bs) -/- //
        if LocoGlobal='TEP70bs' then begin
           LocoWorkDir         := 'TWS/TEP70bs/';
           UltimateTEDAmperage := 800;          // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 1;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 0;            // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := True;         // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := False;        // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := False;        // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'VL_TED';     // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := 'TEP70bs';    // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryTEP70BS;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- �62 (M62) -/- //
        if LocoGlobal='M62' then begin
           LocoWorkDir         := 'TWS/M62/';
           UltimateTEDAmperage := 800;          // ������ ���������� ��� �������� ���
           if VersionID = 1 then
              LocoSectionsNum     := 1		// ������ ���������� ������ ��� �������� ����������
           else
              LocoSectionsNum     := 2;
           LocoPowerVoltage    := 0;            // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := True;         // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := True;         // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := False;        // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'VL_TED';     // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := 'M62';        // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           UnitMain.LocoLength := 17;
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryM62;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ���18�� (TEM18dm) -/- //
        if LocoGlobal='TEM18dm' then begin
           LocoWorkDir         := 'TWS/TEM18dm/';
           //UltimateTEDAmperage := 800;        // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 1;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 0;            // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := False;        // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := False;        // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := False;        // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryTEM18dm;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- 2��10� (2TE10U) -/- //
        if LocoGlobal='2TE10U' then begin
           LocoWorkDir         := 'TWS/2TE10U/';
           UltimateTEDAmperage := 400;          // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 2;		// ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 0;            // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := False;        // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := False;        // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'VL_TED';     // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := '';       // ������ ������� �������� ����� �� ������� ���������
           LocoDIZNamePrefiks  := '2TE10U';     // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           UnitMain.LocoLength := 17;
           ProcReadDataMemoryAddr :=
              @ReadDataMemory2TE10U;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��4� (ED4M) -/- //
        if LocoGlobal='ED4M' then begin
           LocoWorkDir         := 'TWS/ED4m/';
           //UltimateTEDAmperage := 800;        // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 1;	        // ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 0;            // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := True;         // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := True;         // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentStartF          := PChar('TWS/ED4m/sinxrom_start.wav');
           VentCycleF          := PChar('TWS/ED4m/sinxrom_loop.wav');
           VentStopF           := PChar('TWS/ED4m/sinxrom_stop.wav');
           XVentStartF         := PChar('TWS/ED4m/sinxrom_start.wav');
           XVentCycleF         := PChar('TWS/ED4m/sinxrom_loop.wav');
           XVentStopF          := PChar('TWS/ED4m/sinxrom_stop.wav');
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'ED4m';       // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := 'ED4m';   // ������ ������� �������� ����� �� ������� ���������
           ReduktorF := PChar('TWS/'+LocoReductorNamePrefiks+'/ted_vibeg.wav');
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryED4M;		// ������ ��������� �� ������� ������ ������
        end;
        // -/- ��9� (ED9M) -/- //
        if LocoGlobal='ED9M' then begin
           LocoWorkDir         := 'TWS/ED4m/';
           //UltimateTEDAmperage := 800;        // ������ ���������� ��� �������� ���
           LocoSectionsNum     := 1;	        // ������ ���������� ������ ��� �������� ����������
           LocoPowerVoltage    := 0;            // ��� �������������� ���������� [0, -, ~]
           LocoWithTED         := True;         // ������ ��������� ������� �� ������ ���������� ����� ���-��
           LocoWithReductor    := True;         // ������ ��������� ������� �� ������ ���������� ����� ���������
           LocoWithDIZ         := False;        // ������ ��������� ������� �� ������ ���������� ������ ������
           LocoWithSndKM       := True;         // ������ ��������� ������� �� ������ ���������� ������ �����������
           LocoWithSndKM_OP    := False;        // ������ ��������� ������� �� ������ ���������� ����� ���������� ��
           LocoWithSndTP       := True;         // ������ ��������� ������� �� ������ ���������� ����� ��
           LocoWithExtMVSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithExtMKSound  := False;        // ������ ��������� ������� �� ������ ���������� ������� ������ ��
           LocoWithMVPitch     := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� ��
           LocoWithMVTDPitch   := False;        // ������ ��������� ������� �� ������ ���������� ���������� ������������� �� ��
           VentStartF          := PChar('TWS/ED4m/trans_start.wav');
           VentCycleF          := PChar('TWS/ED4m/trans_loop.wav');
           VentStopF           := PChar('TWS/ED4m/trans_stop.wav');
           XVentStartF         := PChar('TWS/ED4m/trans_start.wav');
           XVentCycleF         := PChar('TWS/ED4m/trans_loop.wav');
           XVentStopF          := PChar('TWS/ED4m/trans_stop.wav');
           VentTDPitchIncrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentTDPitchDecrementer:=0;           // ������ �������� ��� ������������ ����������� �� ��
           VentPitchIncrementer:= 0;            // ������ �������� ��� ������������ ����������� ��
           LocoTEDNamePrefiks  := 'ED4m';       // ������ ������� �������� ����� � ������� ���
           LocoReductorNamePrefiks := 'ED4m';   // ������ ������� �������� ����� �� ������� ���������
           ReduktorF := PChar('TWS/'+LocoReductorNamePrefiks+'/ted_vibeg.wav');
           LocoDIZNamePrefiks  := '';           // ������ ������� �������� ����� � ������� ������ ������
           LocoSvistokF        := 'svistok';
           LocoHornF           := 'tifon';
           ProcReadDataMemoryAddr :=
              @ReadDataMemoryED9M;		// ������ ��������� �� ������� ������ ������
        end;

        if FileExists(LocoWorkDir+'DNoise.wav') = True then
           LocoWithDNoisePitch := True else LocoWithDNoisePitch := False;
     end;
end;

end.
