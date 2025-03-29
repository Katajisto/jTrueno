Sheet_Location :: struct {
    x, y, w, h: u32;
}

Spritesheet :: struct {
    texture: *SDL.Texture;
    w: u32;
    h: u32;
    sprite_w: u32;
    sprite_h: u32;
    sprite_count: u32;
}

Fontsheet :: struct {
    spritesheet: Spritesheet;    
    charTable: HT.Table(u8, Sheet_Location);
}

load_default_fontsheet :: () {
    success := load_png_texture_from_file(*GpuContext, "monofont", "monofont.png");
    t, s := get_texture("monofont");
    sheet: Spritesheet;
    sheet.texture = t;
}
