 {AUTHOR: Lucas Rezac}                                                                                                                       
{TITLE: LOG STRING}                                                                                                                         
{REVISON: 2}                                                                                                                                
{REVISED BY: Brandon John, Lucas Rezac, Calvin Field}                                                                                                     
{PURPOSE v1: This object is used to monitor the communication between the RoboRIO and the propeller via UART                                
and log data recieved between the two to a CSV file format on an onboard SD Card.}                                                          
CON                                                                                                                                         
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz           
        _xinfreq = 5_000_000                                                                                                              
                                                                                                                                            
        rxSerialMode = 0'don't invert signal                                                                                                

        
        
        lcd_pin     = 18        'LCD communication pin
        lcd_baud    = 19_200    'LCD communication baudrate
        
        prop_rx     = 31 'This might be interfering with stuff       'Prop-Plug communication recieve pin
        prop_tx     = 30 'This might be interfering with stuff      'Prop-Plug communication transmit pin
        
        eeprom_sda  = 29        'EEPROM data line  -- Transfers data based on clock line
        eeprom_scl  = 28        'EEPROM clock line -- Keeps time to ensure packet viability
       
        adc_CS1     = 20        
        adc_CS2     = 19        
        adc_DO      = 21        
        adc_DI      = 23       
        adc_CLK     = 22       
        
        gpio_0      = 14        'General Purpose Input Output Pin 0
        gpio_1      = 15        'General Purpose Input Output Pin 1
        gpio_2      = 16        'General Purpose Input Output Pin 2
        gpio_3      = 17        'General Purpose Input Output Pin 3

        robo_i2c_scl =12
        robo_i2c_sda =13
        
        robo_tx     = 10        'RoboRIO Transmit Pin
        robo_rx     = 11        'RoboRIO Recieve Pin
        
        robo_cs     = 9         'RoboRIO CS Pin
        robo_clk    = 8         'RoboRIO Clock Pin
        robo_miso   = 7         'RoboRIO MISO
        robo_mosi   = 6         'RoboRIO MOSI

        switch_1    = robo_cs
        switch_2    = robo_clk
        switch_3    = robo_miso
        switch_4    = robo_mosi
        
        robo_sda    = 13        'RoboRIO SDA
        robo_scl    = 12        'RoboRIO SCL
        
        sd_d0       = 1         'SD Card DO
        sd_d1       = 0         'SD Card Data 1
        sd_d2       = 4         'SD Card Data 2      
        sd_d3       = 5         'SD Card CS
        sd_cmd      = 3         'SD Card CMD
        sd_clk      = 2         'SD Card Clock pin
                           
        sd_SPI_DO   = sd_d0
        sd_SPI_CLK  = sd_clk
        sd_SPI_DI   = sd_cmd
        sd_SPI_CS   = sd_d3
        
        led_0       = 24        'Onboard Green LED pin 0
        led_1       = 25        'Onboard Green LED pin 1
        led_2       = 26        'Onboard Green LED pin 2
        led_3       = 27        'Onboard Green LED pin 3
        
        neopixel    = gpio_0    'Point Neopixel to GPIO Pin 0 -- For ease of use       
                                                                                                                                            
        { COMMAND LIST }                                                                                                                    
        GIVE_DATA               = $00 ' Standard, gives basic data on robot. No response expected.                                                 
        WRITE_DATA              = $01 ' Sends a custom string for logging. Appended to current line that is being logged.                          
        SET_LOG_HEADER          = $02 ' Set log header                                                                                             
        SET_SD_FILE_NAME        = $03 ' Set SD log title                                                                                           
        CLOSE_LOG               = $04 ' Close log file, prepare for next log file                                                                  
        SET_TIME                = $05 ' Set current time                                                                                           
       '$06 - $07 reserved                                                                                                                  
        SET_LCD_DISP            = $08 ' Set LCD string display                                                                                     
        SET_LCD_SIZE            = $09 ' Sets the LCD size                                                                                          
       '$0A - $0F reserved                                                                                                                  
        REQUEST_ALL_DIGITAL_IN  = $10 ' Request current values for all inputs                                                                      
        REQUEST_SINGLE_ANALOG   = $11 ' Request current analog input of a single pin
        REQUEST_ALL_ANALOG      = $12 ' Requests current analog input vals of all ADC pins                                                                                 
        SET_PIN                 = $13 ' Sets the value on a specific pin on the propeller to input, output, or releases control of it
        SET_LED_MODE            = $14 ' Sets the LED mode for the neopixels              
       '$13 - $FF reserved                                                                                                                  
                                                                                                                                            
VAR                                                                                                                                         
  long  stack[512]                                                                                                                          
  long  stackSerial[512]                                                                                                                    
  long  globaldatapointer                                                                                                                   
  long  dataPt                                                                                                                              
  long  baud                                                                                                                                
  long  lcdbaud                 'LCD baudrate                                                                                               
  byte  lcdpin                  'pointer to location of the 'toLog' buffer                                                                  
  long  cmd, length                                                                                                                         
  byte  data1[256], data2[256]  'toLog buffer
  long  sdfilename              'pointer to the location of the filename to write to the sd
  byte  filedata[256]
  byte  generalBuffer[251]
  byte  buffer
  byte  rx, tx
  byte  checksum
  byte len2, count2
  long  stopSDPointer
  long  neopointer
  long  timepointer
  long robotData
  
OBJ 
  ser : "FASTSERIAL-080927"
  adc : "jm_adc124s021"   'This is the adc driver for the new MXP board design       
  pst : "Parallax Serial Terminal"
  lcd : "Serial_Lcd"                
  util : "Util"
  'neo : "Neopixel Test 2"
 ' neo : "Neopixel_demo"
  leds : "LED Main"
  'neoDriver : "Neopixel Driver"

PUB dontRunThisMethodDirectly | x  'this runs and tells the terminal that it is the wrong thing to run if it is run. Do not delete. Brandon
pst.start(230400)
repeat x from 0 to 10
  pst.Str(string("YOU RAN THE WRONG PROGRAM!!! RUN MAIN MAIN MAIN!!!",13))
return
PUB init(rx_, tx_, baudrate,dataPointer,savefilename,lcdpin_,lcdbaud_,stopSDPointer_,neopixelPin,timepointer_,maintransmission)
''sets the global data pointer to the given pointer
  globaldatapointer := dataPointer
  rx := rx_
  tx := tx_         
  baud := baudrate
  lcdbaud := lcdbaud_
  lcdpin := lcdpin_
  
  timepointer := timepointer_
  stopSDPointer := stopSDPointer_
  robotData := maintransmission
''sets the global file name to the given pointer
  sdfilename := savefilename
  'lcd.init(lcdpin,lcdbaud,2)
  'lcd.cls
  'for use in the double buffering system
  buffer := false
  'neo.init(neopixelPin,64, @neopointer)   
  cognew(main,@stack)
PRI main | x, in, errors, y, timetmp , intmp
  'starts the program, and waits 3 seconds for you to open up, clear, and re-enable the terminal
  dira[LED_1] := true'set red LED to output
  dira[LED_2] := true 'set yellow LED to output
  util.wait(1)    'wait for debugging purposes
  pst.start(115200)'open debug terminal

  'repeat
   ' pst.str(string("Working")) 'For testing purposes
                    
  pst.str(string("Program start!",13))
  'waitcnt(cnt + clkfreq / 2)

  ''starts the serial object
  adc.start(adc_CS1,adc_CS2,adc_CLK,adc_DI,adc_DO)  'New adc driver
  leds.start(0, neopixel, 60)
  ser.start(robo_rx, robo_tx, 0, baud) 'start the FASTSERIAL-080927 cog
  lcd.init(lcdpin,lcdbaud,4) 'default lcd size is 4 lines 
  lcd.cls 'clears LCD screen
  lcd.cursor(0) 'move cursor to beginning,  just in case
  
  'RECIEVING CODE
  repeat
    pst.str(string("  Outer loop",13))
    'cmd := ser.rxtime(100)    'get the command (The first byte of whats is being sent)
    cmd := ser.rxtime(100) 
    pst.str(string("Command: "))
    pst.hex(cmd, 2)
    pst.str(string("; Datapointer: "))
    pst.hex(long[globaldatapointer], 8)
    pst.char(13)

    'if cmd == REQUEST_ALL_DIGITAL_IN
     ' pst.str(string(" Sending all digital input vals "))
      
  '  command number 0 : Send basic data
    if cmd == GIVE_DATA
                         
      give_data_func
      
    'command number 1 : Recieve and write data
    elseif cmd == WRITE_DATA
    
      write_data_func

    'command number 2 : Set log header
    elseif cmd == SET_LOG_HEADER
    
      set_log_header_func
    
    'command number 3 : Set SD save file name
    elseif cmd == SET_SD_FILE_NAME
    
      set_sd_file_name_func

    'command number 4 : close log file, prepare for next log file
    elseif cmd == CLOSE_LOG

      close_log_func
    
    'command number 5 : sets time
    elseif cmd == SET_TIME

      set_time_func

    'command number 8 : sets lcd display
    elseif cmd == SET_LCD_DISP
      set_lcd_disp_func             
      
    'command number 9  : sets lcd size
    elseif cmd == SET_LCD_SIZE

      set_lcd_size_func

    'command number 0x10 : request all inputs
    elseif cmd == REQUEST_ALL_DIGITAL_IN
      request_all_digitalin_func

    'command number 0x11 : request analogue inputs
    elseif cmd == REQUEST_SINGLE_ANALOG
      request_single_analog_func

     'command number 0x12 : request analogue inputs
    elseif cmd == REQUEST_ALL_ANALOG
      request_all_analog_func

    'command number 0x13 : sets a pin to a value
    elseif cmd == SET_PIN
      set_pin_func

    elseif cmd == SET_LED_MODE
      set_led_mode_func

    else
      pst.str(string("Error: invalid command number",14))
      pst.hex(cmd,8)
    
      
      
PRI give_data_func | x, checktmp
    byte[robotData+0] := ser.rx      'LED Brightness  
    byte[robotData+1] := ser.rx      'Battery Voltage
    byte[robotData+2] := ser.rx      'State (enabled/disabled)
    byte[robotData+3] := ser.rx      'Time Left
    byte[robotData+4] := ser.rx      'User byte 1
    byte[robotData+5] := ser.rx      'User byte 2
    byte[robotData+6] := ser.rx      'User byte 3
    byte[robotData+7] := ser.rx      'User byte 4
    checksum := ser.rx

    checktmp := byte[robotData+0]
    repeat x from 1 to 5
      checktmp += byte[robotData+x]
    checktmp //= 256

    
PRI write_data_func | x, checktmp     ' COMMAND 01
      
      pst.str(string("cmd == 1",13))
   
      length := ser.rx   ' length of string to log to the file, inclueds cmd, len, and checksum bytes
      
      ' invalid packet if length is greater than 250
      if length =< 250

       ' switches to the data buffer that wasn't used last
        if buffer
          dataPt := @data1
        else
          dataPt := @data2        
        
        'pst.str(string("SD: Length:" ))
        'pst.dec(length)
        checksum := WRITE_DATA+length         'originally cmd+length
        'ser.rx
      ' gets all the string data and stores
      ' it to either data1 or data2,
      ' depending on the buffer value                                                                                                                                  
        repeat x from 0 to length-4 'get all data bytes, but don't get cmd, len, or checksum
          byte[dataPt+x] := ser.rx  'get next byte to log, store in buffer
        ' updates the checksum value
          checksum+=byte[dataPt+x]
        byte[dataPt+length-3]:= 0 'set end to 0 so that the string doesn't also write data from previous time  
      ' checks the sum against the given length
      ' if it is bad, then doesn't save the 0
        checktmp := ser.rx  'get the checksum          
        
        if checksum == checktmp 'is the checksum correct?
          long[globaldatapointer] := dataPt   'set the data to write to the sd to the new data
          pst.str(string("SD: Line written: "))     
          pst.str(long[globaldatapointer])
          pst.char(13)
          buffer := !buffer 'switch to use the other buffer next time
          outa[LED_1]:=true'mark that first LED has been set
          
        else 'if some error occured, turns an LED on pin 15 : ON
          pst.str(string("SD: Error: Bad checksum!",13))
          pst.str(string("Checksum should be "))
          pst.dec(checksum)
          pst.str(string(", found: "))
          pst.dec(checktmp)       
          pst.str(string(13,"Data: "))
          pst.str(@dataPt)
          pst.char(13)
          outa[LED_1]:=true
        'longfill(@dataPt,0,64)

PRI set_log_header_func                   'COMMAND 02
      pst.str(string("Error: set_log_header_func function isn't finished yet!"))
      return
      
PRI set_sd_file_name_func | x, checktmp    'COMMAND 03

      pst.str(string("cmd == 3",13))
    ' length of string
      length := ser.rx
      checksum := cmd+length  'set base of checksum
    ' tests if the length is less than 250
      if length < 250
      ' gets all the string data and stores
      ' it to either data1 or data2,
      ' depending on the buffer value                                                                                                                          
        repeat x from 0 to length-4
        
          filedata[x] := ser.rx
        ' 
        ' updates the checksum value
          checksum+=filedata[x]                          
      ' checks the sum against the given length
      ' if it is bad, then doesn't save the packet
        checktmp := ser.rx  
        'checksum //= 256 'mod 256 to calculate checksum
        if checksum == checktmp
          bytemove(sdfilename,@filedata, length-3)
          byte[sdfilename+length-3] := 0 'set the end of the string
          pst.str(string("SD: Set file name to :"))
          pst.str(sdfilename)
          pst.char(13)
        else 'if some error occured, turns an LED on pin 15 : ON
          outa[15]:=true
          pst.str(string("Error setting filename!!!",13,7))
          pst.str(string("Checksum: "))
          pst.hex(checksum,8)
          pst.str(string(", Expected: "))
          pst.hex(checktmp,8)

PRI close_log_func                   'COMMAND 04
      'pst.str(string("Error: close_log_func function isn't finished yet!"))
      'return
    long[globaldatapointer] := string("stop") 'the sd card logger will recognize new data, see that it is a string "stop",
                                               ' and call it's "reinit" function. That will wipe the filename, and setfilename
                                               'function will have to be called again.
PRI set_time_func | intmp, checktmp, timetmp   'COMMAND 05

      checksum:=SET_TIME  'originally checksum:=cmd
      
      intmp := ser.rx                                                   
      checksum+= intmp
      timetmp:=intmp
      
      intmp := ser.rx
      checksum+= intmp
      timetmp:=timetmp*256+intmp
      
      intmp := ser.rx
      checksum+= intmp
      timetmp:=timetmp*256+intmp
      
      intmp := ser.rx
      checksum+= intmp
      timetmp:=timetmp*256+intmp
      checktmp := ser.rx                               
      if checktmp == checksum
        long[timepointer]:=  timetmp  
        pst.str(string("Time set to: "))
        pst.hex(timetmp,8)
      else
        pst.str(string("Error setting time!",13,"Expected_got checksum: ",13))
        pst.hex(checksum,8)
        pst.char("_")
        pst.hex(checktmp,8)
        outa[LED_2] := true    
      pst.char(13)
      
PRI set_lcd_disp_func |  x, actualChecksum, expectedChecksum, count, messageLength, clear         'COMMAND 08

      bytefill(@generalBuffer, 0, 251) 'fill the generalBuffer byte array with 0s or else it will show whats leftover from the last display

      'Clear the screen (cannot use the cls method becuase of the 5ms implemented in it)
      lcd.clrln(0)
      lcd.clrln(1)
      lcd.clrln(2)
      lcd.clrln(3)
      lcd.home 


      messageLength := ser.rx  'Length is the length of the string to be displayed, so it is not including the sent checksum
      actualChecksum := $8 + clear + messageLength  'Start the checksum calculation
      count := 0
      pst.str(string(" Length of message: "))
      pst.dec(messageLength)
      pst.char(13)
      
      if messageLength =< 250
    '   gets all the string data     
                                                                                                                               
        repeat while (count < messageLength)  
          byte[@generalBuffer+count] := ser.rx
          actualChecksum += byte[@generalBuffer+count]
          pst.str(string(" loop count:"))
          pst.dec(count)
          pst.char(13)  
          count++ 
        
        actualChecksum &= $FF
        pst.str(string(" Actual Checksum:"))
        pst.hex(actualChecksum, 2)
          
        expectedChecksum := ser.rx 'Get the checksum sent by from the roboRio
        pst.str(string(" Expected checksum:"))
        pst.hex(expectedChecksum, 2)

        if actualChecksum == expectedChecksum
          lcd.str(@generalBuffer)
          pst.char(13)
          pst.str(string("LCD Set display string to: "))
          pst.str(@generalBuffer)
          pst.char(13)

          'Send confirmation back to the roboRio
          ser.tx($08)
          ser.tx($08)
        else
          pst.str(string(" Error in set_lcd_disp_func: Bad Checksum"))
      else
        pst.str(string(" LCD: Error: Given length was > 32.")) 

PRI set_lcd_size_func | lines        'COMMAND 09

      pst.str(string("cmd == 9",13))

      lcd.finalize

      lines := ser.rx
                                                                   
      pst.str(string("LCD: # of lines set to: "))
      pst.dec(lines)
      
      lcd.init(lcdpin,lcdbaud,lines)

PRI request_all_digitalin_func | pin, values, original_checksum, newChecksum, send, count          'COMMAND 10
    original_checksum := ser.rx
    pst.str(string("Sending them all"))
    if original_checksum == $10
      values := INA 'Get all the digital input vals of the pins as a 4-byte long
      'values := %11110000111100001111000011110000   'For testing correct transmission and checksum
      
      'Send all the digital pin vals along with the command byte and checksum
      ser.tx($10)
      ser.tx(values&$FF)
      ser.tx((values&$FF00)>>8)
      ser.tx((values&$FF0000)>>16)
      ser.tx((values&$FF000000)>>24)
      newChecksum := ($10+(values&$FF)+((values&$FF00)>>8)+((values&$FF0000)>>16)+((values&$FF000000)>>24))&$FF
      ser.tx(newChecksum)
      
    else
      pst.str(string("Error: in function set_pin_func: Bad checksum: "))
      pst.hex(original_checksum,2)
      return


PRI request_single_analog_func |  sent_checksum, original_checksum, pin, value, send, new_checksum           'COMMAND 11
    pin := ser.rx
    sent_checksum := ser.rx
    original_checksum := cmd + pin
    if original_checksum == sent_checksum
      value := adc.read(pin)  'Get the value of a single analog pin (size of 12bits)
      new_checksum := ($11 +(value&$FF) + (value>>8))&$FF
      ser.tx($11)
      ser.tx(value&$FF)
      ser.tx(value>>8)
      ser.tx(new_checksum)          
    else
      pst.str(string("Error: in function request_single_analog_func: Bad checksum!"))
      return    

PRI request_all_analog_func | sent_checksum, new_checksum, value, values, send, count, firstByte, newFullByte      'Command 12
    sent_checksum := ser.rx
    if sent_checksum == $12

    ' 'Go through all adc pins and add them to values
    ' 'Look at software spec sheet command 12 for more info
      'Could put this in a loop
      'adc.unitTestStart 'Use this for testing the old adc driver
      adc.setArray 'Fill the adc array with the current adc vals (only to be used with the new adc driver)
       
      byte[@tempdata+0] := adc.readArray(0)>>4           
      byte[@tempdata+1] := (adc.readArray(0)& $00f)<<4             'Fill in the second half of the byte first
      byte[@tempdata+1] := byte[@tempdata+1] | adc.readArray(1)>>8 'Fill in the first half of the byte by attaching the last 4 bits of adc 2 to it
      byte[@tempdata+2] := adc.readArray(1) & $ff
      
      byte[@tempdata+3] := adc.readArray(2)>>4
      byte[@tempdata+4] := (adc.readArray(2)& $00f)<<4             'Fill in the second half of the byte first 
      byte[@tempdata+4] := byte[@tempdata+4] | adc.readArray(3)>>8 'Fill in the first half of the byte by attaching the last 4 bits of adc 2 to it
      byte[@tempdata+5] := adc.readArray(3) & $ff

      byte[@tempdata+6] := adc.readArray(4)>>4
      byte[@tempdata+7] := (adc.readArray(4)& $00f)<<4             'Fill in the second half of the byte first 
      byte[@tempdata+7] := byte[@tempdata+7] | adc.readArray(5)>>8 'Fill in the first half of the byte by attaching the last 4 bits of adc 2 to it
      byte[@tempdata+8] := adc.readArray(5) & $ff

      byte[@tempdata+9] := adc.readArray(6)>>4
      byte[@tempdata+10] := (adc.readArray(6)& $00f)<<4              'Fill in the second half of the byte first 
      byte[@tempdata+10] := byte[@tempdata+10] | adc.readArray(7)>>8 'Fill in the first half of the byte by attaching the last 4 bits of adc 2 to it
      byte[@tempdata+11] := adc.readArray(7) & $ff

      ser.tx($12)
      new_checksum := $12 'Initialize the checksum as the command byte so the final checksum is calculated correctly
      
      'Send the 12 bytes in the array that was filled above
      repeat 12
        new_checksum := new_checksum+byte[count+@tempdata]
        ser.tx(byte[count+@tempdata])
        count++                                          
      ser.tx(new_checksum) 
    else
      pst.str(string("Error: in function request_single_analog_func: Bad checksum!"))
      return    
  
  
PRI set_pin_func | data, pin, dir_val, out_val, original_checksum, count, transmit        'COMMAND 13    
    data := ser.rx
    dir_val := (data >> 6) & %1
    out_val := data >> 7
    pin := data & %11111
    original_checksum := ser.rx

    if original_checksum == ($13 + data)
       dira[pin] := dir_val
       outa[pin] := out_val'Set the specified pin as an output with the the value passed in
       ser.tx($13) 'Send the confirmation back to the RoboRio
       ser.tx($13) 'Send the confirmation back to the RoboRio
       
    else
      pst.str(string("Error: in function set_pin_func: Bad checksum!"))
      return

PRI set_led_mode_func | mode, original_checksum, calc_checksum          'COMMAND 14

  mode := ser.rx

  original_checksum := ser.rx
  calc_checksum := ( $14 + mode )& $FF

  if calc_checksum == original_checksum
    leds.change_mode(mode)

    ser.tx($14)
    ser.tx($14)
  


dat
  tempdata byte  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  'This is the byte array that will be used for the adc values