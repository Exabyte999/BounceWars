/// @description block of spike heads sliding on a rail. x/y = top left corner on the floor
// width, height, rail_left, rail_right, slide_phase, slide_speed come from the builder
x = lerp(rail_left, rail_right - width, 0.5 + 0.5 * sin(slide_phase));
depth = -(y + height);
