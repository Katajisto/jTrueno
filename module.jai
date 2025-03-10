#import "Basic";
#import "Process";

SDL :: #import,dir "./modules/SDL3";

#load "rendering/base.jai";
#load "editor/base.jai";
#load "yaris/base.jai";
#load "input/base.jai";
#load "trile/base.jai";

Types_Indicator :: struct {
    Texture : Type : SDL.Texture;
    Window_Type: Type : u64;
    Font: Type: u64;
    Font_Effects: Type: u32;
};

GR :: #import "GetRect_LeftHanded"()(Type_Indicator = Types_Indicator);

compile_shaders :: () {
    print(" -- Compiling shaders! --\n");
    res := run_command("bash", "./compile.sh", working_directory=tprint("%shaders", #filepath));
    if res.exit_code != 0 {
        print(" --- Shader compilation failed, aborting build! --- \n\n");
        exit(1);
    }
    print(" -- Shaders OK! -- \n");
}

#run {
    compile_shaders();
}

Font :: Types_Indicator.Font;

defaultFont: u64;

texture_load_from_memory :: (texture: *SDL.Texture, memory: []u8, srgb: bool, build_mipmaps: bool) -> bool {
    print("Texture load from memory called.\n");
    return true;
}
set_scissor :: (x0: s32, y0: s32, x1: s32, y: s32)  {
    print("Set scissor called.\n");
}
clear_scissor :: () {
    print("Clear scissor called.\n");
}
set_shader_for_color :: (enable_blend := false) {
    print("Set shader for color called.\n");
}
set_shader_for_images :: (texture: *SDL.Texture) {
    print("Set shader for texture called.\n");
}
prepare_text :: (font: *Types_Indicator.Font, text: string, effects: Types_Indicator.Font_Effects = 0) -> s64 {
    print("Prepare text called.\n");
    return 0;
}
draw_prepared_text :: (font: *Types_Indicator.Font, x: s64, y: s64, text_color: Vector4, effects: Types_Indicator.Font_Effects = 0) {
    print("Draw text called.\n");
}
get_mouse_pointer_position :: (window: Types_Indicator.Window_Type, right_handed: bool) -> (x: int, y: int, success: bool) {
    return 0, 0, true;
}
get_font_at_size :: (memory: [] u8, pixel_height: int) -> *Font {
    print("Get font at size called.\n");
    return *defaultFont;
}
immediate_triangle :: (p0: Vector3, p1: Vector3, p2: Vector3, c0 := Vector4.{1,1,1,1}, c1 := Vector4.{1,1,1,1}, c2 := Vector4.{1,1,1,1}, uv0 := Vector2.{}, uv1 := Vector2.{}, uv2 := Vector2.{}, normal := Vector3.{z=1}) {
    print("ImTriangle called.\n");
}
immediate_quad :: (p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, color := Vector4.{1,1,1,1}, uv0 := Vector2.{0,0}, uv1 := Vector2.{1,0}, uv2 := Vector2.{1,1}, uv3 := Vector2.{0, 1}) {
    print("ImQuat called.\n");
}
immediate_flush :: () {
    print("ImFlush called.\n");
}


main :: () {
    defaultFont = 42;
    supra_c, ok := init(700, 700, "jTrueno!");
    editorState : Editor_State;

    dp : GR.Draw_Procs = .{
        texture_load_from_memory = texture_load_from_memory,
        set_scissor = set_scissor,
        clear_scissor = clear_scissor,
        set_shader_for_color = set_shader_for_color,
        set_shader_for_images = set_shader_for_images,
        prepare_text = prepare_text,
        draw_prepared_text = draw_prepared_text,
        get_mouse_pointer_position = get_mouse_pointer_position,
        get_font_at_size = get_font_at_size,
        immediate_triangle = immediate_triangle,
        immediate_quad = immediate_quad,
        immediate_flush = immediate_flush
    };

    GR.ui_init("", *dp);

    quit := false;
   
    while !quit {
        quit = input_begin_frame();
        trile_editor_tick(*editorState);

        draw(*supra_c, *editorState);
        reset_temporary_storage();
    }
}
