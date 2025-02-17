cbuffer UBO : register(b0, space1)
{
    float4x4 transform;
};

struct Input
{
    float3 Position : TEXCOORD0;
    float4 Color : TEXCOORD1;
    uint instance: SV_InstanceID;
};

struct Output
{
    float4 Color : TEXCOORD0;
    float4 Position : SV_Position;
};

Output mainf(Input input)
{
    Output output;
    output.Color = input.Color;
    float3 tpos = input.Position;
    tpos.x += input.instance * 10.0;
    output.Position = mul(transform, float4(tpos, 1.0f));
    return output;
}
