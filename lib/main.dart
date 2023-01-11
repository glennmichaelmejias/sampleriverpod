import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

final searchController = TextEditingController();

class SearchResults with ChangeNotifier {
  List<dynamic> _results = [];

  List<dynamic> get results => _results;

  set results(List<dynamic> value) {
    _results = value;
    notifyListeners();
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => SearchResults(),
        child: SearchPage(),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Github Repo Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    final query = searchController.text;
                    if (query.isEmpty) {
                      Provider.of<SearchResults>(context, listen: false)
                          .results = [];
                      return;
                    }
                    final response = await http.get(Uri.parse(
                        'https://api.github.com/search/repositories?q=$query'));
                    final results = json.decode(response.body)['items'];
                    Provider.of<SearchResults>(context, listen: false).results =
                        results;
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<SearchResults>(
              builder: (context, searchResults, _) {
                final results = searchResults.results;
                if (results.isEmpty) {
                  return Center(child: Text('No results'));
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final repo = results[index];
                    return ListTile(
                      title: Text(repo['full_name']),
                      subtitle: Text(repo['html_url']),
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
