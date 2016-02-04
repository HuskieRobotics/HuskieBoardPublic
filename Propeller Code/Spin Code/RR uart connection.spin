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

        'Most of these pins will change because of the new board design
        rxPin = 19 'Expansion board receive pin
        txPin = 8 'Expansion board transmit pin

        ADC_CS_PIN     = 23
        ADC_DO_PIN     = 22
        ADC_DI_PIN     = 21
        ADC_CLK_PIN    = 20                                                                                                                                    
                                                                                                                                            
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
  byte  lcdstr[32]
  byte  buffer
  byte  rx, tx
  byte  checksum
  long  stopSDPointer
  long  neopointer
  long  LED_RED,LED_YELLOW,LED_GREEN
  long  timepointer
  long robotData
  
OBJ 
  ser : "FASTSERIAL-080927"
  adc : "ADC driver"
  pst : "Parallax Serial Terminal"
  lcd : "Serial_Lcd"                
  util : "Util"
  neo : "Neopixel Test 2"

PUB dontRunThisMethodDirectly | x  'this runs and tells the terminal that it is the wrong thing to run if it is run. Do not delete. Brandon
pst.start(230400)
repeat x from 0 to 10
  pst.Str(string("YOU RAN THE WRONG PROGRAM!!! RUN MAIN MAIN MAIN!!!",13))
return
PUB init(rx_, tx_, baudrate,dataPointer,savefilename,lcdpin_,lcdbaud_,stopSDPointer_,neopixelPin,LED_RED_,LED_YELLOW_,LED_GREEN_,timepointer_,maintransmission)
''sets the global data pointer to the given pointer
  globaldatapointer := dataPointer
  rx := rx_
  tx := tx_         
  baud := baudrate
  lcdbaud := lcdbaud_
  lcdpin := lcdpin_  
  LED_RED := LED_RED_
  LED_YELLOW := LED_YELLOW_
  LED_GREEN := LED_GREEN_
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
  dira[LED_RED] := true'set red LED to output
  dira[LED_YELLOW] := true 'set yellow LED to output
  util.wait(1)    'wait for debugging purposes
  pst.start(115_200)'open debug terminal                  
  pst.str(string("Program start!",13))
  ''starts the serial object
  adc.start(ADC_DI_PIN,ADC_DO_PIN,ADC_CLK_PIN,ADC_CS_PIN)'$00FF) 'Start the ADC driver object to get analog values
  ser.start(rxPin, txPin, 0, baud) 'start the FASTSERIAL-080927 cog
  lcd.init(lcdpin,lcdbaud,4) 'default lcd size is 4 lines
  lcd.cls 'clears LCD screen
  lcd.cursor(0) 'move cursor to beginning,  just in case
  
  'RECIEVING CODE
  repeat
    pst.str(string("  Outer loop",13))
    'cmd := ser.rxtime(100)    'get the command (The first byte of whats is being sent)
    cmd := ser.rx
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
      pst.str(string(" Sending all digital input vals "))
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
          outa[LED_GREEN]:=true'mark that first LED has been set
          
        else 'if some error occured, turns an LED on pin 15 : ON
          pst.str(string("SD: Error: Bad checksum!",13))
          pst.str(string("Checksum should be "))
          pst.dec(checksum)
          pst.str(string(", found: "))
          pst.dec(checktmp)       
          pst.str(string(13,"Data: "))
          pst.str(@dataPt)
          pst.char(13)
          outa[LED_RED]:=true
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
        outa[LED_YELLOW] := true    
      pst.char(13)
      
PRI set_lcd_disp_func | x          'COMMAND 08

      pst.str(string("cmd == 8",13))
      'moves cursor to 0,0
      lcd.home

      length := ser.rx

      if length <= 32
    '   gets all the string data                                                                                                                      
        repeat x from 0 to length
          lcdstr[x] := ser.rx
        
        lcd.str(long[lcdstr])
        pst.str(string("LCD: Set display string to :"))
        pst.str(long[lcdstr])
        pst.char(13)
      else
        pst.str(string("LCD: Error: Given length was > 32."))

PRI set_lcd_size_func | lines        'COMMAND 09

      pst.str(string("cmd == 9",13))

      lcd.finalize

      lines := ser.rx
                                                                   
      pst.str(string("LCD: # of lines set to: "))
      pst.dec(lines)
      
      lcd.init(lcdpin,lcdbaud,lines)

PRI request_all_digitalin_func | pin, values, original_checksum, newChecksum, send, count          'COMMAND 10
    original_checksum := ser.rx
    if original_checksum == $10
      values := INA 'Get all the digital input vals of the pins as a 4-byte long
      newChecksum := $10+values
      send := values + newChecksum
      'send := $10 + send '- Dont know if this is needed or not
      'Send the send variable to the roborio throught the tx pin

      count := STRSIZE(@send)
      repeat count
        ser.tx(send)
    else
      pst.str(string("Error: in function set_pin_func: Bad checksum: "))
      pst.hex(original_checksum,2)
      return


PRI request_single_analog_func |  sent_checksum, original_checksum, pin, value, send, new_checksum           'COMMAND 11
    pin := ser.rx
    sent_checksum := ser.rx
    original_checksum := cmd + pin
    if original_checksum == sent_checksum
      value := adc.in(pin)
      new_checksum := $11 + value
      send := value + new_checksum
      'send := $11 + send - Dont know if this is needed or not
      ser.tx(send) 'This might be sending only one byte at a time
    else
      pst.str(string("Error: in function request_single_analog_func: Bad checksum!"))
      return    

PRI request_all_analog_func | sent_checksum, new_checksum, value, values, send, count       'Command 12
    sent_checksum := ser.rx
    if sent_checksum == $12

    ' 'Have to go through all adc pins and add them to values
    ' 'Look at software spec sheet command 12 for more info
      count := 0
      repeat 8
        value := adc.in(count)
        count++
           
      
      repeat (STRSIZE(@send))
        ser.tx(send) 
    else
      pst.str(string("Error: in function request_single_analog_func: Bad checksum!"))
      return    
  
  
PRI set_pin_func | data, pin, value, original_checksum, count, transmit        'COMMAND 13    
    data := ser.rx
    value := data >> 3
    pin := data & %111
    original_checksum := ser.rx

    if original_checksum == ($13 + data)
       outa[pin] := value 'Set the specified pin as an output with the the value passed in

       repeat count  
         ser.tx($13) 'Send the confirmation back to the RoboRio
       
    else
      pst.str(string("Error: in function set_pin_func: Bad checksum!"))
      return


