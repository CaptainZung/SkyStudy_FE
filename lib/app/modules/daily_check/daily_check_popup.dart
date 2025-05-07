import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'daily_check_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        padding: const EdgeInsets.all(32),
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(
          maxWidth: 600,
          minWidth: 400,
          minHeight: 250,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
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
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final days = controller.checkedDays;
                final weekDays = ['Ngày 1', 'Ngày 2', 'Ngày 3', 'Ngày 4', 'Ngày 5', 'Ngày 6', 'Ngày 7'];
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isChecked = days[index];
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isChecked ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 70,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/points.png',
                                  width: 30,
                                  height: 30,
                                ),
                                if (isChecked)
                                  const Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                Positioned(
                                  bottom: 8,
                                  child: Text(
                                    weekDays[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final index = i + 4;
                        final isChecked = days[index];
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isChecked ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 70,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/points.png',
                                  width: 30,
                                  height: 30,
                                ),
                                if (isChecked)
                                  const Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                Positioned(
                                  bottom: 8,
                                  child: Text(
                                    weekDays[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              await controller.fetchCheckInStatus();
                            },
                      child: const Text('Điểm danh'),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
