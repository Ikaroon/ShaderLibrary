#define FOCUS_OLD_BOUND 0
#define FOCUS_NEW_BOUNDS 1

float4 FOCUS_BOUNDS_X;
float4 FOCUS_BOUNDS_Y;
float4 FOCUS_BOUNDS_Z;

float4 FOCUS_DATA;

float InverseLerp(float a, float b, float val) {
	return (val - a) * (1 / (b - a));
}

float StompArea(float a, float b, float val) {
	if (val > min(a,b) && val < max(a,b)) {
		return 0;
	}
	if (val < min(a,b)) {
		return val - a;
	}
	if (val > max(a,b)) {
		return val + b;
	}
	return val;
}

float3 FocusAreaOffset(float3 pos, float3 offset, int boundIndex) {

	int realIndex = clamp(boundIndex, 0, 1);
	float xArea = InverseLerp(FOCUS_BOUNDS_X[realIndex], FOCUS_BOUNDS_X[realIndex + 2], pos.x + offset.x);
	float yArea = InverseLerp(FOCUS_BOUNDS_Y[realIndex], FOCUS_BOUNDS_Y[realIndex + 2], pos.y + offset.y);
	float zArea = InverseLerp(FOCUS_BOUNDS_Z[realIndex], FOCUS_BOUNDS_Z[realIndex + 2], pos.z + offset.z);

	return float3(xArea, yArea, zArea);

}

float FocusAreaMaxOffset(float3 pos, float3 offset, int boundIndex) {

	float3 overlay = FocusAreaOffset(pos, offset, boundIndex);
	return max(abs(StompArea(0, 1, overlay.x)), max(abs(StompArea(0, 1, overlay.y)), abs(StompArea(0, 1, overlay.z))));

}

bool InsideFocusArea(float3 pos, float3 offset, int boundIndex) {
	float overlay = FocusAreaMaxOffset(pos, offset, boundIndex);
	return abs(overlay) == 0;
}



