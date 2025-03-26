import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img;

class DetectionController extends GetxController {
  CameraController? cameraController;
  var isCameraInitialized = false.obs;
  var detectedObjects = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  final Dio dio = Dio();
  final Logger logger = Logger();
  bool _isProcessing = false;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        logger.e('No cameras available on this device');
        errorMessage.value = 'No cameras available on this device';
        return;
      }

      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );

      await cameraController!.initialize().then((_) {
        if (Get.isRegistered<DetectionController>()) {
          isCameraInitialized.value = true;
          logger.i('Camera initialized successfully');
          errorMessage.value = '';
          startImageStream();
        }
      }).catchError((e) {
        logger.e('Error initializing camera: $e');
        errorMessage.value = 'Error initializing camera: $e';
      });
    } catch (e) {
      logger.e('Unexpected error while initializing camera: $e');
      errorMessage.value = 'Unexpected error: $e';
    }
  }

  void startImageStream() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      logger.w('Camera is not initialized for streaming');
      errorMessage.value = 'Camera is not initialized for streaming';
      return;
    }

    cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessing) return;
      _isProcessing = true;

      try {
        // Chuyển CameraImage thành base64
        final bytes = await _convertCameraImageToBytes(image);
        final base64Image = base64Encode(bytes);

        // Gửi khung hình lên server
        await detectObjects(base64Image);
      } catch (e) {
        logger.e('Error processing image stream: $e');
        errorMessage.value = 'Error processing image stream: $e';
      } finally {
        _isProcessing = false;
      }
    });
  }

  // Chuyển CameraImage thành bytes (định dạng JPEG)
  Future<Uint8List> _convertCameraImageToBytes(CameraImage image) async {
    try {
      // Chuyển YUV sang RGB
      final yuvImage = img.Image(
        width: image.width,
        height: image.height,
      );

      final yBuffer = image.planes[0].bytes;
      final uBuffer = image.planes[1].bytes;
      final vBuffer = image.planes[2].bytes;

      // Chuyển đổi YUV sang RGB
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final int uvIndex = (x ~/ 2) + (y ~/ 2) * (image.width ~/ 2);
          final int index = y * image.width + x;

          final int yp = yBuffer[index];
          final int up = uBuffer[uvIndex];
          final int vp = vBuffer[uvIndex];

          // Chuyển YUV sang RGB
          int r = (yp + vp * 1436 / 1024 - 179).round();
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
          int b = (yp + up * 1814 / 1024 - 227).round();

          r = r.clamp(0, 255);
          g = g.clamp(0, 255);
          b = b.clamp(0, 255);

          yuvImage.setPixelRgb(x, y, r, g, b);
        }
      }

      // Chuyển RGB sang JPEG
      final jpegBytes = img.encodeJpg(yuvImage);
      return Uint8List.fromList(jpegBytes);
    } catch (e) {
      logger.e('Error converting CameraImage to bytes: $e');
      throw Exception('Failed to convert CameraImage to bytes: $e');
    }
  }

  Future<void> detectObjects(String base64Image) async {
    try {
      logger.i('Sending frame to detection API');
      final response = await dio.post(
        'http://10.0.2.2:5000/detect',
        data: {'image': base64Image},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          detectedObjects.clear();
          detectedObjects.addAll(List<Map<String, dynamic>>.from(data['objects']));
          for (var i = 0; i < detectedObjects.length; i++) {
            detectedObjects[i]['color'] = Colors.primaries[i % Colors.primaries.length];
          }
          logger.i('Detection successful: ${detectedObjects.length} objects detected');
        } else {
          logger.e('Detection failed: ${data['message']}');
          errorMessage.value = 'Detection failed: ${data['message']}';
        }
      } else {
        logger.e('Failed to call detection API: ${response.statusCode}');
        errorMessage.value = 'Failed to call detection API: ${response.statusCode}';
      }
    } catch (e) {
      logger.e('Error during detection: $e');
      errorMessage.value = 'Error during detection: $e';
    } finally {
      update();
    }
  }

  @override
  void onClose() {
    cameraController?.stopImageStream();
    cameraController?.dispose();
    logger.i('DetectionController closed');
    super.onClose();
  }
}