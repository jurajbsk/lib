module lib.sys.windows.winmain;

mixin template WinMain() {
	pragma(linkerDirective, "/subsystem:windows");
	
	pragma(linkerDirective, "/entry:wmain");
	extern(C) int wmain() {
		import lib.sys.windows.kernel32 : TlsSetValue;
		TlsSetValue(0);
		return main();
	}

	debug {
	}
	else version(D_Optimized) {
		pragma(linkerDirective, "/MERGE:.rdata=. /MERGE:.pdata=. /MERGE:.text=.");
		pragma(linkerDirective, "/SECTION:.,ER");
		pragma(linkerDirective, "/ALIGN:16");
	}
}