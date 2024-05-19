import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'model/note.dart';

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Box<Note> noteBox = Hive.box<Note>('notes');

  void _addNote() {
    final String title = _titleController.text;
    final String description = _descriptionController.text;

    if (title.isNotEmpty && description.isNotEmpty) {
      final note = Note(
        title: title,
        description: description,
      );
      noteBox.add(note);
      _titleController.clear();
      _descriptionController.clear();
    }
  }

  void _updateNote(Note note, int index) {
    note.title = _titleController.text;
    note.description = _descriptionController.text;
    note.save();
    _titleController.clear();
    _descriptionController.clear();
  }

  void _deleteNote(Note note) {
    note.delete();
  }

  void _showForm(BuildContext context, Note? note, int? index) {
    if (note != null) {
      _titleController.text = note.title;
      _descriptionController.text = note.description;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              ElevatedButton(
                child: Text(note == null ? 'Add Note' : 'Update Note'),
                onPressed: () {
                  if (note == null) {
                    _addNote();
                  } else {
                    _updateNote(note, index!);
                  }
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: ValueListenableBuilder(
        valueListenable: noteBox.listenable(),
        builder: (context, Box<Note> notes, _) {
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes.getAt(index);

              return ListTile(
                title: Text(note!.title),
                subtitle: Text(note.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showForm(context, note, index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteNote(note),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showForm(context, null, null),
      ),
    );
  }
}
