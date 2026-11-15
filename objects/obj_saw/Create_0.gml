/// @description spinning arm with a saw on each end. arm_length + spin_speed (degrees/sec) come from the builder
angle = random(360);
depth = -y;

// how close a point is to the arm (bots use this to dodge it)
distance_to_arm = function(_x, _y) {
	var dx = lengthdir_x(arm_length, angle), dy = lengthdir_y(arm_length, angle);
	return distance_to_line(_x, _y, x - dx, y - dy, x + dx, y + dy);
};

// touching the arm or a blade? blades are bigger than the chain
touching = function(_x, _y) {
	var dx = lengthdir_x(arm_length, angle), dy = lengthdir_y(arm_length, angle);
	return distance_to_arm(_x, _y) < 11
		|| point_distance(_x, _y, x + dx, y + dy) < 16
		|| point_distance(_x, _y, x - dx, y - dy) < 16;
};
