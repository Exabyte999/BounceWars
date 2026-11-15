/// @description rail, then a row of spike heads
var bottom = (y + height) * SQUASH;
draw_set_alpha(0.3);
draw_set_colour(C_DARK);
draw_rectangle(x + 4, y * SQUASH + 2, x + width + 4, bottom + 5, false);
draw_set_alpha(1);
var rail_y = (y + height / 2) * SQUASH;
draw_line_width_colour(rail_left - 4, rail_y + 2, rail_right + 4, rail_y + 2, 4, #3a3550, #3a3550);
draw_line_width_colour(rail_left - 4, rail_y, rail_right + 4, rail_y, 2, #8a8fa3, #8a8fa3);
var count = max(1, round(width / 44)), w = width / count, s = w / 43;
for (var i = 0; i < count; i++) {
	var cx = x + w * (i + 0.5);
	draw_sprite_ext(spr_shadow, 0, cx, bottom + 1, w / 14, 0.5, 0, c_white, 0.5);
	draw_sprite_ext(spr_spikehead, 0, cx, bottom, s, s, 0, c_white, 1);
}
