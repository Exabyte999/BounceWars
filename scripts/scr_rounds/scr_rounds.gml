// round builders. each one makes the floor, puts the hazards down and sets the rounds name + rules.
// round_start calls them from obj_game so they set its variables directly

function make_rock(_x, _y, _radius = 16) {
	instance_create_depth(_x, _y, 0, obj_rockhead, { radius: _radius });
}

// rocks spaced evenly in a circle around (cx, cy)
function make_rock_ring(_cx, _cy, _count, _dist, _angle, _radius = 16) {
	for (var k = 0; k < _count; k++) {
		var a = _angle + k * 360 / _count;
		make_rock(_cx + lengthdir_x(_dist, a), _cy + lengthdir_y(_dist, a), _radius);
	}
}

// spin is degrees per second, negative = other way
function make_saw(_x, _y, _length, _spin) {
	instance_create_depth(_x, _y, 0, obj_saw, { arm_length: _length, spin_speed: _spin });
}

// square grid with floor in a shape: circle, square, diamond or donut
function make_arena(_size, _shape, _radius, _type, _look) {
	level_new(_size, _size, _look);
	var mid = (_size - 1) / 2;
	for (var r = 0; r < _size; r++) {
		for (var c = 0; c < _size; c++) {
			var dx = abs(c - mid), dy = abs(r - mid), dist = point_distance(0, 0, dx, dy), inside = false;
			switch (_shape) {
				case "circle": inside = dist <= _radius; break;
				case "square": inside = max(dx, dy) <= _radius; break;
				case "diamond": inside = dx + dy <= _radius; break;
				case "donut": inside = dist <= _radius && dist >= 1.6; break;
			}
			if (inside) level_set(c, r, _type);
		}
	}
}

// ROUND 1: BOING BOING BOULEVARD, the race. first 10 thru. built from the start (bottom) up to the finish (top),
// the 7 sections come in a random order every show
function build_race() {
	var order = array_shuffle(["bump", "gap", "sweep", "piston", "roll", "hops", "bridge"]);
	var heights = { bump: 13, gap: 5, sweep: 15, piston: 16, roll: 18, hops: 12, bridge: 13 };
	var i, d, r, k, total = 10;
	for (i = 0; i < 7; i++) total += heights[$ order[i]];
	level_new(total + 1, 11, Look.grass, Tile.hole); // empty cells in the race are pits, not sky
	var bottom = total; // rows count from the top so "d rows up the course" = row bottom - d
	var w = 11 * TILE;
	var d0 = 4; // where the current section starts

	for (d = 0; d <= 3; d++) level_fill_row(bottom - d, Tile.ground, Look.grass); // start area
	for (i = 0; i < 7; i++) {
		var section = order[i];
		switch (section) {
			case "bump": // rock heads + a few holes
				for (d = d0; d <= d0 + 11; d++) level_fill_row(bottom - d, Tile.ground, Look.sand);
				level_fill_row(bottom - (d0 + 12), Tile.checkpoint);
				repeat (irandom_range(5, 8)) level_set(irandom(10), bottom - irandom_range(d0 + 2, d0 + 10), Tile.hole);
				repeat (irandom_range(10, 14)) {
					var rock_spot = random_floor_spot(30, (bottom - d0 - 10) * TILE, w - 30, (bottom - d0) * TILE);
					if (!is_undefined(rock_spot)) make_rock(rock_spot[0], rock_spot[1]);
				}
				break;
			case "gap": // gap over spikes, fans on the sides, 3 trampolines
				level_fill_row(bottom - d0, Tile.checkpoint);
				var pads = array_shuffle([2, 3, 4, 5, 6, 7, 8]);
				for (k = 0; k < 3; k++) level_set(pads[k], bottom - d0, Tile.pad);
				for (d = d0 + 1; d <= d0 + 4; d++) {
					level_fill_row(bottom - d, Tile.hole);
					level_set(0, bottom - d, Tile.fan);
					level_set(10, bottom - d, Tile.fan);
				}
				break;
			case "sweep": // spinning saw arms, holes near the edges
				for (d = d0; d <= d0 + 13; d++) level_fill_row(bottom - d, Tile.ground, Look.clay);
				level_fill_row(bottom - (d0 + 14), Tile.checkpoint);
				repeat (irandom_range(4, 6)) level_set(choose(0, 1, 9, 10, irandom(10)), bottom - irandom_range(d0 + 1, d0 + 12), Tile.hole);
				var dir = choose(-1, 1);
				make_saw(5.5 * TILE, (bottom - d0 - 2.5) * TILE, 150, dir * random_range(75, 103));
				make_saw(2.5 * TILE, (bottom - d0 - 7.5) * TILE, 92, -dir * random_range(103, 138));
				make_saw(8.5 * TILE, (bottom - d0 - 7.5) * TILE, 92, dir * random_range(103, 138));
				if (random(1) < 0.6) make_saw(5.5 * TILE, (bottom - d0 - 11.5) * TILE, 150, -dir * random_range(68, 96));
				break;
			case "piston": // narrow alley with sliding spike blocks
				for (d = d0; d <= d0 + 14; d++) level_fill_row(bottom - d, Tile.ground, Look.sand, 1, 9);
				level_fill_row(bottom - (d0 + 15), Tile.checkpoint);
				repeat (irandom_range(2, 3)) level_set(choose(1, 9), bottom - irandom_range(d0 + 1, d0 + 13), Tile.hole);
				for (k = 0; k < 4; k++) {
					instance_create_depth(0, (bottom - (d0 + 2 + k * 3.5)) * TILE + 4, 0, obj_spikehead, {
						width: 3 * TILE, height: TILE - 8, rail_left: TILE, rail_right: 10 * TILE,
						slide_phase: random(2 * pi), slide_speed: random_range(1.4, 2.2)
					});
				}
				break;
			case "roll": // balls roll down at u (round_events spawns them)
				for (d = d0; d <= d0 + 16; d++) level_fill_row(bottom - d, Tile.ground, Look.clay);
				repeat (irandom_range(10, 16)) level_set(irandom(10), bottom - irandom_range(d0 + 2, d0 + 14), Tile.hole);
				level_fill_row(bottom - (d0 + 17), Tile.checkpoint);
				roll_top = (bottom - (d0 + 16)) * TILE;
				roll_bottom = (bottom - (d0 - 1)) * TILE;
				break;
			case "hops": // gap every 3rd row with random trampolines
				for (d = d0; d <= d0 + 10; d++) level_fill_row(bottom - d, ((d - d0) mod 3 == 2) ? Tile.hole : Tile.ground, Look.grass);
				for (d = d0 + 2; d <= d0 + 10; d += 3) {
					level_set(irandom_range(1, 9), bottom - d, Tile.pad);
					level_set(irandom_range(1, 9), bottom - (d - 1), Tile.pad);
				}
				level_fill_row(bottom - (d0 + 11), Tile.checkpoint);
				break;
			case "bridge": // 2 wiggly paths 2 tiles wide, one full row halfway to rest
				var left = irandom_range(1, 3), right = irandom_range(7, 9);
				for (d = d0; d <= d0 + 11; d++) {
					r = bottom - d;
					if (d == d0 + 6) { level_fill_row(r, Tile.ground, Look.sand); continue; }
					level_fill_row(r, Tile.hole, Look.sand);
					left = clamp(left + choose(-1, 0, 0, 1), 0, 4);
					right = clamp(right + choose(-1, 0, 0, 1), 6, 9);
					for (k = 0; k < 2; k++) { level_set(left + k, r, Tile.ground); level_set(right + k, r, Tile.ground); }
				}
				level_fill_row(bottom - (d0 + 12), Tile.checkpoint);
				break;
		}
		d0 += heights[$ section];
	}
	for (d = d0; d <= d0 + 5; d++) level_fill_row(bottom - d, Tile.finish);

	round_kind = "race";
	round_name = "BOING BOING BOULEVARD";
	round_desc = "ONLY THE FIRST 10 GET THROUGH. FALL OFF AND A SPRING YEETS YOU BACK TO THE LAST FLAG.";
	target = 10;
	timer = 75;
	round_goal = "FIRST " + string(target) + " TO THE FINISH QUALIFY";
}

// ROUND 2 option: THE FLOOR IS LAVA (ISH). tiles heat up when u stand on them and drop (1.1s, 0.6 was unfair)
function build_melt() {
	var shape = choose("circle", "square", "diamond", "donut"), radius = random_range(6.6, 7.4);
	if (shape == "square") radius -= 0.6;
	if (shape == "diamond") radius += 1.5;
	make_arena(15, shape, radius, Tile.melt, Look.sand);
	melt_rate = random_range(1.2, 1.8);
	var has_saw = (random(1) < 0.8);
	if (has_saw) make_saw(240, 240, 110, choose(-1, 1) * random_range(40, 63));

	round_kind = "melt";
	round_name = "THE FLOOR IS LAVA (ISH)";
	round_desc = "EVERY TILE YOU STAND ON GETS HOT AND DROPS. KEEP YOUR FEET MOVING, AND FEEL FREE TO SHOVE.";
	target = max(2, ceil(count_contenders() / 2));
	timer = 40;
	round_goal = "LAST " + string(target) + " STANDING QUALIFY";
}

// ROUND 2 option: SAW WHAT YOU DID THERE. saws and rocks, gets worse over time (see round_events)
function build_spin() {
	var shape = choose("circle", "square");
	make_arena(15, shape, (shape == "circle") ? 7.2 : 6.5, Tile.ground, Look.grass);
	var a0 = random(360), dir = choose(-1, 1), saws = choose(2, 3), rocks = choose(2, 3, 4);
	for (var k = 0; k < saws; k++) {
		var spin = dir * random_range(52, 80) * ((k mod 2 == 1) ? -1 : 1);
		make_saw(240 + lengthdir_x(85, a0 + k * 360 / saws), 240 + lengthdir_y(85, a0 + k * 360 / saws), 70, spin);
	}
	make_rock_ring(240, 240, rocks, 170, a0 + 34);
	big_saw_in = false;
	next_crumble = 6;
	ring_size = 8;

	round_kind = "spin";
	round_name = "SAW WHAT YOU DID THERE";
	round_desc = "SAWS GET FASTER, A BIG ONE JOINS HALFWAY, AND THE EDGE CRUMBLES EVERY 5 SECONDS.";
	target = max(2, ceil(count_contenders() / 2));
	timer = 25;
	round_goal = "SURVIVE " + string(timer) + "s, OR BE IN THE LAST " + string(target);
}

// ROUND 2 option: DODGEBALL DISASTER. waves of balls from the edges (round_events spawns them)
function build_blitz() {
	make_arena(15, "circle", 7.2, Tile.ground, Look.grass);
	var rocks = choose(0, 2, 3);
	make_rock_ring(240, 240, rocks, 110, random(360));
	next_wave = 1;

	round_kind = "blitz";
	round_name = "DODGEBALL DISASTER";
	round_desc = "WAVES OF SPIKED BALLS ROLL IN FROM THE EDGES. WATCH FOR THE RED WARNING LINES!";
	target = max(2, ceil(count_contenders() / 2));
	timer = 25;
	round_goal = "SURVIVE " + string(timer) + "s, OR BE IN THE LAST " + string(target);
}

// ROUND 3: THE FINAL FLING. arena falls apart ring by ring, last one standing gets the crown
function build_final() {
	var shape = choose("circle", "square", "diamond");
	var radius = (shape == "circle") ? 8 : ((shape == "square") ? 7 : 9.5);
	make_arena(17, shape, radius, Tile.ground, Look.grass);
	var mid = 17 * TILE / 2, dir = choose(-1, 1), rocks = choose(2, 3, 4, 5);
	make_rock_ring(mid, mid, rocks, 120, random(360), 18);
	make_saw(mid, mid, 120, dir * random_range(52, 69));
	var double_saw = (random(1) < 0.4);
	if (double_saw) make_saw(mid, mid, 70, -dir * random_range(69, 92));
	next_crumble = 8;
	ring_size = 8;

	round_kind = "final";
	round_name = "THE FINAL FLING";
	round_desc = "THE ARENA FALLS APART RING BY RING. SHOVE EVERYONE OFF. BE THE LAST ONE STANDING.";
	target = 1;
	timer = 999;
	round_goal = "LAST ONE STANDING WINS";
}

// dodgeball: one wave of balls. every ball sits on the edge first with a red line
// showing where its going, so u can always see it coming (no cheap slop hits)
//   spread = 3 in a fan    wall = 4 side by side
function blitz_wave(_pattern, _speed) {
	var mid = 240, edge = 8 * TILE; // js outside the arena
	var a = random(360), k, start_x = mid + lengthdir_x(edge, a), start_y = mid + lengthdir_y(edge, a);
	var to_mid = point_direction(start_x, start_y, mid, mid);
	switch (_pattern) {
		case "spread":
			for (k = -1; k <= 1; k++) launch_ball(start_x, start_y, to_mid + k * 18, _speed);
			break;
		case "wall":
			for (k = -1.5; k <= 1.5; k += 1) launch_ball(start_x + lengthdir_x(k * 56, a + 90), start_y + lengthdir_y(k * 56, a + 90), to_mid, _speed);
			break;
	}
}

function launch_ball(_x, _y, _dir, _speed) {
	instance_create_depth(_x, _y, 0, obj_spikeball,
		{ radius: 13, roll_x: lengthdir_x(_speed, _dir), roll_y: lengthdir_y(_speed, _dir), rolling: false, wait: 0.9 });
}
