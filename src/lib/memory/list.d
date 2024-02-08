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
		size *= T.sizeof;
		if(!array.ptr) {
			size_t growsize = roundToPage(size);
			array = cast(T[]) _malloc(growsize)[0..size];
			_capacity = growsize;
		}
		else {
			size_t growsize = {
				size_t res = _capacity;
				while(res < size) {
					res = cast(size_t)(res*growfactor);
				} return res;
			}();
			array = cast(T[]) _realloc(array.ptr, growsize, _capacity)[0..array.length+size];
			_capacity += growsize;
		}
	}
	void add(T element) @trusted
	{
		if((array.length+1)*T.sizeof > _capacity) {
			reserve(1);
		}
		else array = array.ptr[0..array.length+1];

		array[$-1] = element;
	}
	void clear() @trusted
	{
		if(!array.ptr) return;
		_capacity = 0;
		free(array.ptr);
	}

	this(size_t size)
	{
		reserve(size);
	}
	typeof(this) opBinary(string op:"~")(T rhs) => add(rhs);
	~this() => clear();
}

unittest
{
	List!long foo;
	foo.add(long.min);
	foo.add(long.max);
	assert(foo.length == 2);
	assert(foo[$-1] == long.max);
}