{**********************************************************
*    Copyright (c) Zeljko Cvijanovic Teslic RS/BiH
*    www.zeljus.com
*    Created by: 13-10-2017
***********************************************************}
unit ADS1115;

{$mode objfpc}{$H+}

interface
uses
   SysUtils, fpi2c;

const
  //=========================================================================
  //  I2C ADDRESS/BITS
  //-------------------------------------------------------------------------
   ADS1015_ADDRESS                         = $49;    // 1001 000 (ADDR = GND)
  //=========================================================================

  //=========================================================================
  //  CONVERSION DELAY (in mS)
  //  -----------------------------------------------------------------------
   ADS1015_CONVERSIONDELAY                 = 1;
   //Orange pi zero   sleep(ADS1115_CONVERSIONDELAY)
   ADS1115_CONVERSIONDELAY                 = 135; //8;
  //=========================================================================

  //=========================================================================
  //  POINTER REGISTER
  //-------------------------------------------------------------------------
   ADS1015_REG_POINTER_MASK        = $03;
   ADS1015_REG_POINTER_CONVERT     = $00;
   ADS1015_REG_POINTER_CONFIG      = $01;
   ADS1015_REG_POINTER_LOWTHRESH   = $02;
   ADS1015_REG_POINTER_HITHRESH    = $03;
  //=========================================================================

  //=========================================================================
  //  CONFIG REGISTER
  //-------------------------------------------------------------------------
   ADS1015_REG_CONFIG_OS_MASK      = $8000;
   ADS1015_REG_CONFIG_OS_SINGLE    = $8000;  // Write: Set to start a single-conversion
   ADS1015_REG_CONFIG_OS_BUSY      = $0000;  // Read: Bit = 0 when conversion is in progress
   ADS1015_REG_CONFIG_OS_NOTBUSY   = $8000;  // Read: Bit = 1 when device is not performing a conversion

   ADS1015_REG_CONFIG_MUX_MASK     = $7000;

   ADS1015_REG_CONFIG_PGA_MASK     = $0E00;

   ADS1015_REG_CONFIG_MODE_MASK    = $0100;
   ADS1015_REG_CONFIG_MODE_CONTIN  = $0000;  // Continuous conversion mode
   ADS1015_REG_CONFIG_MODE_SINGLE  = $0100;  // Power-down single-shot mode (default)

   ADS1015_REG_CONFIG_DR_MASK      = $00E0;

   ADS1015_REG_CONFIG_CMODE_MASK   = $0010;
   ADS1015_REG_CONFIG_CMODE_TRAD   = $0000;  // Traditional comparator with hysteresis (default)
   ADS1015_REG_CONFIG_CMODE_WINDOW = $0010;  // Window comparator

   ADS1015_REG_CONFIG_CPOL_MASK    = $0008;
   ADS1015_REG_CONFIG_CPOL_ACTVLOW = $0000;  // ALERT/RDY pin is low when active (default)
   ADS1015_REG_CONFIG_CPOL_ACTVHI  = $0008;  // ALERT/RDY pin is high when active

   ADS1015_REG_CONFIG_CLAT_MASK    = $0004;  // Determines if ALERT/RDY pin latches once asserted
   ADS1015_REG_CONFIG_CLAT_NONLAT  = $0000;  // Non-latching comparator (default)
   ADS1015_REG_CONFIG_CLAT_LATCH   = $0004;  // Latching comparator

   ADS1015_REG_CONFIG_CQUE_MASK    = $0003;
   ADS1015_REG_CONFIG_CQUE_1CONV   = $0000;  // Assert ALERT/RDY after one conversions
   ADS1015_REG_CONFIG_CQUE_2CONV   = $0001;  // Assert ALERT/RDY after two conversions
   ADS1015_REG_CONFIG_CQUE_4CONV   = $0002;  // Assert ALERT/RDY after four conversions
   ADS1015_REG_CONFIG_CQUE_NONE    = $0003;  // Disable the comparator and put ALERT/RDY in high state (default)
  //=========================================================================


type
  TGains = ( gaTWOTHIRDS    = $0000,  // +/-6.144V range = Gain 2/3
             gaONE          = $0200,  // +/-4.096V range = Gain 1
             gaTWO          = $0400,  // +/-2.048V range = Gain 2 (default)
             gaFOUR         = $0600,  // +/-1.024V range = Gain 4
             gaEIGHT        = $0800,  // +/-0.512V range = Gain 8
             gaSIXTEEN      = $0A00  // +/-0.256V range = Gain 16
           );

  TChannels = (chMUX_SINGLE_0 = $4000,  // Single-ended AIN0
               chMUX_SINGLE_1 = $5000,  // Single-ended AIN1
               chMUX_SINGLE_2 = $6000,  // Single-ended AIN2
               chMUX_SINGLE_3 = $7000  // Single-ended AIN3
              );

  TDifs     = (diMUX_DIFF_0_1 = $0000,  // Differential P = AIN0, N = AIN1 (default)
               diMUX_DIFF_0_3 = $1000,  // Differential P = AIN0, N = AIN3
               diMUX_DIFF_1_3 = $2000,  // Differential P = AIN1, N = AIN3
               diMUX_DIFF_2_3 = $3000  // Differential P = AIN2, N = AIN3
               );

  TRates = (raDR_128SPS    = $0000,  // 128 samples per second
            raDR_250SPS    = $0020,  // 250 samples per second
            raDR_490SPS    = $0040,  // 490 samples per second
            raDR_920SPS    = $0060,  // 920 samples per second
            raDR_1600SPS   = $0080,  // 1600 samples per second (default)
            raDR_2400SPS   = $00A0,  // 2400 samples per second
            raDR_3300SPS   = $00C0  // 3300 samples per second
           );

  { TADS1115 }

  TADS1115 = class
    FI2Cdev: TI2CLinuxDevice;
    FGain: TGains;
    FRate: TRates;
    fConversionDelay: word;
    fBitShift: byte;
  private
    procedure writeRegister(aReg: byte; aValue: word);
    function readRegister(aReg: byte): Word;
  public
    constructor Create(aAddress: TI2CAddress; aBusID: Longword);
    destructor Destroy;

    function readADC_SingleEnded(aChannel: TChannels): Word;
    function readADC_Differential_0_1: Word;
    function readADC_Differential_2_3: Word;
    procedure startComparator_SingleEnded(aChannel: TChannels; aThreshold: word);
    function getLastConversionResults: word;

    property Gain: TGains read fGain write fGain;
    property Rate: TRates read FRate write FRate;
  end;


implementation

{ TADS1115 }
uses strutils;

procedure TADS1115.writeRegister(aReg: byte; aValue: word);
begin
  FI2Cdev.WriteByte(aReg);
  FI2Cdev.WriteRegWord(aReg, byte(aValue  Shr 8));
  FI2Cdev.WriteRegWord(aReg, byte(aValue  and $FF));
end;

function TADS1115.readRegister(aReg: byte): Word;
var
  temp: byte;
begin
  FI2Cdev.WriteRegWord(aReg, ADS1015_REG_POINTER_CONVERT);
  temp:= FI2Cdev.ReadRegWord(aReg);
  Result := ((FI2Cdev.ReadRegWord(aReg) Shl 8) or temp);
end;

constructor TADS1115.Create(aAddress: TI2CAddress; aBusID: Longword);
begin
   FI2Cdev := TI2CLinuxDevice.Create(aAddress, aBusID);
   fConversionDelay := ADS1115_CONVERSIONDELAY;
   fBitShift := 0;
   fGain := gaTWOTHIRDS;  // +/- 6.144V range (limited to VDD +0.3V max!)
   FRate := raDR_1600SPS; // 1600 samples per second (default)
end;

destructor TADS1115.Destroy;
begin
  FI2Cdev.Free;
end;

function TADS1115.readADC_SingleEnded(aChannel: TChannels): Word;
var
  config : Word;
begin

   // Start with default values
    config := ADS1015_REG_CONFIG_CQUE_NONE    or // Disable the comparator (default val)
              ADS1015_REG_CONFIG_CLAT_NONLAT  or // Non-latching (default val)
              ADS1015_REG_CONFIG_CPOL_ACTVLOW or // Alert/Rdy active low   (default val)
              ADS1015_REG_CONFIG_CMODE_TRAD   or // Traditional comparator (default val)
              ord(FRate) or // 1600 samples per second (default)
              ADS1015_REG_CONFIG_MODE_SINGLE;   // Single-shot mode (default)

    // Set PGA/voltage range
    config := config or word(fGain);

    // Set single-ended input channel
    config := config or ord(aChannel);

    // Set 'start single-conversion' bit
    config :=  config or ADS1015_REG_CONFIG_OS_SINGLE;

    // Write config register to the ADC
    writeRegister(ADS1015_REG_POINTER_CONFIG, config);

    // Wait for the conversion to complete
    sleep(fConversionDelay);

    // Read the conversion results
    // Shift 12-bit results right 4 bits for the ADS1015
    Result := readRegister(ADS1015_REG_POINTER_CONVERT); //  Shr fBitShift;
end;

function TADS1115.readADC_Differential_0_1: Word;
var
  config: word;
  res: word;
begin
  // Start with default values
  config := ADS1015_REG_CONFIG_CQUE_NONE    or // Disable the comparator (default val)
            ADS1015_REG_CONFIG_CLAT_NONLAT  or // Non-latching (default val)
            ADS1015_REG_CONFIG_CPOL_ACTVLOW or // Alert/Rdy active low   (default val)
            ADS1015_REG_CONFIG_CMODE_TRAD   or // Traditional comparator (default val)
            ord(FRate)   or // 1600 samples per second (default)
            ADS1015_REG_CONFIG_MODE_SINGLE;   // Single-shot mode (default)

  // Set PGA/voltage range
  config := config or word(fGain);

  // Set channels
  config := config  or ord(TDifs(diMUX_DIFF_0_1));          // AIN0 = P, AIN1 = N

  // Set 'start single-conversion' bit
  config := config or ADS1015_REG_CONFIG_OS_SINGLE;

  // Write config register to the ADC
  writeRegister(ADS1015_REG_POINTER_CONFIG, config);

  // Wait for the conversion to complete
  sleep(fConversionDelay);

  res := readRegister(ADS1015_REG_POINTER_CONVERT) Shr fBitShift;
  if fBitShift = 0 then
    Result := word(res)
  else  begin
    // Shift 12-bit results right 4 bits for the ADS1015,
    // making sure we keep the sign bit intact
    if (res > $07FF) then begin
      // negative number - extend the sign to 16th bit
      res := res or  $F000;
    end;
    Result := word(res);
  end;

end;

function TADS1115.readADC_Differential_2_3: Word;
var
  config: word;
  res: word;
begin
    // Start with default values
    config := ADS1015_REG_CONFIG_CQUE_NONE    or // Disable the comparator (default val)
             ADS1015_REG_CONFIG_CLAT_NONLAT  or // Non-latching (default val)
             ADS1015_REG_CONFIG_CPOL_ACTVLOW or // Alert/Rdy active low   (default val)
             ADS1015_REG_CONFIG_CMODE_TRAD   or // Traditional comparator (default val)
             ord(FRate)   or // 1600 samples per second (default)
             ADS1015_REG_CONFIG_MODE_SINGLE ;   // Single-shot mode (default)

  // Set PGA/voltage range
  config := config or word(fGain);

  // Set channels
  config := config or ord(TDifs(diMUX_DIFF_2_3));          // AIN2 = P, AIN3 = N

  // Set 'start single-conversion' bit
  config := config or ADS1015_REG_CONFIG_OS_SINGLE;

  // Write config register to the ADC
  writeRegister(ADS1015_REG_POINTER_CONFIG, config);

  // Wait for the conversion to complete
  sleep(fConversionDelay);

  // Read the conversion results
  res := readRegister(ADS1015_REG_POINTER_CONVERT) Shr fBitShift;
  if (fBitShift = 0) then
     Result := word(res)
  else  begin
    // Shift 12-bit results right 4 bits for the ADS1015,
    // making sure we keep the sign bit intact
    if (res > $07FF) then begin
      // negative number - extend the sign to 16th bit
      res :=  res or $F000;
    end;
    Result := word(res);
  end;

end;

procedure TADS1115.startComparator_SingleEnded(aChannel: TChannels;  aThreshold: word);
var
  config: word;
begin
     // Start with default values
     config := ADS1015_REG_CONFIG_CQUE_1CONV   or // Comparator enabled and asserts on 1 match
               ADS1015_REG_CONFIG_CLAT_LATCH   or // Latching mode
               ADS1015_REG_CONFIG_CPOL_ACTVLOW or // Alert/Rdy active low   (default val)
               ADS1015_REG_CONFIG_CMODE_TRAD   or // Traditional comparator (default val)
               ord(FRate)   or // 1600 samples per second (default)
               ADS1015_REG_CONFIG_MODE_CONTIN  or // Continuous conversion mode
               ADS1015_REG_CONFIG_MODE_CONTIN;   // Continuous conversion mode

    // Set PGA/voltage range
    config := config or word(fGain);

   // Set single-ended input channel
   config := config or ord(aChannel);

  // Set the high threshold register
  // Shift 12-bit results left 4 bits for the ADS1015
  writeRegister(ADS1015_REG_POINTER_HITHRESH, aThreshold Shl fBitShift);

  // Write config register to the ADC
  writeRegister(ADS1015_REG_POINTER_CONFIG, config);
end;

function TADS1115.getLastConversionResults: word;
var
  res: word;
begin
   // Wait for the conversion to complete
  sleep(fConversionDelay);

  // Read the conversion results
  res := readRegister(ADS1015_REG_POINTER_CONVERT)  Shr fBitShift;
  if (fBitShift = 0) then
     Result := word(res)
  else begin
    // Shift 12-bit results right 4 bits for the ADS1015,
    // making sure we keep the sign bit intact
    if (res > $07FF) then begin
      // negative number - extend the sign to 16th bit
      res := res or $F000;
    end;
    Result := word(res);
   end;
end;


end.
