/// @description hit anyone in the way
if (!contestants_active() || wait > 0) exit;

with (obj_contestant) {
	var dist = point_distance(other.x, other.y, x, y);
	if (can_be_hit() && z < 30 && dist < other.radius + 6 && dist > 0.01 && fresh_hit(other.id)) {
		if (other.rolling) {
			get_hit((x >= other.x) ? 100 : -100, 320, 200); // knocked down the course
			squish = 1.3;
			make_sound(snd_splat, 0.8, 0.3);
			if (is_player) obj_game.shake = 8;
		} else {
			// knocked along the balls path, it keeps rolling (cant hit u twice)
			var ball_speed = max(60, point_distance(0, 0, other.roll_x, other.roll_y));
			get_hit(other.roll_x / ball_speed * 300, other.roll_y / ball_speed * 300, 180);
			ouchie = 0.1;
			make_sound(snd_splat, 0.8, 0.3);
			if (is_player) obj_game.shake = 3;
		}
	}
}
