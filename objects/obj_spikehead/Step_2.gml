/// @description solid, nobody can stand inside it. shoves anyone in the way
if (!contestants_active()) exit;
with (obj_contestant) {
	var gap = 5;
	if (can_be_hit() && x > other.x - gap && x < other.x + other.width + gap && y > other.y - 4 && y < other.y + other.height + 4) {
		var side = (x < other.x + other.width / 2) ? -1 : 1; // which side of the block were on
		x = (side < 0) ? other.x - gap : other.x + other.width + gap; // always push them out
		if (fresh_hit(other.id)) {
			var moving = cos(other.slide_phase) * other.slide_speed; // which way its sliding
			if (sign(moving) == side || abs(moving) < 0.2) { // its coming at u = big shove
				yeet_x = side * 380;
				z_speed = max(z_speed, 140);
				on_ground = false;
			} else yeet_x = side * 120; // u walked into its back = small nudge
			squish = 1;
			ouchie = 0.06;
			make_sound(snd_thud, 0.6, 0.2);
		}
	}
}
