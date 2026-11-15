/// @description spin (hits are in end step)
if (!world_running()) exit;
// saws get angrier: in the final as it shrinks, in the saw round as the clock runs down
var boost = 1;
if (obj_game.phase == "go") {
	if (obj_game.round_kind == "final") boost = 1 + (8 - obj_game.ring_size) * 0.15;
	if (obj_game.round_kind == "spin") boost = 1 + (1 - obj_game.timer / 45) * 0.8;
}
angle += spin_speed * boost * global.dt;
depth = -(y + abs(lengthdir_y(arm_length, angle))); // sort by the end closest to the camera
