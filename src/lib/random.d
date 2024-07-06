module lib.random;
import lib.time;

struct RNG {
	uint function(ref uint seed) randAlgo;
	uint seed;
	void makeSeed() {
		seed = 0;
	}
	uint random(uint cap) {
		return randAlgo(seed) % cap;
	}
}

immutable RNG CRand = {
	randAlgo: (ref uint seed){
		uint result;

		seed *= 1_103_515_245;
		seed += 12_345;
		result = (seed / 65_536) % 2048;

		seed *= 1_103_515_245;
		seed += 12_345;
		result <<= 10;
		result ^= (seed / 65_536) % 1024;

		seed *= 1_103_515_245;
		seed += 12_345;
		result <<= 10;
		result ^= (seed / 65_536) % 1024;
		return result;
	}
};