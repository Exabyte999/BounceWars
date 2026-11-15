// spark particles. positions are world x/y/z

function effects_init() {
	global.particles = part_system_create();
	part_system_depth(global.particles, -15000);
	part_system_automatic_update(global.particles, false); // obj_game updates it so pausing freezes it

	// little coloured squares
	global.pt_spark = part_type_create();
	part_type_shape(global.pt_spark, pt_shape_square);
	part_type_size(global.pt_spark, 0.03, 0.06, 0, 0);
	part_type_speed(global.pt_spark, 0.5, 3, -0.02, 0);
	part_type_direction(global.pt_spark, 0, 360, 0, 0);
	part_type_gravity(global.pt_spark, 0.12, 270);
	part_type_alpha2(global.pt_spark, 1, 0);
	part_type_life(global.pt_spark, 20, 55);
}

function effects_free() {
	part_type_destroy(global.pt_spark);
	part_system_destroy(global.particles);
}

function fx_sparks(_x, _y, _z, _colour, _amount) {
	part_type_colour1(global.pt_spark, _colour);
	part_particles_create(global.particles, _x, _y * SQUASH - _z, global.pt_spark, ceil(_amount * 0.4));
}
