// keyboard + mouse all go into one struct (global.input) every step
// so nothing else has to care what ur playing with
function input_read() {
	var left = keyboard_check(vk_left) || keyboard_check(ord("A"));
	var right = keyboard_check(vk_right) || keyboard_check(ord("D"));
	var up = keyboard_check(vk_up) || keyboard_check(ord("W"));
	var down = keyboard_check(vk_down) || keyboard_check(ord("S"));
	var inp = {
		walk_x: right - left,
		walk_y: down - up,
		jump: keyboard_check_pressed(vk_space),
		jump_held: keyboard_check(vk_space),
		dash: keyboard_check_pressed(vk_shift) || keyboard_check_pressed(ord("E")) || keyboard_check_pressed(ord("J")) || mouse_check_button_pressed(mb_left),
		pause: keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("P")),
		new_game: keyboard_check_pressed(ord("R")),
		// menus
		confirm: keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter),
		click: mouse_check_button_pressed(mb_left),
		left: keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")),
		right: keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")),
		up: keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")),
		down: keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))
	};
	return inp;
}
