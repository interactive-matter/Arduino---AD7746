public class DataSet {
  
  float[] numbers;
  float[] changes;
  
  int maxSamples;
  float minimum = 0;
  float maximum = 0;
  int samplePosition = 0;
  
  public DataSet(int numberOfSamples) {
    numbers = new float[numberOfSamples];
    changes = new float[numberOfSamples];
    maxSamples = numberOfSamples;
  }
  
  public synchronized void addSample(float sample) {

    //store the sample
    numbers[samplePosition] = sample;
    
    //calculate min & max
    minimum = Float.MAX_VALUE;
    maximum = - Float.MAX_VALUE;
    for (int i=0; i<maxSamples;i++) {
      minimum=Math.min(minimum,numbers[i]);
      maximum=Math.max(maximum,numbers[i]);
    }
    //println(minimum+" - "+maximum);
    
    //increase sample position
    samplePosition++;
    if (samplePosition==maxSamples) {
      samplePosition = 0;
    }
  }
  
  public float getMax() {
    return maximum;
  }
  
  public float getMin() {
    return minimum;
  }
  
  public int getNumberOfSamples() {
    return maxSamples;
  }
  
  public float getSample(int position) {
    int arrayPosition = samplePosition + position;
    
    //wrap around if too big
    if (arrayPosition>=maxSamples) {
        arrayPosition -=maxSamples;
    }
    return numbers[arrayPosition];
  }
}
