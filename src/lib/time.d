module lib.time;
@safe nothrow:

version(Windows) {
	import lib.sys.windows.kernel32;
}

ulong freq()
{
	ulong freq;
	version(Windows) {
		QueryPerformanceFrequency(freq);
	}
	return freq;
}
ulong ticks()
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