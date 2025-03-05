#import "Basic";
#import "Math";
SDL :: #import "SDL3";
yaris :: #import "Yaris";

#load "pipelines.jai";
#load "shaders.jai";
#load "meshes.jai";
#load "camera.jai";

Rendering_Draw_State :: struct {
    cmdbuf: *SDL.GPU_Command_Buffer;
};

Rendering_Context :: struct {
    device: *SDL.GPU_Device;
    window: *SDL.Window;
    basePath: string;
    trixelPipeline: *SDL.GPU_Graphics_Pipeline;
    vertexBuffer: *SDL.GPU_Buffer;
    indexBuffer: *SDL.GPU_Buffer;
    drawState: Rendering_Draw_State;
    sceneColorTexture: *SDL.GPU_Texture;
    sceneDepthTexture: *SDL.GPU_Texture;
    instanceTransferBuffer: *SDL.GPU_Transfer_Buffer;
    instanceStorageBuffer: *SDL.GPU_Buffer;
};

Instance_Data :: struct {
    color: Vector4;
    position: Vector4;
}

Position_Color_Vertex :: struct {
	x, y, z: float;
	r, g, b, a: u8;
};

draw :: (ctx: *Rendering_Context) {
    cmdbuf := SDL.acquire_gpu_command_buffer(ctx.device);
    swapchainTexture: *SDL.GPU_Texture;
    if (!SDL.acquire_gpu_swapchain_texture(cmdbuf, ctx.window, *swapchainTexture, null, null)) {
        print("WaitAndAcquireGPUSwapchainTexture failed: %\n", SDL.get_error());
        return;
    }

    iList: [2]Instance_Data = .[
        .{
            color = .{1, 1, 0, 1},
            position = .{0, 0, 0, 0}
        },
        .{
            color = .{0, 0, 1, 1},
            position = .{0, 20, 0, 0}
        }
    ];

	if swapchainTexture {

        dataptr : *Instance_Data = SDL.map_gpu_transfer_buffer(ctx.device, ctx.instanceTransferBuffer, true);

        for 0..iList.count -1 {
            dataptr[it] = iList[it];
        }
        
        SDL.unmap_gpu_transfer_buffer(ctx.device, ctx.instanceTransferBuffer);
    
        copyPass := SDL.begin_gpu_copy_pass(cmdbuf);

        transferBufferLocation := SDL.GPU_Transfer_Buffer_Location.{
            transfer_buffer = ctx.instanceTransferBuffer,
            offset = 0
        };

        bufferRegion := SDL.GPU_Buffer_Region.{
            buffer = ctx.instanceStorageBuffer,
            offset = 0,
            size = size_of(Instance_Data) * iList.count
        };
        
        SDL.upload_to_gpu_buffer(
            copyPass,  
            *transferBufferLocation,
            *bufferRegion,
            true
        );

        SDL.end_gpu_copy_pass(copyPass);
    
        nearPlane := 20.0;
        farPlane := 60.0;

        w, h: s32;
        SDL.get_window_size_in_pixels(ctx.window, *w, *h);
        proj := create_perspective(
            75.0 * 3.141 / 180.0,
            w / cast(float)h,
            nearPlane,
            farPlane,
        );

        view := create_lookat(.{30 * cast(float32) sin(seconds_since_init()), 30, 30 * cast(float32) cos(seconds_since_init())}, .{0,0,0});
        viewproj := view * proj;

		colorTargetInfo: SDL.GPU_Color_Target_Info;
		colorTargetInfo.texture = swapchainTexture;
		colorTargetInfo.clear_color = SDL.F_Color.{ 0.6, 0.9, 1.0, 1.0 };
		colorTargetInfo.load_op = SDL.GPU_Load_Op.CLEAR;
		colorTargetInfo.store_op = SDL.GPU_Store_Op.STORE;

        depthStencilTargetInfo: SDL.GPU_Depth_Stencil_Target_Info;
        depthStencilTargetInfo.texture = ctx.sceneDepthTexture;
        depthStencilTargetInfo.cycle = true;
        depthStencilTargetInfo.clear_depth = 1;
        depthStencilTargetInfo.clear_stencil = 0;
        depthStencilTargetInfo.load_op = SDL.GPU_Load_Op.CLEAR;
        depthStencilTargetInfo.store_op = SDL.GPU_Store_Op.STORE;
        depthStencilTargetInfo.stencil_load_op = SDL.GPU_Load_Op.CLEAR;
        depthStencilTargetInfo.stencil_store_op = SDL.GPU_Store_Op.STORE;

		renderPass := SDL.begin_gpu_render_pass(cmdbuf, *colorTargetInfo, 1, *depthStencilTargetInfo);
        
        SDL.bind_gpu_vertex_storage_buffers(renderPass, 0, *ctx.instanceStorageBuffer, 1);
        
        SDL.push_gpu_vertex_uniform_data(cmdbuf, 0, viewproj.floats.data, size_of(float) * 16);       

        binding : SDL.GPU_Buffer_Binding = .{ buffer = ctx.vertexBuffer, offset = 0};
        SDL.bind_gpu_vertex_buffers(renderPass, 0, *binding, 1);
        
        index_binding : SDL.GPU_Buffer_Binding = .{ buffer = ctx.indexBuffer, offset = 0};
        SDL.bind_gpu_index_buffer(renderPass,*index_binding, SDL.GPU_Index_Element_Size.SIZE_16BIT);
        
        SDL.bind_gpu_graphics_pipeline(renderPass, ctx.trixelPipeline);
		SDL.draw_gpu_indexed_primitives(renderPass, 36, iList.count, 0, 0, 0);
		SDL.end_gpu_render_pass(renderPass);
	}
 	SDL.submit_gpu_command_buffer(cmdbuf);

	return;
}


init :: (w: s32, h: s32, windowName: string) -> (Rendering_Context, bool) {
    if !SDL.init(SDL.Init_Flags.VIDEO | SDL.Init_Flags.GAMEPAD) {
        print("SDL init failed!");
        return .{}, false;
    }
    
    GpuContext : Rendering_Context;

    GpuContext.basePath = yaris.u8_to_string(SDL.get_base_path());
    
	GpuContext.device = SDL.create_gpu_device(
		SDL.GPU_Shader_Format.SPIRV | SDL.GPU_Shader_Format.MSL,
		true,
		null,
    );
    
    if !GpuContext.device {
        print("GPU createdevice failed");
        return .{}, false;
    }

    GpuContext.window = SDL.create_window(to_c_string(windowName), w, h, 0);

    if !GpuContext.window {
        print("Window creation failed: %\n", SDL.get_error());
        return .{}, false;
    }

    if !SDL.claim_window_for_gpu_device(GpuContext.device, GpuContext.window) {
        print("Window claim failed: %\n", SDL.get_error());
        return .{}, false;
    }
    
    GpuContext.trixelPipeline = create_trixel_pipeline(GpuContext);

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
                
	return GpuContext, true;
}

