
int findLargePrime(int n) {
  int count = 0;
  int num = 1;
  while (count < n) {
    num++;
    if (isPrime(num)) {
      count++;
    }
  }
  return num;
}

bool isPrime(int number) {
  if (number < 2) return false;
  for (int i = 2; i <= number ~/ 2; i++) {
    if (number % i == 0) return false;
  }
  return true;
}