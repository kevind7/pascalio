program ProOrange;

uses fpi2c, fpgpio, lcddriver, pascalio,
  sysutils, GpioButons;

var
    btNext, btCount: TButtonGpioLinuxPin;
    lcd: TLCD;

    Count: Longint;
procedure init;
begin
   // sh /Zeljus/script/gpioport.sh
     //gpio  0
   //  writeln(IntToStr(fpsystem('sudo sh -c "echo "0" > /sys/class/gpio/export"')));
   //  writeln(IntToStr(fpsystem('sudo sh -c "echo "in" > /sys/class/gpio/gpio0/direction"')));
     //gpio 1
  //   writeln(IntToStr(fpsystem('sudo sh -c "echo "1" > /sys/class/gpio/export"')));
  //   writeln(IntToStr(fpsystem('sudo sh -c "echo "in" > /sys/class/gpio/gpio1/direction"')));

  Count:= 0;
end;



begin
   Init;
   lcd:= TLCD.Create($3F, 0);

   try
     lcd.init;
     lcd.Clear;
     lcd.WriteString('First row', 1);
     lcd.WriteString('Last row', 2);

     // buton
     btNext    := TButtonGpioLinuxPin.Create(0);
     btNext.Direction    := gdIn;

     btCount    := TButtonGpioLinuxPin.Create(1);
     btCount.Direction    := gdIn;
     btCount.InterruptMode:=[gimRising, gimFalling];

    repeat
       count := btCount.PressCount;
       if count <> 0 then begin
         writeln(' ==========: ', count);
         lcd.Clear;
         lcd.WriteString('PressCount', 1);
         lcd.WriteString(IntToStr(Count), 2);
       end;
    until (not btNext.Value);


     lcd.Clear;
     lcd.WriteString('2222222222', 1);
     lcd.WriteString('exit', 2);

  finally
     lcd.Free;
     btNext.Destroy;
     btCount.Destroy;
   end;

end.

