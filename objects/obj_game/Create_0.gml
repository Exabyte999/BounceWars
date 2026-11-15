/// @description runs the show: settings, saves, music, round rules
randomize();
gpu_set_texfilter(false);

// settings + saves (same keys as the old version so old saves still work)
ini_open(SAVE_FILE);
global.music_volume = ini_read_real("settings", "music", 4);
global.sfx_volume = ini_read_real("settings", "sfx", 6);
var fullscreen = ini_read_real("settings", "fullscreen", 0);
global.wins = ini_read_real("save", "crowns", 0);
global.shows = ini_read_real("save", "shows", 0);
global.skin = ini_read_real("save", "col", 6);
ini_close();
if (fullscreen) window_set_fullscreen(true);

// stuff every object uses
global.time = 0; // seconds since the game started (for animations)
global.dt = 0; // seconds since last step
global.ui_scale = 1; // screen pixels per game pixel, obj_camera sets it
global.input = input_read();
global.font_pixel = font_add_sprite_ext(spr_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:?!()+-/'#", false, 0);
// colour of each skin: spr_hero gets tinted with it (+ hud text and sparks)
global.skin_colours = [ #72a11d, #f2bc7e, #f89cc0, #6cd9f1, #1da166, #9df27e, #f8e69c, #9f6cf1, #1d3da1, #7ef2ea,
	#9cf89d, #f16ca4, #9b1da1, #8e7ef2, #9ce5f8, #f1d46c, #a1321d, #f27ecb, #c29cf8, #6ff16c];
global.bot_names = ["BYTE", "PIXELINA", "RAYTRACY", "OVERCLOCKY", "VSYNC", "FPS GOD", "LAGZILLA", "TURBOBEAN",
	"SILICONNIE", "GIGAHERTZ", "COOLPASTE", "THROTTLE", "FRAMEDROP", "BENCHMARK", "DRIVER DAVE", "BITSY",
	"TERAFLOP", "VOLTRON JR", "SHADERELLA", "MEGAPIXEL", "KERNEL SANDERS", "HOTSPOT", "LOWPOLY", "ANTI ALIAS",
	"BLUE SCREEN BOB", "PING 999", "WOBBLES", "JELLYBYTE"];
effects_init();

// the show
state = "title"; // title, settings, pause, play, over
show_on = false; // is a show going (even if were in a menu)
round_num = 0;
round_kind = ""; // race, melt, spin, blitz, final
round_name = "";
round_desc = "";
round_goal = "";
phase = "intro"; // intro (rules card), count (3 2 1), go, end
phase_clock = 0;
timer = 0; // round clock
target = 0; // how many go through
finished = 0; // race finishers so far
hurry_up = 0; // counts up once ur thru or out so u dont wait around
last_mid_round = "";
shake = 0;
banner_text = "";
banner_time = 0;
banner_colour = C_YELLOW;
winner = noone;
im_out = false;
died_round = 0;
died_place = 0;
gg_timer = 0;

// round event timers (round_events)
next_ball = 0;
next_wave = 0;
melt_rate = 1;
next_crumble = 0;
ring_size = 8;
big_saw_in = false; // has the big saw joined yet (saw round)
roll_top = 0;
roll_bottom = 0;

// music (buzzy bits by dylann taylor, cc0)
music_on = true;
music_track = noone;
bgm = noone;
