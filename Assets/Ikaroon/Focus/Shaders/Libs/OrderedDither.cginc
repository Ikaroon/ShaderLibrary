static const float DITHER_LOOKUP[16] = {
	1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
	13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
	4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
	16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
};

void DitherVisiblity(float4 screenPos, float visiblity) {
	if (screenPos.w == 0) {
		screenPos.w = 1;
	}
	float2 noisePos = ((screenPos.xy / screenPos.w) * 0.5 + 0.5) * _ScreenParams.xy;
	int x = clamp(fmod(noisePos.x * 2, 4), 0, 3);
	int y = clamp(fmod(noisePos.y * 2, 4), 0, 3);

	clip(visiblity - DITHER_LOOKUP[x + y * 4]);
}