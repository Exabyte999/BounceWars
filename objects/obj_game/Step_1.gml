/// @description frame time + input (before everyone elses step)
global.dt = min(delta_time / 1000000, 1 / 30); // capped so a lag spike cant fling everyone off the map
global.time += global.dt;
global.input = input_read();
if (keyboard_check_pressed(vk_f4)) set_fullscreen(!window_get_fullscreen());
if (keyboard_check_pressed(ord("M"))) music_on = !music_on;
