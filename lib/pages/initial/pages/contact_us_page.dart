import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../utils/color.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  static const String _contactEmail = 'organizamaisgrupomp@gmail.com';
  static final Uri _instagramUri =
      Uri.parse('https://www.instagram.com/organizamais.app/');
  static final Uri _tiktokUri =
      Uri.parse('https://www.tiktok.com/@organizamais.app');
  static final Uri _mailtoUri = Uri(scheme: 'mailto', path: _contactEmail);

  Future<void> _openInstagram() async {
    if (!await launchUrl(_instagramUri, mode: LaunchMode.externalApplication)) {
      await launchUrl(_instagramUri, mode: LaunchMode.inAppWebView);
    }
  }

  Future<void> _openTikTok() async {
    if (!await launchUrl(_tiktokUri, mode: LaunchMode.externalApplication)) {
      await launchUrl(_tiktokUri, mode: LaunchMode.inAppWebView);
    }
  }

  Future<void> _openEmail() async {
    await launchUrl(_mailtoUri, mode: LaunchMode.externalApplication);
  }

  Widget _contactTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 16.sp, color: theme.primaryColor),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: DefaultColors.grey20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdsBanner(),
              SizedBox(height: 10.h),
              Text(
                'Estamos sempre prontos para ouvir você. Conta pra gente como podemos ajudar',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: DefaultColors.grey,
                ),
              ),
              SizedBox(height: 10.h),

              // Instagram (substitui telefone)
              _contactTile(
                context: context,
                icon: Iconsax.instagram,
                title: 'Instagram: @organizamais.app',
                subtitle: 'Toque para abrir nosso perfil.',
                onTap: _openInstagram,
              ),

              // TikTok
              _contactTile(
                context: context,
                icon: Iconsax.video_play,
                title: 'TikTok: @organizamais.app',
                subtitle: 'Toque para abrir nosso perfil.',
                onTap: _openTikTok,
              ),

              // Email
              _contactTile(
                context: context,
                icon: Iconsax.sms_tracking,
                title: 'Email: $_contactEmail',
                subtitle: 'Respondemos rapidinho ao seu contato.',
                onTap: _openEmail,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
