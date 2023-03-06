import scala.util.Random
import scala.math.{Pi, abs}
import scopt.{Read, OptionParser}

sealed trait EqualityCheck
case object Associativity extends EqualityCheck
case object MultInv extends EqualityCheck
case object MultInvPi extends EqualityCheck

class TestAssoc {
  def equality_test(equalityCheck: EqualityCheck, x: Double, y: Double, z: Double): Boolean = equalityCheck match {
    case Associativity => x + (y + z) == (x + y) + z
    case MultInv => (x * z) / (y * z) == x / y
    // case MultInv => abs((x * z) / (y * z) - x / y) <= 1E-9 // incredible: it's provided by ChatGPT when translating the Python code (that is using strict equality...)
    // case MultInvPi => abs((x * z * Pi) / (y * z * Pi) - x / y) <= 1E-9  // incredible: it's provided by ChatGPT when translating the Python code (that is using strict equality...)
    case MultInvPi => (x * z * Pi) / (y * z * Pi) == x / y
  }

  def proportion(number: Int, seedVal: Int, equalityCheck: EqualityCheck): Double = {
    val rng = new Random(seedVal)
    val passedTests = (1 to number).count { _ =>
      val x = rng.nextDouble()
      val y = rng.nextDouble()
      val z = rng.nextDouble()
      equality_test(equalityCheck, x, y, z)
    }
    100.0 * passedTests / number
  }
}

case class Config(seed: Int = 0, number: Int = 10000, equalityCheck: EqualityCheck = Associativity)

object Main {
  def main(args: Array[String]): Unit = {

    

    implicit val equalityCheckRead: Read[EqualityCheck] = Read.reads {
      case "Associativity" => Associativity
      case "MultInv" => MultInv
      case "MultInvPi" => MultInvPi
      case other => throw new IllegalArgumentException(s"Invalid equality check: $other")
    }

    val parser = new scopt.OptionParser[Config]("EqualityTest") {
      head("Equality Test", "1.0")
      opt[Int]('s', "seed").required().action((x, c) => c.copy(seed = x))
        .text("Seed value")
      opt[Int]('n', "number").optional().action((x, c) => c.copy(number = x))
        .text("Number of tests")
      opt[EqualityCheck]('e', "equality-check").required().action((x, c) => c.copy(equalityCheck = x))
        .validate {
          case Associativity | MultInv | MultInvPi => success
          case _ => failure("Invalid equality check")
        }
        .text("Type of equality check")
      help("help").text("Prints this usage text")
    }

    parser.parse(args, Config()) match {
      case Some(config) =>
        val testAssoc = new TestAssoc()
        val prop = testAssoc.proportion(config.number, config.seed, config.equalityCheck)
        println(s"$prop%")
      case None =>
    }
  }
}
