module lib.memory.list;
import lib.memory.alloc;

/// Dynamically-sized list, capacity aligned with pages
struct List(T, float growfactor = 2) {
	T[] _array;
	alias _array this;
	size_t _capacity;

	size_t capacity() => _capacity/T.sizeof;
	size_t byteSize(size_t size) => size * T.sizeof;

	void reserveExact(size_t byteSize)
	{
		if(!_array.ptr) {
			size_t growSize = roundUpToPage(byteSize);
			_array = (cast(T*)_malloc(growSize))[0.._array.length];
			_capacity = growSize;
		}
		else {
			size_t growSize = _capacity;
			_array = (cast(T*)_realloc(_array.ptr, growSize, _capacity))[0.._array.length];
			_capacity += growSize;
		}
	}
	void reserve(size_t size)
	{
		size_t growSize;
		if(!_array.ptr) {
			growSize = size;
		}
		else {
			growSize = _capacity;
			while(growSize < byteSize(size)) {
				growSize = cast(size_t)(growSize*growfactor);
			}
		}
		reserveExact(growSize);
	}
	void add(T element = T())
	{
		if(byteSize(_array.length+1) > _capacity) {
			reserve(1);
		}
		_array = _array.ptr[0.._array.length+1];
		_array[$-1] = element;
	}
	void pop(size_t num)
	{
		_array = _array[0..$-num];
	}
	T pop()
	{
		T res = _array[$-1];
		pop(1);
		return res;
	}
	void clear()
	{
		if(!_array.ptr) {
			return;
		}
		_capacity = 0;

		free(_array.ptr);
		_array = null;
	}

	this(T[] arr)
	{
		_array = arr[0..0];
		_capacity = byteSize(arr.length);
	}
	List!T opAssign(T[] arr)
	{
		this = List!T(arr);
		return this;
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