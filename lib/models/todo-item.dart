import '../models/model.dart';

class TodoItem extends Model {
  static String table = 'todo_items';

  int id;
  String task;
  bool complete;
  String reminder;

  TodoItem({this.id, this.task, this.complete, this.reminder});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'task': task,
      'complete': complete,
      'reminder': reminder,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  static TodoItem fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      task: map['task'],
      complete: map['complete'] == 1,
      reminder: map['reminder'],
    );
  }
}
