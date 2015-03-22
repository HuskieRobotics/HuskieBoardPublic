{AUTHOR: Lucas Rezac}
{REVISION: 1}
{REVISED BY: Brandon John, Bennett Johnson}                                                          

CON
        _clkmode   = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq   = 5_000_000


        PP_RX      = 31  'receive from propplug 
        PP_TX      = 30  'trasmit to propplug
        EEPROM_SDA = 29
        EEPROM_SCL = 28
        

        LCD_Pin    = 15
        LCD_Baud   = 19_200

        ADC_CS     = 23
        ADC_DI     = 22
        ADC_DO     = 21
        ADC_CLK    = 20

        GPIO0      = 4
        GPIO1      = 5
        GPIO2      = 6
        GPIO3      = 7

        RRIO_TX    = 19   'so RX on propeller
        RRIO_RX    = 8
                              
        PROP_RRIO_TX = RRIO_RX     'TX from propeller to roborio
        PROP_RRIO_RX = RRIO_TX     'RX to propeller from roborio
        
        RRIO_CS    = 9
        RRIO_CLK   = 10
        RRIO_MISO  = 11
        RRIO_MOSI  = 12
        RRIO_SCL   = 13
        RRIO_SDA   = 14
        {  'What they were supposed to be connected to, but are not...         
        SD_D2      = 25
        SD_D3      = 27
        SD_CMD     = 3
        SD_CLK     = 2
        SD_D0      = 1
        SD_D1      = 0
        SD_SWTICH  = 24
        SD_DETECT  = 26 
        }
        
        SD_D2      = 0
        SD_D3      = 27
        SD_CMD     = 3
        SD_CLK     = 2
        SD_D0      = 1
        SD_D1      = 0
        SD_SWTICH  = 24
        SD_DETECT  = 26
              
        SD_CS      = SD_D3
        SD_DI      = SD_CMD
        SD_SCLK    = SD_CLK
        SD_DO      = SD_D0
                       
        LED_GREEN  = 18
        LED_YELLOW = 17
        LED_RED    = 16

        NEOPIXEL   = GPIO0

        input      = false
        output     = true

        on         = true
        off        = false
VAR
  long  pointerToPointerThing
  long  adcpointer
  long  ldcpointer
  long  FAT32Time
  byte  datFileName[256] 'file name can't be longer than 250 bytes
  byte  stop
  'long neopointer
   
OBJ
  RR_UART : "RR uart connection"
  sd      : "SDcardLogger"
  adc     : "ADC driver"
  'neo : "Neopixel Test 2"
  
PUB main
  longfill(@datFileName,0,32)        

  'starts analogue to digital converter
  adc.start2pin(ADC_DI,ADC_DO,ADC_CLK,ADC_CS,$00FF)
  adcpointer := adc.pointer
  'starts the string logger            
  RR_UART.init(PROP_RRIO_RX,PROP_RRIO_TX,460_800,@pointerToPointerThing,@datFileName,LCD_Pin,LCD_Baud, @stop,NEOPIXEL,LED_RED,LED_YELLOW,LED_GREEN,@FAT32Time)
  'starts the sd card
                   
  'DIRA[25] :=  1
  'DIRA[0]  :=  1
  'OUTA[25] :=  0
  'OUTA[0]  :=  0
  sd.init(27,25,0,1,@pointerToPointerThing,@datFileName,adcpointer, @stop,@FAT32Time)
          'SD_DO,SD_SCLK,SD_DI,SD_CS


  'update yellow and green LEDs to be inverse of I2C inputs
  {DIRA[LED_YELLOW]:= output
  DIRA[LED_GREEN]:= output    
  repeat
    OUTA[LED_YELLOW] := not INA[RRIO_SDA]
    OUTA[LED_GREEN] := not INA[RRIO_SCL]          '}    
                                                        