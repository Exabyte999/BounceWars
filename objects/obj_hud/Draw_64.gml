/// @description intro card, a small count + timer box, countdown + banners
var game = obj_game;
if (game.state != "play" && game.state != "pause" && !(game.state == "settings" && game.show_on)) exit;

// intro card, what this round is about
if (game.phase == "intro") {
	draw_dim(0.35);
	draw_panel(VIEW_W / 2 - 250, 60, VIEW_W / 2 + 250, 250);
	draw_text_fit(VIEW_W / 2, 92, game.round_name, C_YELLOW, 3, fa_center, 470);
	draw_text_wrapped(VIEW_W / 2, 125, game.round_desc, C_WHITE, 450);
	draw_text_fit(VIEW_W / 2, 185, game.round_goal, C_CYAN, 1.5, fa_center, 470);
	draw_text_pixel(VIEW_W / 2, 226, "PRESS SPACE TO START", C_GREY, 1, fa_center);
	exit;
}

// top box: an icon + how many are left (or thru, in the race) | time left, goes red at 5s. used to be 3 boxes of text nobody reads mid round
var race = game.round_kind == "race", secs = max(0, ceil(game.timer));
draw_panel(VIEW_W / 2 - 76, 4, VIEW_W / 2 + 76, 38);
if (race) draw_sprite_ext(spr_flag, global.time * 10, VIEW_W / 2 - 58, 34, 0.55, 0.55, 0, c_white, 1);
else draw_sprite_ext(spr_hero, 0, VIEW_W / 2 - 50, 34, 0.2, 0.2, 0, global.skin_colours[obj_player.skin], 1);
draw_text_pixel(VIEW_W / 2 - 36, 21, race ? string(game.finished) + "/" + string(game.target) : string(count_alive()), C_YELLOW, 1.5);
draw_text_pixel(VIEW_W / 2 + 66, 21, (game.round_kind == "final") ? "FINAL" : string(secs) + "s", (secs <= 5) ? C_RED : C_WHITE, 1.5, fa_right);
if (obj_player.out) { // spectating + a new game button (obj_menu handles the click / R)
	draw_panel(VIEW_W / 2 - 164, VIEW_H - 32, VIEW_W / 2 - 4, VIEW_H - 6);
	draw_panel(VIEW_W / 2 + 4, VIEW_H - 32, VIEW_W / 2 + 164, VIEW_H - 6);
	draw_text_pixel(VIEW_W / 2 - 84, VIEW_H - 19, "SPECTATING", C_GREY, 1.5, fa_center);
	draw_text_pixel(VIEW_W / 2 + 84, VIEW_H - 19, "R: NEW GAME", C_YELLOW, 1.5, fa_center);
}

// countdown in the middle, banners on a dark strip js under the box
if (game.phase == "count") draw_text_pixel(VIEW_W / 2, 150, string(ceil(game.phase_clock)), C_YELLOW, 4.5, fa_center);
if (game.banner_time > 0) {
	var fade = clamp(game.banner_time * 2.5, 0, 1);
	draw_set_alpha(0.5 * fade); draw_set_colour(C_DARK); draw_rectangle(0, 44, VIEW_W, 78, false); draw_set_alpha(1);
	draw_text_fit(VIEW_W / 2, 61, game.banner_text, game.banner_colour, 3, fa_center, VIEW_W - 60, fade);
}
