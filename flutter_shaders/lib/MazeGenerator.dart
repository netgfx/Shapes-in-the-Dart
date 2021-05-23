import 'dart:math';
import 'dart:ui';

class MazeGenerator {
  Size size = Size(411, 840);

  int width = 0;
  int height = 0;
  Map generator = {};
  String algorithm = 'recursiveBacktracking';
  MazeGenerator(Size size) {
    this.size = size;
    width = size.width.toInt();
    height = size.height.toInt();
  }

  // Helper
  // double shuffle(o) {
  //   final _random = new Random();
  //     for (var j, x, i = o.length; i; j = (_random.nextDouble() * i).floor(), x = o[--i], o[i] = o[j], o[j] = x)
  //     return o;
  // }

  // Algorithm

  ///
  /// Recursive Backtracking
  /// http://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking

  List<List<int>> recursiveBacktracking() {
    // initialize the grid
    List<List<int>> grid = [];
    // duplicate to avoid overriding
    int h = height;

    while (h > 0) {
      List<int> cells = [];
      int w = width;
      while (w > 0) {
        cells.add(0);
        w--;
      }
      grid.add(cells);
      h--;
    }

    print(" ---> ${grid.length} ${grid[0].length}");
    int N = 1;
    int S = 2;
    int E = 4;
    int W = 8;
    List<String> dirs = ['N', 'E', 'S', 'W'];
    Map<String, int> dirsValue = {"N": N, "E": E, "S": S, "W": W};
    Map<String, int> DX = {"E": 1, "W": -1, "N": 0, "S": 0};
    Map<String, int> DY = {"E": 0, "W": 0, "N": -1, "S": 1};
    Map<String, int> OPPOSITE = {"E": W, "W": E, "N": S, "S": N};

    void carve_passages_from(int cx, int cy, List<List<int>> grid) {
      dirs.shuffle();
      List<String> directions = dirs;
      //shuffle(dirs);

      directions.forEach((String direction) {
        int nx = cx + DX[direction]!;
        int ny = cy + DY[direction]!;
        //print("$nx $ny");

        if (ny >= 0 && ny <= (grid.length - 1) && nx >= 0 && nx <= (grid.length - 1) && grid[ny][nx] == 0) {
          grid[cy][cx] += dirsValue[direction]!;
          grid[ny][nx] += OPPOSITE[direction]!;
          carve_passages_from(nx, ny, grid);
        }
      });
    }

    carve_passages_from(0, 0, grid);

    return grid;
  }
}
