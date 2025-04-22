import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'daily_check_controller.dart';

class DailyCheckPopup extends StatelessWidget {
  const DailyCheckPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyCheckController controller = Get.find<DailyCheckController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Điểm danh hàng ngày',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      controller.closePopup();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final points = controller.pointsList[index];

                    return Obx(() {
                      final isCheckedIn = controller.checkedIn[index];
                      return GestureDetector(
                        onTap: () {
                          if (!isCheckedIn) {
                            controller.checkIn(index);
                            Get.snackbar(
                              'Thành công',
                              'Bạn đã điểm danh ngày $day và nhận được $points điểm!',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          }
                        },
                        child: AnimatedScale(
                          scale: isCheckedIn ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                              color: isCheckedIn ? Colors.green.shade100 : Colors.white,
                              boxShadow: [
                                if (isCheckedIn)
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                  ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Ngày $day',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                isCheckedIn
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check, color: Colors.green),
                                          const SizedBox(width: 5),
                                          Text(
                                            '+$points',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        '+$points',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                const SizedBox(height: 5),
                                day == 7
                                    ? const Icon(
                                        Icons.card_giftcard,
                                        color: Colors.brown,
                                        size: 30,
                                      )
                                    : Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.star,
                                          color: Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}