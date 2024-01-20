module lib.math;

///Returns the higher argument
T max(T)(T num1, T num2)
{
	return (num1 > num2) ? num1 : num2;
}

///Returns the lower argument
T min(T)(T num1, T num2)
{
	return (num1 < num2) ? num1 : num2;
}