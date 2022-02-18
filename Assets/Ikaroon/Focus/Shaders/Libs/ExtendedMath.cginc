float inverseLerp(float a, float b, float val) {
	return (val - a)*(1 / (b - a));
}

float step(float val, float stepSize) {
	return round(val / stepSize, 0)*stepSize;
}