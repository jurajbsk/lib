module lib.time;
@safe nothrow:

version(Windows) {
	import lib.sys.windows.kernel32;
}

ulong getFreq()
{
	ulong freq;
	version(Windows) {
		QueryPerformanceFrequency(freq);
	}
	return freq;
}
ulong getTicks()
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