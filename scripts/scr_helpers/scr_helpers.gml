// bounce wars (jam theme: BOUNCE BACK). settings + small helpers tht everything uses

#macro VIEW_W 640 // game is laid out at 640x360 (16:9), drawn at the real window size
#macro VIEW_H 360
#macro TILE 32 // one floor tile
#macro SQUASH 0.62 // 3/4 view: screen y = y * SQUASH - z
#macro EDGE 18 // how tall a platforms front face looks
#macro GRAVITY 950
#macro SAVE_FILE "bouncewards.ini"

enum Tile { hole, ground, pad, finish, checkpoint, fan, melt, sky } // sky = never had floor (outside an arena)
enum Look { grass, clay, sand } // floor textures, also frames 0-2 of spr_floor

#macro C_WHITE #f4f6ff
#macro C_GREY #c3c8d9
#macro C_BLUE #7d84a8
#macro C_YELLOW #ffd34d
#macro C_ORANGE #ff9a3c
#macro C_GREEN #76ff3a
#macro C_RED #ff3b3b
#macro C_CYAN #5ef0ff
#macro C_PINK #ff5d8f
#macro C_HEAT #ff4a1c
#macro C_INK #1d1630
#macro C_DARK #0d0b14

// ---- text ----

// pixel font text with a shadow. scale 1 = small, 1.5 = normal, 3 = heading, 4.5 = title
function draw_text_pixel(_x, _y, _text, _colour, _scale = 1, _halign = fa_left, _alpha = 1) {
	// snap to whole screen pixels or the pixel font goes blurry
	var ui = global.ui_scale, s = max(1, round(_scale * ui)) / ui;
	_x = round(_x * ui) / ui;
	_y = round(_y * ui) / ui;
	_text = string_upper(_text);
	draw_set_font(global.font_pixel);
	draw_set_halign(_halign);
	draw_set_valign(fa_middle);
	draw_text_transformed_colour(_x + s, _y + s, _text, s, s, 0, C_INK, C_INK, C_INK, C_INK, _alpha * 0.9);
	draw_text_transformed_colour(_x, _y, _text, s, s, 0, _colour, _colour, _colour, _colour, _alpha);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// same thing but shrinks the text till it fits
function draw_text_fit(_x, _y, _text, _colour, _scale, _halign, _max_width, _alpha = 1) {
	draw_set_font(global.font_pixel);
	while (_scale > 1 && string_width(string_upper(_text)) * _scale > _max_width) _scale -= 0.5;
	draw_text_pixel(_x, _y, _text, _colour, _scale, _halign, _alpha);
}

// small wrapped text centred on x (lines 15px apart)
function draw_text_wrapped(_x, _y, _text, _colour, _max_width) {
	var ui = global.ui_scale, s = max(1, round(ui)) / ui;
	_text = string_upper(_text);
	draw_set_font(global.font_pixel);
	draw_set_halign(fa_center);
	draw_text_ext_transformed_colour(_x + s, _y + s, _text, 15 / s, _max_width / s, s, s, 0, C_INK, C_INK, C_INK, C_INK, 0.9);
	draw_text_ext_transformed_colour(_x, _y, _text, 15 / s, _max_width / s, s, s, 0, _colour, _colour, _colour, _colour, 1);
	draw_set_halign(fa_left);
}

// ---- boxes ----

// purple box from spr_panel (rahmats dark ui pack, recoloured cuz the brown was poopy), cut into 9 pieces so the corners dont stretch into slop
function draw_panel(_x1, _y1, _x2, _y2, _alpha = 0.9, _border = -1) {
	var c = 8, k = 0.5; // corners are 16px in the sprite, drawn at 8px
	var w = (_x2 - _x1 - 2 * c) / 16, h = (_y2 - _y1 - 2 * c) / 16;
	// [src x, src y, x, y, xscale, yscale]: middle, edges, corners
	var parts = [
		[16, 16, _x1 + c, _y1 + c, w, h],
		[16, 0, _x1 + c, _y1, w, k], [16, 32, _x1 + c, _y2 - c, w, k],
		[0, 16, _x1, _y1 + c, k, h], [32, 16, _x2 - c, _y1 + c, k, h],
		[0, 0, _x1, _y1, k, k], [32, 0, _x2 - c, _y1, k, k],
		[0, 32, _x1, _y2 - c, k, k], [32, 32, _x2 - c, _y2 - c, k, k]
	];
	for (var i = 0; i < 9; i++) {
		var p = parts[i];
		draw_sprite_part_ext(spr_panel, 0, p[0], p[1], 16, 16, p[2], p[3], p[4], p[5], c_white, (i == 0) ? _alpha : 1);
	}
	if (_border != -1) { draw_set_colour(_border); draw_rectangle(_x1 + c, _y1 + c, _x2 - c, _y2 - c, true); }
}

function draw_dim(_alpha) {
	draw_set_alpha(_alpha);
	draw_set_colour(C_DARK);
	draw_rectangle(0, 0, VIEW_W, VIEW_H, false);
	draw_set_alpha(1);
}

// ---- misc ----

function play_sfx(_sound, _volume = 1, _pitch = 1) {
	audio_play_sound(_sound, 1, false, _volume * 0.5 * global.sfx_volume / 10, 0, _pitch);
}

// near the camera? far away bots dont make sounds or effects
function on_screen(_x, _y) {
	return abs(_x - obj_camera.cam_x) < VIEW_W * 0.8 && abs(_y * SQUASH - obj_camera.cam_y) < VIEW_H * 0.9;
}

// closest distance from a point to a line (for the saw arms)
function distance_to_line(_px, _py, _x1, _y1, _x2, _y2) {
	var dx = _x2 - _x1, dy = _y2 - _y1, len2 = dx * dx + dy * dy;
	var t = (len2 > 0) ? clamp(((_px - _x1) * dx + (_py - _y1) * dy) / len2, 0, 1) : 0;
	return point_distance(_px, _py, _x1 + t * dx, _y1 + t * dy);
}

// ---- window ----

// biggest 16:9 window tht fits the screen, centred
function window_fit() {
	if (window_get_fullscreen()) return;
	var scale = max(1, min((display_get_width() - 40) / VIEW_W, (display_get_height() - 110) / VIEW_H));
	window_set_size(round(VIEW_W * scale), round(VIEW_H * scale));
	call_later(2, time_source_units_frames, function() { window_center(); });
}

// also saves it so it stays fullscreen next time
function set_fullscreen(_on) {
	window_set_fullscreen(_on);
	if (!_on) call_later(2, time_source_units_frames, window_fit);
	save_settings(_on); // pass it in, window_get_fullscreen can still say the old value this frame
}

// ---- saving ----

function save_settings(_fullscreen = undefined) {
	if (is_undefined(_fullscreen)) _fullscreen = window_get_fullscreen();
	ini_open(SAVE_FILE);
	ini_write_real("settings", "music", global.music_volume);
	ini_write_real("settings", "sfx", global.sfx_volume);
	ini_write_real("settings", "fullscreen", _fullscreen);
	ini_close();
}

function save_progress() {
	ini_open(SAVE_FILE);
	ini_write_real("save", "crowns", global.wins);
	ini_write_real("save", "shows", global.shows);
	ini_write_real("save", "col", global.skin);
	ini_close();
}
