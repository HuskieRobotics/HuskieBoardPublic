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
  byte dataBuffer[101] 'Buffer for data to send to the SD card

OBJ
  adc   : "jm_adc124s021"
  pst   : "Parallax Serial Terminal"
  lcd   : "Serial_Lcd"                
  util  : "Util"
  sd    : "SD Controller"
  main  : "main"
  
PUB init
  if byte[@testAlreadyPassed] == 0  ' Test program has not yet passed, so run the tester
    pst.start(115200)
    adc.start(adc_1, adc_2, adc_clk, adc_di, adc_do)
    sd.start(sd_do, sd_clk, sd_di, sd_d3) 'Start the logger, this automatically mounts the sd card
    tester
  else     ' Run the normal script
    main.main

PRI tester   : pass
'''If any of these tests fail, the whole board fails!'''
    pass := $FF
    
    'Test SD card
    pass &= SD_Test
    
    'Test ADC voltages
    ADC_Test

    'Test all GPIO pins
    GPIO_Test

    'Test the dip switches and the built in LEDs 
    DIP_Test

    ' TODO: If passed everything, save to EEPROM, indicate on lights 
PRI SD_Test : pass | x
  '''Write 100 bytes of data, and verify,
  ''' and then write the same 100 bytes inverted, and read that back with verify.
  ''' Return $FF for success, $00 for failure

  pass := $FFFFFFFF
  bytefill(@dataBuffer, 0, 101)
  sd.openFile(@sdFileName)
  
  'Fill byte array with vals from 0 to 99
  repeat x from 0 to 99
    byte[@dataBuffer+x] := x+32 'Start writing with the " " character

  sd.writeData(@dataBuffer) 'Write the data to the SD card
  sd.closeFile

  bytefill(@dataBuffer, 0, 101)
  
  'Read from the file and verify what was written
  sd.readFile(@sdFileName)

  'Read data to the readData buffer
  sd.readData(@dataBuffer, num_data_bytes)

  repeat x from 0 to 99
    pass &= !( byte[@dataBuffer+x] ^ (x+32) )
  
  '''THIS FUNC IS NOT TESTED!'''

  

PRI ADC_Test

PRI GPIO_Test

PRI DIP_Test

DAT
sdFileName              byte "TestLog.txt",0 'Name of test SD file
testAlreadyPassed       byte 0  ' Stored in EEPROM
                                ' When the value is 0 on boot, it will run the test program.
                                ' When not 0, it will run the main script.
                                ' The test program will set it to a non 0 value once it passes.