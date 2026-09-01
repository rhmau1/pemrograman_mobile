void main(List<String> args) {
  int i = 0;
  // while (i < 5) {
  //   print("perulangan ke ${i + 1}");
  //   i++;
  // }
  // do {
  //   print("perulangan ke ${i + 1}");
  //   i++;
  // } while (i == 5);

  // for (int i = 0; i < 5; i++) {
  //   print("perulangan ke ${i + 1}");
  // }

  for (;;) {
    if (i == 5) {
      break;
    }
    print("perulangan ke ${i + 1}");
    i++;
  }

  for (int j = 1; j < 10; j++) {
    if (j % 2 == 0) {
      continue;
    }
    print(j);
  }
}
