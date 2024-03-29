import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tasknode/data/database.dart';
import 'package:tasknode/util/dialog_box.dart';
import 'package:tasknode/util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //reference the hive box
  final _myBox = Hive.box('mybox');

  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {

    // if this is the 1st time ever opening the app, then create the default data
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      // there alredy exists data
      db.loadData();
    }
    super.initState();
  }

  // text controller
  final _controller = TextEditingController();

/*
  // list of todo tasks
  List toDoList = [
    ["Make Tutorial", false],
    ["Do Extercise", false],
  ];
*/

  // checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDatabase();
  }

  // save new task
  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  // create a new task
  void createNewTask() {
    showDialog(
      context: context, 
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  // delete task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 233, 193),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 250, 220, 165),
        // title
        title: Center(
                child: Text(
                  'Task Node',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 250, 220, 165),
        onPressed: createNewTask,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return ToDoTile(
            taskName: db.toDoList[index][0], 
            taskCompleted: db.toDoList[index][1], 
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
      
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 250, 220, 165),
        child: Container(
          padding: EdgeInsets.all(8.0),
            child: Center(
            child: Text(
              'Made with love ❤️ by Aditya',
                style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}