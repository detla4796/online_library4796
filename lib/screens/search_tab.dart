import 'package:flutter/material.dart';
import '../controllers/book_controller.dart';

class SearchTab extends StatefulWidget {
  final BookController controller;

  const SearchTab({
    super.key,
    required this.controller,
  });

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    
    final results = widget.controller.books.where((book) {
      final author = widget.controller.authors
          .firstWhere((a) => a.id == book.authorId);
      
      final queryNorm = query.trim().toLowerCase();
      final titleNorm = book.title.trim().toLowerCase();
      final authorNorm = author.fullName.trim().toLowerCase();
      
      return titleNorm.contains(queryNorm) || authorNorm.contains(queryNorm);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск по названию или автору',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: query.isEmpty
              ? Center(child: Text('Введите поисковый запрос'))
              : results.isEmpty
                  ? Center(child: Text('Ничего не найдено'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final book = results[index];
                        final author = widget.controller.authors
                            .firstWhere((a) => a.id == book.authorId);

                        return ListTile(
                          title: Text(book.title),
                          subtitle: Text(author.fullName),
                          leading: Icon(Icons.book),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}