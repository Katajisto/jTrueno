SDL :: #import "SDL3";
#import "Basic";

load_shader :: (device: *SDL.GPU_Device, shaderFilename: string, samplerCount: u32, uniformBufferCount: u32, storageBufferCount: u32, storageTextureCount: u32) -> *SDL.GPU_Shader {
    stage : SDL.GPU_Shader_Stage;
    cFilename := to_c_string(shaderFilename);
    if SDL.strstr(cFilename, ".vert") { stage = SDL.GPU_Shader_Stage.VERTEX; }
    else if SDL.strstr(cFilename, ".frag") { stage = SDL.GPU_Shader_Stage.FRAGMENT; }
    else { print("Invalid shader stage.\n"); return null; }
    
    backendFormats := SDL.get_gpu_shader_formats(device);
    format := SDL.GPU_Shader_Format.INVALID;

    entrypoint :: "start";

    if backendFormats & SDL.GPU_Shader_Format.MSL {
    }
}


// 	const char *entrypoint;

// 	if (backendFormats & SDL_GPU_SHADERFORMAT_MSL) {
// 		SDL_snprintf(fullPath, sizeof(fullPath), "%sshaders/MSL/%s.metal", supra_gsc->BasePath, shaderFilename);
// 		format = SDL_GPU_SHADERFORMAT_MSL;
// 		entrypoint = "start";
// 	}

// 	size_t codeSize;
// 	void* code = SDL_LoadFile(fullPath, &codeSize);
// 	if (code == NULL)
// 	{
// 		SDL_Log("Failed to load shader from disk! %s", fullPath);
// 		return NULL;
// 	}

// 	SDL_GPUShaderCreateInfo shaderInfo = {
// 		.code = code,
// 		.code_size = codeSize,
// 		.entrypoint = entrypoint,
// 		.format = format,
// 		.stage = stage,
// 		.num_samplers = samplerCount,
// 		.num_uniform_buffers = uniformBufferCount,
// 		.num_storage_buffers = storageBufferCount,
// 		.num_storage_textures = storageTextureCount
// 	};
// 	SDL_GPUShader* shader = SDL_CreateGPUShader(device, &shaderInfo);
// 	if (shader == NULL)
// 	{
// 		SDL_Log("Failed to create shader!");
// 		SDL_free(code);
// 		return NULL;
// 	}

// 	SDL_free(code);
// 	return shader;
// }

main :: () {
    if !SDL.init(SDL.Init_Flags.VIDEO | SDL.Init_Flags.GAMEPAD) {
        print("SDL init failed!");
        return;
    }
    
	device := SDL.create_gpu_device(
		SDL.GPU_Shader_Format.MSL,
		false,
		null,
    );
    
    if !device {
        print("GPU createdevice failed");
        return;
    }

    window := SDL.create_window("jTrueno", 500, 500, 0);

    if !window {
        print("Window creation failed: %\n", SDL.get_error());
        return;
    }

    if !SDL.claim_window_for_gpu_device(device, window) {
        print("Window claim failed: %\n", SDL.get_error());
        return;
    }

    quit := false;
   
    while !quit {
        evt: SDL.Event;
        while(SDL.poll_event(*evt)) {
            if evt.type == SDL.Event_Type.QUIT {
                quit = true;
                break;
            }
        }
        print("WASTE!\n");
    }
	// SDL_GPUShader* vertexShader = LoadShader(supra_gsc->Device, "tri.vert", 0, 0, 0, 0);
	// if (vertexShader == NULL) {
	// 	print("Failed to create vertex shader!");
	// 	return -1;
	// }
	// SDL_GPUShader* fragmentShader = LoadShader(supra_gsc->Device, "solid.frag", 0, 0, 0, 0);
	// if (fragmentShader == NULL) {
	// 	print("Failed to create fragment shader!");
	// 	return -1;
	// }

	// SDL_GPUGraphicsPipelineCreateInfo pipelineCreateInfo = {
	// 	.target_info = {
	// 		.num_color_targets = 1,
	// 		.color_target_descriptions = (SDL_GPUColorTargetDescription[]){{
	// 			.format = SDL_GetGPUSwapchainTextureFormat(supra_gsc->Device, supra_gsc->Window)
	// 		}},
	// 	},
	// 	.primitive_type = SDL_GPU_PRIMITIVETYPE_TRIANGLELIST,
	// 	.vertex_shader = vertexShader,
	// 	.fragment_shader = fragmentShader,
	// };

	// pipelineCreateInfo.rasterizer_state.fill_mode = SDL_GPU_FILLMODE_FILL;
	// supra_gsc->Pipeline2D = SDL_CreateGPUGraphicsPipeline(supra_gsc->Device, &pipelineCreateInfo);
	// if (supra_gsc->Pipeline2D == NULL) {
	// 	print("Failed to create 2D pipeline!");
	// 	return -1;
	// }

	// SDL_ReleaseGPUShader(supra_gsc->Device, vertexShader);
	// SDL_ReleaseGPUShader(supra_gsc->Device, fragmentShader);
	
    
    print("Hello!\n");
}
