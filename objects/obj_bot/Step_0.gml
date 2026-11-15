/// @description think (presses the same buttons u would), then move (obj_contestant does tht part)
wanna_x = 0;
wanna_y = 0;
holding_jump = true;
if (in_round && !qualified && !falling && boing_time <= 0.6 && obj_game.phase == "go" && contestants_active()) {
	if (obj_game.round_kind == "race") bot_think_race();
	else bot_think_arena();
}
event_inherited();
