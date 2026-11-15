/// @description slide back and forth (hits are in end step)
if (!world_running()) exit;
slide_phase += slide_speed * global.dt;
x = lerp(rail_left, rail_right - width, 0.5 + 0.5 * sin(slide_phase));
