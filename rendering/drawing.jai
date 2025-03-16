/*
	Drawing functions to be used by the engine user.
	Remember to start with beginning drawing and end with ending
	drawing.

	-ktjst
*/


Rendering_Draw_State :: struct {
    cmdbuf: *SDL.GPU_Command_Buffer;
	swapchainTexture: *SDL.GPU_Texture;
};

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
};


begin_draw :: (ctx: *Rendering_Context) {
	if !!ctx.drawState.cmdbuf {
		print("rendering context cmdbuf is not null at begin_draw, did you forget to end draw?\n");
	}
	ctx.drawState.cmdbuf = SDL.acquire_gpu_command_buffer(ctx.device);
	swapchainTexture: *SDL.GPU_Texture;
	if (!SDL.acquire_gpu_swapchain_texture(ctx.drawState.cmdbuf, ctx.window, *swapchainTexture, null, null)) {
	    print("WaitAndAcquireGPUSwapchainTexture failed: %\n", SDL.get_error());
	    return;
	}
    ctx.drawState.swapchainTexture = swapchainTexture;
}

end_draw :: (ctx: *Rendering_Context) {
 	SDL.submit_gpu_command_buffer(ctx.drawState.cmdbuf);
	ctx.drawState.cmdbuf = null;
}

// Render a trile by rendering all of the invidual trixels.
// Meant for usage with with the trile editor.
// 
// TODO: maybe this shouldn't take up an entire render pass, but since this is almost always alone
// its maybe fine
//
// TODO: maybe this should also take a location where to draw it.
// 
render_trixel_trile :: (ctx: *Rendering_Context, trile: *Trile, camera: *Camera) {
    iList: [..]Instance_Data;
    iList.allocator = temp;
    for x: 0..15 {
        for y: 0..15 {
            for z: 0..15 {
                if !trile.trixels[x][y][z].empty {
                    array_add(*iList, Instance_Data.{
                            color = trile.trixels[x][y][z].material.color,
                            position = .{x * TRIXEL_SIZE, y * TRIXEL_SIZE, z * TRIXEL_SIZE, 0}
                    });
                }
            }
        }
    }
    dataptr : *Instance_Data = SDL.map_gpu_transfer_buffer(ctx.device, ctx.instanceTransferBuffer, true);

    for 0..iList.count -1 {
        dataptr[it] = iList[it];
    }
    
    SDL.unmap_gpu_transfer_buffer(ctx.device, ctx.instanceTransferBuffer);

    copyPass := SDL.begin_gpu_copy_pass(ctx.drawState.cmdbuf);

    transferBufferLocation := SDL.GPU_Transfer_Buffer_Location.{
        transfer_buffer = ctx.instanceTransferBuffer,
        offset = 0
    };

    bufferRegion := SDL.GPU_Buffer_Region.{
        buffer = ctx.instanceStorageBuffer,
        offset = 0,
        size = size_of(Instance_Data) * cast(u32) iList.count
    };
    
    SDL.upload_to_gpu_buffer(
        copyPass,  
        *transferBufferLocation,
        *bufferRegion,
        true
    );

    SDL.end_gpu_copy_pass(copyPass);

    viewproj := create_viewproj(camera, ctx);
    
	colorTargetInfo: SDL.GPU_Color_Target_Info;
	colorTargetInfo.texture = ctx.drawState.swapchainTexture;
	colorTargetInfo.clear_color = SDL.F_Color.{ 0.6, 0.9, 1.0, 1.0 };
	colorTargetInfo.load_op = SDL.GPU_Load_Op.LOAD;
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

	renderPass := SDL.begin_gpu_render_pass(ctx.drawState.cmdbuf, *colorTargetInfo, 1, *depthStencilTargetInfo);
    
    SDL.bind_gpu_vertex_storage_buffers(renderPass, 0, *ctx.instanceStorageBuffer, 1);
    
    SDL.push_gpu_vertex_uniform_data(ctx.drawState.cmdbuf, 0, viewproj.floats.data, size_of(float) * 16);       

    binding : SDL.GPU_Buffer_Binding = .{ buffer = ctx.vertexBuffer, offset = 0};
    SDL.bind_gpu_vertex_buffers(renderPass, 0, *binding, 1);
    
    index_binding : SDL.GPU_Buffer_Binding = .{ buffer = ctx.indexBuffer, offset = 0};
    SDL.bind_gpu_index_buffer(renderPass,*index_binding, SDL.GPU_Index_Element_Size.SIZE_16BIT);
    
    SDL.bind_gpu_graphics_pipeline(renderPass, ctx.trixelPipeline);
	SDL.draw_gpu_indexed_primitives(renderPass, 36, cast(u32) iList.count, 0, 0, 0);
	SDL.end_gpu_render_pass(renderPass);
}

render_sky :: (ctx: *Rendering_Context, camera: *Camera) {
    viewproj := create_viewproj(camera, ctx);
    
	colorTargetInfo: SDL.GPU_Color_Target_Info;
	colorTargetInfo.texture = ctx.drawState.swapchainTexture;
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

	renderPass := SDL.begin_gpu_render_pass(ctx.drawState.cmdbuf, *colorTargetInfo, 1, *depthStencilTargetInfo);
    
    SDL.bind_gpu_vertex_storage_buffers(renderPass, 0, *ctx.instanceStorageBuffer, 1);
    
    SDL.push_gpu_vertex_uniform_data(ctx.drawState.cmdbuf, 0, viewproj.floats.data, size_of(float) * 16);       

    binding : SDL.GPU_Buffer_Binding = .{ buffer = ctx.vertexBuffer, offset = 0};
    SDL.bind_gpu_vertex_buffers(renderPass, 0, *binding, 1);
    
    index_binding : SDL.GPU_Buffer_Binding = .{ buffer = ctx.indexBuffer, offset = 0};
    SDL.bind_gpu_index_buffer(renderPass,*index_binding, SDL.GPU_Index_Element_Size.SIZE_16BIT);
    
    SDL.bind_gpu_graphics_pipeline(renderPass, ctx.skyPipeline);
	SDL.draw_gpu_indexed_primitives(renderPass, 36, 1, 0, 0, 0);
	SDL.end_gpu_render_pass(renderPass);
}

// Drawing arbitrary triangles.
// Currently used for UI.

Arb_Tri :: struct {
    pos: [3]Vector3;
    col: [3]Vector4;
}

Arb_Tri_State :: struct {
    active : bool = false;
    trilist : [..]Arb_Tri;
}

arbTriState : Arb_Tri_State;

arb_tri_add :: (tri: Arb_Tri) {
    if !arbTriState.active {
        newList : [..]Arb_Tri;
        newList.allocator = temp;
        arbTriState.trilist = newList;
        arbTriState.active = true;
    }

    array_add(*arbTriState.trilist, tri);
}

arb_tri_flush :: () {
    if !arbTriState.active {
        print("Warning: flushing a non-active arbitrary triangle state.");
        return;
    }

    arbTriState.active = false;    
    print("Drawing % triangles!\n", arbTriState.trilist.count);

	transferData: *Position_Color_Vertex = SDL.map_gpu_transfer_buffer(
		GpuContext.device,
		GpuContext.arbtriTransferBuffer,
		false
	);

    vertCount: u32 = cast(u32) arbTriState.trilist.count * 3;

    transform_to_screen :: (coord: float) -> float {
        return (coord / 700.0) * 2.0 - 1.0;
    }

    for 0..vertCount-1 {
        tri := it / 3;
        vert := it % 3;
        pos := arbTriState.trilist[tri].pos[vert];
        col := arbTriState.trilist[tri].col[vert];
        transferData[it] = .{transform_to_screen(pos.x), transform_to_screen(pos.y) * -1.0, 0, cast(u8)(col.x * 255), cast(u8)(col.y * 255), cast(u8)(col.z * 255), cast(u8)(col.w * 255)};
    }
    
    indexData: *u16 = xx *transferData[vertCount];
    
    for 0..vertCount-1 {
        indexData[it]    = cast(u16) it;
    }

    SDL.unmap_gpu_transfer_buffer(GpuContext.device, GpuContext.arbtriTransferBuffer);

       
    copyPass := SDL.begin_gpu_copy_pass(GpuContext.drawState.cmdbuf);


    loc : SDL.GPU_Transfer_Buffer_Location = .{
     transfer_buffer = GpuContext.arbtriTransferBuffer,
     offset = 0
    };

    bufRegion : SDL.GPU_Buffer_Region = .{
     buffer = GpuContext.arbtriVertexBuffer,
     offset = 0,
     size = size_of(Position_Color_Vertex) * vertCount
    };

    SDL.upload_to_gpu_buffer(
     copyPass,
     *loc,
     *bufRegion,
     false
    );

    loc2 : SDL.GPU_Transfer_Buffer_Location = .{
     transfer_buffer = GpuContext.arbtriTransferBuffer,
     offset = size_of(Position_Color_Vertex) * vertCount
    };
    bufRegion2 : SDL.GPU_Buffer_Region = .{
     buffer = GpuContext.arbtriIndexBuffer,
     offset = 0,
     size = size_of(u16) * vertCount
    };
    SDL.upload_to_gpu_buffer(
     copyPass,
     *loc2,
     *bufRegion2,
     false
    );

    SDL.end_gpu_copy_pass(copyPass);

    // Do the draw:
	colorTargetInfo: SDL.GPU_Color_Target_Info;
	colorTargetInfo.texture = GpuContext.drawState.swapchainTexture;
	colorTargetInfo.clear_color = SDL.F_Color.{ 0.6, 0.9, 1.0, 1.0 };
	colorTargetInfo.load_op = SDL.GPU_Load_Op.LOAD;
	colorTargetInfo.store_op = SDL.GPU_Store_Op.STORE;

	renderPass := SDL.begin_gpu_render_pass(GpuContext.drawState.cmdbuf, *colorTargetInfo, 1, null);
    binding : SDL.GPU_Buffer_Binding = .{ buffer = GpuContext.arbtriVertexBuffer, offset = 0};
    SDL.bind_gpu_vertex_buffers(renderPass, 0, *binding, 1);
    
    index_binding : SDL.GPU_Buffer_Binding = .{ buffer = GpuContext.arbtriIndexBuffer, offset = 0};
    SDL.bind_gpu_index_buffer(renderPass,*index_binding, SDL.GPU_Index_Element_Size.SIZE_16BIT);
    
    SDL.bind_gpu_graphics_pipeline(renderPass, GpuContext.arbtriPipeline);
	SDL.draw_gpu_indexed_primitives(renderPass, vertCount, 1, 0, 0, 0);
	SDL.end_gpu_render_pass(renderPass);
}
