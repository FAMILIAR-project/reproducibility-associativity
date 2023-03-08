#include <iostream>
#include <random>
#include <cmath>
#include <string>
#include <algorithm>
#include <chrono>

enum class EqualityCheck {
    ASSOCIATIVITY = 0,
    MULT_INV = 1,
    MULT_INV_PI = 2
};

bool equality_test(EqualityCheck equality_check, double x, double y, double z) {
    switch(equality_check) {
        case EqualityCheck::ASSOCIATIVITY:
            return x+(y+z) == (x+y)+z;
        case EqualityCheck::MULT_INV:
            return (x * z) / (y * z) == x / y;
        case EqualityCheck::MULT_INV_PI:
            return (x * z * M_PI) / (y * z * M_PI) == (x / y);
    }
}

int proportion(int number, int seed_val, EqualityCheck equality_check) {
     /*
    Note of ChatGPT: The C++ implementation uses the Mersenne Twister random number generator (std::mt19937) from the C++ standard library 
    and the std::uniform_real_distribution to generate random double values in the range [0.0, 1.0].
    TODO: variation points: use a different random number generator, use a different distribution, use a different range, use a different number of samples
    */
    std::mt19937 generator(seed_val);
    std::uniform_real_distribution<double> distribution(0.0, 1.0);
    int ok = 0;
    for (int i = 0; i < number; i++) {
        double x = distribution(generator);
        double y = distribution(generator);
        double z = distribution(generator);
        ok += equality_test(equality_check, x, y, z);
    }
    return ok*100/number;
}

int main(int argc, char* argv[]) {
    int seed_val = std::chrono::system_clock::now().time_since_epoch().count(); // highly discussable, see eg https://simplecxx.github.io/2018/11/03/seed-mt19937.html 
    int number = 10000;
    EqualityCheck equality_check = EqualityCheck::ASSOCIATIVITY;
    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        if (arg == "--seed") {
            seed_val = std::stoi(argv[++i]);
        } else if (arg == "--number") {
            number = std::stoi(argv[++i]);
        } else if (arg == "--equality-check") {
            std::string equality_check_str = argv[++i];
            std::transform(equality_check_str.begin(), equality_check_str.end(), equality_check_str.begin(), ::tolower);
            if (equality_check_str == "associativity") {
                equality_check = EqualityCheck::ASSOCIATIVITY;
            } else if (equality_check_str == "mult-inverse") {
                equality_check = EqualityCheck::MULT_INV;
            } else if (equality_check_str == "mult-inverse-pi") {
                equality_check = EqualityCheck::MULT_INV_PI;
            } else {
                std::cerr << "Invalid --equality-check value." << std::endl;
                return 1;
            }
        }
    }

    std::cout << proportion(number, seed_val, equality_check) << "%" << std::endl;
    return 0;
}
