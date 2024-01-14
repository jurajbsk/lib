module lib.sys.windows.advapi32;
import lib.sys.windows.kernel32;

mixin dynamicLoad!("advapi32.dll", __MODULE__);

extern(Windows) nothrow __gshared:
bool function(char* stringBuffer, int* sizeBuffer) GetUserNameA;