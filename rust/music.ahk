; The total distance between looking straight up and down
height := 1582
; The current look height (assuming no other mouse input)
current := 0
; Some delays to ensure that all inputs register
postMoveDelay := 60
clickHold := 70
postClickDelay := 30

; The offsets from bottom for each playable note
notes :=[]
notes["D"] := -20
notes["D#"] := -210
notes["E"] := -305
notes["F"] := -385 ; F
notes["F#"] := -460
notes["G"] := -530 ; G
notes["G#"] := -600
notes["A"] := -670
notes["A#"] := -740
notes["B"] := -810
notes["C"] := -890
notes["C#"] := -970
notes["D2"] := -1065
notes["D#2"] := -1180
notes["E2"] := -1330
notes["F2 sorta flat"] := -1582

; Some songs
f2::
  bottom()
  note("E")
  note("E")
  note("E")
  rest()
  note("F#")
  rest()
  note("E")
return

f3::
  bottom()
  note("C#")
  note("D2")
  note("E2")
  rest()
  note("C#")
  rest()
  note("D2")
  rest()
  note("B")
  rest()
  note("C#")
  rest()
  note("A")
  rest()
  note("B")
return

f4::
  bottom()
  note("E")
  rest()
  note("A")
  rest()
  note("A")
  rest()
  note("B")
  rest()
  note("C#")
  rest()
  note("A")
  rest()
  note("C#")
  rest()
  note("B")
return

; Gets the offset required to move to the target note
getRelative(note)
{
  global current, notes
  target := notes[note]
  return target - current
}

; Looks straight down
bottom()
{
  global height, current
  move(height)
  current := 0
}

; Looks straight up
top()
{
  global height, current
  move(-height)
  current := height
}

; Two calibration functions I originally used to determine height
calibrateBottom()
{
  global height
  bottom()
  move(-height / 2)
}

calibrateTop()
{
  global height
  top()
  move(height / 2)
}

; Move by the specified vertical distance
move(delta)
{
  global postMoveDelay, current
  DllCall("mouse_event", uint, 1, int, 0, int, delta)
  current += delta
  sleep, postMoveDelay
}

; Play the note with the specified name
note(name)
{
  global clickHold, postClickDelay
  move(getRelative(name))
  Click right down
  sleep, clickHold
  Click right up
  sleep, postClickDelay
}

; Play the chord with the specified name
chord(name)
{
  global clickHold, postClickDelay
  move(getRelative(name))
  Click left down
  sleep, clickHold
  Click left up
  sleep, postClickDelay
}

; rest for one beat
rest()
{
  global clickHold, postClickDelay, postMoveDelay
  sleep, clickHold + postClickDelay + postMoveDelay
}
