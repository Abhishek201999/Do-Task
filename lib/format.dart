import 'package:flutter/material.dart';
import 'package:todo/models/todo-item.dart';
import 'package:intl/intl.dart';

class Format extends StatefulWidget {
  final TodoItem item;
  final Function delete;
  final Function toggle;

  Format({this.item, this.delete, this.toggle});

  @override
  _FormatState createState() => _FormatState();
}

class _FormatState extends State<Format> {
  String timeFormat(TodoItem item) {
    String formatedTime = '';
    DateTime time;
    if (item.reminder != null) {
      time = DateTime.parse(item.reminder);
      if (time.day == DateTime.now().day) {
        formatedTime = DateFormat(DateFormat.HOUR_MINUTE).format(time);
      } else if (time.day == DateTime.now().day + 1) {
        formatedTime = 'Tomorrow';
      } else if (time != DateTime.now()) {
        formatedTime = DateFormat(DateFormat.ABBR_MONTH_DAY).format(time);
      }
    }

    return formatedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.item.id.toString()),
      child: ListTile(
        contentPadding: EdgeInsets.all(3),
        title: widget.item.complete
            ? Text(
                widget.item.task,
                style: TextStyle(decoration: TextDecoration.lineThrough),
              )
            : Text(widget.item.task),
        leading: IconButton(
          icon: widget.item.complete
              ? const Icon(
                  Icons.check_box,
                  color: Colors.lightBlueAccent,
                )
              : const Icon(Icons.check_box_outline_blank),
          onPressed: () => widget.toggle(widget.item),
        ),
        trailing: Padding(
          padding: EdgeInsets.all(8.0),
          child: widget.item.complete
              ? Text(
                  timeFormat(widget.item),
                  style: TextStyle(decoration: TextDecoration.lineThrough),
                )
              : Text(
                  timeFormat(widget.item),
                ),
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => widget.delete(widget.item),
      background: Container(
        padding: const EdgeInsets.all(6),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
        color: Colors.red,
      ),
    );
  }
}
