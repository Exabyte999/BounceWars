/// @description run whichever menu is showing
var game = obj_game, inp = global.input, choice = "", in_menu = (game.state != "play");
var mx = device_mouse_x_to_gui(0), my = device_mouse_y_to_gui(0);

switch (game.state) {
	case "title":
		// a/d or the arrows next to the character change skin
		var skin_change = inp.right - inp.left;
		if (inp.click && point_distance(mx, my, VIEW_W * 0.3 - 78, 202) < 18) skin_change = -1;
		if (inp.click && point_distance(mx, my, VIEW_W * 0.3 + 78, 202) < 18) skin_change = 1;
		if (skin_change != 0) {
			global.skin = (global.skin + 20 + skin_change) mod 20;
			play_sfx(snd_menu_move, 1, 1 + skin_change * 0.1);
		}
		choice = navigate();
		if (choice == "NEW GAME") with (game) show_start();
		if (choice == "CHARACTER") global.skin = (global.skin + 1) mod 20;
		if (choice == "SETTINGS") open_settings("title");
		if (choice == "QUIT GAME") game_end();
		break;

	case "settings":
		// left/right change whatevers sel_btn
		var change = inp.right - inp.left;
		if (change != 0 && sel_btn < 2) change_volume(sel_btn, change);
		if (change != 0 && sel_btn == 2) { set_fullscreen(!window_get_fullscreen()); apply_settings(); }
		// or click the - / + next to the volume bars
		if (inp.click) {
			for (var i = 0; i < 2; i++) {
				var r = item_rect(i), mid = (r[1] + r[3]) / 2;
				if (point_distance(mx, my, r[2] - 132, mid) < 13) { sel_btn = i; change_volume(i, -1); }
				if (point_distance(mx, my, r[2] - 18, mid) < 13) { sel_btn = i; change_volume(i, 1); }
			}
		}
		choice = navigate();
		if (choice == "FULLSCREEN") set_fullscreen(!window_get_fullscreen());
		if (choice == "BACK" || inp.pause) {
			apply_settings();
			game.state = back_to;
			sel_btn = 0;
		}
		break;

	case "play":
		if (inp.pause) { game.state = "pause"; sel_btn = 0; }
		// once ur out: R or click the button next to SPECTATING starts a new game
		var new_game = inp.new_game || (inp.click && point_in_rectangle(mx, my, VIEW_W / 2 + 4, VIEW_H - 32, VIEW_W / 2 + 164, VIEW_H - 6));
		if (obj_player.out && new_game) with (game) show_start();
		break;

	case "pause":
		choice = navigate();
		if (inp.pause || choice == "RESUME") game.state = "play";
		if (choice == "RESTART SHOW") with (game) show_start();
		if (choice == "SETTINGS") open_settings("pause");
		if (choice == "MAIN MENU") { with (game) show_end(); sel_btn = 0; }
		if (choice == "QUIT GAME") game_end();
		break;

	case "over":
		if (game.gg_timer < 1.2) break; // a sec to see who won before the buttons work
		choice = navigate();
		if (choice == "PLAY AGAIN") with (game) show_start();
		if (choice == "MAIN MENU") { with (game) show_end(); sel_btn = 0; }
		if (choice == "QUIT GAME") game_end();
		break;
}

// a press used by a menu shouldnt also make u jump or dash when the game comes back
if (in_menu) {
	global.input.jump = false;
	global.input.dash = false;
	global.input.confirm = false;
	global.input.click = false;
}
