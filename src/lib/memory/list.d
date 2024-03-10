module lib.memory.list;
import lib.memory.alloc;

@safe nothrow pure:
/// Dynamically-sized list, capacity aligned with pages
struct List(T, float growfactor = 2) {
	T[] array;
	alias array this;
	size_t _capacity;
	size_t capacity() => _capacity/T.sizeof;

	void reserveExactly(size_t size)
	{

	}
	void reserve(size_t size) @trusted
	{
		size_t bytesize = size * T.sizeof;

		if(__ctfe) {
			array.length += size;
			_capacity += bytesize;
			return;
		}

		if(!array.ptr) {
			size_t growsize = roundUpToPage(bytesize);
			array = cast(T[]) _malloc(growsize)[0..bytesize];
			_capacity = growsize;
		}
		else {
			size_t growsize = _capacity;
			while(growsize < bytesize) {
				growsize = cast(size_t)(growsize*growfactor);
			}
			array = cast(T[]) _realloc(array.ptr, growsize, _capacity)[0..array.length + bytesize];
			_capacity += growsize;
		}
	}
	void add(T element) @trusted
	{
		if(__ctfe) {
			array ~= element;
			_capacity += T.sizeof;
			return;
		}

		if((array.length+1)*T.sizeof > _capacity) {
			reserve(1);
		}
		else array = array.ptr[0..array.length+1];

		array[$-1] = element;
	}
	void clear() @trusted
	{
		if(!array.ptr) {
			return;
		}
		_capacity = 0;
		if(__ctfe) {
			array.length = 0;
			return;
		}

		free(array.ptr);
		array = null;
	}
}

unittest
{
	List!long foo;
	foo.add(long.min);
	foo.add(long.max);
	assert(foo.length == 2);
	assert(foo[$-1] == long.max);
}