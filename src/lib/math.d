module lib.math;

T max(T)(T num1, T num2)
{
	return (num1 > num2) ? num1 : num2;
}

T min(T)(T num1, T num2)
{
	return (num1 < num2) ? num1 : num2;
}