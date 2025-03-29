HT :: #import "Hash_Table";

Texture_Atlas :: struct {
    surfaces: HT.Table(string, *SDL.Surface);
    textures: HT.Table(string, *SDL.Texture);
}

gTextureAtlas : Texture_Atlas;

Sampler_Palette :: struct {
    pointClamp: *SDL.GPU_Sampler;
}

gSamplers : Sampler_Palette;

get_texture :: (name: string) -> (*SDL.Texture, success: bool #must) {
    t, s := HT.table_find(*gTextureAtlas.textures, name);
    return t, s;
}

load_png_texture_from_memory :: (ctx: *Rendering_Context, name: string, memory: []u8) -> bool {
    stream := SDL.io_from_const_mem(memory.data, xx memory.count);
    surface := SDL_IMG.load_png_io(stream);
    return load_texture_from_surface(ctx, name, surface);
}

load_png_texture_from_file :: (ctx: *Rendering_Context, name: string, filename: string) -> bool {
    surface := SDL_IMG.load(filename.data);
    return load_texture_from_surface(ctx, name, surface);
}

load_texture_from_surface :: (ctx: *Rendering_Context, name: string, surface: *SDL.Surface) -> bool {
    if !surface {
        print("Surface was not loaded due to error: %\n", u8_to_string(SDL.get_error())); 
        return false;
    }

    HT.table_set(*gTextureAtlas.surfaces, name, surface);
    
    textureCreateInfo := SDL.GPU_Texture_Create_Info.{
        type = SDL.GPU_Texture_Type.TYPE_2D,
        format = SDL.GPU_Texture_Format.R8G8B8A8_UNORM,
        width = xx surface.w,
        height = xx surface.h,
        layer_count_or_depth = 1,
        num_levels = 1,
        usage = SDL.GPU_Texture_Usage_Flags.SAMPLER
    };
    
    tex := SDL.create_gpu_texture(ctx.device, *textureCreateInfo);

    if !tex {
        print("Texture was not loaded...\n");
        return false;
    }
    
    HT.table_set(*gTextureAtlas.textures, name, tex);

    
    transferBufferCreateInfo: SDL.GPU_Transfer_Buffer_Create_Info = .{
        usage = SDL.GPU_Transfer_Buffer_Usage.UPLOAD,
        size = xx (surface.w * surface.h * 4)
    };

    transferBuffer := SDL.create_gpu_transfer_buffer(
        ctx.device,
        *transferBufferCreateInfo
    );

    
	transferData: *u8 = SDL.map_gpu_transfer_buffer(
		ctx.device,
		transferBuffer,
		false
	);

	memcpy(transferData, surface.pixels, xx (surface.h * surface.w * 4));
    SDL.unmap_gpu_transfer_buffer(ctx.device, transferBuffer);

    uploadBuf := SDL.acquire_gpu_command_buffer(ctx.device);
    copyPass := SDL.begin_gpu_copy_pass(uploadBuf);
    
    
    loc : SDL.GPU_Texture_Transfer_Info = .{
        transfer_buffer = transferBuffer,
        offset = 0
    };

    bufRegion : SDL.GPU_Texture_Region = .{
        texture = tex,
        w = xx surface.w,
        h = xx surface.h,
        d = 1
    };

    SDL.upload_to_gpu_texture(
        copyPass,
        *loc,
        *bufRegion,
        false
    );

    
    SDL.end_gpu_copy_pass(copyPass);
    SDL.submit_gpu_command_buffer(uploadBuf);
    SDL.release_gpu_transfer_buffer(ctx.device, transferBuffer);

    print("Successfully loaded texture: %\n", name);

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
    gSamplers.pointClamp = SDL.create_gpu_sampler(ctx.device, *info);
}
