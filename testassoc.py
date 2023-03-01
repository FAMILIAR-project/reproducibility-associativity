import argparse
from random import random, seed

def associativity_test() -> bool:
    x = random(); y = random(); z = random()
    return x+(y+z) == (x+y)+z

def proportion(number: int, seed_val: int) -> int:
    seed(seed_val)
    ok = 0
    for i in range(number):
        ok += associativity_test()
    return ok*100/number

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Associativity test with seed.')
    parser.add_argument('--seed', type=int, required=True, help='Seed value')
    parser.add_argument('--number', type=int, default=10000, help='Number of tests')
    args = parser.parse_args()

    print(str(proportion(args.number, args.seed))+"%")

