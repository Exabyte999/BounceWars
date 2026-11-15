/// @description after everyone moved: bumps, then is the round over
if (state != "play" || phase != "go") exit;
contestant_bumps();
round_check_end();
