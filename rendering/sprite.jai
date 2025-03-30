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

dFontsheet : Fontsheet;

load_default_fontsheet :: () {

    fontAtlasInfo : *Font_Atlas_File;

    {
        push_allocator(temp);
        jsonSuccess, info := Jaison.json_parse_file("monofont.json", Font_Atlas_File);
        fontAtlasInfo = *info;
        if !jsonSuccess {
            print("Failed to load json for default font atlas!\n");
            return;
        }
    }
    dFontsheet.spritesheet.w = fontAtlasInfo.atlas.width;
    dFontsheet.spritesheet.h = fontAtlasInfo.atlas.height;

    for 0..fontAtlasInfo.sprites.count-1 {
        sprite := *fontAtlasInfo.sprites[it];
        loc : Sheet_Location = .{
            x = xx sprite.position.x,
            y = xx sprite.position.y,
            w = xx sprite.sourceSize.width,
            h = xx sprite.sourceSize.height,
        };

        HT.table_set(*dFontsheet.charTable, cast,force(u8) sprite.char.value, loc);
    }
        
    success := load_png_texture_from_file(*GpuContext, "monofont", "monofont.png");
    t, s := get_texture("monofont");
    dFontsheet.spritesheet.texture = t;
}

Font_Atlas_Info :: struct {
    imagePath: string;
    width: u32;
    height: u32;
    spriteCount: u32;
    isFont: bool;
    fontSize: u32;
};

Font_Atlas_Position :: struct {
    x: s32;
    y: s32;  
};

Font_Atlas_Rect :: struct {
    x: s32;
    y: s32;
    width: u32;
    height: u32;
};

Font_Atlas_Size :: struct {
    width: u32;
    height: u32;
}

Font_Atlas_Char :: struct {
    value: s32;
    offset: Font_Atlas_Position;
    advanceX: s32;
}

Font_Sprite_Info :: struct {
    nameId: string;
    origin: Font_Atlas_Position;
    position: Font_Atlas_Position;
    sourceSize: Font_Atlas_Size;
    padding: u32;
    trimmed: bool;
    trimRec: Font_Atlas_Rect; 
    char: Font_Atlas_Char;
};

Font_Atlas_File :: struct {
    atlas : Font_Atlas_Info;
    sprites : [..]Font_Sprite_Info;
};

Sprite_Batch :: struct {
    instances: [..]Sprite_Instance_Data;
    texture: *SDL.GPU_Texture;
}

gSpriteBatch : Sprite_Batch;

begin_sprite_batch :: () {
    gSpriteBatch.instances.allocator = temp;
    gSpriteBatch.instances.count = 0;
}

add_font_letter :: (char: u8, font_size: s32, x: s32, y: s32, color: Vector4) {
    if gSpriteBatch.texture != dFontsheet.spritesheet.texture {
        if gSpriteBatch.instances.count > 0 {
            flush_sprite_batch();
        }
        gSpriteBatch.texture = dFontsheet.spritesheet.texture;
    }

    charPos, found := HT.table_find(*dFontsheet.charTable, char);   
    if !found {
        print("No such char % in default font sheet.\n", char);
        return;
    }
    
    rw, rh := get_render_size();
    px := (cast(float)x / cast(float)rw) * 2 - 1;
    py := ((cast(float)y / cast(float)rh) * 2 - 1) * -1;
    charAspect := cast(float)charPos.w / cast(float)charPos.h;
    ph := (cast(float)font_size / rh);
    pw := ((charAspect * cast(float)font_size)/rw); 
    
    u1 : float = cast(float)charPos.x / cast(float)dFontsheet.spritesheet.w;
    v1 : float = cast(float)charPos.y / cast(float)dFontsheet.spritesheet.h;
    u2 : float = cast(float)(charPos.x + charPos.w) / cast(float)dFontsheet.spritesheet.w;
    v2 : float = cast(float)(charPos.y + charPos.h) / cast(float)dFontsheet.spritesheet.h;    
   
    array_add(*gSpriteBatch.instances, Sprite_Instance_Data.{
        position = .{px + pw / 2.0, py - ph / 2.0, pw, ph},
        uv = .{u1, v1, u2, v2},
        color = color
    });
}

get_font_letter_width :: (char: u8, font_size: s32) -> s32 {
    charPos, found := HT.table_find(*dFontsheet.charTable, char);   
    if !found {
        print("No such char % in default font sheet.\n", char);
        return 0;
    }
    charAspect := cast(float)charPos.w / cast(float)charPos.h;
    pw := charAspect * cast(float)font_size; 
    return cast,force(s32) pw;
    
}

flush_sprite_batch :: () {
    if gSpriteBatch.instances.count == 0 return;
    if gSpriteBatch.texture == null {
        print("The texture for the sprite batch flush is null.\n");
        return;
    }

    dataptr : *Sprite_Instance_Data = SDL.map_gpu_transfer_buffer(
        GpuContext.device,
        GpuContext.spriteInstanceTransferBuffer,
        true
    );

    for 0..gSpriteBatch.instances.count -1 {
        dataptr[it] = gSpriteBatch.instances[it];
    }
    
    SDL.unmap_gpu_transfer_buffer(GpuContext.device, GpuContext.spriteInstanceTransferBuffer);

    copyPass := SDL.begin_gpu_copy_pass(GpuContext.drawState.cmdbuf);

    transferBufferLocation := SDL.GPU_Transfer_Buffer_Location.{
        transfer_buffer = GpuContext.spriteInstanceTransferBuffer,
        offset = 0
    };

    bufferRegion := SDL.GPU_Buffer_Region.{
        buffer = GpuContext.spriteInstanceStorageBuffer,
        offset = 0,
        size = size_of(Sprite_Instance_Data) * cast(u32) gSpriteBatch.instances.count
    };
    
    SDL.upload_to_gpu_buffer(
        copyPass,  
        *transferBufferLocation,
        *bufferRegion,
        true
    );

    SDL.end_gpu_copy_pass(copyPass);

    colorTargetInfo: SDL.GPU_Color_Target_Info;
    colorTargetInfo.texture = GpuContext.drawState.swapchainTexture;
    colorTargetInfo.clear_color = SDL.F_Color.{ 0, 0, 0, 0 };
    colorTargetInfo.load_op = SDL.GPU_Load_Op.LOAD;
    colorTargetInfo.store_op = SDL.GPU_Store_Op.STORE;

    renderPass := SDL.begin_gpu_render_pass(GpuContext.drawState.cmdbuf, *colorTargetInfo, 1, null);

    if gScissorActive {
        scissorRect : SDL.Rect = .{gScissor.x, gScissor.y, gScissor.w, gScissor.h};
        SDL.set_gpu_scissor(renderPass, *scissorRect);
    }
    
    SDL.bind_gpu_vertex_storage_buffers(renderPass, 0, *GpuContext.spriteInstanceStorageBuffer, 1);
    
    quadMesh, success := get_mesh("base_quad");
    if !success {
        print("Failed to get base quad mesh!\n");
        return;
    }

    binding : SDL.GPU_Buffer_Binding = .{ buffer = quadMesh.vertexBuffer, offset = 0};
    SDL.bind_gpu_vertex_buffers(renderPass, 0, *binding, 1);
    
    index_binding : SDL.GPU_Buffer_Binding = .{ buffer = quadMesh.indexBuffer, offset = 0};
    SDL.bind_gpu_index_buffer(renderPass,*index_binding, SDL.GPU_Index_Element_Size.SIZE_16BIT);
    
    samplerBinding : SDL.GPU_Texture_Sampler_Binding = .{
        texture = gSpriteBatch.texture,
        sampler = gSamplers.pointClamp
    };
    SDL.bind_gpu_graphics_pipeline(renderPass, GpuContext.spritePipeline);
    SDL.bind_gpu_fragment_samplers(renderPass, 0, *samplerBinding, 1);
    
    SDL.draw_gpu_indexed_primitives(renderPass, 6, cast(u32) gSpriteBatch.instances.count, 0, 0, 0);
    SDL.end_gpu_render_pass(renderPass);

    gSpriteBatch.instances.count = 0;
    gSpriteBatch.texture = null;
}

render_sprite :: (ctx: *Rendering_Context, camera: *Camera) {
    if gSpriteBatch.instances.count > 0 {
        flush_sprite_batch();
    }
}
