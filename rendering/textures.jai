HT :: #import "Hash_Table";

Texture_Atlas :: struct {
    surfaces: HT.Table(string, *SDL.Surface);
    textures: HT.Table(string, *SDL.Texture);
}

gTextureAtlas : Texture_Atlas;

Sampler_Palette :: struct {
    pointClamp: *SDL.GPU_Sampler;
}

SAMPLERS : Sampler_Palette;

load_png_texture_from_memory :: (ctx: *Rendering_Context, name: string, memory: []u8) -> bool {
    stream := SDL.io_from_const_mem(memory.data, xx memory.count);
    surface := SDL_IMG.load_png_io(stream);
    if !surface {
        print("Surface was not loaded due to error: %\n", u8_to_string(SDL.get_error())); 
        return false;
    }

    HT.table_set(*gTextureAtlas.surfaces, name, surface);
    
    textureCreateInfo : SDL.GPU_Texture_Create_Info.{
        type = SDL.GPU_Texture_Type.2D,
        format = SDL.GPU_Texture_Format.R8B8G8A8_UNORM,
        width = surface.w,
        height = surface.h,
        layer_count_or_depth = 1,
        num_levels = 1,
        usage = SDL.GPU_Texture_Usage.SAMPLER
    };
    
    tex := SDL.create_gpu_texture(ctx.device, textureCreateInfo);

    if !tex {
        print("Texture was not loaded...\n");
        return;
    }
    
    HT.table_set(*gTextureAtlas.textures, name, tex);

    
        
    return true;
}

create_samplers :: (ctx: *Rendering_Context) {
    info := SDL.GPU_Sampler_Create_Info.{
        min_filter = SDL.GPU_Filter.NEAREST,
        mag_filter = SDL.GPU_Filter.NEAREST,
        mipmap_mode = SDL.GPU_Sampler_Mipmap_Mode.NEAREST,
        address_mode_u = SDL.GPU_Sampler_Address_Mode.REPEAT,
        address_mode_v = SDL.GPU_Sampler_Address_Mode.REPEAT,
        address_mode_w = SDL.GPU_Sampler_Address_Mode.REPEAT,
    };
    SAMPLERS.pointClamp = SDL.create_gpu_sampler(ctx.device, *info);
}
