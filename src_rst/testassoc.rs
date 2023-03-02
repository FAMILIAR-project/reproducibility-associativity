use rand::prelude::*;
use structopt::StructOpt;

#[derive(Debug, StructOpt)]
#[structopt(name = "ratio-checker")]
struct Opt {
    #[structopt(short, long)]
    error_margin: Option<f64>,
}

#[derive(Debug, Clone, Copy)]
struct Config {
    error_margin: Option<f64>,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            error_margin: Some(f64::EPSILON),
        }
    }
}

fn check_ratio(config: &Config, x: f64, y: f64, z: f64) -> bool {
    if let Some(error_margin) = config.error_margin {        
        #[cfg(feature = "associativity")]
        {
        ((x + y) + z - x - (y + z)).abs() < error_margin
        }
        #[cfg(feature = "mult_inverse")]
        {
        ((x * z) / (y * z) - x / y).abs() < error_margin
        }
        #[cfg(feature = "mult_inverse_pi")]
        {
        ((x * z * std::f64::consts::PI) / (y * z * std::f64::consts::PI) - x / y).abs() < error_margin
        }        

    } else {
        #[cfg(feature = "associativity")]
        {
        (x + y) + z == x + (y + z)
        }

        #[cfg(feature = "mult_inverse")]
        {
        (x * z) / (y * z) == x / y
        }

        #[cfg(feature = "mult_inverse_pi")]
        {
        (x * z * std::f64::consts::PI) / (y * z * std::f64::consts::PI) == (x / y)
        }
    }
}

fn associativity_test(config: &Config) -> bool {
    let mut rng = thread_rng();
    // TODO: this variant for generating random
    // let x = rng.gen::<f64>();
    // let y = rng.gen::<f64>();
    // let z = rng.gen::<f64>();
    let x = rng.gen_range(0.000_000_000_000_001..100.0); // TODO: variation point for range min, max value
    let y = rng.gen_range(0.000_000_000_000_001..100.0);
    let z = rng.gen_range(0.000_000_000_000_001..100.0);
    check_ratio(config, x, y, z)
}

fn proportion(config: &Config, number: i32, seed_val: u64) -> i32 {
    StdRng::seed_from_u64(seed_val);
    let mut ok = 0;
    for _ in 0..number {
        if associativity_test(config) {
            ok += 1;
        }
    }
    ok * 100 / number
}

fn main() {
    let opt = Opt::from_args();

    let config = Config {
        error_margin: opt.error_margin,
    };

    println!("{}%", proportion(&config, 10_000, 1234)); // TODO: variation point for number of tests and seed value

   
}
