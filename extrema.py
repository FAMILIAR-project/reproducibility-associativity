from random import seed
from testassoc import proportion
mini = 100
maxi = 0
mini_seed = 0
maxi_seed = mini_seed
for s in range(mini_seed,10000):
    seed(s)
    p = proportion(1000)
    if p > maxi:
        maxi = p
        maxi_seed = s
        print("seed=",str(mini_seed)," p=",str(mini)+"%; seed=",str(maxi_seed)," p=",str(maxi)+"%")
    if p < mini:
        mini = p
        mini_seed = s
        print("seed=",str(mini_seed)," p=",str(mini)+"%; seed=",str(maxi_seed)," p=",str(maxi)+"%")

