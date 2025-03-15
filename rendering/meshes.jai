upload_buffers :: (ctx: *Rendering_Context) {
    vertexBufferCreateInfo : SDL.GPU_Buffer_Create_Info = .{
        usage = SDL.GPU_Buffer_Usage_Flags.VERTEX,
        size = size_of(Position_Color_Vertex) * 24
    };

    ctx.vertexBuffer = SDL.create_gpu_buffer(
        ctx.device,
        *vertexBufferCreateInfo
    );

    indexBufferCreateInfo : SDL.GPU_Buffer_Create_Info = .{
        usage = SDL.GPU_Buffer_Usage_Flags.INDEX,
        size = size_of(u16) * 36
    };

    ctx.indexBuffer = SDL.create_gpu_buffer(
        ctx.device,
        *indexBufferCreateInfo
    );

    transferBufferCreateInfo: SDL.GPU_Transfer_Buffer_Create_Info = .{
        usage = SDL.GPU_Transfer_Buffer_Usage.UPLOAD,
        size = size_of(Position_Color_Vertex) * 24 + size_of(u16) * 36  
    };

    transferBuffer := SDL.create_gpu_transfer_buffer(
        ctx.device,
        *transferBufferCreateInfo
    );
    
    instanceTransferBufferCreateInfo: SDL.GPU_Transfer_Buffer_Create_Info = .{
        usage = SDL.GPU_Transfer_Buffer_Usage.UPLOAD,
        size = size_of(Instance_Data) * 4096 
    };

    ctx.instanceTransferBuffer = SDL.create_gpu_transfer_buffer(
        ctx.device,
        *instanceTransferBufferCreateInfo
    );

    instanceStorageBufferCreateInfo : SDL.GPU_Buffer_Create_Info = .{
        usage = SDL.GPU_Buffer_Usage_Flags.GRAPHICS_STORAGE_READ,
        size = size_of(Instance_Data) * 4096
    };

    ctx.instanceStorageBuffer = SDL.create_gpu_buffer(
        ctx.device,
        *instanceStorageBufferCreateInfo
    );
    
	transferData: *Position_Color_Vertex = SDL.map_gpu_transfer_buffer(
		ctx.device,
		transferBuffer,
		false
	);

	transferData[0] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 0, 255 };
	transferData[1] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 0, 255 };
	transferData[2] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 0, 255 };
	transferData[3] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 0, 255 };

	transferData[4] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 255, 0, 255 };
	transferData[5] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 255, 0, 255 };
	transferData[6] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 255, 0, 255 };
	transferData[7] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 255, 0, 255 };

	transferData[8] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 255, 255 };
	transferData[9] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 255, 255 };
	transferData[10] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 0, 255, 255 };
	transferData[11] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 0, 255, 255 };

	transferData[12] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 255, 0, 255 };
	transferData[13] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 255, 0, 255 };
	transferData[14] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 255, 0, 255 };
	transferData[15] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 255, 0, 255 };

	transferData[16] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 255, 255, 255 };
	transferData[17] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 255, 255, 255 };
	transferData[18] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 255, 255, 255 };
	transferData[19] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 255, 255, 255 };

	transferData[20] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 0, 255, 255 };
	transferData[21] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 0, 255, 255 };
	transferData[22] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 0, 255, 255 };
	transferData[23] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 0, 255, 255 };

	indexData: *u16 = xx *transferData[24];
	
	indices: [] u16 = .[
		0, 1, 2, 0, 2, 3,
		4, 5, 6, 4, 6, 7,
		8, 9, 10, 8, 10, 11,
		12, 13, 14, 12, 14, 15,
		16, 17, 18, 16, 18, 19,
		20, 21, 22, 20, 22, 23
	];
	memcpy(indexData, indices.data, indices.count * size_of(u16));

	SDL.unmap_gpu_transfer_buffer(ctx.device, transferBuffer);

    uploadBuf := SDL.acquire_gpu_command_buffer(ctx.device);
    copyPass := SDL.begin_gpu_copy_pass(uploadBuf);
	
    loc : SDL.GPU_Transfer_Buffer_Location = .{
        transfer_buffer = transferBuffer,
        offset = 0
    };

    bufRegion : SDL.GPU_Buffer_Region = .{
        buffer = ctx.vertexBuffer,
        offset = 0,
        size = size_of(Position_Color_Vertex) * 24
    };

    SDL.upload_to_gpu_buffer(
        copyPass,
        *loc,
        *bufRegion,
        false
    );
    
    loc2 : SDL.GPU_Transfer_Buffer_Location = .{
        transfer_buffer = transferBuffer,
        offset = size_of(Position_Color_Vertex) * 24
    };
    bufRegion2 : SDL.GPU_Buffer_Region = .{
        buffer = ctx.indexBuffer,
        offset = 0,
        size = size_of(u16) * 36
    };
    SDL.upload_to_gpu_buffer(
        copyPass,
        *loc2,
        *bufRegion2,
        false
    );

    SDL.end_gpu_copy_pass(copyPass);
    SDL.submit_gpu_command_buffer(uploadBuf);
    SDL.release_gpu_transfer_buffer(ctx.device, transferBuffer);
}

// TODO: Actually enforce this on the drawing side and force a flush if too many are added.
MAX_ARBTRI_VERT_AT_ONCE :: 10000;

upload_arbtri_buffers :: (ctx: *Rendering_Context) {
    vertexBufferCreateInfo : SDL.GPU_Buffer_Create_Info = .{
        usage = SDL.GPU_Buffer_Usage_Flags.VERTEX,
        size = size_of(Position_Color_Vertex) * MAX_ARBTRI_VERT_AT_ONCE
    };

    ctx.arbtriVertexBuffer = SDL.create_gpu_buffer(
        ctx.device,
        *vertexBufferCreateInfo
    );

    indexBufferCreateInfo : SDL.GPU_Buffer_Create_Info = .{
        usage = SDL.GPU_Buffer_Usage_Flags.INDEX,
        size = size_of(u16) * MAX_ARBTRI_VERT_AT_ONCE
    };

    ctx.arbtriIndexBuffer = SDL.create_gpu_buffer(
        ctx.device,
        *indexBufferCreateInfo
    );

    transferBufferCreateInfo: SDL.GPU_Transfer_Buffer_Create_Info = .{
        usage = SDL.GPU_Transfer_Buffer_Usage.UPLOAD,
        size = size_of(Position_Color_Vertex) * MAX_ARBTRI_VERT_AT_ONCE + size_of(u16) * MAX_ARBTRI_VERT_AT_ONCE
    };

    ctx.arbtriTransferBuffer = SDL.create_gpu_transfer_buffer(
        ctx.device,
        *transferBufferCreateInfo
    );
} 
