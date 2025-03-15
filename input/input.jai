#import "Basic";

Input_State :: struct {
    keys_currently_down: [..]SDL.Keycode;
    keys_just_down: [..]SDL.Keycode;
    scroll_delta: float;
    mouse_position: Vector2;
}

get_mouse_position :: () -> Vector2 {
    return gInputState.mouse_position;
}

get_scroll_delta :: () -> float {
    return gInputState.scroll_delta;
}

// Reports if a key is down.
is_key_down :: (kc: SDL.Keycode) -> bool {
    found, index := array_find(gInputState.keys_currently_down, kc);
    return found;
}

// It's probably ok for this to just be global for now...
gInputState: Input_State;

is_key_just_down :: (keycode: SDL.Keycode) -> bool {
    found, index := array_find(gInputState.keys_just_down, keycode);
    return found;
}

handle_key_down :: (keycode: SDL.Keycode) {
    array_add_if_unique(*gInputState.keys_currently_down, keycode);
    array_add_if_unique(*gInputState.keys_just_down, keycode);
}

handle_key_up :: (keycode: SDL.Keycode) {
    array_unordered_remove_by_value(*gInputState.keys_currently_down, keycode);
    array_unordered_remove_by_value(*gInputState.keys_just_down, keycode);
}

// Returns true if there was a quit event.
input_begin_frame :: () -> bool {
    gInputState.scroll_delta = 0.0;
    array_reset_keeping_memory(*gInputState.keys_just_down);
    evt: SDL.Event;
    while(SDL.poll_event(*evt)) {
        if evt.type == SDL.Event_Type.QUIT {
            return true;
        }
        if evt.type == SDL.Event_Type.KEY_DOWN {
            handle_key_down(evt.key.key);   
        }
        if evt.type == SDL.Event_Type.KEY_UP {
            handle_key_up(evt.key.key);   
        }
        if evt.type == SDL.Event_Type.MOUSE_WHEEL {
            gInputState.scroll_delta = evt.wheel.y;
        }
        if evt.type == SDL.Event_Type.MOUSE_MOTION {
            gInputState.mouse_position.x = evt.motion.x;
            gInputState.mouse_position.y = evt.motion.y;
        }
    }
    return false;
}
