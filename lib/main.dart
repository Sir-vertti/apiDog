import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog API Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DogScreen(),
    );
  }
}

class DogScreen extends StatefulWidget {
  const DogScreen({super.key});

  @override
  _DogScreenState createState() => _DogScreenState();
}

class _DogScreenState extends State<DogScreen> {
  String _searchQuery = '';
  String _dogImageUrl = '';
  final String _apiKey =
      'live_EaGP35bPsPssdQrM5Vgx4uJMamM6pCcmau461yO50pxXKOevzr7rzNJ23JVjavte';

  Future<void> _fetchDogImage(String breedName) async {
    final response = await http.get(
      Uri.parse('https://api.thedogapi.com/v1/breeds/search?q=$breedName'),
      headers: {'x-api-key': _apiKey},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final breedId = data[0]['id'];
        final breedResponse = await http.get(
          Uri.parse(
              'https://api.thedogapi.com/v1/images/search?breed_id=$breedId'),
          headers: {'x-api-key': _apiKey},
        );
        if (breedResponse.statusCode == 200) {
          final List<dynamic> breedData = jsonDecode(breedResponse.body);
          if (breedData.isNotEmpty) {
            setState(() {
              _dogImageUrl = breedData[0]['url'];
            });
            return;
          }
        }
      } else {
        setState(() {
          _dogImageUrl = '';
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No results'),
              content: const Text('No images found for the entered dog breed.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      throw Exception('Failed to load dog image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Breed Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Enter a dog breed'),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _fetchDogImage(_searchQuery);
              },
              child: const Text('Search'),
            ),
            const SizedBox(height: 16),
            _dogImageUrl.isNotEmpty
                ? Expanded(
                    child: Image.network(
                      _dogImageUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
