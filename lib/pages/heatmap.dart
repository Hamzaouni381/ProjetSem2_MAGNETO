import 'dart:math';
import 'package:arrow_pad/arrow_pad.dart';
import 'package:flutter/material.dart';
import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'calibration.dart';

void main() => runApp(HeatMapApp());

class HeatMapApp extends StatefulWidget {
  @override
  HeatMapState createState() => HeatMapState();
}

class HeatMapState extends State<HeatMapApp> {
  HeatmapItem? selectedItem;
  late HeatmapData heatmapData;
  MagnetometerEvent? magEvent;
  List<List<double>> matrix =
      List.generate(7, (i) => List.generate(7, (j) => 0));
  // initialiser la position initial selectionée dans la matrice
  int selrow = 0;
  int cursorCol = 0;
  // nombre de ligne et de collonnes
  int rows = 7;
  int cols = 7;

  // Update the matrix and cursor position based on the button press
  void miseajourmatrice(String direction) {
    MagnetometerCalibration magnetometerCalibration = MagnetometerCalibration();
    if (magEvent != null) {
      setState(() {
        if (direction == "left") {
          if (cursorCol > 0) {
            cursorCol--;
          }
        } else if (direction == "right") {
          if (cursorCol < cols - 1) {
            cursorCol++;
          }
        } else if (direction == "up") {
          if (selrow > 0) {
            selrow--;
          }
        } else if (direction == "down") {
          if (selrow < rows - 1) {
            selrow++;
          }
        }
        matrix[selrow][cursorCol] = calculateMagneticValue(
          (magEvent!.x - magnetometerCalibration.magXOffset) /
              magnetometerCalibration.magXScale,
          (magEvent!.y - magnetometerCalibration.magYOffset) /
              magnetometerCalibration.magYScale,
          (magEvent!.z - magnetometerCalibration.magZOffset) /
              magnetometerCalibration.magZScale,
        );
        initHeatMapData();
        if (matrixIsFull()) {
          initHeatMapData();
        }
      });
    }
  }

  bool matrixIsFull() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (matrix[row][col] == 0) {
          return false;
        }
      }
    }
    return true;
  }

  double calculateMagneticValue(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  @override
  void initState() {
    initHeatMapData();
    super.initState();
  }

  void initHeatMapData() {
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        magEvent = event;
      });
    });
    final int l = matrix.elementAt(0).length;
    final int c = matrix.length;
    List<String> rows = [];
    List<String> columns = [];
    for (int i = 1; i <= l; i++) {
      columns.add(i.toString());
    }
    for (int j = 1; j <= c; j++) {
      rows.add(j.toString());
    }

    List<Color> colorPalette = [
      const Color.fromRGBO(249, 247, 247, 1),
      const Color.fromRGBO(184, 210, 236, 1),
      const Color.fromRGBO(12, 229, 59, 1),
      const Color.fromRGBO(77, 230, 11, 1),
      const Color.fromRGBO(194, 240, 9, 1),
      const Color.fromRGBO(222, 241, 6, 1),
      const Color.fromRGBO(236, 166, 14, 1),
      const Color.fromRGBO(228, 126, 9, 1),
      const Color.fromRGBO(243, 67, 67, 1),
    ];

    heatmapData = HeatmapData(
      rows: rows,
      columns: columns,
      items: [
        for (int row = 0; row < rows.length; row++)
          for (int col = 0; col < columns.length; col++)
            HeatmapItem(
              value: matrix[row][col],
              xAxisLabel: columns[col],
              yAxisLabel: rows[row],
            ),
      ],
      colorPalette: colorPalette,
      selectedColor: Colors.white,
    );
  }

  String unit = '( µ Tesla) ';
  @override
  Widget build(BuildContext context) {
    final title = (selectedItem != null)
        ? 'Value = ${selectedItem!.value.toStringAsFixed(10)} ${selectedItem!.unit}'
        : 'Value = --- ${heatmapData.items.first.unit}';
    final subtitle = selectedItem != null
        ? 'Position = [${selrow + 1},${cursorCol + 1}]'
        : 'Position = [-,-]';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 35),
              Heatmap(
                  onItemSelectedListener: (HeatmapItem? selectedItem) {
                    setState(() {
                      this.selectedItem = selectedItem;
                    });
                  },
                  heatmapData: heatmapData),
              Text(title, textScaleFactor: 1.4),
              Text(subtitle),
              ArrowPad(
                  height: 120.0,
                  width: 120.0,
                  innerColor: Colors.grey,
                  iconColor: Colors.white,
                  arrowPadIconStyle: ArrowPadIconStyle.arrow,
                  clickTrigger: ClickTrigger.onTapDown,
                  onPressedUp: () => miseajourmatrice("up"),
                  onPressedLeft: () => miseajourmatrice("left"),
                  onPressedRight: () => miseajourmatrice("right"),
                  onPressedDown: () => miseajourmatrice("down")),
            ],
          ),
        ),
      ),
    );
  }
}
