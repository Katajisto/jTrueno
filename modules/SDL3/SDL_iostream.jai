IO_Stream :: void;

load_file :: (file: *u8, data_size: *u64) -> *void #foreign SDL3 "SDL_LoadFile";
io_from_const_mem :: (mem: *u8, size: u64) -> *void #foreign SDL3 "SDL_IOFromConstMem";
