import 'dart:io' as io;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_model.dart';
 
class RealtimeController extends GetxController {
  final Logger logger = Logger();
  final cameraController = UltralyticsYoloCameraController();
  final threshold = 0.5;
  final double iou = 0.5;
  final int inputSize = 640;

  final List<Color> boundingBoxesColorList = [
    Colors.lightBlueAccent,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
    Colors.pink,
    Colors.brown,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.lime,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.black,
  ];

  late final List<Color> randomBoundingBoxColors;
 
  ObjectDetector? predictor;
  var isReady = false.obs;
 
  @override
  void onInit() {
    super.onInit();
    // Khởi tạo danh sách màu ngẫu nhiên
    _initRandomColors();
  }

  void _initRandomColors() {
    final random = Random();
    randomBoundingBoxColors = List.generate(
      boundingBoxesColorList.length,
      (index) => boundingBoxesColorList[random.nextInt(boundingBoxesColorList.length)],
    );
  }

  Future<void> init() async {
    if (isReady.value) return; // tránh init lại nhiều lần
 
    final permissionGranted = await _checkPermissions();
    if (!permissionGranted) {
      logger.e('❌ Permissions not granted.');
      return;
    }
 
    try {
      final modelPath = await _copyAsset('assets/yolov8n_int8.tflite');
      final metadataPath = await _copyAsset('assets/metadata.yaml');
 
      final model = LocalYoloModel(
        id: 'yolo-v8',
        task: Task.detect,
        format: Format.tflite,
        modelPath: modelPath,
        metadataPath: metadataPath,
      );
 
      predictor = ObjectDetector(model: model);
      await predictor!.loadModel(useGpu: true);
 
      logger.i('✅ Model loaded successfully');
      isReady.value = true;
    } catch (e) {
      logger.e('❌ Error during model loading: $e');
    }
  }
 
  Future<String> _copyAsset(String assetPath) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
 
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
    }
 
    return file.path;
  }
 
  Future<bool> _checkPermissions() async {
    List<Permission> permissions = [];
 
    if (!await Permission.camera.isGranted) {
      permissions.add(Permission.camera);
    }
 
    if (permissions.isEmpty) return true;
 
    final statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }
}