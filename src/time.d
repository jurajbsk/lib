module time;
version(Windows) import sys.windows.kernel32;

long freq()
{
	static ulong freq;
	version(Windows) {
		if(!freq) QueryPerformanceFrequency(freq);
	}
	return freq;
}
long ticks()
{
	ulong ticks;
	version(Windows) {
		QueryPerformanceCounter(ticks);
	}
	return ticks;
}
void sleep(uint time)
{
	version(Windows) {
		Sleep(time);
	}
}