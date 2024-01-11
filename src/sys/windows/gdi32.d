module sys.windows.gdi32;
import sys.windows.kernel32;

mixin dynamicLoad!("gdi32.dll", __MODULE__);

extern(Windows) nothrow __gshared:
bool function(void* objectHndl) DeleteObject;
void* function(const void* hndl) CreateCompatibleDC;
BITMAP* function(const void* handle, const BITMAPINFO* bmiPtr, uint usage, void** sectionHndl, void* hSection=null, uint offset=0) CreateDIBSection;
int function(const void* handle, int xDest, int yDest, int DestWidth, int destHeight, int xSrc, int ySrc, int srcWidth, int srcHeight, const void* imageBits, const BITMAPINFO* bmInfo,
             uint useBMIColours, uint rastOp) StretchDIBits;

struct RGBQUAD {
	ubyte blue;
	ubyte green;
	ubyte red;
	ubyte _reserved;
}
struct BITMAP {
	int type = 0;
	int width;
	int height;
	int widthBytes;
	int colourPlanes;
	int pixelBytes;
	void* bitmap;
}
struct BITMAPINFOHEADER {
	uint size = BITMAPINFOHEADER.sizeof;
	int width;
	int height;
	ushort planes = 1;
	ushort bitCount;
	clrCompress compression;
	uint imageSize;
	int XPixelperMeter;
	int YPixelperMeter;
	uint usedColours;
	uint importantColours;
}
struct BITMAPINFO {
	BITMAPINFOHEADER header;
	RGBQUAD[1] colours;
}
enum clrCompress {
	BI_RGB = 0,
	BI_RLE8,
	BI_RLE4,
	BI_BITFIELDS,
	BI_JPEG,
	BI_PNG
}
enum rasterOp : uint {
	BLACKNESS = 0x000042,
	NOTSRCERASE = 0x1100A6,
	NOTSRCCOPY = 0x330008,
	SRCERASE = 0x440328,
	DSTINVERT = 0x550009,
	PATINVERT = 0x5A0049,
	SRCINVERT = 0x660046,
	SRCAND = 0x8800C6,
	MERGEPAINT = 0xBB0226,
	MERGECOPY = 0xC000CA,
	SRCCOPY = 0xCC0020,
	SRCPAINT = 0xEE0086,
	PATCOPY = 0xF00021,
	PATPAINT = 0xFB0A09,
	WHITENESS = 0xFF0062
}