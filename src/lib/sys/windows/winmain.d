module lib.sys.winmain;

mixin template WinMain() {
	pragma(linkerDirective, "/subsystem:windows");
	
	version(LDC) {
		pragma(linkerDirective, "/entry:wmainCRTStartup");
		extern(C) int wmain() {return main();}
	}
	else {
		pragma(linkerDirective, "/entry:mainCRTStartup");
	}
}