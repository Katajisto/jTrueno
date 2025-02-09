#import "Basic";
SDL :: #import "SDL3";
yaris :: #import "Yaris";

Supra_Draw_State :: struct {
    cmdbuf: *SDL.GPU_Command_Buffer;
};

Supra_Context :: struct {
    device: *SDL.GPU_Device;
    window: *SDL.Window;
    basePath: string;
    trixelPipeline: *SDL.GPU_Graphics_Pipeline;
    drawState: Supra_Draw_State;
};

load_shader :: (ctx: *Supra_Context, shaderName: string, samplerCount: u32, uniformBufferCount: u32, storageBufferCount: u32, storageTextureCount: u32) -> *SDL.GPU_Shader {
    stage : SDL.GPU_Shader_Stage;
    cFilename := to_c_string(shaderName);

    entrypoint : string = "mainf";

    if SDL.strstr(cFilename, ".vert") { stage = SDL.GPU_Shader_Stage.VERTEX; entrypoint = "main"; }
    else if SDL.strstr(cFilename, ".frag") { stage = SDL.GPU_Shader_Stage.FRAGMENT; entrypoint = "main"; }
    else { print("Invalid shader stage.\n"); return null; }
    
    backendFormats := SDL.get_gpu_shader_formats(ctx.device);
    format := SDL.GPU_Shader_Format.INVALID;


    shaderpath : string;

    if backendFormats & SDL.GPU_Shader_Format.MSL {
        shaderpath = tprint("%shaders/MSL/%.metal", ctx.basePath, shaderName);
        format = SDL.GPU_Shader_Format.MSL;
    } else if backendFormats & SDL.GPU_Shader_Format.SPIRV {
        shaderpath = tprint("%shaders/SPIRV/%.spv", ctx.basePath, shaderName);
        format = SDL.GPU_Shader_Format.SPIRV;
    }

    codeSize : u64;
    code := SDL.load_file(to_c_string(shaderpath), *codeSize);
    
    if !code {
        print("Failed to load shader from disk! %\n", shaderpath);
    }

    shaderInfo : SDL.GPU_Shader_Create_Info = .{
        code = code,
        code_size = codeSize,
        entry_point = to_c_string(entrypoint),
        format = format,
        stage = stage,
        num_samplers = samplerCount,
        num_uniform_buffers = uniformBufferCount,
        num_storage_buffers = storageBufferCount,
        num_storage_textures = storageTextureCount
    };

    shader := SDL.create_gpu_shader(ctx.device, *shaderInfo);
    if !shader {
        print("Failed to create shader! \n");
        SDL.free(code);
        return null;
    }

    SDL.free(code);
    return shader;
}

begin_draw :: (ctx: *Supra_Context) {
    cmdbuf := SDL.acquire_gpu_command_buffer(ctx.device);
    if !cmdbuf {
        print("Failed to acquire cmd buf!\n");
        return;
    }
    ctx.drawState.cmdbuf = cmdbuf;
}

end_draw :: (ctx: *Supra_Context) {
    if !ctx.drawState.cmdbuf {
        print("cmdbuf is null, did you forget to start drawing before ending it?\n");
    }
 	SDL.submit_gpu_command_buffer(ctx.drawState.cmdbuf);

    newDrawState : Supra_Draw_State;
    ctx.drawState = newDrawState;
}

draw :: (ctx: *Supra_Context) {
    begin_draw(ctx);
    swapchainTexture: *SDL.GPU_Texture;
    if (!SDL.acquire_gpu_swapchain_texture(ctx.drawState.cmdbuf, ctx.window, *swapchainTexture, null, null)) {
        print("WaitAndAcquireGPUSwapchainTexture failed: %\n", SDL.get_error());
        return;
    }

	if swapchainTexture {
		colorTargetInfo: SDL.GPU_Color_Target_Info;
		colorTargetInfo.texture = swapchainTexture;
		colorTargetInfo.clear_color = SDL.F_Color.{ 0.0, 0.0, 0.0, 1.0 };
		colorTargetInfo.load_op = SDL.GPU_Load_Op.CLEAR;
		colorTargetInfo.store_op = SDL.GPU_Store_Op.STORE;
		renderPass := SDL.begin_gpu_render_pass(ctx.drawState.cmdbuf, *colorTargetInfo, 1, null);
		SDL.bind_gpu_graphics_pipeline(renderPass, ctx.trixelPipeline);
		SDL.draw_gpu_primitives(renderPass, 3, 1, 0, 0);
		SDL.end_gpu_render_pass(renderPass);
	}

    end_draw(ctx);

	return;
}


init :: (w: s32, h: s32, windowName: string) -> (Supra_Context, bool) {
    if !SDL.init(SDL.Init_Flags.VIDEO | SDL.Init_Flags.GAMEPAD) {
        print("SDL init failed!");
        return .{}, false;
    }
    
    GpuContext : Supra_Context;

    GpuContext.basePath = yaris.u8_to_string(SDL.get_base_path());
    
	GpuContext.device = SDL.create_gpu_device(
		SDL.GPU_Shader_Format.SPIRV,
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
    
    GpuContext.trixelPipeline = create_pipeline(GpuContext, "tri.vert", "solid.frag");
    
	return GpuContext, true;
}

// TODO: Look over these arguments more carefully.
create_pipeline :: (ctx: Supra_Context, vertShaderName: string, fragShaderName: string, vertSamplerCount: u32 = 0, vertUniformCount: u32 = 0, fragSamplerCount: u32 = 0, fragUniformCount: u32 = 0) -> *SDL.GPU_Graphics_Pipeline {
    vertexShader := load_shader(*ctx, vertShaderName, vertSamplerCount, vertUniformCount, 0, 0);
    fragShader := load_shader(*ctx, fragShaderName, fragSamplerCount, fragUniformCount, 0, 0);

    colorTargetDesc : SDL.GPU_Color_Target_Description = .{
        format = SDL.get_gpu_swapchain_texture_format(ctx.device, ctx.window)
    };


    pipelineCreateInfo : SDL.GPU_Graphics_Pipeline_Create_Info = .{
        target_info = .{
            num_color_targets = 1,
            color_target_descriptions = *colorTargetDesc
        },
        primitive_type = SDL.GPU_Primitive_Type.TRIANGLELIST,
        vertex_shader = vertexShader,
        fragment_shader = fragShader,
    };
    pipelineCreateInfo.rasterizer_state.fill_mode = SDL.GPU_Fill_Mode.FILL;
    pipeline := SDL.create_gpu_graphics_pipeline(ctx.device, *pipelineCreateInfo);
    return pipeline;
}
