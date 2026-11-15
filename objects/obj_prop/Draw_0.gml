/// @description flag, trophy or trampoline standing on the floor (level_place_props makes these)
var floor_y = y * SQUASH;
draw_sprite_ext(spr_shadow, 0, x, floor_y, shadow_w, shadow_h, 0, c_white, shadow_alpha);
draw_sprite_ext(sprite_index, image_index, x, floor_y, image_xscale, image_yscale, 0, c_white, 1);
