module lib.memory.uniqptr;
import lib.memory;

@safe nothrow pure:
/// A unique pointer (array!!!) for automatic heap memory management
struct uniqptr(T) {
	T[] base;
	alias base this;

	void freePtr() @trusted
	{
		T* ptr = base.ptr;
		
		if(ptr) {
			free(ptr);
		}
	}
	void assignPtr(R : T[])(R value)
	{
		base = value;
	}

	this(R)(R value)
	{
		assignPtr(value);
	}
	~this()
    {
		freePtr();
	}
	void opAssign(T[] value)
    {
		freePtr();
		assignPtr(value);
	}
}

unittest
{
	uniqptr!int foo = malloc!int(3);
	foo[] = 2;
	assert(foo == [2,2,2]);
	free(&foo[0]);
}