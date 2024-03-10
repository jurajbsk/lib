module lib.sys.windows.user32;
import lib.sys.windows.kernel32;

mixin dynamicLoad!("user32.dll", __MODULE__);

extern(Windows) @safe nothrow:

ushort function(const ref WindowClassEx windClass) RegisterClassExA;
enum : uint {
	OVERLAPPED = 0x0,
	MAXIMIZEBOX = 0x10000,
	MINIMIZEBOX = 0x20000,
	THICKFRAME = 0x40000,
	SYSMENU = 0x80000,
	CAPTION = 0xC00000,
	VISIBLE = 0x10000000,
	OVERLAPPEDWINDOW = OVERLAPPED | MAXIMIZEBOX | MINIMIZEBOX | THICKFRAME | SYSMENU | CAPTION,
	POPUP = 0x80000000
}
enum : uint {
	WINDOWEDGE = 0x00000100L
}
void* function(uint exStyle, const char* className, const char* windowName, uint style, int x, int y,
               int width, int height, void* parent, void* menu, const void* instance, void* createParam) CreateWindowExA;
void* function(void* winHndl) GetDC;
int function(void* winHndl, void* dcHndl) ReleaseDC;
bool function(Message* msg, void* winHndl, uint filterMin, uint filterMax) GetMessageA;
bool function(Message* msg, void* winHndl, uint filterMin, uint filterMax, PeekMessageFlag removeFlag) PeekMessageA;
enum PeekMessageFlag:uint {NOREMOVE = 0x0, REMOVE = 0x1, NOYIELD = 0x2}
bool function(Message* msg) TranslateMessage;
bool function(Message* msg) DispatchMessageA;
long function(void* handle, uint message, ulong wParameter, long lParameter) DefWindowProcA;
bool function(void* handle, out RECT rect) GetClientRect;
void* function(void* handle, const ref PAINTSTRUCT) BeginPaint;
bool function(void* handle, const ref PAINTSTRUCT) EndPaint;
void* function(void* cursorHndl) SetCursor;

enum int USEDEFAULT = 0x80000000;

struct POINT {
	int x;
	int y;
}
struct Message {
	void* handle;
	uint message;
	ulong wParam;
	long lParam;
	uint time;
	POINT point;
}
enum WM
{
	NULL = 0,
	CREATE = 1,
	DESTROY = 2,
	MOVE = 3,
	SIZE = 5,
	ACTIVATE = 6,
	SETFOCUS = 7,
	KILLFOCUS = 8,
	ENABLE = 10,
	SETREDRAW = 11,
	SETTEXT = 12,
	GETTEXT = 13,
	GETTEXTLENGTH = 14,
	PAINT = 15,
	CLOSE = 16,
	QUIT = 18,
	ACTIVATEAPP = 28,
	SETCURSOR = 32,
	MOUSEACTIVATE = 33
}
struct WindowClassEx {
	uint size = WindowClassEx.sizeof;
	uint style;
	extern(Windows) long function(void* handle, uint message, ulong wParameter, long lParameter) windowProc;
	int clsExtra;
	int wndExtra;
	void* instance;
	void* icon;
	void* cursor;
	void* background;
	const char* menuName;
	const char* className;
	void* smallIcon;
}
enum : uint {
	VREDRAW = 0x0001,
	HREDRAW = 0x0002,
	OWNDC = 0x0020
}
struct WinIconInfo {
	bool fIcon;
	size_t xHotspot;
	size_t yHotspot;
	void* maskBitmap;
	void* colourBitmap;
}
struct WinBitmapInfo {
	size_t type;
	size_t width;
	size_t height;
	size_t widthBytes;
	ushort cPlanes;
	ushort pixelBits;
	void* bitmapPtr;
}
struct RECT
{
	int left;
	int top;
	int right;
	int bottom;
}
struct PAINTSTRUCT
{
	void* handle;
	bool eraseBckgrnd;
	RECT paintRect;
	bool _restore;
	bool _incUpdate;
	ubyte[32] _rgbReserved;
}
struct CURSORINFO {
  uint size = CURSORINFO.sizeof;
  uint flags;
  void* hCursor;
  POINT ptScreenPos;
}