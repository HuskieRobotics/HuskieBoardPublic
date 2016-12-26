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
  adc_clk =      22
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
  byte runLED_DIPSwitch
  long dipSwitchStack[30]
  
OBJ
  adc   : "jm_adc124s021"
  pst   : "Parallax Serial Terminal"
  lcd   : "Serial_Lcd"                
  util  : "Util"
  sd    : "SD Controller"
  eeprom: "Propeller EEprom"
  main  : "main"
  
PUB init

  if long[@testAlreadyPassed] == 0  ' Test program has not yet passed, so run the tester
    pst.start(115200)
    adc.start(adc_1, adc_2, adc_clk, adc_di, adc_do)
    sd.start(sd_do, sd_clk, sd_di, sd_d3) 'Start the logger, this automatically mounts the sd card
    tester
  else     ' Run the normal script
    OUTA[led_0 .. led_3] := 0
    DIRA[led_0 .. led_3] := $F
    repeat 2                       
      waitcnt(cnt+clkfreq/10)
      OUTA[led_0 .. led_3] := %0001
      waitcnt(cnt+clkfreq/10)
      OUTA[led_0 .. led_3] := %0011
      waitcnt(cnt+clkfreq/10)
      OUTA[led_0 .. led_3] := %0010
      waitcnt(cnt+clkfreq/10)
      OUTA[led_0 .. led_3] := %0110
      waitcnt(cnt+clkfreq/10)
      OUTA[led_0 .. led_3] := %0100
      waitcnt(cnt+clkfreq/10)
      OUTA[led_0 .. led_3] := %1100
      waitcnt(cnt+clkfreq/10)
      OUTA[led_0 .. led_3] := %1000
      waitcnt(cnt+clkfreq/10)
      OUTA[led_0 .. led_3] := %1001
    OUTA[led_0 .. led_3] := 0
    DIRA[led_0 .. led_3] := 0
    main.main

PUB tester   : pass  |GPIO_Pass, ADC_Pass, SD_Pass
'''If any of these tests fail, the whole board fails!'''

    runLED_DIP_SwitchPassThrough 'Does not give a result within this list, it only starts a cog that lets the user manually test this function 

    ' Wait until 12 GPIO pins pass - we assume that these are the most likely to pass, and also guaruntee that we are fully seated in the fixture.
    repeat while !GPIO_Test
    waitcnt(cnt + clkfreq)

    GPIO_Pass := GPIO_Test
    
    ' Test ADC voltages
    ADC_Pass := ADC_Test
    
    'Test SD card
    SD_Pass := SD_Test

    pass := GPIO_Pass & ADC_Pass & SD_Pass
                      
    stopLED_DIP_SwitchPassThrough
    OUTA[led_0 .. led_3] := 0
    DIRA[led_0 .. led_3] := $F
    if pass
      ' Save to eeprom!!
      long[@testAlreadyPassed] := True
      eeprom.VarBackup(@testAlreadyPassed, @testAlreadyPassed +4) 
      
      repeat                     
        waitcnt(cnt + clkfreq/8)
        OUTA[led_0 .. led_2] := 7
        waitcnt(cnt + clkfreq/8)
        OUTA[led_0 .. led_2] := 0
        
    else  'Failure: Blink red light, turn on green LEDs (solid) for which ones passed.
      OUTA[led_0] := GPIO_Pass
      OUTA[led_1] := ADC_Pass
      OUTA[led_2] := SD_Pass
      repeat       
        waitcnt(cnt + clkfreq/8)  
        OUTA[led_3] := 1
        waitcnt(cnt + clkfreq/8)
        OUTA[led_3] := 0

PRI runLED_DIP_SwitchPassThrough
  runLED_DIPSwitch := true
  cognew(LED_DIP_Switch_Pass_Through, @dipSwitchStack)
  
PRI stopLED_DIP_SwitchPassThrough
  runLED_DIPSwitch := false

PRI LED_DIP_Switch_Pass_Through
  DIRA[led_0 .. led_3] := $F
  repeat while runLED_DIPSwitch
    OUTA[led_0 .. led_3] := !INA[dipSwitch_4 .. dipSwitch_1]
  OUTA[led_0 .. led_3] := 0
  DIRA[led_0 .. led_3] := 0
  
PRI SD_Test : pass | x
  '''Write 100 bytes of data, and verify,
  ''' and then write the same 100 bytes inverted, and read that back with verify.
  ''' Return $FF for success, $00 for failure

  bytefill(@dataBuffer, 0, 101)
  \sd.openFile(@sdFileName, "w")
  
  'Fill byte array with vals from 0 to 99
  repeat x from 0 to 99
    byte[@dataBuffer+x] := x+32 'Start writing with the " " character

  \sd.writeData(@dataBuffer) 'Write the data to the SD card
  \sd.closeFile

  bytefill(@dataBuffer, 0, 101)
  
  'Read from the file and verify what was written
  \sd.openFile(@sdFileName, "r")

  'Read data to the readData buffer
  \sd.readData(@dataBuffer, num_data_bytes)

  pass := True
  
  repeat x from 0 to 99
    pass &= !( byte[@dataBuffer+x] ^ (x+32) )
  pass === True  'Assignment: Does pass == True?

PRI ADC_Test   : pass | v
''For an explanation of where these values came from, refer to the Test Plan document

  pass := True
                   
  v := adc.read(0) 
  pass &= (v=<3227)
  pass &= (v=>2979)
  
  v := adc.read(1) 
  pass &= (v=<3873)
  pass &= (v=>3575)
  
  v := adc.read(2) 
  pass &= (v=<3198)
  pass &= (v=>2952)
  
  v := adc.read(3) 
  pass &= (v=<2840)
  pass &= (v=>2621)
  
  v := adc.read(4) 
  pass &= (v=<2130)
  pass &= (v=>1966)
  
  v := adc.read(5) 
  pass &= (v=<1420)
  pass &= (v=>1311)
  
  v := adc.read(6) 
  pass &= (v=<1062)
  pass &= (v=>980)
  
  v := adc.read(7) 
  pass &= (v=<387)
  pass &= (v=>357)

PRI GPIO_Test  : pass
  'Test each pair of pins
                                        
  pass := GPIO_Test_Pair(gpio_0, gpio_2)
  pass &= GPIO_Test_Pair(gpio_1, gpio_3)
  pass &= GPIO_Test_Pair(uart_rx, scl)
  pass &= GPIO_Test_Pair(uart_tx, sda)

PRI GPIO_Test_Pair(pin1, pin2) : pass | i
  OUTA[ uart_rx .. gpio_3] := 0
  DIRA[ uart_rx .. gpio_3] := 0
  DIRA[ pin1 ] := 1
  OUTA[ pin1 ] := 1

  i := INA & %00000000000000_11111111_0000000000 ' Magic number - all pins between uart_rx and gpio_3, inclusive
  i ^= |< pin1 ' negate pin1
  i ^= |< pin2 ' negate pin2
  pass := ( i == 0 )

 ' go ahead and check the reverse direction.

  OUTA[ uart_rx .. gpio_3] := 0
  DIRA[ uart_rx .. gpio_3] := 0
  DIRA[ pin2 ] := 1
  OUTA[ pin2 ] := 1

  i := INA & %00000000000000_11111111_0000000000 ' Magic number - all pins between uart_rx and gpio_3, inclusive
  i ^= |< pin1 ' negate pin1
  i ^= |< pin2 ' negate pin2
  pass &= ( i == 0 )

DAT
sdFileName              byte "TestLog.txt",0 'Name of test SD file
testAlreadyPassed       long 0  ' Stored in EEPROM
                                ' When the value is 0 on boot, it will run the test program.
                                ' When not 0, it will run the main script.
                                ' The test program will set it to a non 0 value once it passes.