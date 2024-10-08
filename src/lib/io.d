module lib.io;

alias File = void;

File* getStdHndl(uint stdnum) {
	version(Windows) {
		import lib.sys.windows.kernel32;
		File* file = GetStdHandle(uint.max - (10+stdnum));
	}
	return file;
}

struct _0Std(uint stdnum) {
	File* _stdHandle;
	File* stdHandle() {
		if(!_stdHandle) {
			_stdHandle = getStdHndl(stdnum);
		}
		return _stdHandle;
	}
	alias stdHandle this;
}

File* stdin() {
	static _0Std!0 file;
	return file;
}
File* stdout() {
	static _0Std!1 file;
	return file;
}
File* stderr() {
	static _0Std!2 file;
	return file;
}
void writeA(File* file, string msg)
{
	version(Windows) {
		import lib.sys.windows.kernel32;
		WriteFile(file, msg.ptr, cast(uint)msg.length, null);
	}
}
void writeW(File* file, wstring msg)
{
	version(Windows) {
		import lib.sys.windows.kernel32;
		WriteConsoleW(file, msg.ptr, cast(uint)msg.length, null, null);
	}
}

import lib.string;
void fwrite(S...)(File* outFile, S args)
{
	void writeOut(string msg) => writeA(outFile, msg);

	static foreach(arg; args) {{
		alias argType = typeof(arg);
		static if(is(typeof(arg) == U*, U))
		{
			static if(is(U == void)) {
				fwrite(outFile, cast(size_t)arg);
			}
			else
			{
				if(arg) {
					fwrite(outFile, *arg);
				}
				else writeOut("null");
			}
		}
		// else static if(is(immutable(argType) : wstring)) {
		// 	writeW(stdout, arg);
		// }
		else static if(is(immutable(argType) : immutable(char)) && !is(argType == bool) && !is(argType == enum))
		{
			writeOut(cast(string)(&arg)[0..1]);
		}
		else static if(is(argType == struct) || is(argType == union))
		{
			string header = __traits(identifier, argType) ~ "(";
			writeOut(header);
			enum string[] members = [__traits(allMembers, argType)];
			static foreach(i, membStr; members)
			{{
				auto member = __traits(getMember, arg, membStr);
				if(is(typeof(member) == return) || is(typeof(member) == typeof(arg))) {
					// member is func or __ctor!
				}
				else {
					if(i > 0) {
						writeOut(", ");
					}
					if(is(typeof(member) : U[], U : wchar)) {
						fwrite(outFile, '"', member, '"');
					}
					else {
						fwrite(outFile, member);
					}
				}
			}}
			writeOut(")");
		}
		else static if(is(argType : void[]))
		{
			if(arg.ptr == null) {
				writeOut("null");
				return;
			}
			writeOut("[");
			foreach(i, element; arg) {
				if(i > 0) {
					writeOut(", ");
				}
				fwrite(outFile, element);
			}
			writeOut("]");
		}
		else {
			char[64] buf;
			writeOut(toString(arg, buf));
		}
	}}
}

void write(S...)(S args) => fwrite(stdout, args);
void writeln(S...)(S args) => write(args, '\n');

unittest
{
	struct Test {
		bool a=true;
		Test* t;
		string s="test";
	}
	Test test;
	writeln(test, " 「ただいま印刷中」! 😃 "w, 51_235);
}