import 'dart:io';
import 'package:camera/camera.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:skystudy/app/api/ai_api.dart';
import 'package:skystudy/app/routes/app_pages.dart';

class DetectionController extends GetxController {
  var isCameraInitialized = false.obs;
  CameraController? cameraController;
  var isFlashOn = false.obs;
  var errorMessage = ''.obs;
  var detectedObjects = <Map<String, dynamic>>[].obs;
  var processedImageBase64 = ''.obs;
  var showProcessedImage = false.obs;
  var isLoading = false.obs;

  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;
  final Dio dio = Dio();

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      errorMessage.value = 'Quyền truy cập camera bị từ chối. Vui lòng cấp quyền để sử dụng camera.';
      print('Camera permission denied');
      return;
    }

    if (status.isPermanentlyDenied) {
      errorMessage.value = 'Quyền truy cập camera bị từ chối vĩnh viễn. Vui lòng bật quyền trong cài đặt.';
      print('Camera permission permanently denied');
      return;
    }

    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage.value = 'Không tìm thấy camera trên thiết bị này.';
        print('No cameras found on this device');
        return;
      }

      print('Found ${cameras.length} cameras');
      selectedCameraIndex = 0;
      cameraController = CameraController(
        cameras[selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      print('Initializing camera...');
      await cameraController!.initialize();
      print('Camera initialized successfully');
      isCameraInitialized.value = true;
      update();
    } catch (e) {
      errorMessage.value = 'Lỗi khi khởi tạo camera: $e';
      print('Error initializing camera: $e');
    }
  }

  void toggleFlash() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;
    try {
      isFlashOn.value = !isFlashOn.value;
      await cameraController!.setFlashMode(
        isFlashOn.value ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể bật/tắt đèn flash: $e');
    }
  }

  void switchCamera() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;
    if (cameras.length < 2) return;

    try {
      await cameraController!.dispose();
      selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
      cameraController = CameraController(
        cameras[selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await cameraController!.initialize();
      isFlashOn.value = false;
      update();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chuyển camera: $e');
    }
  }

  Future<void> captureAndPredict() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      Get.snackbar('Lỗi', 'Camera chưa được khởi tạo.');
      print('Camera not initialized');
      return;
    }

    try {
      isLoading.value = true;
      update();

      print('Chụp ảnh...');
      final image = await cameraController!.takePicture();
      print('Ảnh đã chụp: ${image.path}');
      final file = File(image.path);

      if (!file.existsSync()) {
        Get.snackbar('Lỗi', 'Không thể tìm thấy file ảnh đã chụp.');
        print('File ảnh không tồn tại: ${image.path}');
        return;
      }

      final fileSize = await file.length();
      print('Kích thước file ảnh: $fileSize bytes');
      if (fileSize == 0) {
        Get.snackbar('Lỗi', 'File ảnh rỗng. Vui lòng thử lại.');
        print('File ảnh rỗng');
        return;
      }

      print('Chuẩn bị gửi ảnh lên server...');
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      print('Gửi request tới ${ApiConfig.predictEndpoint}');
      final response = await dio.post(
        ApiConfig.predictEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      ).catchError((error) {
        if (error is DioException && error.response != null) {
          print('Lỗi từ server: ${error.response!.statusCode} - ${error.response!.data}');
          Get.snackbar('Lỗi từ server', 'Mã lỗi: ${error.response!.statusCode}\nChi tiết: ${error.response!.data}');
        } else {
          print('Lỗi không xác định: $error');
          Get.snackbar('Lỗi', 'Không thể kết nối tới server: $error');
        }
        throw error;
      });

      print('Nhận response từ server: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = response.data;
        print('Dữ liệu từ server: $data');

        if (data['predictions'] != null && data['predictions'] is List) {
          detectedObjects.clear();
          detectedObjects.addAll(List<Map<String, dynamic>>.from(data['predictions']));
          processedImageBase64.value = data['image']?.toString() ?? '';
          showProcessedImage.value = true;
          print('Đã cập nhật detectedObjects: ${detectedObjects.length} đối tượng');
          print('Điều hướng sang DetectionResultPage...');
          Get.toNamed(
            Routes.detectionresult,
            arguments: {
              'processedImageBase64': processedImageBase64.value,
              'detectedObjects': detectedObjects.toList(),
            },
          );
        } else {
          Get.snackbar('Lỗi', 'Không tìm thấy predictions trong response từ server.');
          print('Không tìm thấy predictions trong response');
        }
      } else {
        Get.snackbar('Lỗi', 'Không thể nhận dạng: ${response.statusCode}');
        print('Lỗi nhận dạng: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Lỗi trong captureAndPredict: $e');
      Get.snackbar('Lỗi', 'Lỗi trong quá trình chụp và nhận diện: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> disposeCamera() async {
    try {
      if (cameraController != null) {
        print('Bắt đầu dispose camera...');
        if (cameraController!.value.isStreamingImages) {
          print('Dừng stream hình ảnh...');
          await cameraController!.stopImageStream();
        }
        if (cameraController!.value.isInitialized) {
          print('Dispose camera controller...');
          await cameraController!.dispose();
        }
        cameraController = null;
        isCameraInitialized.value = false;
        showProcessedImage.value = false;
        detectedObjects.clear();
        processedImageBase64.value = '';
        update();
        print('Camera đã được dispose thành công');
      } else {
        print('CameraController đã là null, không cần dispose');
      }
    } catch (e) {
      print('Lỗi khi dispose camera: $e');
      Get.snackbar('Lỗi', 'Không thể giải phóng camera: $e');
    }
  }

  void navigateToRealtime() {
    print('Chuyển sang RealtimePage...');
    disposeCamera().then((_) {
      Get.offNamed(Routes.realtime);
    });
  }

  @override
  void dispose() {
    Get.delete<DetectionController>();
    super.dispose();
  }

  @override
  void onClose() {
    if (cameraController != null && cameraController!.value.isStreamingImages) {
      cameraController!.stopImageStream();
    }
    cameraController?.dispose();
    cameraController = null;
    detectedObjects.clear();
    print('DetectionController onClose');
    super.onClose();
  }
}