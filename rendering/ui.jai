/*

SDL GPU API backend for GetRect_LeftHanded.

*/

GR :: #import "GetRect_LeftHanded"()(Type_Indicator = Ui_Type_Indicator);

Ui_Font :: struct {
    em_width: u32 = 1;
    character_height: u32 = 30;
}

Ui_Texture :: struct {
    name: string;
}

Ui_Rect :: struct {
    x, y, w, h: s32;  
};

Ui_Type_Indicator :: struct {
    Texture : Type : Ui_Texture;
    Window_Type: Type : u64;
    Font: Type: Ui_Font;
    Font_Effects: Type: u32;
};

Font :: Ui_Font;

defaultFont: Font;

ui_texture_counter : u32 = 0;

texture_load_from_memory :: (texture: *Ui_Texture, memory: []u8, srgb: bool, build_mipmaps: bool) -> bool {
    texname := tprint("ui_tex_%", ui_texture_counter);
    load_png_texture_from_memory(*GpuContext, copy_string(texname), memory);
    ui_texture_counter += 1;
    texture.name = copy_string(texname);
    return true;
}

gScissor : Ui_Rect;
gScissorActive : bool = false;

set_scissor :: (x0: s32, y0: s32, x1: s32, y1: s32)  {
    w,h := get_render_size();
    gScissor = .{x0, y0, x1 - x0, y1 - y0};
    gScissorActive = true;
}
clear_scissor :: () {
    gScissorActive = false;
}

gCurrentTexture : *Ui_Texture = null;

set_shader_for_color :: (enable_blend := false) {
    if ENABLE_UI_DEBUG_LOGGING { print("Setting shader for color.."); }
    immediate_flush(); // We want to do the flush so we can set the sampler for the entire set.
    gCurrentTexture = null;
}


set_shader_for_images :: (texture: *Ui_Texture) {
    if ENABLE_UI_DEBUG_LOGGING { print("Setting shader for textures.."); }
    immediate_flush(); // We want to do the flush so we can set the sampler for the entire set.
    gCurrentTexture = texture;
}

gPreppedText: string;
gPreppedTextWidth : s32;

prepare_text :: (font: *Ui_Type_Indicator.Font, text: string, effects: Ui_Type_Indicator.Font_Effects = 0) -> s64 {
    w : s32 = 0;
    for 0..text.count-1 {
        w += get_font_letter_width(text.data[it], cast(s32) font.character_height);
    }
    gPreppedText = text;
    gPreppedTextWidth = w;
    return w;
}
draw_prepared_text :: (font: *Ui_Type_Indicator.Font, x: s64, y: s64, text_color: Vector4, effects: Ui_Type_Indicator.Font_Effects = 0) {
    w : s32 = cast(s32) x;
    for 0..gPreppedText.count-1 {
        add_font_letter(gPreppedText.data[it], cast(s32) font.character_height, w, cast(s32) y - (cast(s32)font.character_height / 2), text_color);
        w += get_font_letter_width(gPreppedText.data[it], cast(s32) font.character_height);
    }
    flush_sprite_batch();
}
get_mouse_pointer_position :: (window: Ui_Type_Indicator.Window_Type, right_handed: bool) -> (x: int, y: int, success: bool) {
    mp := get_mouse_position();
    return xx mp.x, xx mp.y, true;
}
get_font_at_size :: (memory: [] u8, pixel_height: int) -> *Font {
    f : *Font = New(Font);
    f.character_height = cast(u32) pixel_height;
    f.em_width = cast(u32) get_font_letter_width(109, cast (s32) pixel_height);
    return f;
}

// TODO: Figure out what to do with the normal?
immediate_triangle :: (p0: Vector3, p1: Vector3, p2: Vector3, c0 := Vector4.{1,1,1,1}, c1 := Vector4.{1,1,1,1}, c2 := Vector4.{1,1,1,1}, uv0 := Vector2.{}, uv1 := Vector2.{}, uv2 := Vector2.{}, normal := Vector3.{z=1}) {
    tri: Arb_Tri;
    tri.pos[0] = p0;
    tri.pos[1] = p1;
    tri.pos[2] = p2;

    tri.col[0] = c0;
    tri.col[1] = c1;
    tri.col[2] = c2;
    
    // This UV symbolizes that the sampler should not be used.
    nullUV : Vector2 = .{-4, -2};

    if gCurrentTexture == null {
        tri.uv[0] = nullUV;
        tri.uv[1] = nullUV;
        tri.uv[2] = nullUV;
    } else {
        tri.uv[0] = uv0;
        tri.uv[1] = uv1;
        tri.uv[2] = uv2;
    }

    arb_tri_add(tri);
}

immediate_quad :: (p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, color := Vector4.{1,1,1,1}, uv0 := Vector2.{0,0}, uv1 := Vector2.{1,0}, uv2 := Vector2.{1,1}, uv3 := Vector2.{0, 1}) {
    to_3d_vec :: (v: Vector2) -> Vector3 {
        return .{v.x, v.y, 0.0};
    }
    immediate_triangle(to_3d_vec(p0), to_3d_vec(p1), to_3d_vec(p2), color, color, color, uv0, uv1, uv2);
    immediate_triangle(to_3d_vec(p0), to_3d_vec(p2), to_3d_vec(p3), color, color, color, uv0, uv2, uv3);
}

immediate_flush :: () {
    arb_tri_flush();
}

init_ui :: () {
    dp : GR.Draw_Procs = .{
        texture_load_from_memory = texture_load_from_memory, // implemented
        set_scissor = set_scissor, // implemented
        clear_scissor = clear_scissor, // implemented
        set_shader_for_color = set_shader_for_color,
        set_shader_for_images = set_shader_for_images,
        prepare_text = prepare_text, // implemented
        draw_prepared_text = draw_prepared_text, // implemented, missing color, effects
        get_mouse_pointer_position = get_mouse_pointer_position, // implemented
        get_font_at_size = get_font_at_size, // implemented
        immediate_triangle = immediate_triangle, // implemented
        immediate_quad = immediate_quad, // implemented
        immediate_flush = immediate_flush // implemented
    };

    GR.ui_init("", *dp);
}

tick_ui :: () {
    GR.ui_per_frame_update(1, 700, 700, 0);
}

checkboxTest : bool = false;

render_ui :: () {
    proc := GR.default_theme_procs[0];
    my_theme := proc();
    GR.set_default_theme(my_theme);  // Just in case we don't explicitly pass themes sometimes...!

    r := GR.get_rect(0, 0, 400, 30);
    pressed := GR.button(r, "Hello sailor!", null);

    r2 := GR.get_rect(0, 100, 400, 20);
    checkbox_theme := my_theme.checkbox_theme;
    list : []u8;
    checkbox_theme.font = get_font_at_size(list, 20); // @Cleanup: We have to manually set a font for now.
    pressed = GR.base_checkbox(r2, "GGGG", checkboxTest, *checkbox_theme, 0);
}

