Mesh :: struct {
    vertexBuffer: *SDL.GPU_Buffer;
    indexBuffer: *SDL.GPU_Buffer;
    vertCount: u32;
    indexCount: u32;
}

gMeshTable : HT.Table(string, Mesh);

get_mesh :: (name: string) -> (Mesh, success: bool #must) {
    mesh, success := HT.table_find(*gMeshTable, name);
    return mesh, success;
}

create_mesh :: (ctx: *Rendering_Context, meshName: string, verts: [] Position_Color_Vertex, indices: [] u16) {

    newMesh : Mesh;

    newMesh.vertCount = xx verts.count;
    newMesh.indexCount = xx indices.count;

    vertexBufferCreateInfo : SDL.GPU_Buffer_Create_Info = .{
        usage = SDL.GPU_Buffer_Usage_Flags.VERTEX,
        size = size_of(Position_Color_Vertex) * cast(u32) verts.count
    };

    newMesh.vertexBuffer = SDL.create_gpu_buffer(
        ctx.device,
        *vertexBufferCreateInfo
    );
    
    indexBufferCreateInfo : SDL.GPU_Buffer_Create_Info = .{
        usage = SDL.GPU_Buffer_Usage_Flags.INDEX,
        size = size_of(u16) * cast(u32) indices.count
    };

    newMesh.indexBuffer = SDL.create_gpu_buffer(
        ctx.device,
        *indexBufferCreateInfo
    );

    
    transferBufferCreateInfo: SDL.GPU_Transfer_Buffer_Create_Info = .{
        usage = SDL.GPU_Transfer_Buffer_Usage.UPLOAD,
        size = size_of(Position_Color_Vertex) * cast(u32) verts.count + size_of(u16) * cast(u32) indices.count
    };

    transferBuffer := SDL.create_gpu_transfer_buffer(
        ctx.device,
        *transferBufferCreateInfo
    );

	transferData: *Position_Color_Vertex = SDL.map_gpu_transfer_buffer(
		ctx.device,
		transferBuffer,
		false
	);

    for 0..verts.count-1 {
        transferData[it] = verts[it];
    }

	indexData: *u16 = xx *transferData[verts.count];
	
	memcpy(indexData, indices.data, indices.count * size_of(u16));

	SDL.unmap_gpu_transfer_buffer(ctx.device, transferBuffer);

    uploadBuf := SDL.acquire_gpu_command_buffer(ctx.device);
    copyPass := SDL.begin_gpu_copy_pass(uploadBuf);
	
    loc : SDL.GPU_Transfer_Buffer_Location = .{
        transfer_buffer = transferBuffer,
        offset = 0
    };

    bufRegion : SDL.GPU_Buffer_Region = .{
        buffer = newMesh.vertexBuffer,
        offset = 0,
        size = size_of(Position_Color_Vertex) * cast(u32) verts.count
    };

    SDL.upload_to_gpu_buffer(
        copyPass,
        *loc,
        *bufRegion,
        false
    );
    
    loc2 : SDL.GPU_Transfer_Buffer_Location = .{
        transfer_buffer = transferBuffer,
        offset = size_of(Position_Color_Vertex) * cast(u32) verts.count
    };
    bufRegion2 : SDL.GPU_Buffer_Region = .{
        buffer = newMesh.indexBuffer,
        offset = 0,
        size = size_of(u16) * cast(u32) indices.count
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

    HT.table_set(*gMeshTable, meshName, newMesh);
}

create_mesh :: (ctx: *Rendering_Context, meshName: string, verts: [] Position_Texture_Vertex, indices: [] u16) {
    
    newMesh : Mesh;

    newMesh.vertCount = xx verts.count;
    newMesh.indexCount = xx indices.count;

    vertexBufferCreateInfo : SDL.GPU_Buffer_Create_Info = .{
        usage = SDL.GPU_Buffer_Usage_Flags.VERTEX,
        size = size_of(Position_Texture_Vertex) * cast(u32) verts.count
    };

    newMesh.vertexBuffer = SDL.create_gpu_buffer(
        ctx.device,
        *vertexBufferCreateInfo
    );
    
    indexBufferCreateInfo : SDL.GPU_Buffer_Create_Info = .{
        usage = SDL.GPU_Buffer_Usage_Flags.INDEX,
        size = size_of(u16) * cast(u32) indices.count
    };

    newMesh.indexBuffer = SDL.create_gpu_buffer(
        ctx.device,
        *indexBufferCreateInfo
    );

    
    transferBufferCreateInfo: SDL.GPU_Transfer_Buffer_Create_Info = .{
        usage = SDL.GPU_Transfer_Buffer_Usage.UPLOAD,
        size = size_of(Position_Texture_Vertex) * cast(u32) verts.count + size_of(u16) * cast(u32) indices.count
    };

    transferBuffer := SDL.create_gpu_transfer_buffer(
        ctx.device,
        *transferBufferCreateInfo
    );

	transferData: *Position_Texture_Vertex = SDL.map_gpu_transfer_buffer(
		ctx.device,
		transferBuffer,
		false
	);

    for 0..verts.count-1 {
        transferData[it] = verts[it];
    }

	indexData: *u16 = xx *transferData[verts.count];
	
	memcpy(indexData, indices.data, indices.count * size_of(u16));

	SDL.unmap_gpu_transfer_buffer(ctx.device, transferBuffer);

    uploadBuf := SDL.acquire_gpu_command_buffer(ctx.device);
    copyPass := SDL.begin_gpu_copy_pass(uploadBuf);
	
    loc : SDL.GPU_Transfer_Buffer_Location = .{
        transfer_buffer = transferBuffer,
        offset = 0
    };

    bufRegion : SDL.GPU_Buffer_Region = .{
        buffer = newMesh.vertexBuffer,
        offset = 0,
        size = size_of(Position_Texture_Vertex) * cast(u32) verts.count
    };

    SDL.upload_to_gpu_buffer(
        copyPass,
        *loc,
        *bufRegion,
        false
    );
    
    loc2 : SDL.GPU_Transfer_Buffer_Location = .{
        transfer_buffer = transferBuffer,
        offset = size_of(Position_Texture_Vertex) * cast(u32) verts.count
    };
    bufRegion2 : SDL.GPU_Buffer_Region = .{
        buffer = newMesh.indexBuffer,
        offset = 0,
        size = size_of(u16) * cast(u32) indices.count
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

    HT.table_set(*gMeshTable, meshName, newMesh);
}


upload_buffers :: (ctx: *Rendering_Context) {
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
    

    verts : [24] Position_Color_Vertex;

	verts[0] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 0, 255 };
	verts[1] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 0, 255 };
	verts[2] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 0, 255 };
	verts[3] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 0, 255 };

	verts[4] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 255, 0, 255 };
	verts[5] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 255, 0, 255 };
	verts[6] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 255, 0, 255 };
	verts[7] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 255, 0, 255 };

	verts[8] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 255, 255 };
	verts[9] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 255, 0, 255, 255 };
	verts[10] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 0, 255, 255 };
	verts[11] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 255, 0, 255, 255 };

	verts[12] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 255, 0, 255 };
	verts[13] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 255, 0, 255 };
	verts[14] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 255, 0, 255 };
	verts[15] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 255, 0, 255 };

	verts[16] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 255, 255, 255 };
	verts[17] = .{ -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 255, 255, 255 };
	verts[18] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 255, 255, 255 };
	verts[19] = .{ TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 255, 255, 255 };

	verts[20] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 0, 255, 255 };
	verts[21] = .{ -TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 0, 255, 255 };
	verts[22] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, 0, 0, 255, 255 };
	verts[23] = .{ TRIXEL_SIZE_HALF, TRIXEL_SIZE_HALF, -TRIXEL_SIZE_HALF, 0, 0, 255, 255 };

	indices: [] u16 = .[
		0, 1, 2, 0, 2, 3,
		4, 5, 6, 4, 6, 7,
		8, 9, 10, 8, 10, 11,
		12, 13, 14, 12, 14, 15,
		16, 17, 18, 16, 18, 19,
		20, 21, 22, 20, 22, 23
	];

    create_mesh(ctx, "base_trixel", verts, indices);
    create_mesh(ctx, "skybox", verts, indices);

    // Create the mesh for a quad to use for drawing sprites.
    quad_verts : [4] Position_Texture_Vertex;
    quad_indices : [6] u16;
    
    quad_verts[0] = .{-1, 1, 0, 0, 0};
    quad_verts[1] = .{1, 1, 0, 1, 0};
    quad_verts[2] = .{1, -1, 0, 1, 1};
    quad_verts[3] = .{-1, -1, 0, 0, 1};

    quad_indices[0] = 0;
    quad_indices[1] = 1;
    quad_indices[2] = 2;
    quad_indices[3] = 0;
    quad_indices[4] = 2;
    quad_indices[5] = 3;

    create_mesh(ctx, "base_quad", quad_verts, quad_indices);   
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
