; Hold Ctrl plus the left or right mouse button to spam clicks.
~^LButton::
 while GetKeyState("LButton") && GetKeyState("Ctrl")
 {
  Click up left
  Click down left
 }
Click up left
return

~^RButton::
 while GetKeyState("RButton") && GetKeyState("Ctrl")
 {
  Click up right
  Click down right
 }
Click up right
return
