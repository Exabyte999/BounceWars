/// @description heating tiles count down and drop (only during the round so the floor stops breaking when it ends)
if (rows == 0 || heating == 0 || !world_running() || obj_game.phase != "go") exit; // nothing heating = skip the whole grid
var left = 0;
for (var r = 0; r < rows; r++) {
	for (var c = 0; c < cols; c++) {
		if (heat[r][c] < 0) continue;
		heat[r][c] -= global.dt;
		if (heat[r][c] < 0) {
			tiles[r][c] = Tile.hole;
			heat[r][c] = -1;
			var wx = (c + 0.5) * TILE, wy = (r + 0.5) * TILE;
			if (on_screen(wx, wy)) fx_sparks(wx, wy, 0, C_HEAT, 6);
		} else left++;
	}
}
heating = left; // recounted every time so it cant drift
