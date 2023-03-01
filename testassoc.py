from random import random, seed
def associativity_test() -> bool:
    x = random(); y = random(); z = random()
    return x+(y+z) == (x+y)+z
def proportion(number: int) -> int:
    ok = 0
    for i in range(number):
        ok += associativity_test()
    return ok*100/number

seed(int(input('Seed: ')))
print(str(proportion(10000))+"%")
