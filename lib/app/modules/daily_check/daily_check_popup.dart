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
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
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
            const SizedBox(height: 40),
            const Text(
              'Coming soon...',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
