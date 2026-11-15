/// @description a bot (one of the goonies). its brain lives in scr_bots
event_inherited();
skill = random_range(1.05, 1.25); // how fast + smart it is. was 0.85-1.08 but the goonies were way too easy in playtests, now theyre all faster than u (best by 25%) lol
move_speed = 150 * skill;
brain_cd = 0;
hop_cd = 0;
lane = 5; // race: which column its running up
derp = random(2 * pi);
target_x = x; // arenas: where its tryna go
target_y = y;
