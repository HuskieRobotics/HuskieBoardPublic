{AUTHOR: Lucas Rezac}
{REVISION: 1}
{REVISED BY: Brandon John, Bennett Johnson}
{PURPOSE: This object (herefore to be referred to as Object) is used to initiallize all code
                                developed for the RoboRIO Expansion Board(TM). At this time, Object can only do SD Logging,
                                although it has been prophesized that it will do more in the future.}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  pointerToPointerThing
  long  adcpointer
  long  ldcpointer
  long  datFileName[32] 'name can't be longer than 128 bytes
  
   
OBJ
  wood : "LOG STRING - Lucas Rezac"
  sd   : "SDcardTest"
  util : "Util"
  adc : "ADC driver"
  
PUB main
  longfill(@datFileName,0,32)

  'starts analogue to digital converter
  adc.start(17,19,18,$00FF)
  adcpointer := adc.pointer
  'starts the string logger            
  wood.init(1,0,0,460_800,@pointerToPointerThing,@datFileName)
  'starts the sd card 
  sd.init(7,6,5,4,@pointerToPointerThing,@datFileName,adcpointer)
  
  'this will be replaced with something else, eventually
  util.wait(40)
  sd.end
              
        