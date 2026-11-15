/// @description movement + physics. obj_player / obj_bot fill in the wanna_ stuff first
// lower on screen = drawn in front. once uve dropped a bit into the void u go behind the floor
// (obj_level is depth 1000) so u sink out of sight
depth = (falling && z < -40) ? 1001 : -y;
if (!in_round || !contestants_active()) exit;

var dt = global.dt;
if (obj_game.phase == "end") { // round over, js stand there
	wanna_x = 0; wanna_y = 0;
	wanna_jump = false; holding_jump = true;
	wanna_dash = false;
}

// timers
ouchie -= dt;
bonk_cd -= dt;
squish = max(0, squish - dt * 4);
dash_cd -= dt;
coyote_time -= dt;
boing_time -= dt;
if (wanna_jump) jump_saved = 0.14;
jump_saved -= dt;

// walking
var mx = wanna_x, my = wanna_y, stick = point_distance(0, 0, mx, my);
if (stick > 1) { mx /= stick; my /= stick; }
if (skid_left > 0) { skid_left -= dt; mx = 0; my = 0; } // little skid after a dash lands
var accel = on_ground ? 12 : 6;
if (dash_left > 0) { dash_left -= dt; accel = 0; }
if (!falling) {
	walk_x = lerp(walk_x, mx * move_speed, min(1, dt * accel));
	walk_y = lerp(walk_y, my * move_speed, min(1, dt * accel));
}
var slow_down = power(on_ground ? 0.03 : 0.5, dt); // pushes wear off way faster on the ground
yeet_x *= slow_down;
yeet_y *= slow_down;
if (abs(walk_x) > 30) facing = sign(walk_x);

// jump, dash
if (jump_saved > 0 && (on_ground || coyote_time > 0) && !falling && skid_left <= 0) {
	z_speed = 350;
	on_ground = false;
	coyote_time = 0;
	jump_saved = 0;
	off_pad = false;
	squish = 1;
	make_sound(snd_jump, 0.6, 0.15, random_range(0.95, 1.15));
}
if (wanna_dash && dash_cd <= 0 && !falling && skid_left <= 0) {
	var dir = (facing > 0) ? 0 : 180;
	if (stick > 0.1) dir = point_direction(0, 0, mx, my);
	else if (!is_player) dir = 90; // bots dash forward (up the course)
	yeet_x = lengthdir_x(330, dir);
	yeet_y = lengthdir_y(330, dir);
	z_speed = max(z_speed, 70);
	on_ground = false;
	dash_left = 0.28;
	dash_cd = 0.8;
	make_sound(snd_dash, 0.6, 0.15);
}
wanna_jump = false;
wanna_dash = false;

// move + gravity
x += (walk_x + yeet_x) * dt;
y += (walk_y + yeet_y) * dt;
// qualified = u can walk round the finish zone but never leave it. used to get bumped off the edge after qualifying and respawn at a checkpoint lmao
if (qualified) { if (tile_at(x, y) == Tile.finish) { safe_x = x; safe_y = y; } else { x = safe_x; y = safe_y; } }
z_speed -= GRAVITY * dt;
if (z_speed < 0) z_speed -= GRAVITY * 0.4 * dt; // fall a bit faster than u go up
else if (!holding_jump && !off_pad) z_speed -= GRAVITY * 1.3 * dt; // let go early = small hop
z += z_speed * dt;

var tile = tile_at(x, y);
if (tile == Tile.fan && z < 140) { // fans blow u up
	z_speed += 1700 * dt;
	if (random(1) < dt * 20) fx_sparks(x, y, z - 10, C_CYAN, 1);
}
if (falling) {
	if (z < -260) fell_off();
	exit;
}

// landing
if (z <= 0) {
	if (tile_is_solid(tile)) {
		if (!on_ground && z_speed < -200) squish = 1;
		if (dash_left > 0 && !on_ground) { skid_left = 0.06; dash_left = 0; }
		z = 0;
		z_speed = 0;
		on_ground = true;
		coyote_time = 0.1;
		off_pad = false;
		land_on(tile);
	} else {
		// walked off the edge
		if (on_ground) { on_ground = false; coyote_time = 0.1; }
		if (z < -12) { falling = true; make_sound(snd_fall, 0.7, 0.25); }
	}
} else on_ground = false;
