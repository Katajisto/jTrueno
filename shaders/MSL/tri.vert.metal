#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 1349 "diff.meta.slang"
struct _MatrixStorage_float4x4_ColMajornatural_0
{
    array<float4, int(4)> data_0;
};


#line 1349
matrix<float,int(4),int(4)>  unpackStorage_0(_MatrixStorage_float4x4_ColMajornatural_0 _S1)
{

#line 1349
    return matrix<float,int(4),int(4)> (_S1.data_0[int(0)][int(0)], _S1.data_0[int(1)][int(0)], _S1.data_0[int(2)][int(0)], _S1.data_0[int(3)][int(0)], _S1.data_0[int(0)][int(1)], _S1.data_0[int(1)][int(1)], _S1.data_0[int(2)][int(1)], _S1.data_0[int(3)][int(1)], _S1.data_0[int(0)][int(2)], _S1.data_0[int(1)][int(2)], _S1.data_0[int(2)][int(2)], _S1.data_0[int(3)][int(2)], _S1.data_0[int(0)][int(3)], _S1.data_0[int(1)][int(3)], _S1.data_0[int(2)][int(3)], _S1.data_0[int(3)][int(3)]);
}


#line 13 "tri.vert.slang"
struct Output_0
{
    float4 Color_0 [[user(TEXCOORD)]];
    float4 Position_0 [[position]];
};


#line 6
struct vertexInput_0
{
    float3 Position_1 [[attribute(0)]];
    float4 Color_1 [[attribute(1)]];
};


#line 6
struct SLANG_ParameterGroup_UBO_natural_0
{
    _MatrixStorage_float4x4_ColMajornatural_0 transform_0;
};


#line 19
[[vertex]] Output_0 mainf(vertexInput_0 _S2 [[stage_in]], uint instance_0 [[instance_id]], SLANG_ParameterGroup_UBO_natural_0 constant* UBO_0 [[buffer(0)]])
{
    thread Output_0 output_0;
    (&output_0)->Color_0 = _S2.Color_1;
    thread float3 tpos_0 = _S2.Position_1;
    tpos_0.x = tpos_0.x + float(instance_0) * 10.0;
    (&output_0)->Position_0 = (((float4(tpos_0, 1.0)) * (unpackStorage_0(UBO_0->transform_0))));
    return output_0;
}

