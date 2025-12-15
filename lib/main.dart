import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Модель для пользователя
class User {
  final String name;
  final String title;
  final String text;
  


  User({
    required this.name,
    required this.title,
    required this.text,

  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      title: json['title'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'text': text,
    };
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mock API Users',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];
  bool isLoading = false;
  bool isAddingUser = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  // Метод для отображения ошибок через SnackBar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Метод для загрузки пользователей
  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('https://6939834cc8d59937aa082275.mockapi.io/project'));
      if (response.statusCode == 200) {
        setState(() {
          users = (json.decode(response.body) as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();
        });
      } else {
        showErrorSnackBar("Ошибка при загрузке данных!");
      }
    } catch (e) {
      print("Ошибка загрузки: $e");
      showErrorSnackBar("Не удалось загрузить данные.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Метод для добавления нового пользователя
  Future<void> addUser() async {
    if (_nameController.text.isEmpty) {
      showErrorSnackBar("Имя не может быть пустым");
      return;
    }

    setState(() {
      isAddingUser = true;
    });

    final newUser = User(
      name: _nameController.text,
      title: _titleController.text,
      text: _textController.text,
    );

    try {
      final response = await http.post(
        Uri.parse('https://6939834cc8d59937aa082275.mockapi.io/project'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(newUser.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          users.add(User.fromJson(json.decode(response.body)));
        });
      }
    } catch (e) {
      print("Ошибка добавления пользователя: $e");
      showErrorSnackBar("Ошибка при добавлении пользователя.");
    } finally {
      setState(() {
        isAddingUser = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Список пользователей')),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Автор'),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Заголовок'),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'Текст'),
              ),
            ),

            ElevatedButton(
              onPressed: isAddingUser ? null : addUser,
              child: isAddingUser
                  ? CircularProgressIndicator()
                  : Text('Добавить пользователя'),
            ),

            SizedBox(height: 20),

            Container(
              height: 400,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  user.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 6),

                                Text(
                                  user.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),

                                SizedBox(height: 6),

                                Text(
                                  user.text,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),

                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchUsers,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
