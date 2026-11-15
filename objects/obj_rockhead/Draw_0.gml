/// @description rock head, squashes when it bonks someone
var sy = y * SQUASH + 2, s = (radius * 2 / 32) * (1 + pulse * 0.3);
draw_sprite_ext(spr_shadow, 0, x, sy, radius / 7, radius / 16, 0, c_white, 0.5);
if (pulse > 0.25) draw_sprite_ext(spr_rockhead_hit, min(3, floor((1 - pulse) * 4)), x, sy, s, s * (1 - pulse * 0.2), 0, c_white, 1);
else draw_sprite_ext(spr_rockhead, 0, x, sy, s, s, 0, c_white, 1);
