/// @description shadow, the character at its height + markers
if (!in_round) exit;

// snap to whole screen pixels so the sprite, shadow and camera all move together
var ui = global.ui_scale, sx = round(x * ui) / ui;
var base_y = round(y * SQUASH * ui) / ui; // where ur feet are on the floor
var sy = round((y * SQUASH - z) * ui) / ui, over_floor = solid_at(x, y);

// shadow gets smaller the higher u are
if (over_floor && !falling) {
	var s = clamp(1 - z / 220, 0.4, 1);
	draw_sprite_ext(spr_shadow, 0, sx, base_y, 1.4 * s, 0.55 * s, 0, c_white, 0.7);
}
// landing marker, only when ur way up (launchpads, normal jumps peak ~65) cuz on every jump it was too distracting: faint dots down to where ull land
// white ring = floor under u, red x = ur gonna fall
if (is_player && !on_ground && !falling && z > 80) {
	draw_set_colour(over_floor ? C_WHITE : C_RED);
	draw_set_alpha(0.55);
	for (var d = sy - 4; d < base_y - 8; d += 7) draw_rectangle(sx, d, sx + 1, d + 2, false);
	if (over_floor) draw_ellipse(sx - 12, base_y - 5, sx + 12, base_y + 5, true);
	else { draw_line_width(sx - 7, base_y - 5, sx + 7, base_y + 5, 2); draw_line_width(sx - 7, base_y + 5, sx + 7, base_y - 5, 2); }
	draw_set_alpha(1);
}

// my character for everyone, tinted with their skin colour. its 1 frame so it bobs when running and wobbles when hit instead of animating
var t = global.time + idx * 0.137; // so the goonies arent all in sync
var bob = (on_ground && abs(walk_x) + abs(walk_y) > 45) ? abs(sin(t * 14)) * 3 : 0;
var tilt = (falling || ouchie > 0) ? sin(t * 40) * 12 : 0;
var hero_scale = 0.32, xs = hero_scale * (1 + 0.08 * squish) * facing, ys = hero_scale * (1 - 0.08 * squish);

// the spring tht js yeeted us back
if (boing_time > 0.55) draw_sprite_ext(spr_trampoline_jump, min(7, floor((1 - boing_time) * 18)), spring_x, spring_y * SQUASH + 4, 1.3, 1.3, 0, c_white, 1);

// everyone pops in with a puff at the start of the countdown
if (obj_game.phase == "count" && obj_game.phase_clock > 2.6) {
	draw_sprite_ext(spr_appear, min(6, floor((3 - obj_game.phase_clock) * 17)), sx, sy, 0.9, 0.9, 0, c_white, 1);
	exit;
}
draw_sprite_ext(spr_hero, 0, sx, sy - bob, xs, ys, tilt, (ouchie > 0) ? C_RED : global.skin_colours[skin], (obj_game.phase == "go" && obj_game.phase_clock > 0) ? 0.6 : 1); // see thru while safe

var head_y = sy - 128 * hero_scale;
if (obj_game.winner == id) { // winner wears the trophy
	draw_sprite_ext(spr_shadow, 0, sx, head_y - 1, 1.4, 0.35, 0, c_white, 0.5);
	draw_sprite_ext(spr_trophy, 0, sx, head_y - 2, 0.45, 0.45, 0, c_white, 1);
}
if (is_player) {
	draw_triangle_colour(sx - 5, head_y - 8, sx + 5, head_y - 8, sx, head_y - 2, C_YELLOW, C_YELLOW, C_ORANGE, false);
	draw_text_pixel(sx, head_y - 18, "YOU", C_YELLOW, 1.5, fa_center);
}
