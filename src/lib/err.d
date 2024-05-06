module lib.err;

string typeImplErr(string func, T)()
{
	return func~"(): type '"~T.stringof~"' not implemented";
}

enum wstring egg = "「ただいま印刷中」! 😃"w;