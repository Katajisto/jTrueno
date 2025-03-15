/*

SDL GPU API backend for GetRect_LeftHanded.

*/

GR :: #import "GetRect_LeftHanded"()(Type_Indicator = Ui_Type_Indicator);

Ui_Font :: struct {
    em_width: u32 = 1;
    character_height: u32 = 1;
}

Ui_Type_Indicator :: struct {
    Texture : Type : SDL.Texture;
    Window_Type: Type : u64;
    Font: Type: Ui_Font;
    Font_Effects: Type: u32;
};

Font :: Ui_Font;

defaultFont: Font;

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
prepare_text :: (font: *Ui_Type_Indicator.Font, text: string, effects: Ui_Type_Indicator.Font_Effects = 0) -> s64 {
    print("Prepare text called.\n");
    return 0;
}
draw_prepared_text :: (font: *Ui_Type_Indicator.Font, x: s64, y: s64, text_color: Vector4, effects: Ui_Type_Indicator.Font_Effects = 0) {
    print("Draw text called.\n");
}
get_mouse_pointer_position :: (window: Ui_Type_Indicator.Window_Type, right_handed: bool) -> (x: int, y: int, success: bool) {
    mp := get_mouse_position();
    return xx mp.x, xx mp.y, true;
}
get_font_at_size :: (memory: [] u8, pixel_height: int) -> *Font {
    print("Get font at size called.\n");
    return *defaultFont;
}

// TODO: handle UVs and normal?
// altough I really don't understand the normal part
immediate_triangle :: (p0: Vector3, p1: Vector3, p2: Vector3, c0 := Vector4.{1,1,1,1}, c1 := Vector4.{1,1,1,1}, c2 := Vector4.{1,1,1,1}, uv0 := Vector2.{}, uv1 := Vector2.{}, uv2 := Vector2.{}, normal := Vector3.{z=1}) {
    print("ImTriangle called.\n");
    tri: Arb_Tri;
    tri.pos[0] = p0;
    tri.pos[1] = p1;
    tri.pos[2] = p2;

    tri.col[0] = c0;
    tri.col[1] = c1;
    tri.col[2] = c2;
    arb_tri_add(tri);
}
immediate_quad :: (p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, color := Vector4.{1,1,1,1}, uv0 := Vector2.{0,0}, uv1 := Vector2.{1,0}, uv2 := Vector2.{1,1}, uv3 := Vector2.{0, 1}) {
    to_3d_vec :: (v: Vector2) -> Vector3 {
        return .{v.x, v.y, 0.0};
    }

    print("ImQuad called.\n");
    immediate_triangle(to_3d_vec(p0), to_3d_vec(p1), to_3d_vec(p2), color, color, color, uv0, uv1, uv2);
    immediate_triangle(to_3d_vec(p0), to_3d_vec(p2), to_3d_vec(p3), color, color, color, uv3, uv1, uv2);
}
immediate_flush :: () {
    print("ImFlush called.\n");
    arb_tri_flush();
}

init_ui :: () {
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
}

tick_ui :: () {
    GR.ui_per_frame_update(1, 700, 700, 0);
}

render_ui :: () {
    print("----------------- STARTING NEW UI RENDER ---------------\n");
    r := GR.get_rect(50, 50, 200, 100);
    pressed := GR.button(r, "Hello sailor!", null);
}

