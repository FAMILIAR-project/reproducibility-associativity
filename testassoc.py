# This code takes in a seed value and a number of tests and returns the proportion of tests that pass the equality test.
# The function equality_test() is used to test the associativity or multiplication inverse of the addition operation.
# The function proportion() is used to calculate the proportion of tests that pass the associativity test.
# The test is passed if the result of the test is true.
# The value of the seed is set using the seed() function.
# The value of the number is set to 10000 by default.

import argparse
from random import random, seed
import math
from enum import Enum

class EqualityCheck(Enum):
    ASSOCIATIVITY = 'associativity'
    MULT_INV = 'mult-inverse'
    MULT_INV_PI = 'mult-inverse-pi'

def equality_test(equality_check: EqualityCheck, x, y, z) -> bool:
    if equality_check == EqualityCheck.ASSOCIATIVITY:
        return x+(y+z) == (x+y)+z
    elif equality_check == EqualityCheck.MULT_INV:
        return (x * z) / (y * z) == x / y
    elif equality_check == EqualityCheck.MULT_INV_PI:
        return (x * z * math.pi) / (y * z * math.pi) == (x / y)

def proportion(number: int, seed_val: int, equality_check: EqualityCheck) -> int:
    seed(seed_val)
    ok = 0
    for i in range(number):
        x = random()
        y = random()
        z = random()
        ok += equality_test(equality_check, x, y, z)
    return ok*100/number

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Equality test with seed.')
    parser.add_argument('--seed', type=int, default=None, help='Seed value.')
    parser.add_argument('--number', type=int, default=10000, help='Number of tests')
    parser.add_argument('--equality-check', type=EqualityCheck, required=True, choices=list(EqualityCheck), help='Type of equality check')
    args = parser.parse_args()

    print(str(proportion(args.number, args.seed, args.equality_check))+"%")
