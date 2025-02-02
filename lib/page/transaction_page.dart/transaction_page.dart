// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  final String? type;

  const TransactionPage({
    Key? key,
    this.type,
  }) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: DropdownButton<String>(
          value: widget.type,
          items: [
            DropdownMenuItem(value: 'receita', child: Text('Receita')),
            DropdownMenuItem(value: 'despesa', child: Text('Despesa')),
            DropdownMenuItem(value: 'transferencia', child: Text('Transferência')),
          ],
          onChanged: (String? newValue) {
            // Implementar mudança de tipo
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Implementar ação de aplicar
            },
            child: Text('aplicar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('valor'),
            Row(
              children: [
                Text(
                  'R\$ ',
                  style: TextStyle(fontSize: 32),
                ),
                Expanded(
                  child: TextField(
                    controller: valueController,
                    style: TextStyle(fontSize: 32),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0,00',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calculate),
                  onPressed: () {
                    // Implementar calculadora
                  },
                ),
              ],
            ),
            SizedBox(height: 24),
            Text('título'),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'título',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('descrição'),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'adicione uma descrição',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('data'),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = DateTime.now();
                    });
                  },
                  child: Text('hoje'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedDate.isAtSameMomentAs(DateTime.now()) ? Colors.green : Colors.grey,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = DateTime.now().subtract(Duration(days: 1));
                    });
                  },
                  child: Text('ontem'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2025),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 8),
                      Text('selecionar data'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('categoria'),
            ListTile(
              title: Text('selecione'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Implementar seleção de categoria
              },
            ),
            SizedBox(height: 16),
            Text('conta ou cartão'),
            ListTile(
              title: Text('selecione'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Implementar seleção de conta/cartão
              },
            ),
          ],
        ),
      ),
    );
  }
}
