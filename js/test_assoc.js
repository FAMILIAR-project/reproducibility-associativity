const { ArgumentParser } = require('argparse');
const seedrandom = require('seedrandom');

function associativityTest() {
  const x = Math.random();
  const y = Math.random();
  const z = Math.random();
  return x + (y + z) === (x + y) + z;
}

function proportion(number, seedVal) {
  const rng = seedrandom(seedVal);
  let ok = 0;
  for (let i = 0; i < number; i++) {
    ok += associativityTest();
  }
  return (ok * 100) / number;
}

const parser = new ArgumentParser({
  description: 'Associativity test with seed.',
});

parser.add_argument('--seed', { type: Number, required: true, help: 'Seed value' });
parser.add_argument('--number', { type: Number, default: 10000, help: 'Number of tests' });
const args = parser.parse_args();

console.log(`${proportion(args.number, args.seed)}%`);
