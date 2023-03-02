use rand::prelude::*;

fn associativity_test() -> bool {
    let mut rng = thread_rng();
    let x = rng.gen::<f64>();
    let y = rng.gen::<f64>();
    let z = rng.gen::<f64>();
    x + (y + z) == (x + y) + z
}

fn proportion(number: i32, seed_val: u64) -> i32 {
    StdRng::seed_from_u64(seed_val);
    let mut ok = 0;
    for _ in 0..number {
        if associativity_test() {
            ok += 1;
        }
    }
    ok * 100 / number
}

fn main() {
    println!("{}%", proportion(1000, 1234));
}
