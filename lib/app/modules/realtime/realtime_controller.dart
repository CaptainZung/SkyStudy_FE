import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Detection {
  final List<double> bbox; // [x_center, y_center, width, height]
  final double confidence;
  final String label;
  
  Detection(this.bbox, this.confidence, this.label);
}

class RealtimeController extends GetxController {
  Logger logger = Logger();

  final _modelPath = 'assets/yolo11n_float16.tflite';
  final _inputSize = 640; // Matches model input size
  final _labelsList = [
    'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train',
    'truck', 'boat', 'traffic light', 'fire hydrant', 'stop sign',
    'parking meter', 'bench', 'bird', 'cat', 'dog', 'horse', 'sheep',
    'cow', 'elephant', 'bear', 'zebra', 'giraffe', 'backpack', 'umbrella',
    'handbag', 'tie', 'suitcase', 'frisbee', 'skis', 'snowboard',
    'sports ball', 'kite', 'baseball bat', 'baseball glove', 'skateboard',
    'surfboard', 'tennis racket', 'bottle', 'wine glass', 'cup', 'fork',
    'knife', 'spoon', 'bowl', 'banana', 'apple', 'sandwich', 'orange',
    'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake', 'chair',
    'couch', 'potted plant', 'bed', 'dining table', 'toilet', 'tv',
    'laptop', 'mouse', 'remote', 'keyboard', 'cell phone', 'microwave',
    'oven', 'toaster', 'sink', 'refrigerator', 'book', 'clock', 'vase',
    'scissors', 'teddy bear', 'hair drier', 'toothbrush'
  ];

  var isCameraInitialized = false.obs;
  var detectedClasses = <String>[].obs;
  var cameraLensDirection = CameraLensDirection.back.obs;

  CameraController? cameraController;
  late Interpreter _interpreter;
  late List<int> _inputShape;
  late List<int> _outputShape;

  @override
  void onInit() {
    super.onInit();
    _initializeSystem();
  }

  Future<void> _initializeSystem() async {
    await _setupCamera();
    await _loadModel();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      cameraController = CameraController(
        cameras.firstWhere(
          (c) => c.lensDirection == cameraLensDirection.value,
          orElse: () => cameras.first,
        ),
        ResolutionPreset.medium,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
      _startImageStream();
    } catch (e) {
      Get.snackbar("Error", "Camera initialization failed");
    }
  }

  void _startImageStream() {
    cameraController!.startImageStream((image) {
      _processCameraFrame(image);
    });
  }

  Future<void> _loadModel() async {
    try {
      final options = InterpreterOptions()
      ..threads = 4;
      options.useNnApiForAndroid = true; // Use NNAPI for Android devices
      _interpreter = await Interpreter.fromAsset(_modelPath, options: options);
      
      // Get model input/output shapes
      _inputShape = _interpreter.getInputTensor(0).shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;
      
      logger.i('Input shape: $_inputShape');
      logger.i('Output shape: $_outputShape');
      logger.i('✅ Model loaded');
    } catch (e) {
      logger.e('❌ Model loading error: $e');
      rethrow;
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    if (!isCameraInitialized.value) return;

    try {
      final input = _preprocessImage(image);
      
      // Prepare output buffer
      final output = List<double>.filled(
        _outputShape.reduce((a, b) => a * b), 
        0.0
      );
      
      // Run inference
      _interpreter.run(input, output);

      // Process output
      final detections = _processYoloOutput(output);
      final filteredDetections = _applyNMS(detections, 0.45);
      
      // Update UI
      detectedClasses.value = filteredDetections.map((d) => d.label).toList();
    } catch (e, stack) {
      logger.e('❌ Frame error: $e', stackTrace: stack);
    }
  }

  List<Detection> _processYoloOutput(List<double> output) {
    final detections = <Detection>[];
    final threshold = 0.5;
    final numClasses = _labelsList.length;
    final predictions = output;

    // YOLOv11n output format: 1*84*8400 = 705,600 elements
    // Each detection has 84 values (4 bbox + 80 class scores)
    for (int i = 0; i < 8400; i++) {
      final baseIndex = i * 84;
      
      // Get class scores (skip first 4 bbox values)
      double maxScore = 0;
      int classId = -1;
      for (int j = 0; j < numClasses; j++) {
        final score = predictions[baseIndex + 4 + j];
        if (score > maxScore) {
          maxScore = score;
          classId = j;
        }
      }

      if (maxScore > threshold && classId != -1) {
        // Get bbox [x_center, y_center, width, height]
        final bbox = [
          predictions[baseIndex],
          predictions[baseIndex + 1],
          predictions[baseIndex + 2],
          predictions[baseIndex + 3],
        ];
        detections.add(Detection(bbox, maxScore, _labelsList[classId]));
      }
    }

    return detections;
  }

  List<Detection> _applyNMS(List<Detection> detections, double iouThreshold) {
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    final filteredDetections = <Detection>[];
    
    while (detections.isNotEmpty) {
      // Take detection with highest confidence
      final current = detections.removeAt(0);
      filteredDetections.add(current);
      
      // Remove overlapping detections
      detections.removeWhere((det) {
        return _calculateIoU(current.bbox, det.bbox) > iouThreshold;
      });
    }
    
    return filteredDetections;
  }

  double _calculateIoU(List<double> box1, List<double> box2) {
    // Convert from center coordinates to corner coordinates
    final box1Corner = [
      box1[0] - box1[2]/2, // x1
      box1[1] - box1[3]/2, // y1
      box1[0] + box1[2]/2, // x2
      box1[1] + box1[3]/2  // y2
    ];
    
    final box2Corner = [
      box2[0] - box2[2]/2,
      box2[1] - box2[3]/2,
      box2[0] + box2[2]/2,
      box2[1] + box2[3]/2
    ];
    
    // Calculate intersection area
    final x1 = box1Corner[0] > box2Corner[0] ? box1Corner[0] : box2Corner[0];
    final y1 = box1Corner[1] > box2Corner[1] ? box1Corner[1] : box2Corner[1];
    final x2 = box1Corner[2] < box2Corner[2] ? box1Corner[2] : box2Corner[2];
    final y2 = box1Corner[3] < box2Corner[3] ? box1Corner[3] : box2Corner[3];
    
    final intersection = (x2 - x1) * (y2 - y1);
    if (intersection <= 0) return 0;
    
    // Calculate union area
    final area1 = box1[2] * box1[3];
    final area2 = box2[2] * box2[3];
    final union = area1 + area2 - intersection;
    
    return intersection / union;
  }

  Float32List _preprocessImage(CameraImage image) {
    final rgbBytes = _convertYUV420toRGB(image);
    final resized = _resizeImage(rgbBytes, image.width, image.height, _inputSize, _inputSize);

    final input = Float32List(_inputSize * _inputSize * 3);
    
    // Normalize pixel values to 0-1 (YOLO expects this)
    for (int i = 0; i < resized.length; i++) {
      input[i] = resized[i] / 255.0;
    }
    
    return input;
  }

  Uint8List _convertYUV420toRGB(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yBuffer = image.planes[0].bytes;
    final uBuffer = image.planes[1].bytes;
    final vBuffer = image.planes[2].bytes;
    final uvPixelStride = image.planes[1].bytesPerPixel!;

    final rgbBytes = Uint8List(width * height * 3);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final uvIndex = uvPixelStride * ((y >> 1) * (width >> 1) + (x >> 1));
        final yIndex = y * width + x;

        final yVal = yBuffer[yIndex];
        final uVal = uBuffer[uvIndex];
        final vVal = vBuffer[uvIndex];

        var r = yVal + 1.402 * (vVal - 128);
        var g = yVal - 0.344136 * (uVal - 128) - 0.714136 * (vVal - 128);
        var b = yVal + 1.772 * (uVal - 128);

        r = r.clamp(0, 255).toDouble();
        g = g.clamp(0, 255).toDouble();
        b = b.clamp(0, 255).toDouble();

        final index = yIndex * 3;
        rgbBytes[index] = r.round();
        rgbBytes[index + 1] = g.round();
        rgbBytes[index + 2] = b.round();
      }
    }

    return rgbBytes;
  }

  Uint8List _resizeImage(Uint8List input, int srcW, int srcH, int dstW, int dstH) {
    final output = Uint8List(dstW * dstH * 3);
    final xRatio = srcW / dstW;
    final yRatio = srcH / dstH;

    for (int y = 0; y < dstH; y++) {
      for (int x = 0; x < dstW; x++) {
        final srcX = (x * xRatio).toInt();
        final srcY = (y * yRatio).toInt();
        final srcIndex = (srcY * srcW + srcX) * 3;
        final dstIndex = (y * dstW + x) * 3;

        output[dstIndex] = input[srcIndex];
        output[dstIndex + 1] = input[srcIndex + 1];
        output[dstIndex + 2] = input[srcIndex + 2];
      }
    }

    return output;
  }

  Future<void> toggleCamera() async {
    cameraLensDirection.value = cameraLensDirection.value == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    await cameraController?.dispose();
    await _setupCamera();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    _interpreter.close();
    super.onClose();
  }
}