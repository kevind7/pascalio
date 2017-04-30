{**********************************************************
*    Copyright (c) Zeljko Cvijanovic Teslic RS/BiH
*    www.zeljus.com
*    Created by: 17-12-2016
***********************************************************}
unit lcddriver;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,  fpi2c;

const

// commands
LCD_CLEARDISPLAY =      $01;
LCD_RETURNHOME =        $02;
LCD_ENTRYMODESET =      $04;
LCD_DISPLAYCONTROL =    $08;
LCD_CURSORSHIFT =       $10;
LCD_FUNCTIONSET =       $20;
LCD_SETCGRAMADDR =      $40;
LCD_SETDDRAMADDR =      $80;

// flags for display entry mode
LCD_ENTRYRIGHT =        $00;
LCD_ENTRYLEFT =         $02;
LCD_ENTRYSHIFTINCREMENT = $01;
LCD_ENTRYSHIFTDECREMENT = $00;

// flags for display on/off control
LCD_DISPLAYON =          $04;
LCD_DISPLAYOFF =         $00;
LCD_CURSORON =           $02;
LCD_CURSOROFF =          $00;
LCD_BLINKON =            $01;
LCD_BLINKOFF =           $00;

// flags for display/cursor shift
LCD_DISPLAYMOVE =       $08;
LCD_CURSORMOVE =        $00;
LCD_MOVERIGHT =         $04;
LCD_MOVELEFT =          $00;

// flags for function set
LCD_8BITMODE =         $10;
LCD_4BITMODE =         $00;
LCD_2LINE =            $08;
LCD_1LINE =            $00;
LCD_5x10DOTS =         $04;
LCD_5x8DOTS =          $00;

// flags for backlight control
LCD_BACKLIGHT =        $08;
LCD_NOBACKLIGHT =      $00;

En = %00000100; //0b Enable bit
Rw = %00000010; //0b Read/Write bit
Rs = %00000001; //0b Register select bit

type

  { TLCD }

  TLCD = class
    Fidev: TI2CLinuxDevice;
  private
    procedure Strobe(aData: Byte);
    procedure Write(aCmd: Byte; mode : Byte = 0);
  public
    constructor Create(aAddress: TI2CAddress; aBusID: Longword);
    destructor Destroy;
    procedure Init;
    procedure WriteString(aStr: String; aLine: Byte);
    Procedure Clear;
    procedure WriteBite(aData: Byte);
  end;


implementation

{ LCD }

constructor TLCD.Create(aAddress: TI2CAddress; aBusID: Longword);
begin
   Fidev := TI2CLinuxDevice.Create(aAddress, aBusID);
end;

destructor TLCD.Destroy;
begin
 Fidev.Free;
end;

procedure TLCD.Init;
begin
   with Fidev do begin
     WriteByte($03);
     WriteByte($03);
     WriteByte($03);
     WriteByte($02);

     WriteByte(LCD_FUNCTIONSET + LCD_2LINE + LCD_5x8DOTS + LCD_4BITMODE);
     WriteByte(LCD_DISPLAYCONTROL + LCD_DISPLAYON);
     WriteByte(LCD_CLEARDISPLAY);
     WriteByte(LCD_ENTRYMODESET + LCD_ENTRYLEFT);
     sleep(2);
   end;
end;

procedure TLCD.Strobe(aData: Byte);
begin
 // clocks EN to latch command
   with Fidev do begin
     WriteByte(aData + En + LCD_BACKLIGHT );
     Sleep(5);

     WriteByte((aData AND -5) + LCD_BACKLIGHT);    //  (aData &  ~En) En enable bit
     Sleep(1);
   end;
end;

procedure TLCD.WriteBite(aData: Byte);
begin
 Fidev.WriteByte(aData + LCD_BACKLIGHT);
 Strobe(aData);
end;

procedure TLCD.Write(aCmd: Byte; mode: Byte = 0);
begin
   // write a command to lcd
    WriteBite(mode + (aCmd and $F0));
    WriteBite(mode + (aCmd << 4) AND $F0);
end;

procedure TLCD.WriteString(aStr: String; aLine: Byte);
var
  i: integer;
begin
    // put string function
    case aLine of
        1: Write($80);
        2: Write($C0);
        3: Write($94);
        4: Write($D4);
     end;
   for i:=1 to Length(aStr)  do
     Write(Ord(aStr[i]), Rs);
end;

procedure TLCD.Clear;
begin
   // clear lcd and set to home
   Write(LCD_CLEARDISPLAY);
   Write(LCD_RETURNHOME);
end;


end.

