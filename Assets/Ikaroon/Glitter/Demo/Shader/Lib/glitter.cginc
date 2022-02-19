#include "snoise.cginc"

float invLerp(float a, float b, float x)
{
	return (x - a) * (1 / (b - a));
}

struct pixelData
{
	float3 position;
	float3 normal;
	float3 viewDirection;
	float viewDistance;
	float3 lightDirection;
};

float3 getGlitter(pixelData data, float noiseScale, float amplifierScale, float scaleOnDistance, float depth, float influence, float specularInfluence, float start, float end, float brightness, float3 color)
{
	// Noise map scale
	float scaleFactor = 1 + data.viewDistance * scaleOnDistance;
	float noiseMapScaleA = floor(noiseScale / scaleFactor * 10) / 10;
	float noiseMapScaleB = floor(noiseScale / (scaleFactor + scaleOnDistance * 5) * 10) / 10;
	float noiseMapScale = lerp(noiseMapScaleA, noiseMapScaleB, 0.5);

	// Noise map
	float3 noiseMapX = (data.position) * noiseMapScale;
	float3 noiseMapY = (data.position + float3(noiseMapScale, -noiseMapScale, 0)) * noiseMapScale;
	float3 noiseMapZ = (data.position + float3(0, noiseMapScale, noiseMapScale)) * noiseMapScale;
	float3 noiseMap = float3(snoise(noiseMapX), snoise(noiseMapY), snoise(noiseMapZ));

	// Amplifier map scale
	float amplifierMapScaleA = floor(amplifierScale / scaleFactor * 10) / 10;
	float amplifierMapScaleB = floor(amplifierScale / (scaleFactor + scaleOnDistance * 5) * 10) / 10;
	float amplifierMapScale = lerp(amplifierMapScaleA, amplifierMapScaleB, 0.5);

	// Amplifier map
	float3 amplifierMapX = (data.position + float3(0, 0, 1)) * amplifierMapScale;
	float3 amplifierMapY = (data.position + float3(0, 0, 2)) * amplifierMapScale * 10;
	float amplifierMap = (snoise(amplifierMapX) + snoise(amplifierMapY)) * 0.25 + 0.5;

	// Noise
	float noise = noiseMap * amplifierMap * depth;

	// Default reflection
	float3 defaultReflectionDirection = data.viewDirection - 2 * dot(data.viewDirection, data.normal) * data.normal;

	float reflectionAmount = dot(data.lightDirection, defaultReflectionDirection);
	reflectionAmount = saturate(reflectionAmount);

	// Glitter reflection
	float totalInfluence = lerp(influence, specularInfluence, reflectionAmount);
	float3 glitterReflectionDirection = normalize(defaultReflectionDirection + noise * totalInfluence);

	float glitterReflectionOffset = saturate(1 - dot(defaultReflectionDirection, glitterReflectionDirection));
	glitterReflectionOffset = saturate(invLerp(start, end, glitterReflectionOffset));

	float glitterReflectionAmount = dot(data.lightDirection, glitterReflectionDirection);
	glitterReflectionAmount = pow(saturate(glitterReflectionAmount), 2);

	// Colors
	float3 glitterCol = glitterReflectionOffset * glitterReflectionAmount * brightness * color;

	// Fade out on the backside of objects
	float lightStrength = saturate(dot(data.lightDirection, data.normal));
	return glitterCol * lightStrength;
}