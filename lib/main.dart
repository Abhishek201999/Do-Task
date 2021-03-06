import 'package:flutter/material.dart';
import './models/todo-item.dart';
import './services/db.dart';
import './addTask.dart';
import './format.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await DB.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Do Task',
      home: MyHomePage(),
      theme: ThemeData(
        fontFamily: 'ProductSans',
        brightness: Brightness.light,
        primaryColor: Color.fromRGBO(92, 119, 210, 1),
        accentColor: Color.fromRGBO(92, 119, 210, 0.9),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TodoItem> tasks = [];

  List<TodoItem> get inCompleted =>
      tasks.where((item) => item.complete == false).toList();

  List<Widget> get items => inCompleted
      .map((item) => Format(
            item: item,
            delete: delete,
            toggle: toggle,
          ))
      .toList();

  List<TodoItem> get complete =>
      tasks.where((item) => item.complete == true).toList();

  List<Widget> get doneTask => complete
      .map((item) => Format(
            item: item,
            delete: delete,
            toggle: toggle,
          ))
      .toList();

  void toggle(TodoItem item) async {
    item.complete = !item.complete;
    dynamic result = await DB.update(TodoItem.table, item);
    if (item.complete == true && item.reminder != null) {
      await flutterLocalNotificationsPlugin.cancel(item.id);
    }

    print(result);
    refresh();
  }

  void delete(TodoItem item) async {
    DB.delete(TodoItem.table, item);
    if (item.complete == false && item.reminder != null) {
      await flutterLocalNotificationsPlugin.cancel(item.id);
    }

    refresh();
  }

  void save(int id, String input, String scheduledTime) async {
    Navigator.of(context).pop();
    TodoItem item = TodoItem(
      id: id,
      task: input,
      complete: false,
      reminder: scheduledTime,
    );
    await DB.insert(TodoItem.table, item);
    setState(() => input = '');
    refresh();
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() async {
    List<Map<String, dynamic>> _results = await DB.query(TodoItem.table);
    tasks = _results.map((item) => TodoItem.fromMap(item)).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Do Task'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: const Icon(Icons.format_list_numbered),
              ),
              Tab(
                icon: const Icon(Icons.playlist_add_check),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            items.isEmpty
                ? Center(
                    child: const Text(
                      "Let's get some work done!",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : Center(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return items[index];
                      },
                      itemCount: items.length,
                    ),
                  ),
            doneTask.isEmpty
                ? Center(
                    child: const Text(
                      "Get some work done",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : Center(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return doneTask[index];
                      },
                      itemCount: doneTask.length,
                    ),
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          // backgroundColor: Colors.deepPurple,
          onPressed: () => startAddNewTask(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void startAddNewTask(BuildContext atx) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      context: atx,
      builder: (_) {
        return GestureDetector(
          child: AddTask(save),
          onTap: () {},
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }
}
