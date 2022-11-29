import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Set<int> selectedIndexes = {};
  Set<int> bombIndexes = {};
  Set<int> flagIndexes = {};

  void reset() {
    selectedIndexes = {};
    bombIndexes = {};
    flagIndexes = {};
    Random random = Random();
    while (bombIndexes.length < 10) {
      int randomNumber = random.nextInt(9 * 9);
      bombIndexes.add(randomNumber);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    reset();
  }

  void checkTilesAround(int index) {
    selectedIndexes.add(index);
    if (Demineur.numberBombsAround(index, bombIndexes) == 0) {
      final indexesAround = Demineur.getIndexesAround(index);
      indexesAround.forEach((index) {
        if (!selectedIndexes.contains(index)) {
          checkTilesAround(index);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              padding: const EdgeInsets.all(10),
              itemCount: 9 * 9,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onLongPress: () {
                    if (!flagIndexes.contains(index)) {
                      flagIndexes.add(index);
                    } else {
                      flagIndexes.remove(index);
                    }
                    setState(() {});
                  },
                  onTap: () {
                    selectedIndexes.add(index);
                    if (bombIndexes.contains(index)) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return DemineurAlertDialog(
                              isWin: false,
                              reset: reset,
                            );
                          });
                    } else {
                      checkTilesAround(index);
                    }
                    setState(() {});
                    if (Demineur.hasWin(
                        selectedIndexes.length, bombIndexes.length)) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return DemineurAlertDialog(
                              isWin: true,
                              reset: reset,
                            );
                          });
                    }
                  },
                  child: MinesweeperTile(
                    bombIndexes: bombIndexes,
                    index: index,
                    isSelected: selectedIndexes.contains(index),
                    flagIndexes: flagIndexes,
                  ),
                );
              },
            ),
          ),
        ));
  }
}

class DemineurAlertDialog extends StatelessWidget {
  final bool isWin;
  final Function() reset;
  const DemineurAlertDialog({
    required this.isWin,
    required this.reset,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isWin ? 'Vous avez gagné' : 'Vous avez perdu'),
      actions: [
        ElevatedButton(
            onPressed: () {
              reset();
              Navigator.pop(context);
            },
            child: Text('Recommencer'))
      ],
    );
  }
}

class MinesweeperTile extends StatelessWidget {
  const MinesweeperTile({
    Key? key,
    required this.isSelected,
    required this.index,
    required this.bombIndexes,
    required this.flagIndexes,
  }) : super(key: key);

  final bool isSelected;
  final int index;
  final Set<int> bombIndexes;
  final Set<int> flagIndexes;

  bool hasBombsAround() {
    return Demineur.numberBombsAround(index, bombIndexes) > 0;
  }

  bool get showText =>
      !bombIndexes.contains(index) && isSelected && hasBombsAround();

  Color colorCase() {
    if (isSelected) {
      if (bombIndexes.contains(index)) {
        return Colors.red;
      } else {
        return Color.fromARGB(255, 109, 98, 98);
      }
    }
    if (flagIndexes.contains(index)) {
      return Color.fromARGB(255, 24, 132, 178);
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colorCase(),
      child: showText
          ? Center(
              child: Text(
                  Demineur.numberBombsAround(index, bombIndexes).toString(),
                  style: TextStyle(fontSize: 30)))
          : null,
    );
  }
}

class Demineur {
  static bool hasWin(int nbSelectedIndexes, int nbBombs,
      {int nbTotalTiles = 9 * 9}) {
    return nbTotalTiles - (nbSelectedIndexes + nbBombs) == 0;
  }

  static int numberBombsAround(int index, Set<int> bombIndexes) {
    return getIndexesAround(index)
        .where((index) => bombIndexes.contains(index))
        .toList()
        .length;
  }

  static List<int> getIndexesAround(int index) {
    final i = index ~/ 9;
    final j = index % 9;
    List<int> indexTilesAround = [];

    // Up
    if (i > 0) {
      indexTilesAround.add(index - 9);
      if (j > 0) {
        indexTilesAround.add(index - 10);
      }
      if (j < 8) {
        indexTilesAround.add(index - 8);
      }
    }

    // Down
    if (i < 8) {
      indexTilesAround.add(index + 9);
      if (j > 0) {
        indexTilesAround.add(index + 8);
      }
      if (j < 8) {
        indexTilesAround.add(index + 10);
      }
    }

    // Right
    if (j < 8) {
      indexTilesAround.add(index + 1);
    }

    // Left
    if (j > 0) {
      indexTilesAround.add(index - 1);
    }

    return indexTilesAround;
  }
}
