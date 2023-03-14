import subprocess

CHECK= "associativity"
SEED = 42
NGEN = 20
JS_WITH_GSEED = True

def mk_javascript(echeck, ngen, failing_cases):
    npm_args = ["npm", "start", "--prefix", "js/", "--silent", "--", "--equality-check", echeck, "--seed", str(SEED), "--number", str(ngen)]
    if failing_cases:
        npm_args.append("--failing-cases")
    else:
        npm_args.append("--success-cases")

    if JS_WITH_GSEED:
        npm_args.append("--with-gseed")
    
    return npm_args 

def mk_javascript_check(echeck, x, y, z):
    npm_args = ["npm", "start", "--prefix", "js/", "--silent", "--", "--equality-check", echeck, "--check-case", x, y, z]
    return npm_args


def mk_python(echeck, ngen, failing_cases):
    py_cmd_args = ["python", "testassoc.py", "--number", str(ngen), "--equality-check", echeck]
    if failing_cases:
        py_cmd_args.append("--failing-cases")
    else:
        py_cmd_args.append("--success-cases")
    if SEED is not None:
        py_cmd_args.extend(["--seed", str(SEED)])
    return py_cmd_args

def mk_python_check(echeck, x, y, z):
    py_cmd_args = ["python", "testassoc.py", "--equality-check", echeck, "--check-case", x, y, z]
    return py_cmd_args


def mk_cases(mk_variant, ngen, echeck, failing_cases=False):
    npm_args_str = " ".join(mk_variant(echeck, ngen, failing_cases))
    result = subprocess.run(npm_args_str, shell=True, capture_output=True, text=True)
    return result



def check_cases(result, mk_variant, echeck):
    for res in result.stdout.strip().split("\n"):
        els = res.replace("(", "").replace(")", "").split(",")
        x, y, z = els[0], els[1], els[2] 
        py_cmd_str = " ".join(mk_variant(echeck, x, y, z))
        result_python = subprocess.run(py_cmd_str, shell=True, capture_output=True, text=True)
        print (result_python.stdout.strip())

def mk_failing_cases(mk_variant, echeck, ngen):
    return mk_cases(mk_variant, ngen, echeck, True)

def mk_success_cases(mk_variant, echeck, ngen):
    return mk_cases(mk_variant, ngen, echeck, False)


def MR(echeck, ngen, mk_failing_producers, mk_checker):
    check_cases(mk_failing_cases(mk_failing_producers, echeck, ngen), mk_checker, echeck)

def MR2(echeck, ngen, mk_producers, mk_checker):
    check_cases(mk_success_cases(mk_producers, echeck, ngen), mk_checker, echeck)

print("CHECKING FOR FAILING CASES (JavaScript => Python)")
MR(CHECK, NGEN, mk_javascript, mk_python_check)
print("CHECKING FOR FAILING CASES (Python => JavaScript)")
MR(CHECK, NGEN, mk_python, mk_javascript_check)

print("CHECKING FOR SUCCESS CASES (JavaScript => Python)")
MR2(CHECK, NGEN, mk_javascript, mk_python_check)
print("CHECKING FOR SUCCESS CASES (Python => JavaScript)")
MR2(CHECK, NGEN, mk_python, mk_javascript_check)

# MR2(CHECK, NGEN, mk_javascript, mk_python_check)
# MR(CHECK, NGEN, mk_javascript, mk_javascript_check)
# check_cases(mk_failing_cases(mk_python, CHECK, NGEN), mk_javascript, CHECK)