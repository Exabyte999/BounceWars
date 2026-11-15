/// @description if the window changed size, line the hud up with the stretched game
var w = window_get_width(), h = window_get_height();
if (w < 64 || h < 64 || (w == window_w && h == window_h)) exit; // minimised or nothing changed, js skip
window_w = w;
window_h = h;
// no new game image here on purpose (see obj_camera create), only the hud gets moved
var fit = min(w / VIEW_W, h / VIEW_H);
display_set_gui_maximise(fit, fit, (w - VIEW_W * fit) / 2, (h - VIEW_H * fit) / 2);
