import 'package:flutter/material.dart';
import 'package:todo/models/todo-item.dart';

class Format extends StatelessWidget {
  final TodoItem item;
  final Function delete;
  final Function toggle;

  Format({this.item, this.delete, this.toggle});
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id.toString()),
      child: ListTile(
        contentPadding: EdgeInsets.all(3),
        title: item.complete
            ? Text(
                item.task,
                style: TextStyle(decoration: TextDecoration.lineThrough),
              )
            : Text(item.task),
        leading: IconButton(
          icon: item.complete
              ? const Icon(
                  Icons.check_box,
                  color: Colors.deepPurple,
                )
              : const Icon(Icons.check_box_outline_blank),
          onPressed: () => toggle(item),
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => delete(item),
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
