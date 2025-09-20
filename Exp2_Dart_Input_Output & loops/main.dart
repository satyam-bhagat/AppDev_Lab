import 'dart:io';

void main() {
  print('Simple Dart I/O and Loops Demo');

  stdout.write('Enter a positive integer n: ');
  String? input = stdin.readLineSync();

  if (input == null) {
    print('No input provided. Exiting.');
    return;
  }

  int? n = int.tryParse(input.trim());

  if (n == null || n <= 0) {
    print('Please enter a valid positive integer.');
    return;
  }

  print('\nNumbers from 1 to $n:');
  for (int i = 1; i <= n; i++) {
    stdout.write('$i ');
  }
  print('\n');

  int sum = 0;
  for (int i = 1; i <= n; i++) {
    sum += i;
  }
  print('Sum of numbers from 1 to $n is: $sum');

  print('\nUsing a while loop to count down:');
  int k = n;
  while (k > 0) {
    stdout.write('$k ');
    k--;
  }

  print('\n\nDone.');
}
