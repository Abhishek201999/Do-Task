import 'package:flutter/material.dart';

class AddTask extends StatefulWidget {
  final Function save;
  AddTask(this.save);

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _taskController = TextEditingController();
  bool isButtonEnabled = false;

  void _submitData() {
    final enteredTask = _taskController.text;
    widget.save(enteredTask);
  }

  @override
  void initState() {
    super.initState();
    _taskController.addListener(isEnabled);
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  bool isEnabled() {
    setState(() {
      if (_taskController.text.isNotEmpty) {
        isButtonEnabled = true;
      }
    });
    return isButtonEnabled;
  }

  @override
  Widget build(BuildContext context) {
    var keyHeight = MediaQuery.of(context).viewInsets.bottom + 100;

    return Container(
      height: keyHeight,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'What would you like to do?',
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.deepPurple,
                ),
                onPressed: _taskController.text.isNotEmpty
                    ? () => _submitData()
                    : () {},
              ),
            ),
            onChanged: (val) => isEnabled(),
            controller: _taskController,
            onSubmitted: (_) => _submitData(),
          ),
        ],
      ),
    );
  }
}
