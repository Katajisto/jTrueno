Texture2D<float4> Texture : register(t0, space2);
SamplerState Sampler : register(s0, space2);


float4 main(float4 color: TEXCOORD0, float2 uv: TEXCOORD1) : SV_Target0
{
    // These are set this way if there is currently not a texture binding.
    if(uv.x < -3.999 && uv.y < -1.999) {
        return color;
    }
    return Texture.Sample(Sampler, uv) * color;
}
