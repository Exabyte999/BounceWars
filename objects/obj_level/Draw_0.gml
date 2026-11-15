/// @description draw the floor, only the rows on screen
if (rows == 0) exit;
var cam_y = obj_camera.cam_y, first = max(0, floor((cam_y - VIEW_H / 2 - 60) / (TILE * SQUASH)));
var last = min(rows - 1, ceil((cam_y + VIEW_H / 2 + 120) / (TILE * SQUASH)));
for (var r = first; r <= last; r++) {
	for (var c = 0; c < cols; c++) {
		draw_floor_tile(c, r);
		if (tiles[r][c] == Tile.checkpoint) draw_checkpoint_stripe(c, r);
	}
}
