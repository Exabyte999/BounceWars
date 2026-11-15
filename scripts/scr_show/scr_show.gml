// the show: starting shows + rounds, stuff tht happens during rounds, who goes thru.
// the ones marked (obj_game) run inside obj_game so they use its variables directly

// is stuff moving? (not paused, not on the intro card)
function world_running() {
	var g = obj_game;
	return (g.state == "play" || g.state == "over") && g.phase != "intro";
}

// same but players also wait during the 3-2-1
function contestants_active() { return world_running() && obj_game.phase != "count"; }

// still playing this round (not out, not already qualified)
function count_alive() {
	var n = 0;
	with (obj_contestant) if (in_round && !qualified) n++;
	return n;
}

// still in the show at all
function count_contenders() {
	var n = 0;
	with (obj_contestant) if (!out) n++;
	return n;
}

// big message in the middle of the screen
function set_banner(_text, _time, _colour) {
	with (obj_game) { banner_text = _text; banner_time = _time; banner_colour = _colour; }
}

// knocks someone out of the show
function eliminate(_who) {
	with (_who) { out = true; in_round = false; }
	_who.place = count_contenders() + 1;
	if (_who.is_player) {
		with (obj_game) { im_out = true; died_round = round_num; died_place = _who.place; }
		set_banner(choose("ELIMINATED!", "YEETED!", "BONK! YOU'RE OUT!"), 3, C_PINK);
		play_sfx(snd_eliminated);
	}
}

// (obj_game) new show: 20 players, round 1
function show_start() {
	with (obj_contestant) instance_destroy();
	var names = array_shuffle(global.bot_names), skins = [];
	for (var i = 0; i < 20; i++) if (i != global.skin) array_push(skins, i);
	skins = array_shuffle(skins);
	instance_create_depth(0, 0, 0, obj_player, { idx: 0, name: "YOU", skin: global.skin });
	for (i = 1; i < 20; i++) instance_create_depth(0, 0, 0, obj_bot, { idx: i, name: names[i], skin: skins[i - 1] });

	winner = noone;
	im_out = false;
	show_on = true;
	state = "play";
	global.shows++;
	save_progress();
	round_start(1);
}

// (obj_game) back to the menu, clear everything
function show_end() {
	with (obj_contestant) instance_destroy();
	clear_round_stuff();
	level_clear();
	show_on = false;
	round_num = 0;
	winner = noone;
	state = "title";
}

// hazards, props and sparks from the last round
function clear_round_stuff() {
	with (obj_hazard) instance_destroy();
	with (obj_prop) instance_destroy();
	part_particles_clear(global.particles);
}

// (obj_game) builds round 1, 2 or 3 and puts everyone whos left on the start
function round_start(_round) {
	round_num = _round;
	clear_round_stuff();
	obj_camera.snap = true; // cut straight to the new arena, no swoop
	finished = 0;
	hurry_up = 0;
	next_ball = 1;
	phase = "intro";
	phase_clock = 10;

	switch (_round) {
		case 1: build_race(); break;
		case 2: // random pick out of lava / saws / dodgeball, never the same as last show (fruit heist got cut)
			var pick = choose("melt", "spin", "blitz");
			while (pick == last_mid_round) pick = choose("melt", "spin", "blitz");
			last_mid_round = pick;
			if (pick == "melt") build_melt();
			if (pick == "spin") build_spin();
			if (pick == "blitz") build_blitz();
			break;
		default: build_final();
	}
	level_place_props();

	var live = [];
	with (obj_contestant) {
		in_round = !out;
		qualified = false;
		place = 0;
		if (!out) array_push(live, id);
	}
	array_sort(live, function(a, b) { return a.idx - b.idx; });
	var n = array_length(live);
	for (var i = 0; i < n; i++) {
		var spot = spawn_point(i, n);
		live[i].place_at_start(spot[0], spot[1]);
	}
	play_sfx(snd_round_start);
}

// (obj_game) start spots: a grid at the bottom of the race, a ring in arenas
function spawn_point(_i, _count) {
	var L = obj_level;
	if (round_kind == "race") {
		var row = L.rows - 2 - (_i div 10), col = 0.5 + (_i mod 10);
		return [(col + 0.5) * TILE * (L.cols - 1) / 10, (row + 0.5) * TILE];
	}
	// ring is wider in the saw round so ur not starting inside a saw
	var a = _i / max(1, _count) * 360, dist = 4.5 * TILE;
	if (round_kind == "melt") dist = 4.2 * TILE;
	if (round_kind == "spin") dist = 5.8 * TILE;
	var cx = L.cols * TILE / 2, cy = L.rows * TILE / 2;
	repeat (12) { // slide round the ring till ur not in a rock
		if (!rock_near(cx + lengthdir_x(dist, a), cy + lengthdir_y(dist, a), 20)) break;
		a += 6;
	}
	return [cx + lengthdir_x(dist, a), cy + lengthdir_y(dist, a)];
}

// (obj_game) stuff tht happens during a round
function round_events(_dt) {
	var L = obj_level, cx = L.cols * TILE / 2, cy = L.rows * TILE / 2;
	var r, c;
	switch (round_kind) {
		case "race": // a ball rolls down human bowling every 1.3 to 2.1 secs
			next_ball -= _dt;
			if (next_ball <= 0) {
				next_ball = random_range(1.3, 2.1);
				instance_create_depth(random_range(30, L.cols * TILE - 30), roll_top, 0, obj_spikeball,
					{ radius: 22, roll_x: 0, roll_y: random_range(110, 150), rolling: true, wait: 0 });
			}
			break;

		case "blitz": // waves get faster and closer together as time runs out
			if (phase != "go") break;
			next_wave -= _dt;
			if (next_wave <= 0 && instance_number(obj_spikeball) < 14) {
				var progress = clamp(1 - timer / 25, 0, 1); // 0 at the start, 1 at the end
				next_wave = lerp(2.2, 1.0, progress);
				blitz_wave(choose("spread", "wall"), lerp(130, 200, progress));
			}
			break;

		case "melt": // random tiles heat up too, more over time, way more once ur out
			if (phase != "go") break;
			var heat_rate = melt_rate * (0.8 + (40 - timer) * 0.12) * ((hurry_up > 3) ? 6 : 1);
			repeat (2) {
				if (random(1) < _dt * heat_rate) {
					c = irandom(L.cols - 1);
					r = irandom(L.rows - 1);
					if (tile_get(c, r) == Tile.melt) tile_heat_up(c, r, 1.0);
				}
			}
			break;

		case "spin": // big saw joins halfway, edge crumbles every 5s
			if (phase != "go") break;
			if (!big_saw_in && timer < 12.5) {
				big_saw_in = true;
				make_saw(cx, cy, 110, choose(-1, 1) * random_range(70, 90));
				set_banner("BIG SAW INCOMING!", 1.5, C_HEAT);
				play_sfx(snd_shrink);
			}
			next_crumble -= _dt;
			if (next_crumble <= 0 && ring_size > 4) {
				next_crumble = 5;
				arena_shrink("THE EDGE IS CRUMBLING!");
			}
			break;

		case "final": // shrinks every 6s (every 2s once ur out so u dont wait forever)
			if (phase != "go") break;
			next_crumble -= _dt;
			var smallest = (hurry_up > 3) ? 1 : 2;
			if (next_crumble <= 0 && ring_size > smallest) {
				next_crumble = (hurry_up > 3) ? 2 : 6;
				arena_shrink("THE ARENA IS SHRINKING!");
			}
			break;
	}
}

// (obj_game) the outer ring heats up and drops
function arena_shrink(_message) {
	ring_size -= 1;
	var L = obj_level, mid = (L.cols - 1) / 2;
	for (var r = 0; r < L.rows; r++) {
		for (var c = 0; c < L.cols; c++) {
			if (tile_is_solid(tile_get(c, r)) && point_distance(c, r, mid, mid) > ring_size) tile_heat_up(c, r, 1.6);
		}
	}
	set_banner(_message, 1.5, C_HEAT);
	play_sfx(snd_shrink);
}

// (obj_game) players push each other apart, a dash slams whoever it hits
function contestant_bumps() {
	var list = [];
	with (obj_contestant) if (in_round && !falling) array_push(list, id);
	var n = array_length(list), slam = (round_kind == "final") ? 360 : 320;
	for (var i = 0; i < n; i++) {
		var a = list[i];
		for (var j = i + 1; j < n; j++) {
			var b = list[j];
			if (abs(a.z - b.z) > 14) continue;
			var d = point_distance(a.x, a.y, b.x, b.y);
			if (d >= 14 || d < 0.1) continue;
			var nx = (b.x - a.x) / d, ny = (b.y - a.y) / d, overlap = (14 - d) * 0.25;
			a.x -= nx * overlap; a.y -= ny * overlap;
			b.x += nx * overlap; b.y += ny * overlap;
			// dash into someone = they get slammed
			if (a.dash_left > 0 && b.dash_left <= 0) { slam_into(b, nx * slam, ny * slam); a.dash_left = 0; }
			else if (b.dash_left > 0 && a.dash_left <= 0) { slam_into(a, -nx * slam, -ny * slam); b.dash_left = 0; }
		}
	}
}

function slam_into(_who, _push_x, _push_y) {
	with (_who) {
		yeet_x += _push_x;
		yeet_y += _push_y;
		z_speed = 200;
		on_ground = false;
		ouchie = 0.1;
		squish = 1.3;
		fx_sparks(x, y, 10, C_WHITE, 8);
		if (on_screen(x, y)) play_sfx(snd_hit, 0.6);
		if (is_player || obj_player.dash_left > 0) obj_game.shake = 6;
	}
}

// (obj_game) is the round over? if so work out who goes thru
function round_check_end() {
	// nobody finished the race in time, hurry up
	if (round_kind == "race" && timer <= 0 && finished == 0) hurry_up = 99;

	// ur thru (or out) and 3s passed, so fill the rest of the places
	if (hurry_up > 3) {
		if (round_kind == "spin" || round_kind == "blitz") timer = 0;
		else if (round_kind == "race") {
			while (finished < target) { // whoever got furthest up goes thru
				var best = noone;
				with (obj_bot) if (in_round && !qualified && (best == noone || y < best.y)) best = id;
				if (best == noone) break;
				best.qualify();
			}
		} else if (hurry_up > 45) {
			// melt + final speed up instead (round_events). this is only if the goonies STILL havent finished after 45s
			while (count_alive() > target) {
				var victims = [];
				with (obj_bot) if (in_round && !qualified) array_push(victims, id);
				if (array_length(victims) == 0) break;
				eliminate(victims[irandom(array_length(victims) - 1)]);
			}
		}
	}

	var over = false;
	switch (round_kind) {
		case "race": over = (finished >= target || timer <= 0); break;
		case "final": over = (count_alive() <= 1); break;
		default: over = (count_alive() <= target || timer <= 0); // melt, spin, blitz
	}
	if (over) round_finish();
}

// (obj_game) round ended, sort out who qualified, whos out and who won
function round_finish() {
	phase = "end";
	phase_clock = 4;

	// everyone still standing goes thru (in the race anyone who didnt finish is out)
	var kind = round_kind;
	with (obj_contestant) {
		if (in_round && kind == "race") {
			if (!qualified) eliminate(id);
		} else if (in_round) {
			if (kind == "final") { obj_game.winner = id; place = 1; }
			if (is_player) {
				if (kind == "final") set_banner("YOU WIN THE CROWN!", 4, C_YELLOW);
				else set_banner("QUALIFIED!", 2.5, C_YELLOW);
				play_sfx(snd_win);
			}
		}
	}
	if (kind == "race" && !(im_out && died_round == 1)) set_banner("ROUND OVER!", 3, C_CYAN);

	if (kind == "final") {
		if (winner == noone) winner = instance_find(obj_contestant, 0); // js in case, shouldnt ever happen
		if (winner.is_player) { global.wins++; save_progress(); }
		else set_banner(winner.name + " WINS THE CROWN!", 4, C_CYAN);
		phase_clock = 5;
		repeat (4) fx_sparks(winner.x + random_range(-60, 60), winner.y + random_range(-60, 60), 40, choose(C_YELLOW, C_GREEN, C_RED, C_CYAN, C_PINK), 20);
	}
}
