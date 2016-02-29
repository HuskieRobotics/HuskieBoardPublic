

CON

        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz           
        _xinfreq = 5_000_000  

        R_LEDS_PIN = 4 'The LEDS on the right side of the Robot
        L_LEDS_PIN = 5 'The LEDS on the left side of the Robot
        R_LED_LEN = 60
        L_LED_LEN = 60      

VAR
  long RED, BLUE

OBJ
  R_neoDriver : "Neopixel Driver"
  L_neoDriver : "Neopixel Driver"       

PUB main                

  R_neoDriver.start(R_LEDS_PIN, R_LED_LEN)
  L_neoDriver.start(L_LEDS_PIN, L_LED_LEN)

  set_colors
  R_neoDriver.off

  R_neoDriver.set_all(RED)
  L_neoDriver.set_all(BLUE)    

PRI set_colors
  RED := R_neoDriver.colorx(255,0,0, 180)
  BLUE := R_neoDriver.colorx(0,0,255, 180)