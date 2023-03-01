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
		public double random() {
			return new java.util.Random().nextFloat();
		}
	}
	class MathRandom implements IRandom {
		public double random() {
			return Math.random(); 
		}
	}
	
	
	boolean associativity_test(){
	  double x = rand.random(); double y = rand.random(); double z = rand.random();
	  //  printf("%f   %f   %f   %d\n",x,y,z,x+(y+z) == (x+y)+z);
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
		t.setRand(t.new BasicRandom());
		System.out.println(String.valueOf(t.proportion(10000)+"%"));
		t.setRand(t.new MathRandom());
		System.out.println(String.valueOf(t.proportion(10000)+"%"));
	}
}
