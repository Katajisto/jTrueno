struct Input
{
    float3 Position : TEXCOORD0;
    float4 Color : TEXCOORD1;
    float2 UV : TEXCOORD2;
};

struct Output
{
    float4 Color: TEXCOORD0;
    float2 UV : TEXCOORD1;
    float4 Position : SV_Position;
};

Output main(Input input)
{
    Output output;
    output.Position = float4(input.Position, 1.0);
    output.Color = float4(input.Color);
    output.UV = input.UV;
    return output;
}
