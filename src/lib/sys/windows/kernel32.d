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
bool QueryPerformanceFrequency(out ulong perfFreq);
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

//alias windowsFunction = extern(Windows) nothrow __gshared;