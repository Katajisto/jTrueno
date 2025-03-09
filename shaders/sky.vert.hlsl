cbuffer UBO : register(b0, space1)
{
    float4x4 transform : packoffset(c0);
};

struct Input
{
    float3 Position : TEXCOORD0;
    float4 Color : TEXCOORD1;
};

struct Output
{
    float3 skyDirection: TEXCOORD0;
    float4 Position : SV_Position;
};

Output main(Input input)
{
    Output output;
    output.Position = mul(transform, float4(input.Position * -200.0, 1.0f));
    output.skyDirection = normalize(-input.Position);
    return output;
}
