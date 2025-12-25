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
    final query = _searchController.text.toLowerCase().trim();
    
    final results = widget.controller.books.where((book) {
      final author = widget.controller.authors
          .firstWhere((a) => a.id == book.authorId);
      
      final titleNorm = book.title.trim().toLowerCase();
      final authorNorm = author.fullName.trim().toLowerCase();
      
      String? readerName;
      if (book.status == 'loaned' && book.id != null) {
        final loanInfo = widget.controller.loanInfoByBook[book.id];
        if (loanInfo != null) {
          readerName = (loanInfo['readerName'] as String?)?.trim().toLowerCase();
        }
      }
      
      return titleNorm.contains(query) || authorNorm.contains(query) || (readerName != null && readerName.contains(query));
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск по названию, автору или читателю',
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
                        
                        final isOnShelf = book.status == 'on_shelf';
                        final loanInfo = widget.controller.loanInfoByBook[book.id];
                        
                        String subtitle = author.fullName;
                        if (!isOnShelf && loanInfo != null) {
                          subtitle += ' • У читателя: ${loanInfo['readerName']}';
                        }
                        
                        return ListTile(
                          title: Text(book.title),
                          subtitle: Text(subtitle),
                          leading: Icon(
                            isOnShelf ? Icons.check_circle : Icons.person,
                            color: isOnShelf ? Colors.green : Colors.orange,
                          ),
                          trailing: Text(
                            isOnShelf ? 'На полке' : 'Выдана',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}