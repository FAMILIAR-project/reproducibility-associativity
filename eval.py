import subprocess

import numpy as np

GNUMBER_GENERATIONS=100
REPEAT=10
CSV_SEPARATOR=","

COLUMN_NAMES = ["Language", "Library", "System", "Compiler", "VariabilityMisc", "EqualityCheck", "NumberGenerations", "min", "max", "std", "mean"]

def print_column_names():
    # Print column names with separator, except for last element
    for i, col in enumerate(COLUMN_NAMES):
        if i < len(COLUMN_NAMES) - 1:
            print(col + CSV_SEPARATOR, end="")
        else:
            print(col)

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


def analyze_results(repeat, cmd_str, env = {}):
    assert(repeat > 0)
    results = []
    for i in range(repeat):
        result = subprocess.run(cmd_str, shell=True, capture_output=True, text=True, env=env)
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


########### variants 


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
   

def compile_JAVA_variants():
    # execute javac -d . *.java
    cmd_args = ["javac", "-d", ".", "*.java"]
    cmd_str = " ".join(cmd_args)
    result = subprocess.run(cmd_str, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print("Error while compiling Java variants")
        print(result.stderr)
        exit(1)
    

# TODO JDK version... GraalVM?
def test_JAVA_variants(rand_strategy_name, ngen, test_cmd):
    variant_info = {
        "Language": "Java",
        "Library": rand_strategy_name,
        "System": "linux",
        "Compiler": "",
        "VariabilityMisc": "",
        "NumberGenerations": GNUMBER_GENERATIONS,
        "EqualityCheck": "associativity", # TODO associativity only at the moment
    }

    cmd_args = ["java", "assoc.TestAssoc", test_cmd, str(ngen)]
    cmd_str = " ".join(cmd_args)
    result = analyze_results(REPEAT, cmd_str)
    print_variant_results(variant_info, result)

def testCvariants(ngen):

    variant_info = {
        "Language": "C",
        "Library": "",
        "System": "",
        "Compiler": "",
        "VariabilityMisc": "",
        "NumberGenerations": ngen,
        "EqualityCheck": "associativity", # TODO associativity only supported at the moment
    }

    COMPILERS = ["gcc", "clang"]
    OPTIONS = ["-DCUSTOM=1", "", "-DWIN=1 -DCUSTOM=1", "-DWIN=1"]
    FLAGS = ["-DOLD_MAIN_C=1", ""]

    for compiler in COMPILERS:
        for i in range(4):
            for flag in FLAGS:
                cmd_args = ["./testassoc", str(ngen)]

                if compiler == "gcc" and "-DWIN=1" in OPTIONS[i]:
                    cmd_args = ["wine", "./testassoc.exe", str(ngen)]

                if compiler == "gcc" and "-DWIN=1" in OPTIONS[i]:
                    compiler = "i686-w64-mingw32-gcc"
                
                if i == 0:
                    library_name = "custom"
                    os_name = "Linux"
                elif i == 1:
                    library_name = "(srand48+drand48)"
                    os_name = "Linux"
                elif i == 2:
                    library_name = "custom"
                    if "gcc" in compiler:
                        os_name = "Windows (with wine and cross-compilation)"
                    else: # clang
                        os_name = "Linux (no cross-compilation with clang)"
                else:
                    library_name = "(srand+rand)"
                    if "gcc" in compiler:
                        os_name = "Windows (with wine and cross-compilation)"
                    else: # clang
                        os_name = "Linux (no cross-compilation with clang)"

                variant_info["Library"] = library_name
                variant_info["System"] = os_name
                variant_info["Compiler"] = compiler
                variant_info["VariabilityMisc"] = OPTIONS[i] + " " + flag
                variant_info["NumberGenerations"] = ngen
                
                # compilation
                compile_cmd_arg = [compiler, "-o", "testassoc", "testassoc.c", OPTIONS[i], flag]
                clean_compile_cmd_args = [cmd_arg for cmd_arg in compile_cmd_arg if cmd_arg != ""]

                compilation_result = subprocess.run(clean_compile_cmd_args, capture_output=True, text=True)
                if compilation_result.returncode != 0:
                    print("Error while compiling C variant")
                    print(compilation_result.stderr)
                    exit(1)         
               
                # execution 
                exec_cmd_str = " ".join(cmd_args)
                l_env = {}
                if "wine" in cmd_args:
                    l_env["WINEDEBUG"] = "-all" # not sure it's working
                result_str = analyze_results(REPEAT, exec_cmd_str, l_env)

                print_variant_results(variant_info, result_str)

print_column_names()

testCvariants(GNUMBER_GENERATIONS)


compile_JAVA_variants() # prerequisites, applies to all variants
test_JAVA_variants("java.util.Random.nextFloat()", GNUMBER_GENERATIONS, "basic")
test_JAVA_variants("Math.random()", GNUMBER_GENERATIONS, "math")
test_JAVA_variants("java.util.Random.nextDouble()", GNUMBER_GENERATIONS, "double")


test_PY_variants("associativity", GNUMBER_GENERATIONS)
test_PY_variants("mult-inverse", GNUMBER_GENERATIONS)
test_PY_variants("mult-inverse-pi", GNUMBER_GENERATIONS)

test_PY_variants("associativity", GNUMBER_GENERATIONS, 42)
test_PY_variants("mult-inverse", GNUMBER_GENERATIONS, 42)
test_PY_variants("mult-inverse-pi", GNUMBER_GENERATIONS, 42)
