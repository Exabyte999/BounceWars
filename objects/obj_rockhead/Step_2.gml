/// @description solid, nobody can stand inside it. bonks anyone who walks into it
if (!contestants_active()) exit;
with (obj_contestant) {
	var dist = point_distance(other.x, other.y, x, y), reach = other.radius + 5;
	if (can_be_hit() && dist < reach && dist > 0.01) {
		var nx = (x - other.x) / dist, ny = (y - other.y) / dist;
		x = other.x + nx * reach; // always push them out so nobody clips into it
		y = other.y + ny * reach;
		if (fresh_hit(other.id)) {
			other.pulse = 1;
			get_hit(nx * 300, ny * 300, 120);
			squish = 1.3;
			make_sound(snd_trampoline, 0.8, 0.25, random_range(0.85, 1.15));
			if (is_player) obj_game.shake = 3;
		}
	}
}
