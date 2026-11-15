/// @description every player (u + 19 goonies). parent of obj_player and obj_bot
// idx, name and skin get passed in by show_start

// x / y is on the floor, z is how high up u are (fake 3d)
z = 0;
z_speed = 0;
walk_x = 0; // walking speed
walk_y = 0;
yeet_x = 0; // extra speed from hits and dashes, wears off
yeet_y = 0;
on_ground = true;
coyote_time = 0; // can still jump a tiny bit after running off a ledge
jump_saved = 0; // pressing jump right before landing still counts
off_pad = false; // launched by a trampoline (always a full jump)
falling = false; // fell off and dropping into the void rip
facing = 1;
squish = 0;
ouchie = 0;
bonk_cd = 0; // the hazard tht js hit u cant hit u again for a sec
last_bonker = noone;

// moves
dash_left = 0;
dash_cd = 0;
skid_left = 0;
boing_time = 0; // got sprung back after falling
spring_x = 0;
spring_y = 0;
checkpoint_x = 0;
checkpoint_y = 0;

// show stuff
out = false; // out of the show
in_round = true;
qualified = false;
place = 0;

// different for the player and the bots
is_player = false;
move_speed = 158;

// controls, filled in every step by obj_player (keyboard) or obj_bot (its brain)
wanna_x = 0;
wanna_y = 0;
wanna_jump = false;
holding_jump = true;
wanna_dash = false;

// loud for u, quiet for bots (and only if theyre on screen)
make_sound = function(_sound, _player_volume, _bot_volume, _pitch = 1) {
	if (is_player) play_sfx(_sound, _player_volume, _pitch);
	else if (on_screen(x, y)) play_sfx(_sound, _bot_volume, _pitch);
};

// cant be hit when ur high up or falling
can_be_hit = function() { return in_round && !falling && z <= 26; };

// true if this is a new hit. same hazard cant hit again for 0.25s (otherwise its a hit every frame, pure slop)
fresh_hit = function(_hazard) {
	if (obj_game.phase == "go" && obj_game.phase_clock > 0) return false; // safe for the first 1.5s of a round
	if (bonk_cd > 0 && last_bonker == _hazard) return false;
	bonk_cd = 0.25;
	last_bonker = _hazard;
	return true;
};

// knocked by a hazard
get_hit = function(_push_x, _push_y, _lift) {
	yeet_x = _push_x;
	yeet_y = _push_y;
	z_speed = max(z_speed, _lift);
	on_ground = false;
	squish = 1.2;
	ouchie = 0.08;
};

// teleport somewhere and get launched up on a spring (used for respawns + rescues)
launch_to = function(_x, _y, _z_speed) {
	x = _x;
	y = _y;
	z = 0;
	z_speed = _z_speed;
	walk_x = 0; walk_y = 0;
	yeet_x = 0; yeet_y = 0;
	on_ground = false;
	falling = false;
	boing_time = 1;
	spring_x = x;
	spring_y = y;
};

// bounce back onto safe floor in an arena
rescue = function(_message) {
	var spot = level_safe_spot();
	launch_to(spot[0], spot[1], 420);
	if (is_player && _message != "") {
		set_banner(_message, 1.5, C_YELLOW);
		play_sfx(snd_bounce_back, 0.9);
	}
};

// fell far enough into the void, what happens depends on the round
fell_off = function() {
	falling = false;
	var kind = obj_game.round_kind;
	// race: a spring yeets u back to the last flag (thats the "bounce back" in the jam theme)
	if (kind == "race") {
		launch_to(checkpoint_x + random_range(-30, 30), checkpoint_y, 330);
		squish = 1.2;
		fx_sparks(x, y, 0, C_YELLOW, 14);
		if (is_player) {
			set_banner(choose("WIPEOUT!", "OOF!", "WHOOPS!", "BOUNCED BACK!"), 1, C_PINK);
			play_sfx(snd_bounce_back, 0.8);
		}
		return;
	}
	// last one standing can never be knocked out
	if (obj_game.phase != "go" || obj_game.phase_clock > 0 || count_alive() <= 1) { rescue("SAVED BY THE BOUNCE!"); return; }
	eliminate(id);
};

// crossed the race finish
qualify = function() {
	qualified = true;
	safe_x = x; safe_y = y; // the finish zone spot to snap back to (see Step)
	obj_game.finished += 1;
	place = obj_game.finished;
	fx_sparks(x, y, 0, global.skin_colours[skin], 24);
	if (is_player) {
		set_banner("QUALIFIED!", 2.5, C_YELLOW);
		fx_sparks(x, y, 20, C_YELLOW, 40);
		play_sfx(snd_win);
	} else if (on_screen(x, y)) play_sfx(snd_pickup, 0.4);
};

// what the tile ur standing on does (pads, checkpoints and the finish are only in the race)
land_on = function(_tile) {
	switch (_tile) {
		case Tile.pad: // trampoline, big bounce and a push up the course
			z_speed = 560;
			on_ground = false;
			off_pad = true;
			squish = 1.5;
			yeet_y -= 260;
			make_sound(snd_trampoline, 0.8, 0.3, random_range(0.9, 1.1));
			if (on_screen(x, y)) fx_sparks(x, y, 0, C_ORANGE, 8);
			break;
		case Tile.checkpoint: // remember this row for the spring
			checkpoint_x = clamp(x, TILE, (obj_level.cols - 1) * TILE);
			checkpoint_y = floor(y / TILE) * TILE + TILE / 2;
			break;
		case Tile.finish:
			if (!qualified) qualify();
			break;
		case Tile.melt: // standing on it heats it up (only during the round)
			if (obj_game.phase == "go") tile_heat_up(floor(x / TILE), floor(y / TILE), 1.1);
			break;
	}
};

// on the start line for a new round
place_at_start = function(_x, _y) {
	x = _x;
	y = _y;
	z = 0;
	z_speed = 0;
	walk_x = 0; walk_y = 0;
	yeet_x = 0; yeet_y = 0;
	on_ground = true;
	falling = false;
	checkpoint_x = x;
	checkpoint_y = y;
	dash_left = 0;
	skid_left = 0;
	boing_time = 0;
	depth = -y;
};
