import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import './main.dart';

class AddTask extends StatefulWidget {
  final Function save;
  AddTask(this.save);

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _taskController = TextEditingController();
  var enteredTask;
  bool isButtonEnabled = false;
  DateTime scheduledDate;
  DateTime pickedDate;

  @override
  Widget build(BuildContext context) {
    var keyHeight = MediaQuery.of(context).viewInsets.bottom + 130;

    return Container(
      height: keyHeight,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              hintText: 'What would you like to do?',
            ),
            onChanged: (val) => isEnabled(),
            controller: _taskController,
            onSubmitted: (_) => _submitData(),
          ),
          Row(
            children: [
              OutlineButton(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
                child: Text('Reminder'),
                onPressed: () async {
                  await _selectDate(context);
                  if (pickedDate != null) {
                    await _selectTime(context);
                  }
                },
              ),
              Spacer(),
              OutlineButton(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
                child: Text('Save'),
                onPressed: _taskController.text.isNotEmpty
                    ? () async {
                        await _submitData();
                      }
                    : () {},
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _submitData() async {
    try {
      enteredTask = _taskController.text;
      String scheduleDateString;
      var id = DateTime.now().millisecond;
      if (scheduledDate != null) {
        await schedule(id);
        scheduleDateString = scheduledDate.toIso8601String();
      }

      widget.save(
        id,
        enteredTask,
        scheduleDateString,
      );
    } catch (error) {
      showErrorDialog();
    }
  }

  Future<DateTime> _selectDate(BuildContext context) async {
    pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    return pickedDate;
  }

  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    setState(() {
      scheduledDate =
          pickedDate.add(Duration(hours: picked.hour, minutes: picked.minute));
    });

    return picked;
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

  Future<void> schedule(int id) async {
    try {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        enteredTask,
        'To Do Notification',
        'Do the task',
        priority: Priority.Max,
        importance: Importance.Max,
        playSound: true,
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics,
        iOSPlatformChannelSpecifics,
      );
      await flutterLocalNotificationsPlugin.schedule(id, 'Task reminder',
          enteredTask, scheduledDate, platformChannelSpecifics);
    } catch (error) {
      showErrorDialog();
    }
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Text('An error occured '),
        );
      },
    );
  }
}
