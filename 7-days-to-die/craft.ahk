; General note: I make a positional assumption about scrapping.
;  For certain items, an unexpected action may be taken.

; The lower bound of the inventory space
invLimitY = 910
; The right bound of the inventory space
invLimitX = 1420
; The size of an inventory slot
invSlotSize = 78

; A delay used to make sure that actions register
lagDelay := 70
busyWaitDelay := 10

; bitmasks for color components
redMask = 0x0000FF
greenMask = 0x00FF00
blueMask = 0xFF0000

; An array of named locations
locations :=[]
locations["secondActionRow"] := {"x": 900, "y": 350}
locations["firstRecipe"] := {"x": 600, "y": 250}
locations["lastQueueHover"] := {"x": 570, "y": 870}
locations["lastQueueColor"] := {"x": 560, "y": 850}
locations["firstQueueHover"] := {"x": 800, "y": 870}
locations["firstQueueColor"] := {"x": 790, "y": 855}

; Reload the script (stopping any running functions)
^b::
  Reload
return

^l::
  craftLoop()
return

^k::
  scrapAll()
return

; Prerequisites:
;   the desired crafting recipe is the first in the search results
;   the mouse is over the first empty inventory slot
; This will repeatedly craft the selected item, then drop/scrap it.
craftLoop()
{
  MouseGetPos, xPos, yPos
  originalX := xPos
  originalY := yPos
  while yPos = originalY
  {
    craft()
    awaitQueueEmpty()
    scrap()
    MouseGetPos, xPos, yPos
  }
}

; Starting at current mouse position, scrap/drop all inventory
scrapAll()
{
  global invLimitY
  MouseGetPos, xPos, yPos
  while yPos < invLimitY
  {
    scrap()
    nextInv()
    MouseGetPos, xPos, yPos
  }
}

; Move to the given named location
moveTo(location)
{
  global locations
  coords := locations[location]
  MouseMove, coords["x"], coords["y"], 0
}

; Get the color at the given named location
colorAt(location)
{
  global locations
  coords := locations[location]
  PixelGetColor, color, coords["x"], coords["y"]
  return color
}

; Scrap (or drop if scrapping is not available) the item under the mouse
scrap()
{
  MouseGetPos, xPos, yPos
  click()
  awaitQueueNotFull()
  secondActionRow()
  MouseMove, xPos, yPos, 0
}

; Click the second action row in an item description (assumes one is open)
secondActionRow()
{
  moveTo("secondActionRow")
  click()
}

; Click the left mouse button
click()
{
  global lagDelay
  Sleep, lagDelay
  Click down
  Sleep, lagDelay
  Click up
  Sleep, lagDelay
}

; Move to the next inventory slot (assumes the mouse is on one)
nextInv()
{
  global invLimitX, invSlotSize
  MouseGetPos, xPos, yPos
  if (xPos < invLimitX) {
    xPos += invSlotSize
  } else {
    yPos += invSlotSize
    xPos -= invSlotSize * 7
  }
  MouseMove, xPos, yPos, 0
}

; Move the mouse to the first inventory slot
firstInv()
{
  global invLimitX, invLimitY, invSlotSize
  MouseMove, invLimitX - invSlotSize * 6.5, invLimitY - invSlotSize * 3.5, 0
}

; Craft the currently selected recipe (assumes one is selected)
craft()
{
  MouseGetPos, xPos, yPos
  moveTo("firstRecipe")
  click()
  awaitQueueNotFull()
  secondActionRow()
  MouseMove, xPos, yPos, 0
}

; Determines, loosely, if a color is redMask
isRed(color)
{
  global redMask, greenMask, blueMask
  red := color & redMask
  green := (color & greenMask) >> 8
  blue := (color & blueMask) >> 16
  return (red > (3 * (blue + green)))
}

; Returns after the crafting queue has an open slot
awaitQueueNotFull()
{
  global lagDelay, busyWaitDelay
  MouseGetPos, originalX, originalY
  moveTo("lastQueueHover")
  Sleep, lagDelay
  while isRed(colorAt("lastQueueColor"))
  {
    Sleep, busyWaitDelay
  }
  MouseMove, originalX, originalY, 0
}

; Returns true if the first queue color is red
isFirstQueueRed()
{
  global lagDelay
  color := colorAt("firstQueueColor")
  if (not isRed(color)) {
    ; Make sure the red color isn't just momentarily gone
    sleep, lagDelay
    color := colorAt("firstQueueColor")
  }
  return isRed(color)
}

; Returns after the crafting queue is empty
awaitQueueEmpty()
{
  global lagDelay, busyWaitDelay
  MouseGetPos, originalX, originalY
  moveTo("firstQueueHover")
  sleep, lagDelay
  while isFirstQueueRed()
  {
    sleep, busyWaitDelay
  }
  MouseMove, originalX, originalY, 0
}
