#import "Basic";
#import "Math";
#load "pipelines.jai";
#load "shaders.jai";
#load "meshes.jai";
#load "camera.jai";
#load "drawing.jai";
#load "ui.jai";
#load "sprite.jai";
#load "textures.jai";

Instance_Data :: struct {
    color: Vector4;
    position: Vector4;
}

Sprite_Instance_Data :: struct {
    position: Vector4;  // x, y, width, height
    uv:       Vector4;  // u1, v1, u2, v2
    color:    Vector4;
}

Position_Color_UV_Vertex :: struct {
	x, y, z: float;
	r, g, b, a: u8;
    u, v : float;
};

Position_Color_Vertex :: struct {
	x, y, z: float;
	r, g, b, a: u8;
};

Position_Texture_Vertex :: struct {
	x, y, z: float;
    u, v: float;
};

draw :: (editorState: *Editor_State) {
    trile: Trile;
    camera := get_trile_editor_camera(editorState);

    begin_draw(*GpuContext);
    render_sky(*GpuContext, *camera);
    render_trixel_trile(*GpuContext, *trile, *camera);
    render_ui();
    end_draw(*GpuContext);


	return;
}

Rendering_Context :: struct {
    device: *SDL.GPU_Device;
    window: *SDL.Window;
    drawState: Rendering_Draw_State;
	
    basePath: string;
	
    trixelPipeline: *SDL.GPU_Graphics_Pipeline;
    skyPipeline: *SDL.GPU_Graphics_Pipeline;
    arbtriPipeline: *SDL.GPU_Graphics_Pipeline;
    spritePipeline: *SDL.GPU_Graphics_Pipeline;
    
    vertexBuffer: *SDL.GPU_Buffer;
    indexBuffer: *SDL.GPU_Buffer;
    
    arbtriVertexBuffer: *SDL.GPU_Buffer;
    arbtriIndexBuffer: *SDL.GPU_Buffer;
    arbtriTransferBuffer: *SDL.GPU_Transfer_Buffer;
	
    sceneColorTexture: *SDL.GPU_Texture;
    sceneDepthTexture: *SDL.GPU_Texture;
	
    instanceTransferBuffer: *SDL.GPU_Transfer_Buffer;
    instanceStorageBuffer: *SDL.GPU_Buffer;

    spriteInstanceTransferBuffer: *SDL.GPU_Transfer_Buffer;
    spriteInstanceStorageBuffer: *SDL.GPU_Buffer;
};

GpuContext : Rendering_Context;

get_render_size :: () -> (s32, s32) {
    w, h: s32;
    SDL.get_window_size_in_pixels(GpuContext.window, *w, *h);
    return w, h;
}

init :: (w: s32, h: s32, windowName: string) -> (bool) {
    if !SDL.init(SDL.Init_Flags.VIDEO | SDL.Init_Flags.GAMEPAD) {
        print("SDL init failed!");
        return false;
    }
    

    GpuContext.basePath = u8_to_string(SDL.get_base_path());
    
	GpuContext.device = SDL.create_gpu_device(
		SDL.GPU_Shader_Format.SPIRV | SDL.GPU_Shader_Format.MSL,
		true,
		null,
    );
    
    if !GpuContext.device {
        print("GPU createdevice failed");
        return false;
    }

    GpuContext.window = SDL.create_window(to_c_string(windowName), w, h, 0);

    if !GpuContext.window {
        print("Window creation failed: %\n", SDL.get_error());
        return false;
    }

    if !SDL.claim_window_for_gpu_device(GpuContext.device, GpuContext.window) {
        print("Window claim failed: %\n", SDL.get_error());
        return false;
    }

    create_all_pipelines(*GpuContext);

    {
        w, h: s32;
        SDL.get_window_size_in_pixels(GpuContext.window, *w, *h);

        sceneTexCreateInfo : SDL.GPU_Texture_Create_Info = .{
            type = SDL.GPU_Texture_Type.TYPE_2D,
            width = xx w,
            height = xx h,
            layer_count_or_depth = 1,
            num_levels = 1,
            sample_count = SDL.GPU_Sample_Count.ONE,
            format = SDL.GPU_Texture_Format.R8G8B8A8_UNORM,
            usage = SDL.GPU_Texture_Usage_Flags.SAMPLER | SDL.GPU_Texture_Usage_Flags.COLOR_TARGET
        };
        
        GpuContext.sceneColorTexture = SDL.create_gpu_texture(
            GpuContext.device,
            *sceneTexCreateInfo
        );

        sceneDepthTexCreateInfo : SDL.GPU_Texture_Create_Info = .{
            type = SDL.GPU_Texture_Type.TYPE_2D,
            width = xx w,
            height = xx h,
            layer_count_or_depth = 1,
            num_levels = 1,
            sample_count = SDL.GPU_Sample_Count.ONE,
            format = SDL.GPU_Texture_Format.D16_UNORM,
            usage = SDL.GPU_Texture_Usage_Flags.SAMPLER | SDL.GPU_Texture_Usage_Flags.DEPTH_STENCIL_TARGET
        };

        GpuContext.sceneDepthTexture = SDL.create_gpu_texture(
            GpuContext.device,
            *sceneDepthTexCreateInfo  
        );
        
    }
    
    load_default_fontsheet();
    
    upload_buffers(*GpuContext);
    upload_arbtri_buffers(*GpuContext);

    create_samplers(*GpuContext);
                
	return true;
}

