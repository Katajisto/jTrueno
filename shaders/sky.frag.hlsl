float3 sky(float3 skypos, float3 sunpos) {
    
    float3 sunCol = float3(1.0, 1.0, 1.0);
    float3 sunHalo = float3(1.0, 1.0, 1.0);
    float3 horizonHalo = float3(1.0, 1.0, 1.0);
    float3 sunDisk = float3(1.0, 1.0, 1.0);
    float3 baseSky = float3(0.384, 0.8117, 0.9568);
    float3 topSky = float3(0.17, 0.4, 0.95);

    float sDist = dot(normalize(skypos), normalize(sunpos));

    float3 npos = normalize(skypos);


    float3 skyGradient = lerp(baseSky, topSky, clamp(skypos.y, 0.0, 0.7));

    float3 final = skyGradient;
    final += sunHalo.xyz * clamp((sDist - 0.95) * 10.0, 0.0, 0.8) * 0.2;

    // Sun disk
    if(sDist > 0.9997) {
        final = sunDisk.xyz * 5.0;
    }

    // Horizon halo
    final += lerp(horizonHalo.xyz, float3(0.0,0.0,0.0), clamp(abs(npos.y) * 80.0, 0.0, 1.0)) * 0.03;

    final = float3(final);

    return final;
}


float4 main(float3 skyDirection: TEXCOORD0) : SV_Target0
{
    return float4(sky(skyDirection, normalize(float3(1.0, 0.4, 0.2))), 1.0);
    //return float4(skyDirection.y + 0.3, 0.0, 0.0, 1.0);
}
