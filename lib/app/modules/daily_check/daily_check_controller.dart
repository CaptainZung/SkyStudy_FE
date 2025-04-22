import 'package:get/get.dart';

class DailyCheckController extends GetxController {
  // Danh sách điểm cho mỗi ngày trong tuần
  var pointsList = [10, 20, 30, 40, 50, 60, 100].obs;

  // Trạng thái điểm danh của mỗi ngày, mặc định là chưa điểm danh
  var checkedIn = [false, false, false, false, false, false, false].obs;

  // Hàm xử lý khi người dùng bấm vào một ngày
  void checkIn(int dayIndex) {
    // Nếu người dùng chưa điểm danh, thì điểm danh và cập nhật trạng thái
    if (!checkedIn[dayIndex]) {
      checkedIn[dayIndex] = true;
      // Cập nhật điểm thưởng (có thể thực hiện thêm các logic khác nếu cần)
      // Ví dụ, có thể thêm số điểm vào một tài khoản người dùng nào đó ở đây
    }
  }

  // Hàm để lấy điểm của ngày đã điểm danh
  int getPointsForDay(int dayIndex) {
    return pointsList[dayIndex];
  }

  // Đóng popup
  void closePopup() {
    Get.back();
  }
}
