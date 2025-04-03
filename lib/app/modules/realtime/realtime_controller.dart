import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:skystudy/app/api/ai_api.dart';
import 'package:logger/logger.dart';

class RealtimeController extends GetxController {
  var isCameraInitialized = false.obs;
  CameraController? cameraController;
  var errorMessage = ''.obs;
  var detectedObjects = <Map<String, dynamic>>[].obs;
  var processedImageBase64 = ''.obs;
  List<CameraDescription> cameras = [];
  WebSocketChannel? channel;
  final Logger logger = Logger();
  var isConnected = false.obs;
  var isProcessing = false.obs;
  var frameRate = 10.obs; // số khung hình mỗi giây

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      // Yêu cầu quyền truy cập camera
      var status = await Permission.camera.request();
      if (!status.isGranted) {
        errorMessage.value = 'Từ chối quyền truy cập camera';
        logger.e('Từ chối quyền truy cập camera');
        return;
      }

      // Lấy danh sách camera có sẵn
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage.value = 'Không tìm thấy camera';
        logger.e('Không tìm thấy camera');
        return;
      }

      // Khởi tạo camera controller
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium, // Độ phân giải trung bình để tối ưu hiệu suất
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
      
      // Kết nối WebSocket sau khi camera sẵn sàng
      connectWebSocket();
      
      // Bắt đầu gửi khung hình
      startFrameStream();
      
    } catch (e) {
      errorMessage.value = 'Lỗi khởi tạo camera: $e';
      logger.e('Lỗi khởi tạo camera: $e');
      }
    }

  void connectWebSocket() {
    try {
      logger.i('Đang kết nối tới WebSocket: ${ApiConfig.websocketEndpoint}');
      channel = IOWebSocketChannel.connect(
        Uri.parse(ApiConfig.websocketEndpoint),
        pingInterval: Duration(seconds: 10),
      );

      channel!.stream.listen(
        handleWebSocketMessage,
        onError: (error) {
          logger.e('Lỗi WebSocket: $error');
          errorMessage.value = 'Lỗi WebSocket: $error';
          isConnected.value = false;
          reconnectWebSocket();
        },
        onDone: () {
          logger.w('Kết nối WebSocket đã đóng');
          errorMessage.value = 'Kết nối WebSocket đã đóng';
          isConnected.value = false;
          reconnectWebSocket();
        },
      );
      
      isConnected.value = true;
      errorMessage.value = '';
      logger.i('Kết nối WebSocket thành công');
      
    } catch (e) {
      logger.e('Lỗi kết nối WebSocket: $e');
      errorMessage.value = 'Lỗi kết nối WebSocket: $e';
      isConnected.value = false;
      reconnectWebSocket();
    }
  }

  void handleWebSocketMessage(dynamic message) {
    try {
      if (message is String) {
        // Xử lý tin nhắn JSON (đối tượng phát hiện)
        final data = jsonDecode(message);
        
        if (data is Map && data.containsKey('objects')) {
          detectedObjects.assignAll(
            List<Map<String, dynamic>>.from(data['objects'])
          );
          logger.i('Cập nhật đối tượng phát hiện: ${detectedObjects.length}');
        }
        
        if (data is Map && data.containsKey('ping')) {
          logger.i('Nhận tín hiệu ping giữ kết nối');
        }
      } else if (message is Uint8List) {
        // Xử lý tin nhắn nhị phân (khung hình ảnh)
        processedImageBase64.value = base64Encode(message);
        logger.i('Nhận khung hình ảnh đã xử lý');
      }
    } catch (e) {
      logger.e('Lỗi xử lý tin nhắn WebSocket: $e');
    }
  }

  void reconnectWebSocket() {
    Future.delayed(Duration(seconds: 3), () {
      logger.i('Đang thử kết nối lại WebSocket...');
      connectWebSocket();
    });
  }

  void startFrameStream() {
    Timer.periodic(Duration(milliseconds: (1000 / frameRate.value).round()), (timer) async {
      if (!isConnected.value || !isCameraInitialized.value || isProcessing.value) {
        return;
      }
      
      isProcessing.value = true;
      try {
        final image = await cameraController!.takePicture();
        final bytes = await image.readAsBytes();
        channel?.sink.add(bytes);
        logger.i('Đã gửi khung hình tới WebSocket');
      } catch (e) {
        logger.e('Lỗi khi gửi khung hình: $e');
      } finally {
        isProcessing.value = false;
      }
    });
  }

  Future<void> disposeResources() async {
    try {
      // Đóng kết nối WebSocket
      await channel?.sink.close();
      
      // Giải phóng camera
      if (cameraController != null) {
        if (cameraController!.value.isStreamingImages) {
          await cameraController!.stopImageStream();
        }
        if (cameraController!.value.isInitialized) {
          await cameraController!.dispose();
        }
      }
      
      logger.i('Đã giải phóng tất cả tài nguyên');
    } catch (e) {
      logger.e('Lỗi khi giải phóng tài nguyên: $e');
    }
  }

  @override
  void onClose() {
    disposeResources();
    super.onClose();
  }
}