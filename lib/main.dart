import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

Database db;
Random rand = new Random();

void main() async {
  db = await openDatabase("my_db.db", version: 1,
      onCreate: (database, version) async {
    await database.execute('''create table account(
          _id integer primary key autoincrement,
          name text,
          age int
          )''');
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sqflite demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'sqflite demo app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Account> _accounts = [];

  @override
  void didChangeDependencies() {
    _refreshList();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _accounts.length,
        itemBuilder: (con, index) {
          var account = _accounts[index];
          return ListTile(
            title: Text(account.name),
            subtitle: Text("Age ${account.age}"),
            onTap: () {
              _removeAccount(account);
            },
          );
        },
      ).build(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAccount,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  void _addAccount() async {
    await _insertAccount(db, _makeName(), _makeAge());
    _refreshList();
  }

  void _refreshList() async {
    List<Account> accounts = await _getAllAccount(db);
    setState(() {
      _accounts.clear();
      _accounts.addAll(accounts);
    });
  }

  void _removeAccount(Account account) async {
    await _deleteAccount(db, account);
    _refreshList();
  }
}

List<String> _names = ["moke", "piyo", "mallo", "bill", "steve", "zack"];

String _makeName() {
  return _names[rand.nextInt(1000) % 6];
}

int _makeAge() {
  return rand.nextInt(30) + 5;
}

class Account {
  final int id;
  final String name;
  final int age;

  Account(this.id, this.name, this.age);
}

Future _insertAccount(Database db, String name, int age) async {
  var values = <String, dynamic>{
    "name": name,
    "age": age,
  };
  await db.insert("account", values);
}

Future<List<Account>> _getAllAccount(Database db) async {
  List<Map> results = await db.query("account");
  // map to account list
  return results.map((Map m) {
    int id = m["_id"];
    String name = m["name"];
    int age = m["age"];
    return Account(id, name, age);
  }).toList();
}

Future _updateAccount(Database db, int id, String name, int age) async {
  var values = <String, dynamic>{
    "name": name,
    "age": age,
  };
  await db.update("account", values, where: "_id=?", whereArgs: [id]);
}

Future _deleteAccount(Database db, Account account) async {
  await db.delete("account", where: "_id=?", whereArgs: [account.id]);
}
