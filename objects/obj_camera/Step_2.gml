/// @description follow u (or watch the middle once ur out), then move the view + background
var game = obj_game, running = (game.state == "play" || game.state == "over");

if (game.show_on && running) {
	var target = obj_player.id;
	var watching = !target.in_round && game.round_kind != "race"; // ur out: js watch the middle of the arena
	var L = obj_level, tx = watching ? L.cols * TILE / 2 : target.x;
	var ty = watching ? L.rows * TILE / 2 * SQUASH : target.y * SQUASH - target.z * 0.5 - ((game.round_kind == "race") ? 60 : 0);
	if (game.phase == "intro" && game.round_kind == "race") {
		// fly down the course while the rules are up, ends at the start line
		var f = clamp(1 - game.phase_clock / 4, 0, 1);
		cam_x = L.cols * TILE / 2;
		cam_y = lerp(10 * TILE * SQUASH, target.y * SQUASH - 60, f);
	} else {
		if (game.round_kind != "race" && !watching) { // arenas: stay halfway between u and the middle
			tx = lerp(L.cols * TILE / 2, tx, 0.5);
			ty = lerp(L.rows * TILE / 2 * SQUASH, ty, 0.5);
		}
		if (!target.falling && !watching) { // look a bit ahead of where ur running
			tx += target.walk_x * 0.08;
			ty += target.walk_y * SQUASH * 0.08;
		}
		var follow = (snap || target.boing_time > 0.8) ? 1 : min(1, global.dt * 4); // glide, but snap after a spring or a new round
		snap = false;
		cam_x = lerp(cam_x, tx, follow);
		cam_y = lerp(cam_y, ty, follow);
	}
}

// shake, then move the view (snapped to whole screen pixels)
var shake_x = 0, shake_y = 0;
if (game.shake > 0) {
	shake_x = round(random_range(-game.shake, game.shake) * 0.25);
	shake_y = round(random_range(-game.shake, game.shake) * 0.25);
}
var ui = global.ui_scale, left = round((cam_x - VIEW_W / 2) * ui) / ui - shake_x;
var top = round((cam_y - VIEW_H / 2) * ui) / ui - shake_y;
camera_set_view_pos(view_camera[0], left, top);

// background: a colour per round, scrolls slower than the floor, darker in game
var bg_layer = layer_get_id("Background"), bg = layer_background_get_id(bg_layer);
var round_bgs = [spr_bg_blue, spr_bg_blue, spr_bg_yellow, spr_bg_pink];
layer_background_sprite(bg, game.show_on ? round_bgs[clamp(game.round_num, 0, 3)] : spr_bg_green);
layer_background_blend(bg, game.show_on ? #7d7a86 : c_white);
layer_x(bg_layer, round((left - cam_x * 0.1) * ui) / ui); // whole pixels so it doesnt shimmer like janis
layer_y(bg_layer, round((top - cam_y * 0.1) * ui) / ui);
