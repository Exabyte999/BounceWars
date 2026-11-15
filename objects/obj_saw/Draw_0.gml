/// @description post, chain arm, 2 spinning saws
var hx = x, hy = y * SQUASH, h = 12; // h = how high the arm is
var dx = lengthdir_x(arm_length, angle), dy = lengthdir_y(arm_length, angle) * SQUASH;
// arm shadow + post
draw_set_alpha(0.25);
draw_line_width_colour(hx - dx, hy - dy + 2, hx + dx, hy + dy + 2, 6, C_DARK, C_DARK);
draw_set_alpha(1);
draw_sprite_ext(spr_shadow, 0, hx, hy, 1.2, 0.5, 0, c_white, 0.6);
draw_line_width_colour(hx, hy, hx, hy - h, 4, #8a8fa3, #5b5f73);
// chain
for (var k = -arm_length; k <= arm_length; k += 9) draw_sprite(spr_saw_chain, 0, hx + lengthdir_x(k, angle), hy + lengthdir_y(k, angle) * SQUASH - h);
// saws
var frame = floor(global.time * 24) mod 8;
for (var side = -1; side <= 1; side += 2) {
	draw_sprite_ext(spr_shadow, 0, hx + dx * side, hy + dy * side, 1.4, 0.5, 0, c_white, 0.45);
	draw_sprite_ext(spr_saw, frame, hx + dx * side, hy + dy * side - h, 0.9, 0.9, 0, c_white, 1);
}
draw_sprite_ext(spr_floor, 3, hx - 8, hy - h - 8, 0.5, 0.5, 0, c_white, 1); // metal cap on top
