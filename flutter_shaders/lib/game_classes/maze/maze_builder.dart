import 'dart:math';

class Cell {
  double x;
  double y;
  bool top;
  bool left;
  bool right;
  bool bottom;
  double? set;

  Cell({
    required this.x,
    required this.y,
    required this.top,
    required this.left,
    required this.bottom,
    required this.right,
    this.set,
  }) {}

  getPropertyByKey(String key) {
    switch (key) {
      case "set":
        {
          return this.set;
        }

      case "x":
        {
          return this.x;
        }

      case "y":
        {
          return this.y;
        }

      case "top":
        {
          return this.top;
        }
      case "bottom":
        {
          return this.bottom;
        }
      case "left":
        {
          return this.left;
        }
      case "right":
        {
          return this.right;
        }
    }
  }
}

List<dynamic> compact(List<dynamic> array) {
  return array.where((u) => u != 0.0).toList();
}

List<dynamic> difference(List<dynamic> c, List<dynamic> d) {
  return [c, d].reduce((a, b) => c.toSet().difference(b.toSet()).toList());
}

List<dynamic> initial(List<dynamic> array) {
  return array.sublist(0, array.length - 1);
}

/// { [key]: T[] }
Map<int, List<dynamic>> oldgroupBy(List<Cell> list, String key) {
  List<dynamic> keys = list.map((item) => item.getPropertyByKey(key)).toList();
  var uniqKeys = uniq(keys).toList();
  Map<int, List<dynamic>> _dict = {};
  uniqKeys.asMap().forEach((index, element) {
    _dict[element.toInt()] = [];
  });

  // uniqKeys.reduce((prev, next) => {
  //       {
  //         ...prev,
  //         [next]: []
  //       }
  //     });
  Map<int, List<dynamic>> dict = _dict;

  list.forEach((item) => dict[item.getPropertyByKey(key)]?.add(item));
  //print(dict);
  return dict;
}

Map<T, List<S>> groupBy<S, T>(Iterable<S> values, T Function(S) key) {
  var map = <T, List<S>>{};
  for (var element in values) {
    (map[key(element)] ??= []).add(element);
  }
  return map;
}

last(List<dynamic> array) {
  return array[array.length - 1];
}

Iterable range(double n, {int end = 0}) {
  return end != 0
      ? List.from(List.generate(end - n.round(), (int index) => index, growable: true)).map((k) => k + n)
      : List.from(List.generate(n.round(), (int index) => index, growable: true));
}

List<dynamic> uniq(List<dynamic> array) {
  return [...new Set.from(array)];
}

List<dynamic> sampleSize(List<dynamic>? array, double? n, Function random) {
  n = n == null ? 1 : n;
  double length = (array == null) ? 0.0 : array.length.toDouble();

  /// !length note
  if (length == 0 || n < 1) {
    return [];
  }
  n = n > length ? length : n;
  int index = -1;
  double lastIndex = length - 1;
  List result = [...?array];
  while (++index < n) {
    //var _random = random();
    var rand = index + (random() * (lastIndex - index + 1)).floor() as int;
    Cell value = result[rand];
    result[rand] = result[index];
    result[index] = value;
  }
  return result.sublist(0, n.round());
}

Function mulberry32(int seed) {
  return () {
    seed += 0x6D2B79F5;
    int t = seed;
    t = imul2(t ^ t >> 15, t | 1);
    t ^= t + imul2(t ^ t >> 7, t | 61);
    double result = ((t ^ t >> 14) >> 0) / 4294967296;

    return result;
  };
}

int imul2(int a, int b) {
  int aHi = (a >> 16) & 0xffff;
  int aLo = a & 0xffff;
  int bHi = (b >> 16) & 0xffff;
  int bLo = b & 0xffff;
  // the shift by 0 fixes the sign on the high part
  // the final |0 converts the unsigned value into a signed value
  return ((aLo * bLo) + (((aHi * bLo + aLo * bHi) << 16) >> 0)).toSigned(32);
}

List<Cell> mergeSetWith(List<Cell> row, double oldSet, double newSet) {
  row.forEach((box) {
    if (box.set == oldSet) box.set = newSet;
  });

  return row;
}

List<Cell> populateMissingSets(List<Cell> row, Function random) {
  var _map = row.map((row) => row.set).toList();
  List<dynamic> _uniq = uniq(_map);
  List<dynamic> setsInUse = compact(_uniq);
  List<dynamic> allSets = range(1, end: row.length + 1).toList();
  List<dynamic> diff = difference(allSets, setsInUse);
  List<double> availableSets = diff.cast<double>();
  availableSets.sort((a, b) => (0.5 - random()).sign.toInt());
  // print("$availableSets, $setsInUse, $allSets");
  row.where((box) => box.set == 0).toList().asMap().forEach((i, box) {
    box.set = availableSets[i];
  });

  return row;
}

List<Cell> mergeRandomSetsIn(List<Cell> row, Function random, {probability = 0.5}) {
  // Randomly merge some disjoint sets

  var allBoxesButLast = initial(row);
  allBoxesButLast.asMap().forEach((x, current) {
    var next = row[x + 1];
    var differentSets = current.set != next.set;
    var rand = random();
    var shouldMerge = rand <= probability;

    if (current.x == 0 && current.y == 0) {
      //print(">>>> $rand  $differentSets $shouldMerge ${current.set}, ${next.set}");
    }
    if (differentSets && shouldMerge) {
      row = mergeSetWith(row, next.set!, current.set);
      current.right = false;
      row[x + 1].left = false;
    }
  });

  allBoxesButLast.add(row[row.length - 1]);
  return allBoxesButLast as List<Cell>;
}

addSetExits(List<Cell> row, List<Cell> nextRow, Function random) {
  // Randomly add bottom exit for each set
  List<dynamic> setsInRow = [];

  groupBy(row, (item) => (item as Cell).set!.round()).forEach((key, value) {
    setsInRow.add(value);
  });

  setsInRow.forEach((set) {
    List<dynamic> exits = sampleSize(set, (random() * set.length).ceil().toDouble(), random);
    exits.forEach((exit) {
      //if (exit) {
      Cell below = nextRow[exit.x.round()];
      exit.bottom = false;
      below.top = false;
      below.set = exit.set;
      //}
    });
  });

  return setsInRow;
}

List<List<Cell>> generate({int width = 8, int height = 0, closed = true, seed = 1}) {
  height = width;
  var rand = Random(seed);
  Function random = mulberry32(seed);
  //() => rand.nextDouble(); //mulberry32(seed);
  //print("${random()}, ${random()}, ${random()}");
  List<List<Cell>> maze = [];
  var r = range(width.toDouble());

  // Populate maze with empty cells:
  for (var y = 0; y < height; y += 1) {
    var row = r.map((x) {
      return Cell(
        x: x.toDouble(),
        y: y.toDouble(),
        top: closed || y > 0,
        left: closed || x > 0,
        bottom: closed || y < (height - 1),
        right: closed || x < (width - 1),
        set: 0,
      );
    }).toList();
    maze.add(row);
  }

  // All rows except last:
  initial(maze).asMap().forEach((y, row) {
    // TODO initial temp?
    row = populateMissingSets(row, random);
    //print(row.toList());
    row = mergeRandomSetsIn(row, random);
    addSetExits(row, maze[y + 1], random);
  });

  var lastRow = last(maze).toList();
  lastRow = populateMissingSets(lastRow, random);
  lastRow = mergeRandomSetsIn(lastRow, random, probability: 1);

  return maze;
}
