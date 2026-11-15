/// @description sizes the window + follows the action. view 0 in the room is the camera
cam_x = VIEW_W / 2; // middle of the screen (screen space so y is already squashed)
cam_y = VIEW_H / 2;
snap = true; // jump straight to the target next frame instead of gliding over (new round)
window_w = 0;
window_h = 0;
// gpu stuff, all done once here so nothing makes new textures while ur playing (tht kept crashing the gpu driver: "device lost")
surface_depth_disable(true); // no 3d depth buffers on surfaces, a 2d game doesnt need them
surface_resize(application_surface, VIEW_W * 3, VIEW_H * 3); // the game image is made ONCE at 3x (1920x1080), gamemaker stretches it to the window
view_wport[0] = VIEW_W * 3;
view_hport[0] = VIEW_H * 3;
global.ui_scale = 3;
texture_prefetch("Default"); // load all the art now instead of the first time it shows up mid round
window_fit();
