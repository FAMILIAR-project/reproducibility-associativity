package main

import (
    "flag"
    "fmt"
    "math"
    "math/rand"
	"time"
)

type EqualityCheck string

const (
    ASSOCIATIVITY  EqualityCheck = "associativity"
    MULT_INV       EqualityCheck = "mult-inverse"
    MULT_INV_PI    EqualityCheck = "mult-inverse-pi"
)

func equalityTest(equalityCheck EqualityCheck, x, y, z float64) bool {
    switch equalityCheck {
    case ASSOCIATIVITY:
        return x+(y+z) == (x+y)+z
    case MULT_INV:
        return (x*z)/(y*z) == x/y
    case MULT_INV_PI:
        return (x*z*math.Pi)/(y*z*math.Pi) == x/y
    }
    return false
}

func proportion(number int, seedVal int64, equalityCheck EqualityCheck) int {
	if seedVal != 0 {
        rand.Seed(seedVal)
    } else {
        rand.Seed(time.Now().UnixNano())
    }
    ok := 0
    for i := 0; i < number; i++ {
        x := rand.Float64()
        y := rand.Float64()
        z := rand.Float64()
        ok += btoi(equalityTest(equalityCheck, x, y, z))
    }
    return (ok * 100) / number
}

func btoi(b bool) int {
    if b {
        return 1
    }
    return 0
}

func main() {
    var seedVal int64
    var number int
    var equalityCheckStr string
    flag.Int64Var(&seedVal, "seed", 0, "Seed value.")
    flag.IntVar(&number, "number", 10000, "Number of tests")
    flag.StringVar(&equalityCheckStr, "equality-check", "", "Type of equality check")
    flag.Parse()

    var equalityCheck EqualityCheck
    switch equalityCheckStr {
    case string(ASSOCIATIVITY):
        equalityCheck = ASSOCIATIVITY
    case string(MULT_INV):
        equalityCheck = MULT_INV
    case string(MULT_INV_PI):
        equalityCheck = MULT_INV_PI
    default:
        flag.PrintDefaults()
        return
    }

   
    fmt.Printf("%v%%\n", proportion(number, seedVal, equalityCheck))
}
