/// @description the floor grid. round builders fill it in (scr_rounds / scr_level)
depth = 1000; // behind everyone
rows = 0;
cols = 0;
tiles = []; // tiles[row][column] = a Tile
heat = []; // seconds till a heating tile drops, -1 = not heating
heating = 0; // how many tiles are heating rn, Step skips the whole grid when its 0
looks = []; // floor texture per row

draw_floor_tile = function(c, r) {
	var type = tiles[r][c];
	if (type == Tile.sky) return; // outside an arena, nothing to draw
	var x1 = c * TILE, x2 = x1 + TILE, y1 = r * TILE * SQUASH, y2 = (r + 1) * TILE * SQUASH;
	if (!tile_is_solid(type)) {
		draw_pit(c, r, x1, y1, x2, y2);
		if (type == Tile.fan) draw_fan(c, r, x1, y1, x2, y2);
		return;
	}
	// heating tiles shake and go red
	var tint = c_white;
	if (heat[r][c] >= 0) {
		var shake = random_range(-1.5, 1.5) * (1 - heat[r][c]);
		x1 += shake;
		x2 += shake;
		tint = merge_colour(c_white, C_HEAT, 0.25 + clamp(1 - heat[r][c] / 0.6, 0, 1) * 0.6);
	}
	// spr_floor frame for the top, spr_floor_edge (cainos brick wall) for the front
	var top = looks[r], edge = looks[r];
	if (type == Tile.checkpoint) { top = 3; edge = Look.sand; }
	if (type == Tile.pad) { top = 4; edge = Look.clay; }
	if (type == Tile.finish) { top = 5; edge = Look.clay; }
	if (!tile_is_solid(tile_get(c, r + 1))) draw_sprite_ext(spr_floor_edge, edge, x1, y2, 1, EDGE / 18, 0, tint, 1);
	draw_sprite_ext(spr_floor, top, x1, y1, 1, SQUASH, 0, tint, 1);
	// dark outline where the floor ends so u can see the edges. its a stretched 1px sprite not a line,
	// so the whole floor draws in one batch instead of the gpu switching between sprites and lines every tile
	if (!tile_is_solid(tile_get(c - 1, r))) draw_sprite_stretched_ext(spr_pixel, 0, x1, y1, 2, y2 - y1, C_INK, 0.7);
	if (!tile_is_solid(tile_get(c + 1, r))) draw_sprite_stretched_ext(spr_pixel, 0, x2 - 2, y1, 2, y2 - y1, C_INK, 0.7);
	if (!tile_is_solid(tile_get(c, r - 1))) draw_sprite_stretched_ext(spr_pixel, 0, x1, y1, x2 - x1, 2, C_INK, 0.7);
};

// a hole: dark floor with stealthix spikes in it (seen from above now, not side on), shadows under the ledges
draw_pit = function(c, r, x1, y1, x2, y2) {
	draw_sprite_ext(spr_floor, Look.grass, x1, y1, 1, (y2 - y1) / 32, 0, #4a3d63, 1);
	draw_sprite_ext(spr_spikes, 0, x1, y1, 1, SQUASH, 0, #b0a8c8, 1); // top down spikes lying in the pit
	if (tile_is_solid(tile_get(c, r - 1))) draw_sprite_stretched_ext(spr_pixel, 0, x1, y1, x2 - x1, EDGE + 7, #0b0816, 0.45);
	if (tile_is_solid(tile_get(c - 1, r))) draw_sprite_stretched_ext(spr_pixel, 0, x1, y1, 6, y2 - y1, #0b0816, 0.45);
	if (tile_is_solid(tile_get(c + 1, r))) draw_sprite_stretched_ext(spr_pixel, 0, x2 - 6, y1, 6, y2 - y1, #0b0816, 0.45);
};

// fan in a pit blowing u up
draw_fan = function(c, r, x1, y1, x2, y2) {
	var fx = x1 + TILE / 2, fy = y2 + 46;
	draw_sprite_ext(spr_fan, floor(global.time * 20) mod 4, fx, fy, 1.3, 1.3, 0, c_white, 1);
	draw_set_colour(C_CYAN);
	draw_set_alpha(0.18 + 0.1 * sin(global.time * 8 + r));
	draw_rectangle(x1 + 3, y1 - 60, x2 - 3, fy, false);
	draw_set_alpha(0.6);
	draw_set_colour(C_WHITE);
	for (var k = 0; k < 3; k++) {
		var line_y = fy - ((global.time * 120 + k * 37 + c * 13) mod 110);
		draw_line(x1 + 6 + k * 9, line_y, x1 + 6 + k * 9, line_y - 10);
	}
	draw_set_alpha(1);
};

// glowing line across a checkpoint row (the flags are obj_prop)
draw_checkpoint_stripe = function(c, r) {
	draw_sprite_stretched_ext(spr_pixel, 0, c * TILE, (r + 0.5) * TILE * SQUASH - 1, TILE, 2, C_WHITE, 0.5 + 0.3 * sin(global.time * 4));
};
