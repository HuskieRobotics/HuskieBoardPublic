{AUTHOR: Calvin Field}
{PURPOSE: Will control the LED's on the robot. The mode/patterns will be changed through the UART connection
        Is in separate cog as to not interfere with other board functions}

CON                                                                                                                                         
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz           
        _xinfreq = 5_000_000

        ALL_OFF       = 0
        ALL_WHITE     = 1
        ALL_RED       = 2
        ALL_GREEN     = 3
        ALL_BLUE      = 4
        BLUE_ORANGE   = 5

        
        LED_WS2812_TYPE         = 0
        LED_WS2812b_TYPE        = 1

VAR
  byte mode
  byte stop_mode
  byte r,g,b  'These are the rgb values to manually change the colors
  byte set_all
  byte led_channel
  byte level  'This is the intensity of the custom rgb vals
  byte num_leds
  long cog
  long stack[150]

OBJ
  neo : "Neopixel Driver"

PUB start(startMode, pin, led_num, strip_type) | white

  neo.stop
  
  if cog
    cogstop(cog)
  
  mode := startMode
  num_leds := led_num
  
  if strip_type == LED_WS2812_TYPE
    neo.start(pin, led_num)
  elseif strip_type == LED_WS2812b_TYPE
    neo.start_b(pin,led_num)

  cog := cognew(main,@stack)

PRI main | custom     
  stop_mode := 1
  r := 255
  g := 255
  b := 255
  level := 100
  repeat 'Main loop      
    if stop_mode == 1
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

      elseif mode == BLUE_ORANGE   'MODE: 5
        blue_orange_split_func
    else
      custom := neo.colorx(r,g,b, level)
      if set_all
        neo.set_all(custom)
      else
        neo.set(led_channel, custom)
PUB change_mode(newMode)
  mode := newMode

PUB get_mode
  return mode
PUB stop_modes
  stop_mode := 0
PUB start_modes
  stop_mode := 1
PUB set_all_func(newR,newG,newB) 'Will only display this custom set RGB value if modes are stopped
  set_all := true
  r := newR
  g := newG
  b := newB
PUB set_intensity(newI)
  level := newI

PUB set_channel_rgb(ch, newR, newG, newB)'Will only display this custom set RGB value if modes are stopped  
  set_all := false
  led_channel := ch
  r := newR
  g := newG
  b := newB

PRI led_off_func                                         'MODE: 0
  neo.off
  
PRI set_all_white_func | white                           'MODE: 1
  white := neo.colorx(255,255,255, 100)
  neo.set_all(white)

PRI set_all_red_func | red                               'MODE: 2
  red := neo.colorx(255,0,0, 100)
  neo.set_all(red)

PRI set_all_green_func | green1, blue                    'MODE: 3
  green1 := neo.colorx(0,255,0,100)
  neo.set_all(green1)

PRI set_all_blue_func | blue                             'MODE: 4
  blue := neo.colorx(0,0,255,100)
  neo.set_all(blue)

PRI blue_orange_split_func | green2, blue, x, orange  'MODE: 5

  orange := neo.colorx(255,50,0,255)
  blue := neo.colorx(0,0,255, 255)
   
  x := 0
  repeat x from 0 to (num_leds/2)-1
    neo.set(x, blue)

  x := num_leds/2
  repeat x from (num_leds/2) to num_leds
    neo.set(x, orange)

  