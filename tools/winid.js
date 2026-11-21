// winid.js <app name> [width height]: the window numbers of that app's ordinary windows (the one of that size, as System Events gives it), the largest first, so screencapture -l photographs the window itself
// (covered or not, without bringing it forward). Audit 2026-11-21 #2: a photo of the screen region took whatever lay on top.
ObjC.import('CoreGraphics');
function run(argv) {
  var l = ObjC.castRefToObject($.CGWindowListCopyWindowInfo($.kCGWindowListOptionAll, 0)), out = [];
  for (var i = 0; i < l.count; i++) { var w = l.objectAtIndex(i);
    if (ObjC.unwrap(w.objectForKey('kCGWindowOwnerName')) !== argv[0] || ObjC.unwrap(w.objectForKey('kCGWindowLayer')) !== 0) continue;
    var b = ObjC.deepUnwrap(w.objectForKey('kCGWindowBounds'));
    if (argv[1] && (Math.round(b.Width) != argv[1] || Math.round(b.Height) != argv[2])) continue;   // the window of that size
    out.push([b.Width * b.Height, ObjC.unwrap(w.objectForKey('kCGWindowNumber'))]);
  }
  return out.sort(function (x, y) { return y[0] - x[0]; }).map(function (x) { return x[1]; }).join(' ');   // the largest first
}
