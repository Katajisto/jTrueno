struct SpriteData
{
    float4 Color;
    float3 Position;
};

cbuffer UBO : register(b0, space1)
{
    float4x4 transform : packoffset(c0);
};

struct Input
{
    float3 Position : TEXCOORD0;
    float4 Color : TEXCOORD1;
    uint InstanceIndex : SV_InstanceID;
};

StructuredBuffer<SpriteData> databuf : register(t0, space0);

struct Output
{
    float4 Color : TEXCOORD0;
    float4 Position : SV_Position;
};

Output main(Input input)
{
    Output output;
    output.Color = databuf[input.InstanceIndex].Color;
    output.Position = mul(transform, float4(input.Position + databuf[input.InstanceIndex].Position, 1.0f));
    return output;
}
