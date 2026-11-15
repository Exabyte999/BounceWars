/// @description wait on the edge, then roll. bounces off rocks, gone when its done
if (!world_running()) exit;
var dt = global.dt;
if (wait > 0) { wait -= dt; exit; }
x += roll_x * dt;
y += roll_y * dt;
spin += point_distance(0, 0, roll_x, roll_y) * dt / radius;
depth = -y;

// rocks bounce balls off like a mirror
with (obj_rockhead) {
	var dist = point_distance(x, y, other.x, other.y);
	if (dist < radius + other.radius && dist > 0.01) {
		var nx = (other.x - x) / dist, ny = (other.y - y) / dist;
		var along = other.roll_x * nx + other.roll_y * ny; // how fast its going into the rock
		if (along < 0) { other.roll_x -= 2 * along * nx; other.roll_y -= 2 * along * ny; pulse = 1; }
		other.x = x + nx * (radius + other.radius);
		other.y = y + ny * (radius + other.radius);
	}
}

if (rolling) {
	// race ball: smashes at the bottom of its section
	if (y > obj_game.roll_bottom) { fx_sparks(x, y, 0, choose(#a46bff, C_GREEN), 10); instance_destroy(); }
} else {
	// dodgeball: gone once its rolled out past the arena
	var cx = obj_level.cols * TILE / 2, cy = obj_level.rows * TILE / 2;
	if (point_distance(x, y, cx, cy) > 8 * TILE + 20 && (x - cx) * roll_x + (y - cy) * roll_y > 0) instance_destroy();
}
