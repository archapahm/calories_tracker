import 'package:calories_tracker/services/authorization.dart';
import 'package:calories_tracker/views/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Selector Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DateSelectorPage(),
    );
  }
}

class FoodItem {
  final String name;
  final double calories;

  FoodItem({required this.name, required this.calories});

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      calories: json['calories'],
    );
  }
}

class DateSelectorPage extends StatefulWidget {
  @override
  _DateSelectorPageState createState() => _DateSelectorPageState();
}

class _DateSelectorPageState extends State<DateSelectorPage> {
  List<DateTime> selectedDates = [];

  final bool useDissmissible = false;
  final Authorization auth = Authorization();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && !selectedDates.contains(picked)) {
      setState(() {
        selectedDates.add(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = (auth.authInst.currentUser == null
        ? ''
        : auth.authInst.currentUser!.uid);
    String? currentUserName = (auth.authInst.currentUser == null
        ? ''
        : auth.authInst.currentUser!.displayName);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Dates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              bool status = await auth.logOut();
              if (status) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              }
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: Text('Select Date'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedDates.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title:
                      Text('${selectedDates[index].toLocal()}'.split(' ')[0]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailPage(date: selectedDates[index])),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final DateTime date;

  DetailPage({required this.date});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<FoodItem> _foodItems = [];
  double _totalCalories = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  // void initState() {
  //   super.initState();
  //   fetchCalories("10oz steak and 1kg tomato");
  // }

  Future<void> fetchCalories(String query) async {
    final response = await http.get(
      Uri.parse('https://api.calorieninjas.com/v1/nutrition?query=$query'),
      headers: {'X-Api-Key': 'bXZe/ZebuEe5u/ZgzxCQDA==fitF1Hkw5TfQYlvz'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] is List) {
        List<FoodItem> newItems = (data['items'] as List)
            .map((item) => FoodItem.fromJson(item))
            .toList();

        setState(() {
          _foodItems = [..._foodItems, ...newItems];
          _totalCalories =
              _foodItems.fold(0, (sum, item) => sum + item.calories);
        });
      } else {
        throw Exception('Invalid data format: items is not a List');
      }
    } else {
      throw Exception('Failed to load calories data');
    }
  }

  void addFoodItem() async {
    String query = _controller.text;
    if (query.isNotEmpty) {
      await fetchCalories(query);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Tracker'),
      ),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Enter meal',
                    border: OutlineInputBorder(),
                  ))),
          ElevatedButton(
            onPressed: addFoodItem,
            child: Text('Add'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _foodItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_foodItems[index].name),
                  trailing: Text('${_foodItems[index].calories} cal'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Total Calories: $_totalCalories cal'),
          ),
        ],
      ),
    );
  }
}
