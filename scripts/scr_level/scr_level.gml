// the floor is a grid in obj_level: tiles[row][column], each tile is TILE x TILE

// wipes the level and makes an empty grid (sky, or holes for the race)
function level_new(_rows, _cols, _look = Look.grass, _empty = Tile.sky) {
	with (obj_level) {
		rows = _rows;
		cols = _cols;
		tiles = [];
		heat = [];
		heating = 0;
		looks = [];
		for (var r = 0; r < rows; r++) {
			tiles[r] = array_create(cols, _empty);
			heat[r] = array_create(cols, -1); // -1 = fine, otherwise seconds till it drops
			looks[r] = _look;
		}
	}
}

function level_clear() { level_new(0, 0); }

function level_set(_c, _r, _type) { with (obj_level) tiles[_r][_c] = _type; }

// fills a row (or columns c1 to c2) with one tile type
function level_fill_row(_r, _type, _look = Look.grass, _c1 = 0, _c2 = -1) {
	with (obj_level) {
		if (_c2 < 0) _c2 = cols - 1;
		for (var c = _c1; c <= _c2; c++) tiles[_r][c] = _type;
		looks[_r] = _look;
	}
}

function tile_get(_c, _r) {
	var L = obj_level;
	if (_c < 0 || _r < 0 || _c >= L.cols || _r >= L.rows) return Tile.hole;
	return L.tiles[_r][_c];
}

function tile_at(_x, _y) { return tile_get(floor(_x / TILE), floor(_y / TILE)); }

function tile_is_solid(_type) {
	return _type == Tile.ground || _type == Tile.pad || _type == Tile.finish || _type == Tile.checkpoint || _type == Tile.melt;
}

function solid_at(_x, _y) { return tile_is_solid(tile_at(_x, _y)); }

function tile_heating(_c, _r) { return tile_is_solid(tile_get(_c, _r)) && obj_level.heat[_r][_c] >= 0; }

// starts a tiles countdown, it drops when it hits 0
function tile_heat_up(_c, _r, _seconds) { with (obj_level) if (heat[_r][_c] < 0) { heat[_r][_c] = _seconds; heating++; } }

// somewhere safe near the middle to bounce someone back to. tries to avoid rocks + saws first,
// then js any floor. if theres basically no floor left it builds a 3x3 pad in the middle
function level_safe_spot() {
	var L = obj_level, cx = L.cols * TILE / 2, cy = L.rows * TILE / 2, a = random(360);
	for (var fussy = 1; fussy >= 0; fussy--) {
		for (var k = 0; k < 60; k++) {
			var d = random(5 * TILE);
			var qx = cx + lengthdir_x(d, a + k * 57), qy = cy + lengthdir_y(d, a + k * 57);
			var clear = !fussy || (!rock_near(qx, qy, 24) && !saw_near(qx, qy));
			if (clear && solid_at(qx, qy) && !tile_heating(floor(qx / TILE), floor(qy / TILE))) return [qx, qy];
		}
	}
	var c0 = floor(cx / TILE), r0 = floor(cy / TILE);
	var type = (obj_game.round_kind == "melt") ? Tile.melt : Tile.ground;
	with (obj_level) {
		for (var r = r0 - 1; r <= r0 + 1; r++) {
			for (var c = c0 - 1; c <= c0 + 1; c++) { tiles[r][c] = type; heat[r][c] = -1; }
		}
	}
	return [cx, cy];
}

function rock_near(_x, _y, _gap) {
	var near = false;
	with (obj_rockhead) if (point_distance(x, y, _x, _y) < radius + _gap) near = true;
	return near;
}

function saw_near(_x, _y) {
	var near = false;
	with (obj_saw) if (distance_to_arm(_x, _y) < 40) near = true;
	return near;
}

// flags, trophies and trampolines are their own instances (obj_prop)
// so if ur standing behind one ur drawn behind it
function level_place_props() {
	with (obj_prop) instance_destroy();
	var L = obj_level;
	for (var r = 0; r < L.rows; r++) {
		for (var c = 0; c < L.cols; c++) {
			var type = L.tiles[r][c], cx = (c + 0.5) * TILE, cy = (r + 0.5) * TILE;
			if (type == Tile.pad) {
				instance_create_depth(cx, cy + 10, -r * TILE, obj_prop, { sprite_index: spr_trampoline,
					image_xscale: 1.1, image_yscale: 1.1, shadow_w: 1.6, shadow_h: 0.5, shadow_alpha: 0.55 });
			}
			if (type == Tile.checkpoint && (c == 0 || c == L.cols - 1)) {
				instance_create_depth(cx, cy, -cy, obj_prop, { sprite_index: spr_flag, image_index: c mod 10,
					image_xscale: (c == 0) ? 0.8 : -0.8, image_yscale: 0.8, shadow_w: 1.1, shadow_h: 0.4, shadow_alpha: 0.55 });
			}
			if (type == Tile.finish && (c == 1 || c == L.cols - 2) && tile_get(c, r - 1) != Tile.finish) {
				instance_create_depth(cx, cy, -cy, obj_prop, { sprite_index: spr_trophy,
					image_xscale: 0.7, image_yscale: 0.7, shadow_w: 2.4, shadow_h: 0.7, shadow_alpha: 0.6 });
			}
		}
	}
}

// random spot on solid floor inside a box (not in a rock), or undefined if it cant find one
function random_floor_spot(_x1, _y1, _x2, _y2) {
	repeat (30) {
		var fx = random_range(_x1, _x2), fy = random_range(_y1, _y2);
		if (solid_at(fx, fy) && !rock_near(fx, fy, 24)) return [fx, fy];
	}
	return undefined;
}
