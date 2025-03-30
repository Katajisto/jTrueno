struct SpriteInstanceData
{
    float4 Position;  // x, y, width, height
    float4 UV;       // u1, v1, u2, v2
    float4 color;       // u1, v1, u2, v2
};

StructuredBuffer<SpriteInstanceData> instanceData : register(t0, space0);

struct Input
{
    float3 Position : TEXCOORD0;
    float2 TexCoord : TEXCOORD1;
    uint InstanceIndex : SV_InstanceID;
};

struct Output
{
    float2 TexCoord : TEXCOORD0;
    float4 Color : TEXCOORD1;
    float4 Position : SV_Position;
};

Output main(Input input)
{
    Output output;
    SpriteInstanceData instance = instanceData[input.InstanceIndex];
    
    // Transform vertex position based on instance data
    float2 pos = input.Position.xy;
    pos.x = pos.x * instance.Position.z + instance.Position.x;
    pos.y = pos.y * instance.Position.w + instance.Position.y;
    
    // Transform UV coordinates based on instance data
    float2 uv = input.TexCoord;
    uv.x = uv.x * (instance.UV.z - instance.UV.x) + instance.UV.x;
    uv.y = uv.y * (instance.UV.w - instance.UV.y) + instance.UV.y;
    
    output.TexCoord = uv;
    output.Position = float4(pos, 0.0f, 1.0f);
    output.Color = instance.color;
    return output;
}
