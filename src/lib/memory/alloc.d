module lib.memory.alloc;
version(LDC) import ldc.attributes;
else {
	struct allocSize {long sizeArgIdx; long numArgIdx;}
}

@safe nothrow pure{
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

@allocSize(0) void* _malloc(size_t size) @trusted
{
	version(Windows) {
		void* ptr = VirtualAlloc(null, size, COMMIT, READWRITE);
	}
	return ptr;
}
@allocSize(0) void* _malloc(size_t size, void* startAddress) @trusted
{
	version(Windows) {
		void* ptr = VirtualAlloc(startAddress, size, RESERVE||COMMIT, READWRITE);
	}
	return ptr;
}
/// Returns allocated memory, minimum size specified by the argument
T[] malloc(T)(size_t size = 1) @trusted
{
	//static if(is(T : immutable dchar)) size++;

	T* ptr = cast(T*) _malloc(size * T.sizeof);
	return ptr[0..size];
}

@allocSize(1) void* _realloc(void* ptr, size_t size, size_t cursize) @trusted
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
T[] realloc(T)(T[] block, size_t size) @trusted
{
	if(roundDownToPage(block.length * T.sizeof) >= size * T.sizeof) {
		return block[0..size];
	}
	
	T* ptr = cast(T*) _realloc(block.ptr, size*T.sizeof, block.length*T.sizeof);
	return ptr[0..size];
}
/// Frees allocated memory
void free(void* block) @trusted
{
	version(Windows) {
		enum : uint {
			DECOMMIT = 0X4000,
			RELEASE = 0X8000
		}
		bool errCode = VirtualFree(block, 0, RELEASE);
	}
}
version(LDC) pragma(LDC_alloca) void* _alloca(size_t size) @trusted pure;
/// Allocates memory on the stack, freed when function
T[] alloca(T)(size_t size) @trusted
{
	version(LDC) {
	T* ptr = cast(T*) _alloca(size * T.sizeof);
	return ptr[0..size];
	}
	else static assert(0, "Sorry bud, you'll need LDC2 to use alloca()");
}

nothrow __gshared:
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
}
else version(Posix) extern(C)
{
	void* mmap64(void*, size_t, int, int, int, long);
	void* mmap(void*, size_t, int, int, int, long);
}
}

unittest
{
	int[] foo = malloc!int(3);
	assert(foo.length == 3);
	foo = realloc(foo, 1);
	assert(foo.length == 1);

	byte[] bar = malloc!byte(getPageSize);
	void* barptr = &bar[0];

	bar = realloc(bar, bar.length-5);
	assert(&bar[0] == barptr); //check smaller sizes realloc'ed in-place
	import std;
	bar = realloc(bar, getPageSize*3);
	bar[$-1] = 5;
	assert(bar[getPageSize*3-1] == 5);
}