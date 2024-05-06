module lib.io;

enum File : void* {
	init = null
}

File getStdHndl(uint stdnum) {
	version(Windows) {
		import lib.sys.windows.kernel32;
		File file = cast(File) GetStdHandle(uint.max - (10+stdnum));
	}
	return file;
}

struct _0Std(uint stdnum) {
	File _stdHandle;
	File stdHandle() {
		if(!_stdHandle) {
			_stdHandle = getStdHndl(stdnum);
		}
		return _stdHandle;
	}
	alias stdHandle this;
}

File stdin() {
	static _0Std!0 file;
	return file;
}
File stdout() {
	static _0Std!1 file;
	return file;
}
File stderr() {
	static _0Std!2 file;
	return file;
}
void write(File file, string msg)
{
	version(Windows) {
		import lib.sys.windows.kernel32;
		WriteFile(file, msg.ptr, cast(uint)msg.length, null);
	}
}
void writeW(File file, wstring msg)
{
	version(Windows) {
		import lib.sys.windows.kernel32;
		WriteConsoleW(file, msg.ptr, cast(uint)msg.length, null, null);
	}
}
