float xBlurDistance;

Texture xTexture;
sampler WaterTextureSampler : register (s0) = sampler_state { Texture = <xTexture>; };

Texture yTexture;
sampler LosTextureSampler : register (s1) = sampler_state { Texture = <yTexture>; };

Texture yLosTexture;
sampler LosSampler : register (s2) = sampler_state { Texture = <yLosTexture>; };


Texture xWaterBumpMap;
sampler WaterBumpSampler  = 
sampler_state 
{ 
	Texture = <xWaterBumpMap>; 
	MagFilter = LINEAR; 
	MinFilter = LINEAR; 
	MipFilter = LINEAR; 
	AddressU = WRAP; 
	AddressV = WRAP;
};

float xWaveWidth;
float xWaveHeight;
float2 xWavePos;
float2 xBumpPos;

float4 main(float4 position : SV_Position, float4 color : COLOR0, float2 texCoord : TEXCOORD0) : COLOR0
{	
	float4 bumpColor = tex2D(WaterBumpSampler, texCoord+xWavePos+xBumpPos);
	bumpColor = (bumpColor + tex2D(WaterBumpSampler, texCoord-xWavePos*2.0f+xBumpPos))*0.5f;
	
	float2 samplePos = texCoord;
	
	samplePos.x+=(bumpColor.r-0.5f)*xWaveWidth;	
	samplePos.y+=(bumpColor.g-0.5f)*xWaveHeight;	

	float4 sample;
	sample = tex2D( WaterTextureSampler, float2(samplePos.x+xBlurDistance, samplePos.y+xBlurDistance));
	sample += tex2D( WaterTextureSampler, float2(samplePos.x-xBlurDistance, samplePos.y-xBlurDistance));
	sample += tex2D( WaterTextureSampler, float2(samplePos.x+xBlurDistance, samplePos.y-xBlurDistance));
	sample += tex2D( WaterTextureSampler, float2(samplePos.x-xBlurDistance, samplePos.y+xBlurDistance));	
	
	sample = sample * 0.25;
	
    return sample;
}

float4 main2(float4 position : SV_Position, float4 color : COLOR0, float2 texCoord : TEXCOORD0) : COLOR0
{    
	float2 lossamplePos = texCoord;
	
    float4 losColor = tex2D(LosSampler, lossamplePos);
    float4 texsample = tex2D(LosTextureSampler, lossamplePos);
    
    float4 outColor = float4((texsample.x * losColor.x), (texsample.y * losColor.y), (texsample.z * losColor.z), 1);
        
    return outColor;
}


technique LosShader
{
    pass Pass1
    {
        PixelShader = compile ps_4_0_level_9_1 main2();
    }
}

technique WaterShader
{
    pass Pass1
    {
        PixelShader = compile ps_4_0_level_9_1 main();
    }
}