import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_note.dart';

class WorkoutNotesService {
  String _keyForUser(String username) => 'workout_notes_$username';

  Future<List<WorkoutNote>> getNotes(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(username));
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((e) => WorkoutNote.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _save(String username, List<WorkoutNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(notes.map((e) => e.toJson()).toList());
    await prefs.setString(_keyForUser(username), raw);
  }

  Future<void> addNote(String username, WorkoutNote note) async {
    final notes = await getNotes(username);
    notes.add(note);
    await _save(username, notes);
  }

  Future<void> updateNote(String username, WorkoutNote updated) async {
    final notes = await getNotes(username);
    final index = notes.indexWhere((n) => n.id == updated.id);
    if (index != -1) {
      notes[index] = updated;
      await _save(username, notes);
    }
  }

  Future<void> deleteNote(String username, String id) async {
    final notes = await getNotes(username);
    notes.removeWhere((n) => n.id == id);
    await _save(username, notes);
  }
}




