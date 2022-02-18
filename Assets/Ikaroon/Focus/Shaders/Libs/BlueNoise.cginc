sampler2D _BlueNoise;
float4 _BlueNoise_TexelSize;

float4 SampleNoise(float4 screenPos) {
	if (screenPos.w == 0) {
		screenPos.w = 1;
	}
	float2 noisePos = ((screenPos.xy / screenPos.w) * 0.5 + 0.5) * _BlueNoise_TexelSize.xy * _ScreenParams.xy;
	return tex2D(_BlueNoise, noisePos.xy * 2);
}