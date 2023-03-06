import subprocess

import numpy as np

GNUMBER_GENERATIONS=100
REPEAT=10
CSV_SEPARATOR=","

COLUMN_NAMES = ["Language", "Library", "System", "Compiler", "VariabilityMisc", "EqualityCheck", "NumberGenerations", "min", "max", "mean", "std"]

def print_column_names():
    # Print column names with separator, except for last element
    for i, col in enumerate(COLUMN_NAMES):
        if i < len(COLUMN_NAMES) - 1:
            print(col + CSV_SEPARATOR, end="")
        else:
            print(col)
    print()

def print_variant_results(variant_info, result):
    for k in result.keys():
        variant_info[k] = result[k]
    for i, col in enumerate(COLUMN_NAMES):
        if i < len(COLUMN_NAMES) - 1:
            if col in variant_info:
                print(f"{variant_info[col]}{CSV_SEPARATOR}", end="")
            else:
                print(f"{CSV_SEPARATOR}", end="")
        else:
            if col in variant_info:
                print(f"{variant_info[col]}")
            else:
                print(f"{CSV_SEPARATOR}")
    print()

def test_PY_variants(test_name, ngen, seed=None):
    variant_info = {
    "Language": "Python",
    "Library": "std",
    "System" : "linux",
    "Compiler": "",
    "VariabilityMisc": "",
    "NumberGenerations": ngen,
    "EqualityCheck": test_name,
    }

    if seed is not None:
        variant_info["VariabilityMisc"] = f"seed {seed}"
    else:
        variant_info["VariabilityMisc"] = "no seed"

    cmd_args = ["python", "testassoc.py", "--number", str(ngen), "--equality-check", test_name]
    if seed is not None:
        cmd_args.extend(["--seed", str(seed)])
    cmd_str = " ".join(cmd_args)
    result = analyze_results(REPEAT, cmd_str)
    print_variant_results(variant_info, result)
   
def analyze_results(repeat, cmd_str):
    assert(repeat > 0)
    results = []
    for i in range(repeat):
        result = subprocess.run(cmd_str, shell=True, capture_output=True, text=True)
        results.append(result.stdout.strip())
    # compute min, max, mean, std of results and store them in a dictionary
    # each element of results being a string ending with % 
    results = [float(r.replace("%", "")) for r in results]
    res = {
        "min": np.min(results),
        "max": np.max(results),
        "mean": np.mean(results), # assume repeat > 0
        "std": np.std(results),
    }
    return res

print_column_names()

test_PY_variants("associativity", GNUMBER_GENERATIONS)
test_PY_variants("mult-inverse", GNUMBER_GENERATIONS)
test_PY_variants("mult-inverse-pi", GNUMBER_GENERATIONS)

test_PY_variants("associativity", GNUMBER_GENERATIONS, 42)
test_PY_variants("mult-inverse", GNUMBER_GENERATIONS, 42)
test_PY_variants("mult-inverse-pi", GNUMBER_GENERATIONS, 42)
