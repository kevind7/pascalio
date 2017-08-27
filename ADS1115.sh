#!/bin/zsh -f
I2C_BUS=0
ADS_ADDR="0x49"          # ADDR pin = GND
ADS_CONF_H_THERMO="0x8f" # OS=1(start conversion),MUX=000(diff. input AIN0,AIN1),PGA=111(range 0.256V),MODE=1(single shot mode)
ADS_CONF_L_THERMO="0x03" # DR=000(8sps),nouse COMP(def. value)
ADS_CONF_H_LM61="0xe5"   # OS=1(start conversion),MUX=110(single-end input AIN2),PGA=010(range 2.048V),MODE=1(single shot mode)
ADS_CONF_L_LM61="0x03"   # DR=000(8sps),nouse COMP(def. value)
LSB_THERMO=7.8125        # LSB= 7.8125 uV
LSB_LM61=62.5            # LSB=62.5    uV


# set and start A/D convert, wait and get value
THERMO_HEX=` i2cset -y ${I2C_BUS} ${ADS_ADDR} 0x01 ${ADS_CONF_H_THERMO} ${ADS_CONF_L_THERMO} i ; sleep 0.2 ; i2cget -y ${I2C_BUS} ${ADS_ADDR} 0x00 w | tr '[:lower:]' '[:upper:]' | sed -e 's/0X\(..\)\(..\)/\2\1/g'`
LM61_HEX=`   i2cset -y ${I2C_BUS} ${ADS_ADDR} 0x01 ${ADS_CONF_H_LM61}   ${ADS_CONF_L_LM61}   i ; sleep 0.2 ; i2cget -y ${I2C_BUS} ${ADS_ADDR} 0x00 w | tr '[:lower:]' '[:upper:]' | sed -e 's/0X\(..\)\(..\)/\2\1/g'`
echo "Thermocouple_raw_HEX : ${THERMO_HEX}"
echo "LM61CIZ_raw_HEX      : ${LM61_HEX}"

# HEX2DEC
THERMO=` echo "obase=10;ibase=16;${THERMO_HEX}"|bc`
if [ ${THERMO} -ge 32768 ];
then
    THERMO=`echo "${THERMO} - 65536"|bc`
fi
LM61=`   echo "obase=10;ibase=16;${LM61_HEX}"|bc`
echo "Thermocouple_raw     : ${THERMO}"
echo "LM61CIZ_raw          : ${LM61}"

# value to voltage
THERMO_uV=`echo "scale=12;${THERMO}*${LSB_THERMO}"|bc`
LM61_uV=`  echo "slace=12;${LM61}*${LSB_LM61}"|bc`
echo "Thermocouple_uV      : ${THERMO_uV} uV"
echo "LM61_uV              : ${LM61_uV} uV"

# voltage to temp.
THERMO_degC=`echo "scale=12;${THERMO_uV}/40.7"|bc`
LM61_degC=`  echo "scale=12;( ${LM61_uV}-600000 )/10000"|bc`
echo "Thermocouple_degC    : ${THERMO_degC} degC"
echo "LM61_degC            : ${LM61_degC} degC"

# result degC
DEGC=`echo "scale=12;${THERMO_degC}+${LM61_degC}"|bc`
echo "RESULT : ${DEGC} degC"