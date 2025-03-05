TRIXEL_SIZE :: 0.0625;
TRIXEL_SIZE_HALF :: 0.03125;

Material :: struct {
	color: Vector4 = .{1, 1, 1, 1}; 
	roughness: float = 0;
	metallic: float = 0;
	emit: float = 0;
}

Trixel :: struct {
	empty: bool = false;
	material: Material;
};

Trile :: struct {
	trixels: [16][16][16]Trixel;
};
