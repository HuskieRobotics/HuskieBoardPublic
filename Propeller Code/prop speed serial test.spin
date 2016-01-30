{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                       'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

OBJ
  ser      : "FASTSERIAL-080927"
  'ser      : "FullDuplexSerial" ' Can handle 230400
PUB start
ser.start(31, 30, 0, 921600)
loop

PUB loop
  ser.tx(ser.rx)
  loop
        