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
# scroll: mirror.sh scroll <dy>   (negative = page moves up / content scrolls down)
if [ "$1" = "scroll" ]; then
  b=($(bounds | tr ',' ' ')); X=$(( b[1] + b[3]/2 )); Y=$(( b[2] + b[4]/2 ))
  osascript -l JavaScript -e "ObjC.import('CoreGraphics'); var m=\$.CGEventCreateMouseEvent(null, 5, \$.CGPointMake($X,$Y), 0); \$.CGEventPost(0,m); delay(0.1);
    for (var i=0;i<10;i++){ var e=\$.CGEventCreateScrollWheelEvent(null, 0, 1, Math.round($2/10)); \$.CGEventPost(0,e); delay(0.03);} 'ok'"
fi
# drag: mirror.sh drag <x1> <y1> <x2> <y2>   (a finger swipe, window points)
if [ "$1" = "drag" ]; then
  b=($(bounds | tr ',' ' ')); X1=$(( b[1] + $2 )); Y1=$(( b[2] + $3 )); X2=$(( b[1] + $4 )); Y2=$(( b[2] + $5 ))
  osascript -l JavaScript -e "ObjC.import('CoreGraphics'); function ev(t,x,y){ var e=\$.CGEventCreateMouseEvent(null,t,\$.CGPointMake(x,y),0); \$.CGEventPost(0,e); }
    ev(1,$X1,$Y1); for (var i=1;i<=20;i++){ delay(0.012); ev(6,$X1+($X2-$X1)*i/20,$Y1+($Y2-$Y1)*i/20); } delay(0.05); ev(2,$X2,$Y2); 'ok'"
fi
# path: mirror.sh path <hold_s> x1 y1 [wait_s x y]...   slow drag through waypoints (moving icons in jiggle mode)
if [ "$1" = "path" ]; then
  b=($(bounds | tr ',' ' ')); shift; H=$1; shift
  P="[$(( b[1] + $1 )),$(( b[2] + $2 ))"; shift 2; S=""
  while [ $# -ge 3 ]; do S="$S,[$1,$(( b[1] + $2 )),$(( b[2] + $3 ))]"; shift 3; done
  osascript -l JavaScript -e "ObjC.import('CoreGraphics'); function ev(t,x,y){ var e=\$.CGEventCreateMouseEvent(null,t,\$.CGPointMake(x,y),0); \$.CGEventPost(0,e); }
    var p=$P], steps=[${S#,}], cx=p[0], cy=p[1]; ev(1,cx,cy); delay($H);
    steps.forEach(function(s){ for (var i=1;i<=25;i++){ ev(6, cx+(s[1]-cx)*i/25, cy+(s[2]-cy)*i/25); delay(0.02);} cx=s[1]; cy=s[2]; delay(s[0]); });
    ev(2,cx,cy); 'ok'"
fi
