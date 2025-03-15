#import "Basic";
#import "Math";
#load "pipelines.jai";
#load "shaders.jai";
#load "meshes.jai";
#load "camera.jai";
#load "drawing.jai";
#load "ui.jai";

Instance_Data :: struct {
    color: Vector4;
    position: Vector4;
}

Position_Color_Vertex :: struct {
	x, y, z: float;
	r, g, b, a: u8;
};

draw :: (editorState: *Editor_State) {
    trile: Trile;
    camera := get_trile_editor_camera(editorState);

    begin_draw(*GpuContext);
    render_sky(*GpuContext, *camera);
    render_trixel_trile(*GpuContext, *trile, *camera);
    print("-- RENDER??? --\n");
    render_ui();
    print("-- RENDER OVErRR??? --\n");
    end_draw(*GpuContext);


	return;
}

GpuContext : Rendering_Context;

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
    
    GpuContext.trixelPipeline = create_trixel_pipeline(GpuContext);
    GpuContext.skyPipeline = create_sky_pipeline(GpuContext);
    GpuContext.arbtriPipeline = create_arbtri_pipeline(GpuContext);

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
    
    upload_buffers(*GpuContext);
    upload_arbtri_buffers(*GpuContext);
                
	return true;
}

