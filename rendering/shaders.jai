load_shader :: (ctx: *Rendering_Context, shaderName: string, samplerCount: u32, uniformBufferCount: u32, storageBufferCount: u32, storageTextureCount: u32) -> *SDL.GPU_Shader {
    stage : SDL.GPU_Shader_Stage;
    cFilename := to_c_string(shaderName);

    entrypoint : string = "main";

    if SDL.strstr(cFilename, ".vert") { stage = SDL.GPU_Shader_Stage.VERTEX; }
    else if SDL.strstr(cFilename, ".frag") { stage = SDL.GPU_Shader_Stage.FRAGMENT; }
    else { print("Invalid shader stage.\n"); return null; }
    
    backendFormats := SDL.get_gpu_shader_formats(ctx.device);
    format := SDL.GPU_Shader_Format.INVALID;


    shaderpath : string;

    if backendFormats & SDL.GPU_Shader_Format.MSL {
        print("Loading metal...\n");
        shaderpath = tprint("%shaders/MSL/%.msl", ctx.basePath, shaderName);
        format = SDL.GPU_Shader_Format.MSL;
        entrypoint = "main0";
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

