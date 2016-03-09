{AUTHOR: Calvin Field}
{PURPOSE: Will control the LED's on the robot. The mode/patterns will be changed through the UART connection}

CON                                                                                                                                         
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz           
        _xinfreq = 5_000_000

        ALL_OFF      = 0
        ALL_WHITE    = 1
        ALL_RED      = 2
        ALL_GREEN    = 3
        ALL_BLUE     = 4
        GREEN_ORANGE = 5

VAR
  byte mode
  byte num_leds
  long  stack[100]

OBJ
  neo : "Neopixel Driver"
  pst : "Parallax Serial Terminal"

PUB start(startMode, pin, led_num)
  mode := startMode

  num_leds := led_num
  neo.start(pin, led_num)

  cognew(main,@stack)

PRI main

  repeat 'Main loop   
    if mode == ALL_OFF           'MODE: 0
      led_off_func
      
    elseif mode == ALL_WHITE     'MODE: 1
      set_all_white_func

    elseif mode == ALL_RED       'MDDE: 2
      set_all_red_func

    elseif mode == ALL_GREEN     'MODE: 3
      set_all_green_func

    elseif mode == ALL_BLUE      'MDOE: 4
      set_all_blue_func

    elseif mode == GREEN_ORANGE  'MODE: 5
      green_orange_split_func
    

PUB change_mode(newMode)
  mode := newMode

PUB get_mode
  return mode

PRI led_off_func                                        'MODE: 0
  neo.off
  
PRI set_all_white_func | white                          'MODE: 1
  white := neo.colorx(255,255,255, 100)
  neo.set_all(white)

PRI set_all_red_func | red                              'MODE: 2
  red := neo.colorx(255,0,0, 100)
  neo.set_all(red)

PRI set_all_green_func | green                          'MODE: 3
  green := neo.colorx(0,255,0,100)
  neo.set_all(green)

PRI set_all_blue_func | blue                            'MODE: 4
  blue := neo.colorx(0,0,255,100)
  neo.set_all(blue)

PRI green_orange_split_func | green, orange, half, red  'MODE: 5
   
  green := neo.colorx(0,255,0,255)
  orange := neo.colorx(230,92,0,255)
  red := neo.colorx(255,0,0, 100)

  repeat   
    half := 0
    repeat half from 0 to (num_leds/2)-1
      neo.set(half, green)

    half := num_leds/2
    repeat half from (num_leds/2) to num_leds
      neo.set(half, orange)

    waitcnt(cnt + clkfreq) 'Wait a second then switch sides

    half := 0
    repeat half from 0 to (num_leds/2)-1
      neo.set(half, orange)

    half := num_leds/2
    repeat half from (num_leds/2) to num_leds
      neo.set(half, green)

    waitcnt(cnt + clkfreq)    

  
  