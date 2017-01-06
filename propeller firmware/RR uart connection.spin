{AUTHOR: Lucas Rezac, Calvin Field}                                                                                                                       
{TITLE: LOG STRING}                                                                                                                           
{REVISED BY: Brandon John, Lucas Rezac, Calvin Field}                                                                                                     
CON     'Permanent constants
                                                                                                                                    
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz           
        _xinfreq = 5_000_000                                                                                                              
                                                                                                                                            
        
        lcd_pin     = 18        'LCD communication pin
        
        prop_rx     = 31        'Prop-Plug communication recieve pin
        prop_tx     = 30        'Prop-Plug communication transmit pin
        
        eeprom_sda  = 29        'EEPROM data line
        eeprom_scl  = 28        'EEPROM clock line
       
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
                                
        robo_mosi   = 6         'RoboRIO MOSI   
        robo_miso   = 7         'RoboRIO MISO   
        robo_clk    = 8         'RoboRIO Clock Pin 
        robo_cs     = 9         'RoboRIO CS Pin    

        switch_1    = robo_mosi      '6
        switch_2    = robo_miso      '7
        switch_3    = robo_clk       '8
        switch_4    = robo_cs        '9
        
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
        
        led_0       = 24        'Onboard Green  LED 0
        led_1       = 25        'Onboard Green  LED 1
        led_2       = 26        'Onboard Green  LED 2
        led_3       = 27        'Onboard Red    LED 3
        
        neopixel    = gpio_0    'Point Neopixel to GPIO Pin 0 -- For ease of use       

        
        ' Prevent GPIO output control on certain pins
        ' When the serial API sets DIRA or OUTA, first AND the request
        ' with this constant so that it cannot break communication.
        OUTPUT_MASK = %00_00_1111_00000_1111111_00_1111_000000
        '          EEPROM+Ser      ADC         UART     SDCARD
        'This allows control of the 4 LEDs, GPIO, roboRIO rx and tx                                                                                                                     
CON     { COMMAND LIST }                                                                                                                    
        WRITE_DATA              = $01 ' Sends a custom string for logging. Appended to current line that is being logged.                          
        SET_LOG_HEADER          = $02 ' Deprecated: Set log header. Use WRITE_DATA instead.                                                                                             
        SET_SD_FILE_NAME        = $03 ' Set SD log filename/opens file                                                                                           
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
        SET_LED_RGB             = $15 ' Sets the LEDs to a custom RGB value
        SET_LED_INTENSITY       = $16 ' Sets the LEDs brightness intensity (0-100)    
       '$17 - $FE reserved
        REQUEST_VERSION         = $FF ' Request the HuskieBoard's current version                                                                                                                  
CON    ''user settings
                                                        
        lcd_baud    = 19_200    'LCD communication baudrate
        LCD_SIZE    = 4         'default lcd size is 4 lines                                                                                                                                          
VAR                                                                                                                                         
  long  stack[512]                                                                                                                                    
  long  baud                                                                                                                                
  long  cmd, length   
  long  firmware_version                                                                                                                       
  byte  serialBuffer[256]    'Used for caching received data to check checksums before using.                                                        
  'byte  generalBuffer[251] 
  byte  checksum
  byte  len2, count2                        
  
OBJ 
  ser    : "FASTSERIAL-080927"
  adc    : "jm_adc124s021"   'This is the adc driver for the new MXP board design       
  pst    : "Parallax Serial Terminal"   'Uncomment this line to enable debugging statements on the USB port at 115200 baud.
  'pst    : "Disabled Parallax Serial Terminal"   'Uncomment this line to disable debugging
  lcd    : "Serial_Lcd"  
  leds   : "LED Main"
  sd     : "SD Controller"

PUB dontRunThisMethodDirectly  'this runs and tells the terminal that it is the wrong thing to run if it is run. Do not delete. Brandon
  pst.start(115200)
  repeat 10
    pst.Str(string("YOU RAN THE WRONG PROGRAM!!! RUN main.spin!!!",13))
    waitcnt(cnt+clkfreq)'Wait 1 second
  abort

PUB init(baud_,firmware_version_)

  baud := baud_
  firmware_version := firmware_version_
                              
  cognew(main,@stack)

PRI main

  pst.start(115200)'open debug terminal
  pst.str(string("Start"))

  adc.start(adc_CS1,adc_CS2,adc_CLK,adc_DI,adc_DO)  'New adc driver    
  leds.start(0, neopixel, 40)
  ser.start(robo_rx, robo_tx, 0, baud) 'start the FASTSERIAL-080927 cog
  lcd.init(lcd_pin,lcd_baud,LCD_SIZE)  
  lcd.cls 'clears LCD screen
  lcd.cursor(0) 'move cursor to beginning

  pst.str(string("Mounting SD card...",13))
  sd.start(sd_SPI_DO, sd_SPI_CLK, sd_SPI_DI, sd_SPI_CS) 'Start the logger, this automatically mounts the sd card
  pst.str(string("SD card mounted successfully!",13))
  
  
  'RECIEVING CODE
  repeat                              
   'get the command (The first byte of whats is being sent)
    cmd := ser.rxtime(100)
      
    'command number 1 : Recieve and write data
    if cmd == WRITE_DATA
      printcmd
      write_data_func

    'command number 2 : Set log header
    elseif cmd == SET_LOG_HEADER
      printcmd
      set_log_header_func
    
    'command number 3 : Set SD save file name
    elseif cmd == SET_SD_FILE_NAME
      printcmd
      set_sd_file_name_func

    'command number 4 : close log file, prepare for next log file
    elseif cmd == CLOSE_LOG
      printcmd
      close_log_func
    
    'command number 5 : sets time for SD card file writes. This does not increment the time automatically.
    elseif cmd == SET_TIME
      printcmd
      set_time_func

    'command number 8 : sets lcd display
    elseif cmd == SET_LCD_DISP
      printcmd
      set_lcd_disp_func             
      
    'command number 9  : sets lcd size
    elseif cmd == SET_LCD_SIZE
      printcmd
      set_lcd_size_func

    'command number 0x10 : request all inputs
    elseif cmd == REQUEST_ALL_DIGITAL_IN
      printcmd
      request_all_digitalin_func

    'command number 0x11 : request analogue inputs
    elseif cmd == REQUEST_SINGLE_ANALOG
      printcmd
      request_single_analog_func

     'command number 0x12 : request analogue inputs
    elseif cmd == REQUEST_ALL_ANALOG
      printcmd
      request_all_analog_func

    'command number 0x13 : sets a pin to a value
    elseif cmd == SET_PIN
      printcmd
      set_pin_func

    elseif cmd == SET_LED_MODE
      printcmd
      set_led_mode_func

    elseif cmd == SET_LED_RGB
      printcmd
      set_led_rgb_func

    elseif cmd == SET_LED_INTENSITY

    elseif cmd == REQUEST_VERSION
      printcmd
      request_version_func
      
    elseif cmd <> -1      
      pst.str(string("Error: invalid command number: "))
      pst.hex(cmd,8)
      pst.char(13)
      pst.char(13)

PRI printcmd
    pst.str(string(13,"cmd == "))
    pst.hex(cmd,8)
    pst.char(13)

PRI recieve_string(strptr,errorMsg,maxlength) | x,checktmp
    length := ser.rx
    checksum := cmd+length
    if maxlength and length < maxlength
      repeat x from 0 to length-1
        byte[strptr+x] := ser.rx
        checksum += byte[strptr+x]

      byte[strptr+length] := 0 
      checktmp := ser.rx
       
      if checksum == checktmp
        pst.str(string(13,"Length: "))
        pst.dec(length)
        pst.char(13)
        return length
      else
        pst.str(errorMsg)
        pst.str(string(13,"Bad checksum!",13))
        pst.str(string("Checksum should be "))
        pst.dec(checksum)
        pst.str(string(", found: "))
        pst.dec(checktmp)       
        pst.str(string(13,"Data: "))
        pst.str(strptr)
        pst.char(13)
        return false
    else
      pst.str(string("Error: length recieved was longer than given max length",13))
      return false

PRI request_version_func | originalChecksum, newChecksum, version
    version := firmware_version
    originalChecksum := ser.rx
    pst.hex(version,8)
    if originalChecksum == $FF
      ser.tx($FF)
      ser.tx(version&$FF)
      ser.tx((version&$FF00)>>8)
      ser.tx((version&$FF0000)>>16)
      ser.tx((version&$FF000000)>>24)
      newChecksum := ($10+(version&$FF)+((version&$FF00)>>8)+((version&$FF0000)>>16)+((version&$FF000000)>>24))&$FF
      ser.tx(newChecksum)
    else
      pst.str(string("Wrong checksum in request_version_func"))


PRI write_data_func                   ' COMMAND 01

    if recieve_string(@serialBuffer,string("Error receiving in write_data_func"),255)
      sd.writeData(@serialBuffer)
      pst.str(string("SD: Line written: "))     
      pst.str(@serialBuffer)
      pst.char(13)
                                

PRI set_log_header_func                  'COMMAND 02                    
    
    if recieve_string(@serialBuffer,string("Error setting SD log header!"),255)
      pst.str(string("New log header recieved: "))
      pst.str(@serialBuffer)
      pst.char(13)
      sd.writeData(@serialBuffer)
           
PRI set_sd_file_name_func | t               'COMMAND 03
    sd.closeFile     'Make sure file is closed before opening a new one.
    pst.str(string("SD card file was closed."))
    
    if recieve_string(@serialBuffer,string("Error reading new file name"),32)
      t:= sd.openFile(@serialBuffer,"a")  'append to the file
      pst.str(string("SD: Set file name to: "))
      pst.str(@serialBuffer)
      pst.char(13)                                           
      pst.str(string("SD: File open success (0 is good): "))
      pst.dec(t)
      pst.char(13)

PRI close_log_func                       'COMMAND 04
    if ser.rx == $04
      sd.closeFile
      pst.str(string("SD card file was closed."))
    else
      pst.str(string("Did not close file - bad checksum!"))
                                               
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
      sd.setdatedirect(timetmp)  
      pst.str(string("Time set to: "))
      pst.hex(timetmp,8)
    else
      pst.str(string("Error setting time!",13,"Expected_got checksum: ",13))
      pst.hex(checksum,8)
      pst.char("_")
      pst.hex(checktmp,8)     
    pst.char(13)
      
PRI set_lcd_disp_func | len         'COMMAND 08

    len := recieve_string(@serialBuffer,string("Error reading LCD data"),251) 
    if len
      lcd.strWithLen(@serialBuffer,length)
      pst.char(13)
      pst.str(string("LCD Set display string to: "))
      pst.str(@serialBuffer)
      pst.char(13)
       
      'Send confirmation back to the roboRio
      ser.tx($08)
      ser.tx($08)

PRI set_lcd_size_func | lines        'COMMAND 09


    lines := ser.rx
    if ser.rx == (($09 + lines) & $FF)
      if lines == 2 or lines == 4
        lcd.finalize   'Stop LCD controller, so that it can be resumed.
        pst.str(string("LCD: # of lines set to: "))
        pst.dec(lines) 
        lcd.init(lcd_pin,lcd_baud,lines)
         
        ser.tx($09)
        ser.tx($09)
      else
        pst.str(string("LCD: Invalid # of lines"))
        ser.tx($09)
        ser.tx($00)

PRI request_all_digitalin_func | pin, values, original_checksum, newChecksum, send, count          'COMMAND 10
    if ser.rx == $10 'Does checksum byte match?
      values := INA 'Get all the digital input vals of the pins as a 4-byte long
      
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


PRI request_single_analog_func |  pin, value, send, new_checksum           'COMMAND 11
    pin := ser.rx  
    if ( (cmd + pin) & $FF) == ser.rx    'Does checksum byte match?
      value := adc.read(pin)  'Get the value of a single analog pin (size of 12bits)
      new_checksum := ($11 +(value&$FF) + (value>>8))&$FF
      ser.tx($11)
      ser.tx(value&$FF)
      ser.tx(value>>8)
      ser.tx(new_checksum)          
    else
      pst.str(string("Error: in function request_single_analog_func: Bad checksum!"))
      return    

PRI request_all_analog_func | new_checksum, value, values, send, count, firstByte, newFullByte      'Command 12
    if ser.rx == $12  'Does checksum byte match?

    ' 'Go through all adc pins and add them to values
      adc.readToArray 'Fill the adc array with the current adc vals (only to be used with the new adc driver)
     
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
      pst.str(string("Sending Raw ADC Vals"))
      pst.char(13)
      count := 0
      repeat 12
        new_checksum := new_checksum+byte[@tempdata+count]       
        ser.tx(byte[@tempdata+count])

        count++
                                         
      ser.tx(new_checksum)


    else
      pst.str(string("Error: in function request_single_analog_func: Bad checksum!"))
      return    
  
  
PRI set_pin_func | data, pin, dir_val, out_val        'COMMAND 13    
    data := ser.rx
    
    dir_val := (data & %00000_010 ) >> 1
    out_val := (data & %00000_001 )
    pin := (data & %11111_000) >> 3

    if ser.rx == ($13 + data)&$FF
      if (|<pin) & OUTPUT_MASK
        dira[pin] := dir_val
        outa[pin] := out_val'Set the specified pin as an output with the the value passed in 
        ser.tx($13) 'Send the confirmation back to the RoboRio
        ser.tx($13) 'Send the confirmation back to the RoboRio
      else                                                   
        ser.tx($13)
        ser.tx($0) 'Send Error back to roboRIO
       
    else
      pst.str(string("Error: in function set_pin_func: Bad checksum!"))

PRI set_led_mode_func | mode, original_checksum, calc_checksum          'COMMAND 14

    mode := ser.rx
     
    original_checksum := ser.rx
    calc_checksum := ( $14 + mode )& $FF
     
    if calc_checksum == original_checksum
      pst.str(string("Starting mode: "))
      pst.dec(mode)
      pst.char(13)
      leds.start_modes
      leds.change_mode(mode)
    else
      pst.str(string("Error: in function set_led_mode_func: Bad checksum!"))
      return
     

PRI set_led_rgb_func | r,g,b, original_checksum, calc_checksum               'COMMAND 15
    r := ser.rx
    g := ser.rx
    b := ser.rx
     
    original_checksum := ser.rx
    calc_checksum := ($15 + r + g + b) & $FF
     
    if calc_checksum == original_checksum
      leds.stop_modes
      leds.set_all(r,g,b)
    else
      pst.str(string("Error: in function set_led_rgb_func: Bad checksum!"))
      return
     
     
PRI set_led_intensity_func | intensity, original_checksum, calc_checksum     'COMMAND 16
    intensity := ser.rx
     
    original_checksum := ser.rx
    calc_checksum := ($15 + intensity) & $FF
     
    if calc_checksum == original_checksum
      leds.stop_modes
      leds.set_intensity(intensity)
    else
      pst.str(string("Error: in function set_led_intensity_func: Bad checksum!"))
      return
     

dat
  tempdata byte  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  'This is the byte array that will be used for the adc values