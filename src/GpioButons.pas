{**********************************************************
*    Copyright (c) Zeljko Cvijanovic Teslic RS/BiH
*    www.zeljus.com
*    Created by: 30-04-2017
***********************************************************}
unit GpioButons;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpgpio;

type

    { TButtonGpioLinuxPin }

    TButtonGpioLinuxPin = class(TGpioLinuxPin)
    private
      FNewValue: boolean;
      FPressButton: Boolean;
      FPressCount: Longint;
      FCount: Longint;
      function GetPressCount: LongInt;
    public
      constructor Create(aID: Longword); overload;
      destructor Destroy; override;
    public
      property PressCount: LongInt read GetPressCount;
    end;

implementation

{ TButtonGpioLinuxPin }

function TButtonGpioLinuxPin.GetPressCount: LongInt;
begin
  FPressCount := 0;
  if PollChange(0, 100, FNewValue) then begin
    if (FPressButton) and (FNewValue) then FPressCount := FCount;
    FPressButton := not FNewValue;
  end;
  If FPressButton then  FCount := FCount + 1 else FCount := 0;
  Result := FPressCount;
end;

constructor TButtonGpioLinuxPin.Create(aID: Longword);
begin
  inherited Create(aID);
  FPressButton := false;
  FCount:= 0;
end;

destructor TButtonGpioLinuxPin.Destroy;
begin
  inherited Destroy;
end;

end.

