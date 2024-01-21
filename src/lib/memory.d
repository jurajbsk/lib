module lib.memory;
version(LDC) import ldc.attributes;
else {
	struct allocSize {long sizeArgIdx; long numArgIdx;}
}

nothrow @safe:

@allocSize(0) void* _malloc(size_t size) @trusted
{
	version(Windows) {
		void* ptr = VirtualAlloc(null, size, COMMIT, READWRITE);
	}
	return ptr;
}
/// Returns allocated memory, minimum size specified by the argument
T[] malloc(T)(size_t size)
{
	//static if(is(T : immutable dchar)) size++;

	T* ptr = cast(T*) _malloc(size * T.sizeof);
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
else alias _alloca = _malloc;
/// Allocates memory on the stack, freed when function
T[] alloca(T)(size_t size)
{
	T* ptr = cast(T*) _alloca(size * T.sizeof);
	return ptr[0..size];
}

/// A unique pointer for automatic heap memory management
@safe pure struct uniqptr(T0) {
	enum bool isArray = is(T0:U[], U);
	static if(isArray) {
		alias T = T0;
	}
	else {
		alias T = T0*;
	}

	T trunk;
	alias trunk this;

	void freePtr()
	{
		static if(isArray) auto ptr = &trunk[0];
		else auto ptr = trunk;
		
		if(ptr) {
			free(ptr);
		}
	}
	void assignPtr(R)(R value)
	{
		static assert(!is(R : uniqptr));
		trunk = cast(T) value;
	}

	this(R)(R value)
	{
		assignPtr(value);
	}
	~this()
    {
		freePtr();
	}
	void opAssign(T value)
    {
		freePtr();
		assignPtr(value);
	}
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

unittest
{
	uniqptr!(int[]) foo = malloc!int(5);
	foo[] = 2;
	int[5] test = [2,2,2,2,2];
	assert(foo == test);
	free(foo.ptr);

	uniqptr!long bar = malloc!long;
	*bar = 5;
	assert(*bar == 5);
	free(bar);
}