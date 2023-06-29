import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

Map<String, bool> blacklistFlags = {
  'nsfw': false,
  'racist': false,
  'sexist': false,
  'religious': false,
  'political': false,
  'explicit': false,
};

Map<String, bool> paramList = {
  'Programming': false,
  'Miscellaneous': false,
  'Dark': false,
  'Pun': false,
  'Spooky': false,
  'Christmas': false,
};

class Jokes {
  String setup;
  String delivery;

  Jokes({required this.setup, required this.delivery});

  factory Jokes.fromJson(Map<String, dynamic> json) {
    return Jokes(setup: json['setup'], delivery: json['delivery']);
  }
}

String params = 'Any';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool tellJoke = true;

  @override
  Widget build(BuildContext context) {
    Future<Jokes> giveValue() {
      return Future(
        () async {
          dynamic filterUrl = 'https://v2.jokeapi.dev/joke/$params';

          final blackList = [
            if (blacklistFlags['nsfw'] == true) 'nsfw',
            if (blacklistFlags['racist'] == true) 'racist',
            if (blacklistFlags['sexist'] == true) 'sexist',
            if (blacklistFlags['religious'] == true) 'religious',
            if (blacklistFlags['political'] == true) 'political',
            if (blacklistFlags['explicit'] == true) 'explicit'
          ];

          final addParams = [
            if (paramList['Programming'] == true) 'Programming',
            if (paramList['Miscellaneous'] == true) 'Miscellaneous',
            if (paramList['Dark'] == true) 'Dark',
            if (paramList['Pun'] == true) 'Pun',
            if (paramList['Spooky'] == true) 'Spooky',
            if (paramList['Christmas'] == true) 'Christmas',
          ];

          if (addParams.isNotEmpty) {
            params = addParams.join(',');
            filterUrl = 'https://v2.jokeapi.dev/joke/$params';
          }

          if (blackList.isNotEmpty) {
            filterUrl = Uri.parse(filterUrl).replace(queryParameters: {
              'blacklistFlags': blackList.join(','),
            }).toString();
          }

          final response = await http.get(Uri.parse(filterUrl));

          if (response.statusCode == 200) {
            return Jokes.fromJson(jsonDecode(response.body));
          } else {
            throw Exception('error');
          }
        },
      );
    }

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
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (tellJoke)
                    FutureBuilder(
                      future: giveValue(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    snapshot.data!.setup,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    snapshot.data!.delivery,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Expanded(
                            // height: 300,
                            child: Center(
                                child: Text('Bad Request ☹.. Hit Again')),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        tellJoke = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      animationDuration: const Duration(seconds: 1),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.0,
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
                  const SizedBox(
                    height: 30,
                  ),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: blacklistFlags.entries.map(
                      (entry) {
                        final key = entry.key;
                        final value = entry.value;

                        return ElevatedButton(
                          onPressed: () {
                            setState(
                              () {
                                if (blacklistFlags[key] == true) {
                                  blacklistFlags[key] = false;
                                } else {
                                  blacklistFlags[key] = true;
                                }

                                tellJoke = true;
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: value
                                ? const Color.fromARGB(255, 92, 91, 91)
                                : Colors.redAccent,
                          ),
                          child: Text(key),
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: paramList.entries.map(
                      (entry) {
                        final key = entry.key;
                        final value = entry.value;

                        return ElevatedButton(
                          onPressed: () {
                            setState(
                              () {
                                if (paramList[key] == true) {
                                  paramList[key] = false;
                                } else {
                                  paramList[key] = true;
                                }

                                tellJoke = true;
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: value
                                ? const Color.fromARGB(255, 92, 91, 91)
                                : Colors.green,
                          ),
                          child: Text(key),
                        );
                      },
                    ).toList(),
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
