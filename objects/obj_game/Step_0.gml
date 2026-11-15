/// @description music, then the round phases: intro card > 3 2 1 > go > end
var dt = global.dt;

// menu tune on the title screen, game tune everywhere else
var want = (state == "title" || (state == "settings" && !show_on)) ? snd_music_title : snd_music_game;
if (!music_on) {
	if (bgm != noone) audio_stop_sound(bgm);
	bgm = noone;
	music_track = noone;
} else if (music_track != want && audio_system_is_available()) { // browsers mute the page till the first click / key, so wait for tht or the music never starts
	if (bgm != noone) audio_stop_sound(bgm);
	bgm = audio_play_sound(want, 0, true, global.music_volume * 0.05);
	music_track = want;
}

// the round only runs while playing (or on the game over screen)
if (state == "over") gg_timer += dt;
if (state != "play" && state != "over") exit;

banner_time -= dt;
shake = max(0, shake - dt * 30);
part_system_update(global.particles);

switch (phase) {
	case "intro": // rules card, wait or skip with space / click
		phase_clock -= dt;
		if (phase_clock <= 0 || (phase_clock < 9.4 && (global.input.confirm || global.input.click))) {
			phase = "count";
			phase_clock = 3;
			obj_camera.snap = true; // skipping the race flyover cuts straight to the start
		}
		break;
	case "count": // 3 2 1
		var before = ceil(phase_clock);
		phase_clock -= dt;
		if (ceil(phase_clock) != before && phase_clock > 0) play_sfx(snd_menu_move, 1, 1 + (3 - ceil(phase_clock)) * 0.25);
		if (phase_clock <= 0) {
			phase = "go";
			phase_clock = 1.5; // first 1.5s of the round nobody can get hurt. was 3s but tht felt way too long
			set_banner("GO!", 0.8, C_YELLOW);
			play_sfx(snd_win, 0.6, 1.4);
		}
		round_events(dt);
		break;
	case "go":
		timer -= dt;
		phase_clock -= dt;
		if (obj_player.qualified || obj_player.out) hurry_up += dt; // ur done, hurry it up
		round_events(dt);
		break;
	case "end": // results showing, then next round (or game over)
		phase_clock -= dt;
		round_events(dt);
		if (phase_clock <= 0 && state == "play") {
			if (round_num < 3) round_start(round_num + 1);
			else { state = "over"; gg_timer = 0; }
		}
		break;
}
