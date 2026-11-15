/// @description knock away anyone the arm or a blade touches
if (!contestants_active()) exit;
with (obj_contestant) {
	if (can_be_hit() && z < 16 && other.touching(x, y) && fresh_hit(other.id)) {
		// knocked the way the arm is swinging, harder near the tips
		var dir = point_direction(other.x, other.y, x, y) + sign(other.spin_speed) * 90;
		var force = 210 + point_distance(x, y, other.x, other.y) * 1.5;
		get_hit(lengthdir_x(force, dir), lengthdir_y(force, dir), 230);
		make_sound(snd_hit, 0.8, 0.3);
		if (is_player) obj_game.shake = 8;
	}
}
