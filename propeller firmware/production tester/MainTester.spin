{
Author: Calvin Field
Revised by:
Pin info is on the "To do on Board Design"
Test board plan info is on the "Test Plan" google doc
}


CON
        _clkmode    = xtal1 + pll16x                                           'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq    = 5_000_000

  sd_d1 =        0
  sd_do =        1
  sd_clk =       2
  sd_di =        3
  sd_d2 =        4
  sd_d3 =        5

  dipSwitch_4 =  6
  dipSwitch_3 =  7
  dipSwitch_2 =  8
  dipSwitch_1 =  9

  uart_rx =      10
  uart_tx =      11

  scl =          12
  sda =          13

  gpio_0 =       14
  gpio_1 =       15
  gpio_2 =       16
  gpio_3 =       17

  lcd_pin =      18

  adc_2 =        19
  adc_1 =        20
  adc_do =       21
  adc_clk =     22
  adc_di =       23

  led_0 =        24
  led_1 =        25
  led_2 =        26
  led_3 =        27

  eeprom_scl =   28
  eeprom_sda =   29

  usb_tx =       30
  usb_rx =       31

  num_data_bytes = 100

VAR
  byte writeData[100] 'Logs 100bytes of data to the SD card
  byte readData[100] 'Where the read data will be stored from the SD card

OBJ
  adc : "jm_adc124s021"
  pst : "Parallax Serial Terminal"
  lcd : "Serial_Lcd"                
  util : "Util"
  sd   : "SD Controller"
  
PUB init
  pst.start(115200)
  adc.start(adc_1, adc_2, adc_clk, adc_di, adc_do)
  sd.start(sd_do, sd_clk, sd_di, sd_d3) 'Start the logger, this automatically mounts the sd card
  main

PRI main
'''If any of these tests fail, the whole board fails!'''

    'Test SD card
    SD_Test

    'Test ADC voltages
    ADC_Test

    'Test all GPIO pins
    GPIO_Test

    'Test the dip switches and the built in LEDs 
    DIP_Test

PRI SD_Test | x
  '''Write 100 bytes of data, and verify,
  ''' and then write the same 100 bytes inverted, and read that back with verify.

  sd.openFile(@sdFileName)
  
  'Fill byte array with vals from 0 to 99
  repeat x from 0 to 99
    byte[@writeData+x] := x

  sd.writeData(@writeData) 'Write the data to the SD card
  sd.closeFile

  'Read from the file and verify what was written
  sd.openFile(@sdFileName)

  'Read data to the readData buffer
  sd.readData(readData, num_data_bytes)

  '''THIS FUNC IS NOT FINISHED!'''

  

PRI ADC_Test

PRI GPIO_Test

PRI DIP_Test

DAT
sdFileName    byte "TestLog.txt",0 'Name of test SD file
