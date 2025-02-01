import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/transaction_controller.dart';

class TransactionPage extends StatelessWidget {
  final controller = Get.put(TransactionController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: controller.primaryColor,
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.transactionType.value,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(value: 'receita', child: Text('receita')),
                                DropdownMenuItem(value: 'despesa', child: Text('despesa')),
                                DropdownMenuItem(value: 'transferência', child: Text('transferência')),
                              ],
                              onChanged: (value) => controller.transactionType.value = value!,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        child: Text('aplicar', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          // Add your save logic here
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ),

                // Value input section
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('valor', style: TextStyle(color: Colors.white)),
                      Row(
                        children: [
                          Text(
                            'R\$ ${controller.value.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              // Add your value edit logic here
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.calculate, color: Colors.white),
                            onPressed: () {
                              // Add your calculator logic here
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Form section
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('título'),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'título',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('descrição'),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'adicione uma descrição',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('data'),
                          Row(
                            children: [
                              ElevatedButton(
                                child: Text('hoje'),
                                onPressed: () => controller.selectedDate.value = DateTime.now(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: controller.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              OutlinedButton(
                                child: Text('ontem'),
                                onPressed: () => controller.selectedDate.value = DateTime.now().subtract(Duration(days: 1)),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              OutlinedButton(
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today),
                                    SizedBox(width: 4),
                                    Text('selecionar data'),
                                  ],
                                ),
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: controller.selectedDate.value,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) controller.selectedDate.value = date;
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text('categoria'),
                          ListTile(
                            title: Text('selecione'),
                            trailing: Icon(Icons.chevron_right),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onTap: () {
                              // Add your category selection logic here
                            },
                          ),
                          SizedBox(height: 16),
                          Text('conta ou cartão'),
                          ListTile(
                            title: Text('selecione'),
                            trailing: Icon(Icons.chevron_right),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onTap: () {
                              // Add your account selection logic here
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
