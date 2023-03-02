package assoc;
import  java.util.Random;

public class TestAssoc {
	private IRandom rand;


	void setRand(IRandom r) {
		this.rand = r;
	}

	interface IRandom {
		public double random();
	}
	
	class BasicRandom implements IRandom {

		Random r = new Random();

		public double random() {
			return r.nextFloat();
		}
	}
	class MathRandom implements IRandom {
		public double random() {
			return Math.random(); 
		}
	}
	
	
	boolean associativity_test(){
	  double x = rand.random(); double y = rand.random(); double z = rand.random();
	  return x+(y+z) == (x+y)+z;
	}

	double proportion(int number)
	{
	  int ok=0;
	  for (int i=0;i<number;i++) ok += associativity_test()? 1:0;
	  return ok*100.0/number;
	}


	public static void main(String[] args) {
		TestAssoc t = new TestAssoc();
		int numTrials = 10000; // default number of trials

		// java assoc.TestAssoc basic|math number eg java assoc.TestAssoc math 1000

		// TODO seed?

		if (args.length > 0) {
			String arg = args[0];
			if (arg.equals("basic")) {
				t.setRand(t.new BasicRandom());
			} else if (arg.equals("math")) {
				t.setRand(t.new MathRandom());
			} else {
				throw new IllegalArgumentException("Invalid parameter: " + arg);
			}

			if (args.length > 1)
				numTrials = Integer.parseInt(args[1]);	// != 0	
		} 
		System.out.println(String.valueOf(t.proportion(numTrials)+"%"));
	}
	
}
