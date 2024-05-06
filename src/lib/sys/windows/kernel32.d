module lib.sys.windows.kernel32;

mixin template dynamicLoad(string fileName, string moduleName)
{
	void moduleInit() nothrow @trusted
	{
		static bool used = false;
		if(used) return;
		used = true;
		void* libPtr = LoadLibraryA(fileName.ptr);
		// this loads all function pointers in this module
		static foreach (string thing; __traits(derivedMembers, mixin(moduleName)))
		{
			static if (is(typeof(*mixin(thing)) == function)) // "thing" must be function pointer
			{
				mixin(thing) = cast(typeof(mixin(thing))) GetProcAddress(libPtr, thing);
			}
		}
	}
}

extern(Windows) nothrow @safe:
void* GetModuleHandleA(const char* moduleName = null);
void* LoadLibraryA(const char* libFileName);
alias winFuncter = extern(Windows) long function() nothrow;
winFuncter GetProcAddress(void* dll, const char* funcName);
bool QueryPerformanceCounter(out ulong perfCount);
pure bool QueryPerformanceFrequency(out ulong perfFreq);
void Sleep(uint ms);
pure void GetSystemInfo(out SYSTEM_INFO sysInfo);
struct SYSTEM_INFO {
	union {
		uint dwOemId;
		struct {
			ushort cpuArchitecture;
			ushort _reserved;
		}
	}
	uint pageSize;
	void* minAppAddr;
	void* maxAppAdrr;
	uint* activeCpuMask;
	uint cpuCount;
	uint cpuType;
	uint allocGranularity;
	ushort cpuLevel;
	ushort cpuRevision;
}
bool WriteFile(void* fileHndl, const char* msg, uint toWrite, uint* written, OVERLAPPED* overlapped = null);
struct OVERLAPPED {
	ulong* internal;
	ulong* internalHigh;
	union {
		struct {
			uint offset;
			uint offsetHigh;
		}
		void* pointer;
	}
	void* eventHndl;
}
void* GetStdHandle(uint stdHndlNum);
bool WriteConsoleA(void* consoleOutput, const char* msg, uint length, uint* written, void* reserved);
bool WriteConsoleW(void* consoleOutput, const wchar* msg, uint length, uint* written, void* reserved);