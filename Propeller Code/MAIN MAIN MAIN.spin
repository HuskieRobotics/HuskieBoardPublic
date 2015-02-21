{AUTHOR: Lucas Rezac}
{REVISION: 1}
{REVISED BY: Brandon John, Bennett Johnson}
{PURPOSE: This object (herefore to be referred to as Object) is used to initiallize all code
                                developed for the RoboRIO Expansion Board(TM). At this time, Object can only do SD Logging,
                                although it has been prophesized that it will do more in the future.}

CON
        _clkmode   = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq   = 5_000_000


        PP_RX      = 31  'receive from propplug 
        PP_RX      = 32  'trasmit to propplug
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

        RRIO_TX    = 7
        RRIO_RX    = 8
        RRIO_CS    = 9
        RRIO_CLK   = 10
        RRIO_MISO  = 11
        RRIO_MOSI  = 12
        RRIO_SCL   = 13
        RRIO_SDA   = 14
                  
        SD_D2      = 25
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

VAR
  long  pointerToPointerThing
  long  adcpointer
  long  ldcpointer
  long  datFileName[32] 'file name can't be longer than 128 bytes
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
  adc.start(ADC_DO,ADC_CLK,ADC_CS,$00FF)'ADC WON'T WORK!! EXPECTS ONE PIN COMM, connected over 2!
  adcpointer := adc.pointer
  'starts the string logger            
  RR_UART.init(RRIO_RX,RRIO_TX,0,460_800,@pointerToPointerThing,@datFileName,LCD_Pin,LCD_Baud, @stop)
  'starts the sd card 
  sd.init(SD_DO,SD_CLK,SD_DI,SD_CS,@pointerToPointerThing,@datFileName,adcpointer, @stop)

              
                          