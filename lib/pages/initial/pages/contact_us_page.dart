import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../ads_banner/ads_banner.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  static const String _contactEmail = 'organizamaisgrupomp@gmail.com';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: const Text('Fale conosco'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdsBanner(),
            SizedBox(
              height: 4.h,
            ),
            Text(
              'Fala com a gente 🚀',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Sabemos que cuidar das finanças às vezes pode dar um nó na cabeça 🤯. Mas relaxa, você não está sozinho nessa! Se tiver dúvida, ideia, sugestão ou até mesmo uma bronca (faz parte 😅), fala com a gente por aqui. Nosso time responde rapidinho e adora ouvir o que você tem a dizer. Afinal, esse app é feito pra você – e fica ainda melhor com a sua ajuda 💬✨',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Manda aquele textão no e-mail 📧 ",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _contactEmail,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(
                        const ClipboardData(text: _contactEmail));
                    Get.snackbar(
                      'Copiado',
                      'Email copiado para a área de transferência',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: EdgeInsets.all(12.w),
                    );
                  },
                  child: Icon(
                    Iconsax.clipboard_tick,
                    size: 22.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              'Ou toque no emoji para copiar e colar no seu app de email favorito.',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
