{Parallax Serial Terminal Disabler}

'This is a quick method to disable all of a set of serial writes.
'Does not support inputs, on purpose. 

PUB Start(baudrate)
  return True
PUB StartRxTx(rxpin, txpin, mode, baudrate)
  return True
PUB Stop
PUB Char(bytechr)
PUB Chars(bytechr, count)
PUB Str(stringptr)
PUB StrIn(stringptr)
PUB StrInMax(stringptr, maxcount)
PUB Dec(value)
PUB Bin(value, digits)
PUB Hex(value, digits)
PUB Clear
PUB ClearEnd
PUB ClearBelow
PUB Home
PUB Position(x, y)
PUB PositionX(x)
PUB PositionY(y)
PUB NewLine
PUB LineFeed
PUB MoveLeft(x)
PUB MoveRight(x)
PUB MoveUp(y)
PUB MoveDown(y)
PUB Tab
PUB Backspace
PUB Beep    