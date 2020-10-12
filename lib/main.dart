import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:date_format/date_format.dart';
import 'common/Global.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TODO DEMO',
        theme: ThemeData(primarySwatch: Colors.red),
        home: TodoList());
  }
}

class TodoList extends StatefulWidget {
  TodoList({Key key}) : super(key: key);
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  // 获取缓存数据
  _TodoListState() {
    Global.getData().then((value) {
      setState(() => this.todoLists = value);
    });
  }

  final SlidableController slidableController = SlidableController();
  List todoLists = [];
  int _currentIndex = 0;
  String date = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
  List appTabs = [
    BottomNavigationBarItem(icon: Icon(Icons.toc), title: Text('ALL')),
    BottomNavigationBarItem(icon: Icon(Icons.alarm), title: Text('ACTIVE')),
    BottomNavigationBarItem(
        icon: Icon(Icons.alarm_on), title: Text('COMPLETED'))
  ];
  @override
  Widget build(BuildContext context) {
    int activeLen = todoLists.where((item) => !item['selected']).length;
    String title =
        activeLen > 0 ? 'TodoList($activeLen items left)' : 'TodoList';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(
            Icons.playlist_add_check,
            color: Colors.white,
          ),
          onPressed: _checkedAllTodos,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addTodos(context),
          )
        ],
      ),
      body: _todoState() ? ListView(children: _renderTodos()) : tipText(),
      floatingActionButton: FloatingActionButton(
        onPressed: _emptyTodos,
        child: Icon(
          Icons.delete,
          size: 22,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [...appTabs],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // 全选/取消全选
  _checkedAllTodos() {
    bool checkedStatus = todoLists.every((element) => element['selected']);
    setState(
        () => todoLists.forEach((item) => item['selected'] = !checkedStatus));
    _updateTodoList(todoLists);
  }

  // _todoState => 每个tabs应该显示todo-items or tiptext？
  bool _todoState() {
    if (_currentIndex == 0) return todoLists.length > 0;
    return !todoLists.every(
        (item) => (_currentIndex == 1) ? item['selected'] : !item['selected']);
  }

  // 多条件控制渲染todos
  List<Widget> _renderTodos() {
    if (_currentIndex == 0)
      return todoLists.map((item) => todoItem(item)).toList();
    return todoLists.map((item) {
      bool flag = (_currentIndex == 1) ? !item['selected'] : item['selected'];
      return flag ? todoItem(item) : SizedBox();
    }).toList();
  }

  // 底部tabs切换
  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  // 添加事项
  void _addTodos(context) {
    String date = formatDate(
        DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add todo'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'what needs to be done?',
          ),
          onSubmitted: (value) {
            Map temp = {
              'selected': false,
              'date': date,
              'value': value,
            };
            setState(() => todoLists.add(temp));
            _updateTodoList(todoLists);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  // 清空已完成事项
  void _emptyTodos() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Prompt'),
          content: Text('empty completed items?'),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text('Confirm'),
              onPressed: () {
                if (todoLists.length <= 0) return Navigator.of(context).pop();
                setState(
                    () => todoLists.removeWhere((item) => item['selected']));
                _updateTodoList(todoLists);
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );

  // 长按显示详情
  void _showDetails(item) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('items details'),
          content: ListTile(
            title: Text('Founded in ${item['date']}'),
            subtitle: Text(item['value']),
          ),
        ),
      );

  // todoLists-card
  Widget todoItem(Map item) {
    return Slidable(
      key: Key(item['date']),
      controller: slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: todo(item),
      secondaryActions: [
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            setState(() => todoLists.remove(item));
            _updateTodoList(todoLists);
          },
        )
      ],
    );
  }

  // todoLists-card-items
  Widget todo(Map item) {
    bool _todoSwitch = item['selected'];
    final textStyle = TextStyle(
        decoration:
            _todoSwitch ? TextDecoration.lineThrough : TextDecoration.none,
        color: _todoSwitch ? Colors.black45 : Colors.black);

    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(10, 2.5, 10, 2.5),
      onTap: () {
        setState(() => item['selected'] = !item['selected']);
        _updateTodoList(todoLists);
      },
      onLongPress: () => _showDetails(item),
      title: Text(
        item['date'].toString(),
        style: textStyle,
      ),
      subtitle: Text(
        item['value'],
        style: textStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      leading: Icon(
        _todoSwitch ? Icons.check_circle : Icons.check_circle_outline,
        size: 20,
      ),
      // trailing: IconButton(
      //   icon: Icon(Icons.close),
      //   iconSize: 20,
      //   color: Colors.red,
      //   onPressed: () => setState(() => todoLists.remove(item)),
      // ),
    );
  }

  // 无todos时的center-text提示
  Widget tipText() {
    return Center(
      child: Text(
        'None Todos',
        style: TextStyle(color: Colors.grey, fontSize: 16.0),
      ),
    );
  }

  // 更新数据
  _updateTodoList(todoLists) => Global.saveData(todoLists);
}
