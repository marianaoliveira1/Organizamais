// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'widgtes/resume_content.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 20.h),
        child: SingleChildScrollView(
          child: SafeArea(
            child: ResumeContent(),
          ),
        ),
      ),
    );
  }
}
