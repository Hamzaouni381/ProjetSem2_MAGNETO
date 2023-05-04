import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'heatmap.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;
  double _xa = 0;
  double _ya = 0;
  double _za = 0;

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.ultraHigh,
    );

    _initializeControllerFuture = _controller.initialize();
    chartData = getChartData();
    Timer.periodic(const Duration(seconds: 1), updateDataSource);
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _xa = event.x;
        _ya = event.y;
        _za = event.z;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(children: [
              Positioned.fill(
                child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller)),
              ),
              Positioned(
                  bottom: -27,
                  left: 36,
                  child: SizedBox(
                    height: 300,
                    width: 370,
                    child: Opacity(
                        opacity: 1,
                        child: SfCartesianChart(
                            series: <LineSeries<LiveData, double>>[
                              LineSeries<LiveData, double>(
                                onRendererCreated:
                                    (ChartSeriesController controller) {
                                  _chartSeriesController = controller;
                                },
                                dataSource: chartData,
                                color: Color.fromARGB(255, 209, 3, 202),
                                xValueMapper: (LiveData sales, _) => sales.time,
                                yValueMapper: (LiveData sales, _) =>
                                    sales.x_acc,
                              ),
                              LineSeries<LiveData, double>(
                                onRendererCreated:
                                    (ChartSeriesController controller) {
                                  _chartSeriesController = controller;
                                },
                                dataSource: chartData,
                                color: const Color.fromARGB(255, 255, 0, 0),
                                xValueMapper: (LiveData sales, _) => sales.time,
                                yValueMapper: (LiveData sales, _) =>
                                    sales.y_acc,
                              ),
                              LineSeries<LiveData, double>(
                                onRendererCreated:
                                    (ChartSeriesController controller) {
                                  _chartSeriesController = controller;
                                },
                                dataSource: chartData,
                                color: const Color.fromARGB(255, 0, 255, 0),
                                xValueMapper: (LiveData sales, _) => sales.time,
                                yValueMapper: (LiveData sales, _) =>
                                    sales.z_acc,
                              )
                            ],
                            primaryXAxis: NumericAxis(
                                majorGridLines: const MajorGridLines(width: 0),
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                                interval: 3,
                                title: AxisTitle(text: 'Time (seconds)')),
                            primaryYAxis: NumericAxis(
                                axisLine: const AxisLine(width: 0),
                                majorTickLines: const MajorTickLines(size: 0),
                                title: AxisTitle(
                                  text: 'Magnetometer',
                                  textStyle: const TextStyle(
                                    color: Color.fromRGBO(3, 3, 3, 1),
                                  ),
                                )))),
                  )),
              Positioned(
                  child: Container(
                      child: Opacity(opacity: 0.6, child: HeatMapApp()))),
              Positioned(
                left: 0.5,
                bottom: 10,
                child: Container(
                    width: 70.0,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.grey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Divider(
                            color: Colors.white,
                            thickness: 2.0,
                            indent: 9,
                            endIndent: 9,
                            height: 45,
                          ),
                          CircleAvatar(
                              radius: 33,
                              backgroundColor: Colors.white,
                              child: Image.asset(
                                'img/magnetologo.png',
                                fit: BoxFit.cover,
                              )),
                          const Divider(
                            color: Colors.white,
                            thickness: 2.0,
                            indent: 9,
                            endIndent: 9,
                            height: 45,
                          ),
                          Text(
                              ' ${(sqrt(_xa * _xa + _ya * _ya + _za * _za) / 1.5).toStringAsFixed(3)} \nµ Tesla',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 19.5)),
                          const Divider(
                            color: Colors.white,
                            thickness: 2.0,
                            indent: 9,
                            endIndent: 9,
                            height: 45,
                          ),
                          IconButton(
                            hoverColor: Colors.grey,
                            onPressed: () async {
                              try {
                                await _initializeControllerFuture;
                                final image = await _controller.takePicture();

                                if (!mounted) return;

                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DisplayPictureScreen(
                                      imagePath: image.path,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                print(e);
                              }
                            },
                            iconSize: 50,
                            color: Colors.white,
                            icon: const Icon(Icons.camera_alt),
                          ),
                          const Divider(
                            color: Colors.white,
                            thickness: 2.0,
                            indent: 9,
                            endIndent: 9,
                            height: 45,
                          ),
                          Text('${_xa.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 19.5)),
                          const Divider(
                            color: Colors.white,
                            thickness: 2.0,
                            indent: 9,
                            endIndent: 9,
                            height: 45,
                          ),
                          Text('${_ya.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 19.5)),
                          const Divider(
                            color: Colors.white,
                            thickness: 2.0,
                            indent: 9,
                            endIndent: 9,
                            height: 45,
                          ),
                          Text('${_za.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 19.5)),
                          const Divider(
                            color: Colors.white,
                            thickness: 2.0,
                            indent: 9,
                            endIndent: 9,
                            height: 45,
                          ),
                        ])
                        ),
              )
            ]);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  double time = 10;
  void updateDataSource(Timer timer) {
    chartData.add(LiveData(time++, _xa, _ya, _za));
    chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, _xa, _ya, _za),
      LiveData(1, _xa, _ya, _za),
      LiveData(2, _xa, _ya, _za),
      LiveData(3, _xa, _ya, _za),
      LiveData(4, _xa, _ya, _za),
      LiveData(5, _xa, _ya, _za),
      LiveData(6, _xa, _ya, _za),
      LiveData(7, _xa, _ya, _za),
      LiveData(8, _xa, _ya, _za),
      LiveData(9, _xa, _ya, _za),
      LiveData(10, _xa, _ya, _za),
    ];
  }
}

class LiveData {
  LiveData(this.time, this.x_acc, this.y_acc, this.z_acc);
  final double time;
  final double x_acc;
  final double y_acc;
  final double z_acc;
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Image.file(
        File(imagePath),
        height: 920,
        width: 630,
      )),
    );
  }
}
