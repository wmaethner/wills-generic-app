import 'package:flutter/material.dart';
import 'package:wills_generic_app/applets/applet_ideas/database.dart';

class AppletIdeasScreen extends StatefulWidget {
  const AppletIdeasScreen({super.key});

  @override
  State<AppletIdeasScreen> createState() => _AppletIdeasScreenState();
}

class _AppletIdeasScreenState extends State<AppletIdeasScreen> {
  List<Map<String, dynamic>> _ideas = [];
  bool _loading = true;
  String _sortBy = 'created_at DESC';

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  Future<void> _loadIdeas() async {
    setState(() => _loading = true);
    final ideas = await AppletIdeasDB.instance.query('ideas', orderBy: _sortBy);
    setState(() {
      _ideas = ideas;
      _loading = false;
    });
  }

  Future<void> _showIdeaDialog({Map<String, dynamic>? existing}) async {
    final titleController = TextEditingController(text: existing?['title'] ?? '');
    final descController = TextEditingController(text: existing?['description'] ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'New Idea' : 'Edit Idea'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final data = {
                  'title': titleController.text.trim(),
                  'description': descController.text.trim(),
                };
                if (existing == null) {
                  data['created_at'] = DateTime.now().toIso8601String();
                  await AppletIdeasDB.instance.insert('ideas', data);
                } else {
                  await AppletIdeasDB.instance.update('ideas', data, where: 'id = ?', whereArgs: [existing['id']]);
                }
                if (context.mounted) Navigator.pop(context);
                await _loadIdeas();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteIdea(int id) async {
    await AppletIdeasDB.instance.delete('ideas', where: 'id = ?', whereArgs: [id]);
    await _loadIdeas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applet Ideas'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadIdeas();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'created_at DESC', child: Text('Newest First')),
              const PopupMenuItem(value: 'created_at ASC', child: Text('Oldest First')),
              const PopupMenuItem(value: 'title ASC', child: Text('Title A-Z')),
              const PopupMenuItem(value: 'title DESC', child: Text('Title Z-A')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _ideas.isEmpty
              ? const Center(child: Text('No ideas yet. Tap + to add one!'))
              : ListView.builder(
                  itemCount: _ideas.length,
                  itemBuilder: (context, index) {
                    final idea = _ideas[index];
                    return Dismissible(
                      key: ValueKey(idea['id']),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async =>
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Idea?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                      onDismissed: (_) => _deleteIdea(idea['id'] as int),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          title: Text(idea['title'] as String),
                          subtitle: (idea['description'] as String).isNotEmpty
                              ? Text(
                                  idea['description'] as String,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () => _showIdeaDialog(existing: idea),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showIdeaDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
