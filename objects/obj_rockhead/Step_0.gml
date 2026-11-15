/// @description squish fades (hits are in end step after everyone moved)
if (!world_running()) exit;
pulse = max(0, pulse - global.dt * 3);
