import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Jokes {
  String setup;
  String delivery;

  Jokes({required this.setup, required this.delivery});

  factory Jokes.fromJson(Map<String, dynamic> json) {
    return Jokes(setup: json['setup'], delivery: json['delivery']);
  }
}

Future<Jokes> giveValue() {
  bool x = true;
  return Future(() async {
    final baseUrl = Uri.parse('https://v2.jokeapi.dev/joke/Any');
    final filterUrl = baseUrl.replace(queryParameters: {
      'blacklistFlags': [if (x) 'nsfw', 'racist', 'other'].join(','),
    });

    print(filterUrl.toString());

    final response = await http.get(baseUrl);

    if (response.statusCode == 200) {
      return Jokes.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('error');
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool tellJoke = true;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.amber[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 5,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Why so serious?'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 243, 210, 250),
                  Color.fromARGB(255, 239, 218, 243),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (tellJoke)
                    FutureBuilder(
                      future: giveValue(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  snapshot.data!.setup,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  snapshot.data!.delivery,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Text('Bad Request ☹.. Hit Again');
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        tellJoke = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 8,
                      ),
                      child: Text(
                        'Another Joke!',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
