create_trixel_pipeline :: (ctx: Rendering_Context) -> *SDL.GPU_Graphics_Pipeline {
    vertexShader := load_shader(*ctx, "tri.vert", 0, 1, 1, 0);
    fragShader := load_shader(*ctx, "solid.frag", 0, 1, 0, 0);

    colorTargetDesc : SDL.GPU_Color_Target_Description = .{
        format = SDL.GPU_Texture_Format.R8G8B8A8_UNORM
    };

    vertexBufferDesc : SDL.GPU_Vertex_Buffer_Description = .{
        slot = 0,
        input_rate = SDL.GPU_Vertex_Input_Rate.VERTEX,
        instance_step_rate = 0,
        pitch = size_of(Position_Color_Vertex) 
    };

    attributes : [2] SDL.GPU_Vertex_Attribute;
    attributes[0] = .{
            buffer_slot = 0,
            format = SDL.GPU_Vertex_Element_Format.FLOAT3,
            location = 0,
            offset = 0
    };
    attributes[1] = .{
            buffer_slot = 0,
            format = SDL.GPU_Vertex_Element_Format.UBYTE4_NORM,
            location = 1,
            offset = size_of(float) * 3
    };

    pipelineCreateInfo : SDL.GPU_Graphics_Pipeline_Create_Info = .{
        target_info = .{
            num_color_targets = 1,
            color_target_descriptions = *colorTargetDesc,
            has_depth_stencil_target = true,
            depth_stencil_format = SDL.GPU_Texture_Format.D16_UNORM
        },
        depth_stencil_state = .{
            enable_depth_test = true,
            enable_depth_write = true,
            enable_stencil_test = false,
            compare_op = SDL.GPU_Compare_Op.LESS,
            write_mask = 0xFF  
        },
        rasterizer_state = .{
            cull_mode = SDL.GPU_Cull_Mode.NONE,
            fill_mode = SDL.GPU_Fill_Mode.FILL,
            front_face = SDL.GPU_Front_Face.COUNTER_CLOCKWISE 
        },
        vertex_input_state = .{
            num_vertex_buffers = 1,
            vertex_buffer_descriptions = *vertexBufferDesc,
            num_vertex_attributes = 2,
            vertex_attributes = attributes.data
        },
        primitive_type = SDL.GPU_Primitive_Type.TRIANGLELIST,
        vertex_shader = vertexShader,
        fragment_shader = fragShader,
    };
    pipelineCreateInfo.rasterizer_state.fill_mode = SDL.GPU_Fill_Mode.FILL;
    pipeline := SDL.create_gpu_graphics_pipeline(ctx.device, *pipelineCreateInfo);
    return pipeline;
}

create_sky_pipeline :: (ctx: Rendering_Context) -> *SDL.GPU_Graphics_Pipeline {
    vertexShader := load_shader(*ctx, "sky.vert", 0, 1, 0, 0);
    fragShader := load_shader(*ctx, "sky.frag", 0, 1, 0, 0);

    colorTargetDesc : SDL.GPU_Color_Target_Description = .{
        format = SDL.GPU_Texture_Format.R8G8B8A8_UNORM
    };

    vertexBufferDesc : SDL.GPU_Vertex_Buffer_Description = .{
        slot = 0,
        input_rate = SDL.GPU_Vertex_Input_Rate.VERTEX,
        instance_step_rate = 0,
        pitch = size_of(Position_Color_Vertex) 
    };

    attributes : [2] SDL.GPU_Vertex_Attribute;
    attributes[0] = .{
            buffer_slot = 0,
            format = SDL.GPU_Vertex_Element_Format.FLOAT3,
            location = 0,
            offset = 0
    };
    attributes[1] = .{
            buffer_slot = 0,
            format = SDL.GPU_Vertex_Element_Format.UBYTE4_NORM,
            location = 1,
            offset = size_of(float) * 3
    };

    pipelineCreateInfo : SDL.GPU_Graphics_Pipeline_Create_Info = .{
        target_info = .{
            num_color_targets = 1,
            color_target_descriptions = *colorTargetDesc,
            has_depth_stencil_target = true,
            depth_stencil_format = SDL.GPU_Texture_Format.D16_UNORM
        },
        depth_stencil_state = .{
            enable_depth_test = true,
            enable_depth_write = true,
            enable_stencil_test = false,
            compare_op = SDL.GPU_Compare_Op.LESS,
            write_mask = 0xFF  
        },
        rasterizer_state = .{
            cull_mode = SDL.GPU_Cull_Mode.NONE,
            fill_mode = SDL.GPU_Fill_Mode.FILL,
            front_face = SDL.GPU_Front_Face.COUNTER_CLOCKWISE 
        },
        vertex_input_state = .{
            num_vertex_buffers = 1,
            vertex_buffer_descriptions = *vertexBufferDesc,
            num_vertex_attributes = 2,
            vertex_attributes = attributes.data
        },
        primitive_type = SDL.GPU_Primitive_Type.TRIANGLELIST,
        vertex_shader = vertexShader,
        fragment_shader = fragShader,
    };
    pipelineCreateInfo.rasterizer_state.fill_mode = SDL.GPU_Fill_Mode.FILL;
    pipeline := SDL.create_gpu_graphics_pipeline(ctx.device, *pipelineCreateInfo);
    return pipeline;
}

create_arbtri_pipeline :: (ctx: Rendering_Context) -> *SDL.GPU_Graphics_Pipeline {
    vertexShader := load_shader(*ctx, "arbtri.vert", 0, 1, 0, 0);
    fragShader := load_shader(*ctx, "arbtri.frag", 0, 1, 0, 0);

    colorTargetDesc : SDL.GPU_Color_Target_Description = .{
        format = SDL.GPU_Texture_Format.R8G8B8A8_UNORM
    };

    vertexBufferDesc : SDL.GPU_Vertex_Buffer_Description = .{
        slot = 0,
        input_rate = SDL.GPU_Vertex_Input_Rate.VERTEX,
        instance_step_rate = 0,
        pitch = size_of(Position_Color_Vertex) 
    };

    attributes : [2] SDL.GPU_Vertex_Attribute;
    attributes[0] = .{
            buffer_slot = 0,
            format = SDL.GPU_Vertex_Element_Format.FLOAT3,
            location = 0,
            offset = 0
    };
    attributes[1] = .{
            buffer_slot = 0,
            format = SDL.GPU_Vertex_Element_Format.UBYTE4_NORM,
            location = 1,
            offset = size_of(float) * 3
    };

    pipelineCreateInfo : SDL.GPU_Graphics_Pipeline_Create_Info = .{
        target_info = .{
            num_color_targets = 1,
            color_target_descriptions = *colorTargetDesc,
            has_depth_stencil_target = true,
            depth_stencil_format = SDL.GPU_Texture_Format.D16_UNORM
        },
        depth_stencil_state = .{
            enable_depth_test = true,
            enable_depth_write = true,
            enable_stencil_test = false,
            compare_op = SDL.GPU_Compare_Op.LESS,
            write_mask = 0xFF  
        },
        rasterizer_state = .{
            cull_mode = SDL.GPU_Cull_Mode.NONE,
            fill_mode = SDL.GPU_Fill_Mode.FILL,
            front_face = SDL.GPU_Front_Face.COUNTER_CLOCKWISE 
        },
        vertex_input_state = .{
            num_vertex_buffers = 1,
            vertex_buffer_descriptions = *vertexBufferDesc,
            num_vertex_attributes = 2,
            vertex_attributes = attributes.data
        },
        primitive_type = SDL.GPU_Primitive_Type.TRIANGLELIST,
        vertex_shader = vertexShader,
        fragment_shader = fragShader,
    };
    pipelineCreateInfo.rasterizer_state.fill_mode = SDL.GPU_Fill_Mode.FILL;
    pipeline := SDL.create_gpu_graphics_pipeline(ctx.device, *pipelineCreateInfo);
    return pipeline;
}

create_sprite_pipeline :: (ctx: Rendering_Context) -> *SDL.GPU_Graphics_Pipeline {
    vertexShader := load_shader(*ctx, "sprite.vert", 0, 1, 0, 0);
    fragShader := load_shader(*ctx, "sprite.frag", 0, 1, 0, 0);

    colorTargetDesc : SDL.GPU_Color_Target_Description = .{
        format = SDL.GPU_Texture_Format.R8G8B8A8_UNORM
    };

    vertexBufferDesc : SDL.GPU_Vertex_Buffer_Description = .{
        slot = 0,
        input_rate = SDL.GPU_Vertex_Input_Rate.VERTEX,
        instance_step_rate = 0,
        pitch = size_of(Position_Color_Vertex) 
    };

    attributes : [2] SDL.GPU_Vertex_Attribute;
    attributes[0] = .{
            buffer_slot = 0,
            format = SDL.GPU_Vertex_Element_Format.FLOAT3,
            location = 0,
            offset = 0
    };
    attributes[1] = .{
            buffer_slot = 0,
            format = SDL.GPU_Vertex_Element_Format.UBYTE4_NORM,
            location = 1,
            offset = size_of(float) * 3
    };

    pipelineCreateInfo : SDL.GPU_Graphics_Pipeline_Create_Info = .{
        target_info = .{
            num_color_targets = 1,
            color_target_descriptions = *colorTargetDesc,
            has_depth_stencil_target = true,
            depth_stencil_format = SDL.GPU_Texture_Format.D16_UNORM
        },
        depth_stencil_state = .{
            enable_depth_test = true,
            enable_depth_write = true,
            enable_stencil_test = false,
            compare_op = SDL.GPU_Compare_Op.LESS,
            write_mask = 0xFF  
        },
        rasterizer_state = .{
            cull_mode = SDL.GPU_Cull_Mode.NONE,
            fill_mode = SDL.GPU_Fill_Mode.FILL,
            front_face = SDL.GPU_Front_Face.COUNTER_CLOCKWISE 
        },
        vertex_input_state = .{
            num_vertex_buffers = 1,
            vertex_buffer_descriptions = *vertexBufferDesc,
            num_vertex_attributes = 2,
            vertex_attributes = attributes.data
        },
        primitive_type = SDL.GPU_Primitive_Type.TRIANGLELIST,
        vertex_shader = vertexShader,
        fragment_shader = fragShader,
    };
    pipelineCreateInfo.rasterizer_state.fill_mode = SDL.GPU_Fill_Mode.FILL;
    pipeline := SDL.create_gpu_graphics_pipeline(ctx.device, *pipelineCreateInfo);
    return pipeline;
}

create_all_pipelines :: (ctx: *Rendering_Context) {
    ctx.trixelPipeline = create_trixel_pipeline(ctx);
    ctx.skyPipeline = create_sky_pipeline(ctx);
    ctx.arbtriPipeline = create_arbtri_pipeline(ctx);
    ctx.spritePipeline = create_sprite_pipeline(ctx);
}
