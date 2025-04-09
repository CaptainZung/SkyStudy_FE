import 'package:flutter/material.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';
import 'package:google_fonts/google_fonts.dart';
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'VỀ CHÚNG TÔI',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildMemberCard(
                imagePath: 'assets/images/khai.png',
                quote:
                    'Tôi rất vui khi dự án này được cho ra cộng đồng trẻ em sử dụng. Các em hãy nhớ 1 câu “Học, học nữa, học mãi”',
                role: 'Người thành lập',
                name: 'Chế Quang Khải',
                isReversed: false,
              ),
              SizedBox(height: 10),
              _buildMemberCard(
                imagePath: 'assets/images/dung.png',
                quote:
                    'Máy em dùng thấy hiệu ứng mượt mà với đẹp vậy là biết ai làm rồi đó',
                role: 'Phát triển giao diện',
                name: 'Lê Huỳnh Dũng',
                isReversed: true,
              ),
               SizedBox(height: 10),
              _buildMemberCard(
                imagePath: 'assets/images/hung.png',
                quote:
                    'Mọi thứ hoạt động mượt mà trơn tru không lag là nhờ anh hết đó mấy em',
                role: 'Xử lí Logic',
                name: 'Phạm Tiến Hưng',
                isReversed: false,
              ),
              SizedBox(height: 5),
              _buildMemberCard(
                imagePath: 'assets/images/bach.png',
                quote: '“Chụp nhiều lên mấy em”',
                role: 'Phát triển AI camera',
                name: 'Trần Duy Bách',
                isReversed: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard({
    required String imagePath,
    required String quote,
    required String role,
    required String name,
    required bool isReversed,
  }) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        imagePath,
        width: 140,
        height: 150,
        fit: BoxFit.cover,
      ),
    );

    final quoteText = Expanded(
      child: Text(
        quote,
        style: const TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.italic,
        ),
        textAlign: isReversed ? TextAlign.right : TextAlign.left,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment:
            isReversed ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isReversed ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: isReversed
                ? [quoteText, const SizedBox(width: 12), image]
                : [image, const SizedBox(width: 12), quoteText],
          ),
          const SizedBox(height: 8),
          Text(
            role,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 20,
            ),
            textAlign: isReversed ? TextAlign.right : TextAlign.left,
          ),
          Text(
            name,
            textAlign: isReversed ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
