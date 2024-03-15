module lib.sys.linux;
import ldc.llvmasm;

nothrow:

size_t syscall(Args...)(ptrdiff_t callId, Args args)
{
    static assert(args.length > 0, "syscall(): need at least 1 arg");
    static assert(args.length <= 6, "syscall(): too many args");

	version(X86_64)
	{
        enum reglist = ["{rdi}", "{rsi}", "{rdx}", "{r10}", "{r8}", "{r9}"];
        enum string registers = {
            string res;
            foreach(i; 0 .. args.length) {
                res ~= ","~reglist[i];
            } return res;
        }();

		return __asm!ulong("syscall",
        "={rax}, {rax}"~registers,
                callId, cast(ptrdiff_t)args);
	}
}