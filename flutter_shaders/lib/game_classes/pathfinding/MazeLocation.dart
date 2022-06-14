//
//  MazeLocation.dart
//  BFS-Showcase
//
//  Created by Mixalis Dobekidis on 5/5/21.
//

enum Cell {
  empty, // 1
  blocked, // = 0
  key, // = 5
  goal, // = 2
  notFound //= -1
}

class MazeLocation {
  int row = 0;
  int col = 0;

  MazeLocation({required this.row, required this.col}) {}

  getRow() {
    return row;
  }

  getCol() {
    return col;
  }
}
