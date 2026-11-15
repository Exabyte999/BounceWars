// bot brains (the goonies). they run inside obj_bot and press the same wanna_ "buttons" u would,
// so they follow all the same rules as u, no cheating

// race: pick the best lane, run up it, jump gaps and saws
function bot_think_race() {
	var dt = global.dt;
	brain_cd -= dt;
	hop_cd -= dt;
	var c0 = floor(x / TILE), r0 = floor(y / TILE);

	// every so often give each lane a score based on whats in the next few rows
	if (brain_cd <= 0) {
		brain_cd = random_range(0.15, 0.3);
		var best = c0, top_score = -9999;
		for (var c = 0; c < obj_level.cols; c++) {
			var lane_x = (c + 0.5) * TILE;
			var s = -abs(c - c0) * 0.6 + random(0.8) * (1.2 - skill); // worse bots wander more
			for (var k = 1; k <= 3; k++) {
				var ahead = tile_get(c, r0 - k);
				if (!tile_is_solid(ahead) && ahead != Tile.fan && tile_get(c, r0) != Tile.pad) s -= (k == 1) ? 3 : 1.5;
			}
			if (tile_get(c, r0) == Tile.pad) s += 2;
			with (obj_spikeball) if (abs(x - lane_x) < 34 && y < other.y && y > other.y - 160) s -= 4;
			with (obj_rockhead) if (abs(x - lane_x) < 26 && y < other.y && y > other.y - 90) s -= 2;
			with (obj_spikehead) if (y < other.y && y > other.y - 70 && lane_x > x - 12 && lane_x < x + width + 12) s -= 3;
			if (s > top_score) { top_score = s; best = c; }
		}
		lane = best;
	}

	// run up the lane, little derp so they dont look like robots
	var lane_target = (lane + 0.5) * TILE + sin(global.time * 2 + derp) * 6;
	wanna_x = clamp((lane_target - x) / 30, -1, 1);
	wanna_y = -1;
	// go round a rock thats right in front instead of running into it over and over like janis
	with (obj_rockhead) if (abs(x - other.x) < radius + 10 && y < other.y && y > other.y - 40) other.wanna_x = (other.x < x) ? -1 : 1;

	// jump gaps (sometimes + dash for distance) and saw arms
	if (on_ground && hop_cd <= 0) {
		var next_tile = tile_at(x, y - 22);
		if (!tile_is_solid(next_tile) && next_tile != Tile.fan && tile_at(x, y) != Tile.pad) {
			wanna_jump = true;
			hop_cd = 0.4;
			if (random(1) < 0.6 * skill) wanna_dash = true;
		}
		with (obj_saw) if (distance_to_arm(other.x, other.y) < 30 && random(1) < other.skill) { other.wanna_jump = true; other.hop_cd = 0.5; }
	}
}

// arenas: stay on safe floor near the middle, dodge stuff, shove people
function bot_think_arena() {
	var dt = global.dt, kind = obj_game.round_kind;
	var cx = obj_level.cols * TILE / 2, cy = obj_level.rows * TILE / 2;
	brain_cd -= dt;

	// try 10 random spots and pick the best: solid, near the middle, not heating up, away from spike balls,
	// close to u (so they come for u), and in the final near anyone to shove
	if (brain_cd <= 0) {
		brain_cd = random_range(0.15, 0.35);
		var top_score = -9999;
		repeat (10) {
			var qx = x + random_range(-90, 90), qy = y + random_range(-90, 90);
			var s = -point_distance(qx, qy, cx, cy) * 0.02;
			if (!solid_at(qx, qy)) s -= 50;
			else if (tile_heating(floor(qx / TILE), floor(qy / TILE))) s -= 10;
			with (obj_spikeball) s -= max(0, 70 - point_distance(qx, qy, x, y)) * 0.5;
			if (obj_player.in_round) s -= point_distance(qx, qy, obj_player.x, obj_player.y) * 0.03;
			if (kind == "final") {
				var nearest = 9999;
				with (obj_contestant) if (id != other.id && in_round) nearest = min(nearest, point_distance(qx, qy, x, y));
				s -= nearest * 0.03;
			}
			if (s > top_score) { top_score = s; target_x = qx; target_y = qy; }
		}
	}

	wanna_x = clamp((target_x - x) / 25, -1, 1);
	wanna_y = clamp((target_y - y) / 25, -1, 1);

	// hop on melting floor sometimes, turn round at the edge
	if (on_ground && kind == "melt" && random(1) < dt * 2.5) wanna_jump = true;
	if (on_ground && !solid_at(x + wanna_x * 20, y + wanna_y * 20)) { wanna_x = -wanna_x; wanna_y = -wanna_y; }

	with (obj_saw) if (other.on_ground && distance_to_arm(other.x, other.y) < 26 && random(1) < other.skill) other.wanna_jump = true;

	// shove! dash into anyone close, and twice as keen when its u. made this meaner after playtesting cuz the goonies were js vibing
	var shove_rate = (kind == "final") ? 6 : 3.5;
	if (dash_cd <= 0) {
		with (obj_contestant) if (id != other.id && in_round && point_distance(x, y, other.x, other.y) < 56 && random(1) < dt * shove_rate * other.skill * (is_player ? 2 : 1)) {
			other.wanna_x = (x - other.x) / 56;
			other.wanna_y = (y - other.y) / 56;
			other.wanna_dash = true;
			break;
		}
	}
}
