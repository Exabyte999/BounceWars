/// @description spiked ball. before it rolls its a blinking ghost with a dotted line showing where its going
var sy = y * SQUASH, s = radius * 2 / 26;
if (wait > 0) {
	var dir = point_direction(0, 0, roll_x, roll_y), blink = (floor(wait * 8) mod 2 == 0);
	draw_set_colour(C_RED);
	draw_set_alpha(blink ? 0.9 : 0.5);
	for (var k = 1; k <= 8; k++) draw_circle(x + lengthdir_x(k * 24, dir), (y + lengthdir_y(k * 24, dir)) * SQUASH, 2, false);
	draw_set_alpha(1);
	draw_sprite_ext(spr_spikeball, 0, x, sy - radius, s, s, 0, blink ? #ff8080 : c_white, 0.6);
	exit;
}
draw_sprite_ext(spr_shadow, 0, x, sy, radius / 8, radius / 18, 0, c_white, 0.5);
draw_sprite_ext(spr_spikeball, 0, x, sy - radius, s, s, -radtodeg(spin), c_white, 1);
