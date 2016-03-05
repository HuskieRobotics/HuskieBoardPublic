CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000


OBJ
  pst : "Parallax Serial Terminal"
                      
PUB main | x
  pst.start(115200)

  dira[24 .. 27]~~

  dira[6 .. 9]~
  
  'repeat
   ' outa[24..27] := !ina[6..9]
  x := 24
  repeat

    repeat 10
  
      repeat x from 27 to 24
        outa[x] := true
        outa[23..(x-1)] := false
        outa[23] := false
        
        outa[(x+1)..28] := false
        outa[28] := false
        
        waitcnt(cnt + clkfreq / 10)

      outa[24..27] := false
    
      repeat x from 24 to 27
        outa[x] := true
        outa[23..(x-1)] := false
        outa[23] := false
        
        outa[(x+1)..28] := false
        outa[28] := false
        
        waitcnt(cnt + clkfreq / 10)

    outa[24..27] := false
    
    repeat 10
    
      repeat x from 24 to 27
        outa[x] := true
        waitcnt(cnt + clkfreq / 10)

      repeat x from 24 to 27
        outa[x] := false
        waitcnt(cnt + clkfreq / 10)

      