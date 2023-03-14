const { ArgumentParser } = require('argparse');
const seedrandom = require('seedrandom');

const EqualityCheck = Object.freeze({
  ASSOCIATIVITY: "associativity",
  MULT_INVERSE: "mult_inverse",
  MULT_INVERSE_PI: "mult_inverse_pi",
});

function equality_test(option, x, y, z) {  
  if (option === EqualityCheck.ASSOCIATIVITY) {
    return x + (y + z) === (x + y) + z;
  } else if (option === EqualityCheck.MULT_INVERSE) {
    return (x * z) / (y * z) === x / y;
  } else if (option === EqualityCheck.MULT_INVERSE_PI) {
    const pi = Math.PI;
    return (x * z * pi) / (y * z * pi) === x / y;
  } else {
    throw new Error("Invalid option");
  }
}

function proportion(number, seedVal, option, withSeed = true) {
  const rng = seedrandom(seedVal, { global: withSeed }); // !without global : true, the seed does not affect Math.random() above! (and btw it changes all results!)
  let ok = 0;
  for (let i = 0; i < number; i++) {
    const x = Math.random();
    const y = Math.random();
    const z = Math.random();
    ok += equality_test(option, x, y, z);
  }
  return (ok * 100) / number;
}


// Function to filter cases based on the equality check and the condition
function filterCases(number, seedVal, option, condition, withSeed = true) {
  const rng = seedrandom(seedVal, { global: withSeed });
  let cases = [];
  for (let i = 0; i < number; i++) {
    const x = Math.random();
    const y = Math.random();
    const z = Math.random();
    if (equality_test(option, x, y, z) === condition) {
      cases.push([x, y, z]);
    }
  }
  return cases;
}

// Function to get passing cases
function successCases(number, seedVal, option, withSeed = true) {
  return filterCases(number, seedVal, option, true, withSeed);
}

// Function to get failing cases
function failingCases(number, seedVal, option, withSeed = true) {
  return filterCases(number, seedVal, option, false, withSeed);
}

// Function to print triplets (cases)
function printCases(lcases) {
  // start printing "("" and ending with ")"
  // then print each element of lcases separated by , and space except last element
  // then print last element and ")"
  console.log(`(${lcases.map((x) => x.join(", ")).join(")\n(")})`);
  
}

const parser = new ArgumentParser({
  description: 'Associativity test with seed.',
});

parser.add_argument('--seed', { type: Number, help: 'Seed value' });
parser.add_argument('--number', { type: Number, default: 10000, help: 'Number of tests' });
parser.add_argument('--equality-check', { choices: Object.values(EqualityCheck), default: EqualityCheck.ASSOCIATIVITY, help: 'Type of equality check (associativity, mult_inverse, mult_inverse_pi)' });
parser.add_argument('--with-gseed', { action: 'store_true', help: 'Use global seed value in random number generation' });

// Add mutually exclusive group for additional features
const group = parser.add_mutually_exclusive_group();
group.add_argument('--check-case', { nargs: 3, type: Number, metavar: ['X', 'Y', 'Z'], help: 'Give x, y and z and check equality wrt --equality-check argument.' });
group.add_argument('--failing-cases', { action: 'store_true', help: 'Print all failing cases (if any).' });
group.add_argument('--success-cases', { action: 'store_true', help: 'Print all passing cases (if any).' });

const args = parser.parse_args();

// Check if --check-case argument is passed
if (args.check_case) {
  const [x, y, z] = args.check_case;
  if (equality_test(args.equality_check, x, y, z)) {
    console.log(`1`);
  } else {
    console.log(`0`);
  }
} else if (args.failing_cases) {
  printCases(failingCases(args.number, args.seed, args.equality_check, args.with_gseed));
} else if (args.success_cases) {
  printCases(successCases(args.number, args.seed, args.equality_check, args.with_gseed));
} else {
// Call the proportion function with the "withSeed" parameter value taken from the command line
console.log(`${proportion(args.number, args.seed, args.equality_check, args.with_gseed)}%`);
}
