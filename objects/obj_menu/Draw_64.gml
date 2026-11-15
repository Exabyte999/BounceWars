/// @description draw the title, settings, pause or game over screen
var game = obj_game;
switch (game.state) {
	case "title":
		draw_text_pixel(VIEW_W / 2, 40, "BOUNCE WARS", C_YELLOW, 4.5, fa_center);
		draw_text_pixel(VIEW_W / 2, 76, "20 PLAYERS. 3 ROUNDS. 1 VERY SMUG WINNER.", C_WHITE, 1.5, fa_center);

		// ur character, big, with arrows to change skin
		var cx = VIEW_W * 0.3;
		draw_panel(cx - 105, 98, cx + 105, 312, 0.92, (sel_btn == 1) ? C_YELLOW : -1); // lights up when CHARACTER is picked
		draw_text_pixel(cx, 118, "YOUR CHARACTER", C_GREY, 1, fa_center);
		draw_sprite_ext(spr_shadow, 0, cx, 256, 4.2, 1.1, 0, c_white, 0.6);
		draw_sprite_ext(spr_hero, 0, cx, 256, 0.9, 0.9, 0, global.skin_colours[global.skin], 1);
		draw_sprite_ext(spr_btn_previous, 0, cx - 78, 202, 1.5, 1.5, 0, c_white, 1);
		draw_sprite_ext(spr_btn_next, 0, cx + 78, 202, 1.5, 1.5, 0, c_white, 1);
		draw_text_pixel(cx, 278, "SKIN " + string(global.skin + 1) + " / 20", global.skin_colours[global.skin], 1.5, fa_center);
		draw_text_pixel(cx, 296, "A / D TO CHANGE", C_GREY, 1, fa_center);

		draw_items();
		draw_text_pixel(VIEW_W / 2, VIEW_H - 16, "W / S: CHOOSE      SPACE / ENTER: SELECT", C_GREY, 1, fa_center, 0.85);
		if (global.shows > 0) draw_text_pixel(VIEW_W - 10, 10, "CROWNS " + string(global.wins) + "   SHOWS " + string(global.shows), C_BLUE, 1, fa_right);
		break;

	case "settings":
		if (game.show_on) draw_dim(0.55);
		draw_panel(VIEW_W / 2 - 175, 36, VIEW_W / 2 + 175, 302, 0.96);
		draw_text_pixel(VIEW_W / 2, 66, "SETTINGS", C_YELLOW, 3, fa_center);
		draw_items();
		draw_text_pixel(VIEW_W / 2, 284, "LEFT / RIGHT TO CHANGE      ESC: BACK", C_GREY, 1, fa_center);
		break;

	case "pause":
		draw_dim(0.55);
		draw_panel(VIEW_W / 2 - 150, 28, VIEW_W / 2 + 150, 324, 0.95);
		draw_text_pixel(VIEW_W / 2, 56, "PAUSED", C_YELLOW, 3, fa_center);
		draw_items();
		break;

	case "over":
		var p = obj_player.id, champ = (game.winner != noone) ? game.winner : p;
		draw_dim(clamp(game.gg_timer * 0.8, 0, 0.72));
		if (champ == p) {
			draw_sprite_ext(spr_shadow, 0, VIEW_W / 2, 66, 4.5, 1.1, 0, c_white, 0.6);
			draw_sprite_ext(spr_trophy, 0, VIEW_W / 2, 66, 1.2, 1.2, 0, c_white, 1);
			draw_text_fit(VIEW_W / 2, 94, "YOU WIN!", C_YELLOW, 4.5, fa_center, VIEW_W - 60);
			draw_text_fit(VIEW_W / 2, 128, "YOU BEAT ALL 19 OTHER PLAYERS!", global.skin_colours[p.skin], 1.5, fa_center, VIEW_W - 60);
		} else {
			draw_text_fit(VIEW_W / 2, 34, champ.name + " WINS!", global.skin_colours[champ.skin], 3, fa_center, VIEW_W - 60);
			draw_sprite_ext(spr_shadow, 0, VIEW_W / 2, 122, 3, 0.8, 0, c_white, 0.6);
			draw_sprite_ext(spr_hero, 0, VIEW_W / 2, 122, 0.6, 0.6, 0, global.skin_colours[champ.skin], 1);
			var result = game.im_out ? "YOU WERE OUT IN ROUND " + string(game.died_round) + "  (PLACE " + string(game.died_place) + " OF 20)" : "SO CLOSE!";
			draw_text_fit(VIEW_W / 2, 140, result, C_WHITE, 1.5, fa_center, VIEW_W - 60);
		}
		// ur stats
		draw_panel(VIEW_W / 2 - 140, 154, VIEW_W / 2 + 140, 207, 0.9);
		draw_text_pixel(VIEW_W / 2 - 125, 170, "YOUR WINS", C_GREY);
		draw_text_pixel(VIEW_W / 2 + 125, 170, string(global.wins), C_YELLOW, 1.5, fa_right);
		draw_text_pixel(VIEW_W / 2 - 125, 191, "SHOWS PLAYED", C_GREY);
		draw_text_pixel(VIEW_W / 2 + 125, 191, string(global.shows), C_WHITE, 1.5, fa_right);
		if (game.gg_timer > 1.2) draw_items();
		break;
}
