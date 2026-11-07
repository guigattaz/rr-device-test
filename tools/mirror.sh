#!/bin/zsh
# Drives the iPhone Mirroring window on the Mac (needs Accessibility + Screen Recording for the app that runs this).
#   mirror.sh shot <file.png>        screenshot of the mirroring window only
#   mirror.sh tap <x> <y>            tap at x,y in window points (0,0 = top-left of the window)
#   mirror.sh type "<text>"          type text into the focused field
#   mirror.sh key <name>             return | escape | home (cmd-1) | switcher (cmd-2) | spotlight (cmd-3)
#   mirror.sh bounds                 window x y w h
APP="iPhone Mirroring"
bounds() { osascript -e "tell application \"System Events\" to tell process \"$APP\" to get {position, size} of window 1" | tr -d ' ' ; }
case "$1" in
  bounds) bounds ;;
  shot) b=($(bounds | tr ',' ' ')); screencapture -x -R "${b[1]},${b[2]},${b[3]},${b[4]}" "$2" ;;
  tap) b=($(bounds | tr ',' ' ')); X=$(( b[1] + $2 )); Y=$(( b[2] + $3 ))
       osascript -l JavaScript -e "ObjC.import('CoreGraphics'); var p=\$.CGPointMake($X,$Y);
         ['kCGEventLeftMouseDown','kCGEventLeftMouseUp'].forEach(function(t){ var e=\$.CGEventCreateMouseEvent(null, t==='kCGEventLeftMouseDown'?1:2, p, 0); \$.CGEventPost(0, e); delay(0.05); }); 'ok'" ;;
  type) osascript -e "tell application \"$APP\" to activate" -e "delay 0.2" -e "tell application \"System Events\" to keystroke \"$2\"" ;;
  key) osascript -e "tell application \"$APP\" to activate" -e "delay 0.2" -e "tell application \"System Events\"
         if \"$2\" is \"return\" then key code 36
         if \"$2\" is \"escape\" then key code 53
         if \"$2\" is \"home\" then keystroke \"1\" using command down
         if \"$2\" is \"switcher\" then keystroke \"2\" using command down
         if \"$2\" is \"spotlight\" then keystroke \"3\" using command down
       end tell" ;;
esac
