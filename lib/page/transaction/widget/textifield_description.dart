import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextFieldDescriptionTransaction extends StatelessWidget {
  const TextFieldDescriptionTransaction({
    super.key,
    required this.titleController,
  });

  final TextEditingController titleController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: titleController,
      decoration: InputDecoration(
        hintText: 'Adicione a descrição',
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16.sp,
        ),
        prefixIcon: Icon(
          Icons.edit_outlined,
          color: Colors.grey,
          size: 24.sp,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
      ),
      style: TextStyle(
        fontSize: 16.sp,
        color: Colors.black87,
      ),
    );
  }
}
