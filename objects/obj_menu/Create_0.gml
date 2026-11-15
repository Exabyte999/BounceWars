/// @description title screen, settings, pause + game over
depth = -200; // on top of the hud
sel_btn = 0; // highlighted button
back_to = "title"; // where back goes from settings
old_mx = 0;
old_my = 0;

// every screen: its buttons + where they go [middle x, top y, width, height, gap]
screens = {
	title: { items: ["NEW GAME", "CHARACTER", "SETTINGS", "QUIT GAME"], box: [VIEW_W * 0.68, 124, 216, 34, 7] },
	settings: { items: ["MUSIC", "SOUND FX", "FULLSCREEN", "BACK"], box: [VIEW_W / 2, 94, 310, 38, 8] },
	pause: { items: ["RESUME", "RESTART SHOW", "SETTINGS", "MAIN MENU", "QUIT GAME"], box: [VIEW_W / 2, 84, 236, 36, 7] },
	over: { items: ["PLAY AGAIN", "MAIN MENU", "QUIT GAME"], box: [VIEW_W / 2, 238, 216, 34, 5] }
};
// browsers dont let a page close itself, so in the html5 build quit would do nothing. js take it off the menus
if (os_browser != browser_not_a_browser) {
	var lists = [screens.title.items, screens.pause.items, screens.over.items];
	for (var k = 0; k < 3; k++) array_delete(lists[k], array_get_index(lists[k], "QUIT GAME"), 1);
}
// icon next to each button
icons = {};
var pairs = [
	["NEW GAME", spr_btn_play], ["RESUME", spr_btn_play], ["PLAY AGAIN", spr_btn_play],
	["CHARACTER", spr_btn_levels], ["FULLSCREEN", spr_btn_levels], ["SETTINGS", spr_btn_settings],
	["QUIT GAME", spr_btn_close], ["RESTART SHOW", spr_btn_restart], ["MAIN MENU", spr_btn_back],
	["BACK", spr_btn_back], ["MUSIC", spr_btn_volume], ["SOUND FX", spr_btn_volume]
];
for (var i = 0; i < array_length(pairs); i++) icons[$ pairs[i][0]] = pairs[i][1];

// buttons on the screen thats showing (none while playing)
items = function() {
	var s = screens[$ obj_game.state];
	return is_undefined(s) ? [] : s.items;
};

// [x1, y1, x2, y2] of button i
item_rect = function(i) {
	var L = screens[$ obj_game.state].box, x1 = L[0] - L[2] / 2, y1 = L[1] + i * (L[3] + L[4]);
	return [x1, y1, x1 + L[2], y1 + L[3]];
};

// up/down/mouse to move, space/enter/click to pick. returns the picked label or ""
navigate = function() {
	var list = items(), n = array_length(list);
	if (n == 0) return "";
	var inp = global.input;
	sel_btn = clamp(sel_btn, 0, n - 1);
	if (inp.up) { sel_btn = (sel_btn + n - 1) mod n; play_sfx(snd_menu_move, 0.6, 1.2); }
	if (inp.down) { sel_btn = (sel_btn + 1) mod n; play_sfx(snd_menu_move, 0.6, 1.2); }
	// mouse highlights whatever its over (only when it actually moves, so it doesnt fight the keys)
	var mx = device_mouse_x_to_gui(0), my = device_mouse_y_to_gui(0), hover = -1;
	for (var i = 0; i < n; i++) {
		var r = item_rect(i);
		if (point_in_rectangle(mx, my, r[0], r[1], r[2], r[3])) hover = i;
	}
	if (hover >= 0 && (mx != old_mx || my != old_my)) sel_btn = hover;
	old_mx = mx;
	old_my = my;
	if ((inp.click && hover >= 0) || inp.confirm) {
		if (inp.click && hover >= 0) sel_btn = hover;
		play_sfx(snd_pickup, 0.6);
		return list[sel_btn];
	}
	return "";
};

open_settings = function(from) {
	back_to = from;
	obj_game.state = "settings";
	sel_btn = 0;
};

// 0 = music, 1 = sfx. changes it, updates the music thats playing and saves
change_volume = function(_which, _step) {
	if (_which == 0) global.music_volume = clamp(global.music_volume + _step, 0, 10);
	else { global.sfx_volume = clamp(global.sfx_volume + _step, 0, 10); play_sfx(snd_menu_move); }
	apply_settings();
};

apply_settings = function() {
	with (obj_game) if (bgm != noone) audio_sound_gain(bgm, global.music_volume * 0.05, 0);
	save_settings();
};

// buttons for this screen (+ volume bars in settings)
draw_items = function() {
	var list = items(), n = array_length(list), screen = obj_game.state;
	for (var i = 0; i < n; i++) {
		var r = item_rect(i), sel = (i == sel_btn), mid = (r[1] + r[3]) / 2, col = sel ? C_YELLOW : C_WHITE;
		draw_panel(r[0], r[1], r[2], r[3], sel ? 0.98 : 0.85, sel ? C_YELLOW : -1);
		var icon = icons[$ list[i]];
		if (!is_undefined(icon)) draw_sprite_ext(icon, 0, r[0] + 22, mid, 0.8, 0.8, 0, c_white, 1);
		if (screen == "settings" && i < 3) draw_text_fit(r[0] + 42, mid, list[i], col, 1.5, fa_left, (r[2] - r[0]) - ((i < 2) ? 190 : 100));
		else draw_text_fit((r[0] + r[2] + 24) / 2, mid, list[i], col, 1.5, fa_center, (r[2] - r[0]) - 56);
		if (sel) { // little bouncing arrow
			var ax = r[0] - 8 - abs(sin(global.time * 4)) * 3;
			draw_triangle_colour(ax - 9, mid - 6, ax - 9, mid + 6, ax, mid, C_YELLOW, C_YELLOW, C_YELLOW, false);
		}
		if (screen == "settings" && i < 2) { // - [##########] +
			var value = (i == 0) ? global.music_volume : global.sfx_volume;
			draw_sprite(spr_btn_previous, 0, r[2] - 132, mid);
			draw_sprite(spr_btn_next, 0, r[2] - 18, mid);
			for (var k = 0; k < 10; k++) {
				var bx = r[2] - 116 + k * 8.6;
				draw_set_colour((k < value) ? C_YELLOW : #4a3d63);
				draw_rectangle(bx, mid - 6, bx + 6, mid + 6, false);
			}
		}
		if (screen == "settings" && i == 2) {
			var fs = window_get_fullscreen();
			draw_text_pixel(r[2] - 16, mid, fs ? "ON" : "OFF", fs ? C_GREEN : C_GREY, 1.5, fa_right);
		}
	}
};
