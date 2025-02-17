#import "Math";

create_perspective :: (fov: float, aspect: float, near: float, far: float) -> Matrix4 {
	num : float = 1.0 / tan(fov * 0.5);
	return .{
		num / aspect, 0, 0, 0,
		0, num, 0, 0,
		0, 0, far / (near - far), -1,
		0, 0, (near * far) / (near - far), 0
	};
}

// Matrix4x4 Matrix4x4_CreatePerspectiveFieldOfView(
// 	float fieldOfView,
// 	float aspectRatio,
// 	float nearPlaneDistance,
// 	float farPlaneDistance
// ) {
// 	float num = 1.0f / ((float) SDL_tanf(fieldOfView * 0.5f));
// 	return (Matrix4x4) {
// 		num / aspectRatio, 0, 0, 0,
// 		0, num, 0, 0,
// 		0, 0, farPlaneDistance / (nearPlaneDistance - farPlaneDistance), -1,
// 		0, 0, (nearPlaneDistance * farPlaneDistance) / (nearPlaneDistance - farPlaneDistance), 0
// 	};
// }

create_lookat :: (position: Vector3, target: Vector3) -> Matrix4 {
	up: Vector3 = .{0, 1, 0};
	targetToPos := position - target;
	A := normalize(targetToPos);
	B := normalize(cross(up, A));
	C := cross(A, B);

	return .{
		B.x, C.x, A.x, 0,
		B.y, C.y, A.y, 0,
		B.z, C.z, A.z, 0,
		-dot(B, position), -dot(C, position), -dot(A, position), 1
	};
}

// Matrix4x4 Matrix4x4_CreateLookAt(
// 	Vector3 cameraPosition,
// 	Vector3 cameraTarget,
// 	Vector3 cameraUpVector
// ) {
// 	Vector3 targetToPosition = {
// 		cameraPosition.x - cameraTarget.x,
// 		cameraPosition.y - cameraTarget.y,
// 		cameraPosition.z - cameraTarget.z
// 	};
// 	Vector3 vectorA = Vector3_Normalize(targetToPosition);
// 	Vector3 vectorB = Vector3_Normalize(Vector3_Cross(cameraUpVector, vectorA));
// 	Vector3 vectorC = Vector3_Cross(vectorA, vectorB);

// 	return (Matrix4x4) {
// 		vectorB.x, vectorC.x, vectorA.x, 0,
// 		vectorB.y, vectorC.y, vectorA.y, 0,
// 		vectorB.z, vectorC.z, vectorA.z, 0,
// 		-Vector3_Dot(vectorB, cameraPosition), -Vector3_Dot(vectorC, cameraPosition), -Vector3_Dot(vectorA, cameraPosition), 1
// 	};
// }


