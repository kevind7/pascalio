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
      FPressCount: Longint;
      FCount: Longint;
      function GetPressCount: LongInt;
    public
      constructor Create(aID: Longword); overload;
      destructor Destroy; override;
      function PollChange(delay: Longint; timeout: Longint; out aValue: Boolean): Boolean; override;
    public
      property PressCount: LongInt read GetPressCount;
    end;


implementation

{ TButtonGpioLinuxPin }

function TButtonGpioLinuxPin.GetPressCount: LongInt;
begin
 PollChange(0, 50, FNewValue);
 Result := FPressCount;
end;

constructor TButtonGpioLinuxPin.Create(aID: Longword);
begin
  inherited Create(aID);
  FCount:= 0;
end;

destructor TButtonGpioLinuxPin.Destroy;
begin
  inherited Destroy;
end;

function TButtonGpioLinuxPin.PollChange(delay: Longint; timeout: Longint; out aValue: Boolean): Boolean;
begin
  Result:=inherited PollChange(delay, timeout, aValue);
  if Value then FPressCount := FCount;
  if (not Value) then  FCount := FCount + 1 else FCount := 0;
end;

end.

