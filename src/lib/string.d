module lib.string;
import lib.err;

// Needs to be a constant-sized array, size changes based on T
string toString(T)(T arg, char[] buffer)
{
	static if(is(immutable(T) : string) || is(immutable(T) : wstring)) {
		return arg;
	}
	
	else static if(is(T : long)) {
		// max size: ~31
		bool start;
		if(arg < 0) {
			buffer[0] = '-';
			arg *= -1;
			start = 1;
		}

		ubyte len = 1;
		for(T num = arg; num > 10; num /= 10) {
			len++;
		}
		buffer = buffer[0..len];
		foreach_reverse(i; start .. len+start) {
			buffer[i] = arg%10 + '0';
			arg /= 10;
		}
		return cast(string)buffer;
	}
	else static if(is(T == enum)) {
		enum string[] _enumTable = [__traits(allMembers, T)];
		string[_enumTable.length] enumTable = _enumTable;
		if(arg < enumTable.length) {
			return enumTable[arg];
		}
		else {
			return cast(long)arg;
		}
	}
	else {
		static assert(0, typeImplErr!(__FUNCTION__, T));
	}
}

string parseCStr(char* cstr)
{
	uint i;
	while(cstr[i] != '\0') {
		i++;
	}
	return cast(string)cstr[0..i];
}