Editor_State :: struct {
    trileEditor: Trile_Edit_State;
}

Trile_Edit_State :: struct {
    rotation: float = 0.0;
    tilt: float = 0.0;
    zoom: float = 3.0;
};

TRILE_ROTATION_SPEED :: 0.03;

trile_editor_tick :: (state: *Editor_State) {
    if is_key_down(SDL.Keycode.D) {
        state.trileEditor.rotation += TRILE_ROTATION_SPEED;
    }
    if is_key_down(SDL.Keycode.A) {
        state.trileEditor.rotation -= TRILE_ROTATION_SPEED;
    }
    if is_key_down(SDL.Keycode.W) {
        state.trileEditor.tilt += TRILE_ROTATION_SPEED;
    }
    if is_key_down(SDL.Keycode.S) {
        state.trileEditor.tilt -= TRILE_ROTATION_SPEED;
    }
    state.trileEditor.tilt = clamp(state.trileEditor.tilt, -(PI/2.0) + 0.01, PI/2.0 - 0.01);
    state.trileEditor.zoom = clamp(state.trileEditor.zoom + get_scroll_delta() * -0.2, 0.3, 3.0);
    
}

get_trile_editor_camera :: (state: *Editor_State) -> Camera {
    camera: Camera;
    camera.near = 0.1;
    camera.far = 100;

    rot  := state.trileEditor.rotation;
    tilt := state.trileEditor.tilt;

    cameraDir : Vector3    = .{1, 0, 0};
    qrotation : Quaternion = .{cos(rot/2.0),0,sin(rot/2.0),0};
    qtilt     : Quaternion = .{cos(tilt/2.0),sin(tilt/2.0), 0, 0};

    rotate(*cameraDir, qrotation * qtilt);
    camera.position = .{0.5, 0.5, 0.5};

    camera.position += cameraDir * state.trileEditor.zoom;
    camera.target = .{0.5, 0.5, 0.5};
    
    return camera;
}
