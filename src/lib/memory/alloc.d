module lib.memory.alloc;
version(LDC) import ldc.attributes;
else {
	struct allocSize {long sizeArgIdx; long numArgIdx;}
}
version(Posix) import lib.sys.linux;

uint getPageSize()
{
	version(Windows) {
		import lib.sys.windows.kernel32;
		SYSTEM_INFO si;
		GetSystemInfo(si);
		uint res = si.pageSize;
	}
	return res;
}
size_t roundUpToPage(size_t size)
{
	return size + getPageSize - (size % getPageSize);
}
size_t roundDownToPage(size_t size)
{
	return size - (size % getPageSize);
}
uint getAllocGranularity()
{
	version(Windows) {
		import lib.sys.windows.kernel32;
		SYSTEM_INFO si;
		GetSystemInfo(si);
		uint res = si.allocGranularity;
	}
	return res;
}

@allocSize(0) void* _malloc(size_t size, void* startPtr=null)
{
	version(Windows) {
		void* ptr = VirtualAlloc(startPtr, size, RESERVE|COMMIT, READWRITE);
	}
	else version(Posix) {
		// mmap
		void* ptr = syscall(9, null, size, cast(int)1|2, cast(int)0);
	}
	return ptr;
}
/// Returns allocated memory, minimum size specified by the argument
T[] malloc(T)(size_t size = 1)
{
	//static if(is(T : immutable dchar)) size++;

	T* ptr = cast(T*) _malloc(size * T.sizeof);
	return ptr[0..size];
}

@allocSize(1) void* _realloc(void* ptr, size_t size, size_t cursize)
{
	void* oldptr = _malloc(size, ptr);
	if(oldptr) {
		return oldptr;
	}

	ubyte* newptr = cast(ubyte*) _malloc(size);

	size_t min = (size > cursize)? cursize : size;
	foreach(i; 0..min) {
		newptr[i] = (cast(ubyte*)ptr)[i];
	}
	free(ptr);
	
	return newptr;
}
/// Reallocates memory
T[] realloc(T)(T[] block, size_t size)
{
	if(roundDownToPage(block.length * T.sizeof) >= size * T.sizeof) {
		return block[0..size];
	}
	
	T* ptr = cast(T*) _realloc(block.ptr, size*T.sizeof, block.length*T.sizeof);
	return ptr[0..size];
}
/// Frees allocated memory
void free(void* block)
{
	version(Windows) {
		enum : uint {
			DECOMMIT = 0X4000,
			RELEASE = 0X8000
		}
		bool errCode = VirtualFree(block, 0, RELEASE);
	}
}
version(LDC) pragma(LDC_alloca) void* _alloca(size_t size) pure;
/// Allocates memory on the stack, freed when function
T[] alloca(T)(size_t size)
{
	version(LDC) {
	T* ptr = cast(T*) _alloca(size * T.sizeof);
	return ptr[0..size];
	}
	else static assert(0, "You need LDC2 to use alloca()");
}

version(Windows) extern(Windows) {
	void* VirtualAlloc(void* startAddress=null, size_t size, uint allocFlag, uint protectFlag);
	enum : uint {
		COMMIT = 0x1000,
		RESERVE = 0x2000
	}
	enum : uint {
		NOACCESS = 0x1,
		READONLY = 0x2,
		READWRITE = 0x4
	}
	bool VirtualFree(const void* address, size_t size = 0, uint flags);
	struct SEC_ATTRS {
		uint length;
		void* secDesc;
		bool inherit;
	}
	void* CreateFileMappingA(void* fileHndl, SEC_ATTRS* secAttrs, uint flags, uint maxSizeHigh, uint maxSizeLow, char* name=null);
	void* MapViewOfFile(void* fileHndl, uint flags, uint fileOffsetHigh=0, uint fileOffsetLow=0, size_t sizeToMap=0);
	bool UnmapViewOfFile(void* basePtr);
	struct MEMORY_BASIC_INFO {
		void* basePtr;
		void* basePage;
		uint allocProtect;
		ushort partitionId;
		size_t regionSize;
		uint state;
		uint protect;
		uint type;
	}
	size_t VirtualQuery(void* basePtr, out MEMORY_BASIC_INFO infoBuff, size_t buffSize=MEMORY_BASIC_INFO.sizeof);
}

unittest
{
	// array
	int[] foo = malloc!int(3);
	assert(foo.length == 3);
	foo = realloc(foo, 1);
	assert(foo.length == 1);

	// "large" allocs
	byte[] bar = malloc!byte(2*getPageSize);
	// in-place realloc
	void* oldptr = bar.ptr;
	bar = realloc(bar, bar.length-5);
	assert(bar.ptr == oldptr);
	// out-of-place realloc
	bar[5] = 5;
	bar = realloc(bar, bar.length*3);
	assert(bar[5] == 5);

	// free
	free(foo.ptr);
	free(bar.ptr);
}