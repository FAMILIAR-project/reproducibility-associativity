package assoc;
import  java.util.Random;

public class TestAssoc {
	private BasicRandom rand;


	void setRand(BasicRandom r) {
		this.rand = r;
	}
	
	class BasicRandom extends java.util.Random {
		public double random() {
			//System.out.println(Math.random());
			return nextFloat(); 
		}
	}
	class MathRandom extends BasicRandom {
		public double random() {
			//System.out.println(Math.random());
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
