module lib.memory.list;
import lib.memory.alloc;

/// Dynamically-sized list, capacity aligned with pages
struct List(T, float growfactor = 2) {
	T[] array;
	alias array this;
	size_t _capacity;

	size_t capacity() => _capacity/T.sizeof;
	size_t bytesize(size_t size) => size * T.sizeof;

	void reserveExact(size_t size)
	{
		if(__ctfe) {
			array.length += size;
			_capacity += bytesize(size);
			return;
		}

		if(!array.ptr) {
			size_t growsize = roundUpToPage(bytesize(size));
			array = cast(T[]) _malloc(growsize)[0..bytesize(size)];
			_capacity = growsize;
		}
		else {
			size_t growsize = _capacity;
			
			array = cast(T[]) _realloc(array.ptr, growsize, _capacity)[0..bytesize(array.length) + bytesize(size)];
			_capacity += growsize;
		}
	}
	void reserve(size_t size)
	{
		size_t growsize;
		if(!array.ptr) {
			growsize = size;
		}
		else {
			growsize = _capacity;
			while(growsize < bytesize(size)) {
				growsize = cast(size_t)(growsize*growfactor);
			}
		}
		reserveExact(growsize);
	}
	T* add(T element = T())
	{
		if(__ctfe) {
			array ~= element;
			_capacity += T.sizeof;
			return &array[$-1];
		}

		if((array.length+1)*T.sizeof > _capacity) {
			reserve(1);
		}
		else array = array.ptr[0..array.length+1];

		array[$-1] = element;
		return &array[$-1];
	}
	void clear()
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