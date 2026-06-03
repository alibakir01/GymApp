import 'package:flutter/material.dart';

import '../models/workout_note.dart';
import '../services/workout_notes_service.dart';

class WorkoutNotesPage extends StatefulWidget {
  final String username;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const WorkoutNotesPage({
    super.key,
    required this.username,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<WorkoutNotesPage> createState() => _WorkoutNotesPageState();
}

class _WorkoutNotesPageState extends State<WorkoutNotesPage> {
  final WorkoutNotesService _service = WorkoutNotesService();
  List<WorkoutNote> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _service.getNotes(widget.username);
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  Future<void> _addOrEditNote({WorkoutNote? existing}) async {
    final result = await showModalBottomSheet<WorkoutNote>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _NoteEditorSheet(
          isDarkMode: widget.isDarkMode,
          existing: existing,
        );
      },
    );
    if (result != null) {
      if (existing == null) {
        await _service.addNote(widget.username, result);
      } else {
        await _service.updateNote(widget.username, result);
      }
      await _loadNotes();
    }
  }

  Future<void> _deleteNote(String id) async {
    await _service.deleteNote(widget.username, id);
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ağırlık Not Defteri'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditNote(),
        label: const Text('Not Ekle'),
        icon: const Icon(Icons.add),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: widget.isDarkMode
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B1B1B), Color(0xFF2C2C2C)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFFE5DD)],
                ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _notes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Henüz not yok. Aşağıdaki buton ile ilk notunuzu ekleyin.',
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return Dismissible(
                        key: ValueKey(note.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteNote(note.id),
                        child: Card(
                          color: widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            onTap: () => _addOrEditNote(existing: note),
                            title: Text(
                              note.exerciseName,
                              style: TextStyle(
                                color: widget.isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              _formatSubtitle(note),
                              style: TextStyle(
                                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[700],
                              ),
                            ),
                            trailing: Text(
                              '${note.weight.toStringAsFixed(note.weight % 1 == 0 ? 0 : 1)} kg',
                              style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _formatSubtitle(WorkoutNote note) {
    final dateStr = '${note.date.day.toString().padLeft(2, '0')}.${note.date.month.toString().padLeft(2, '0')}.${note.date.year}';
    final repsStr = '${note.reps} tekrar';
    final commentStr = (note.comment == null || note.comment!.trim().isEmpty) ? '' : ' • ${note.comment}';
    return '$dateStr • $repsStr$commentStr';
  }
}

class _NoteEditorSheet extends StatefulWidget {
  final bool isDarkMode;
  final WorkoutNote? existing;

  const _NoteEditorSheet({
    required this.isDarkMode,
    this.existing,
  });

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _exerciseController;
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _commentController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _exerciseController = TextEditingController(text: widget.existing?.exerciseName ?? '');
    _weightController = TextEditingController(
      text: widget.existing != null ? widget.existing!.weight.toString() : '',
    );
    _repsController = TextEditingController(
      text: widget.existing != null ? widget.existing!.reps.toString() : '',
    );
    _commentController = TextEditingController(text: widget.existing?.comment ?? '');
    _selectedDate = widget.existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1B1B1B) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existing == null ? 'Not Ekle' : 'Notu Düzenle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _exerciseController,
                  decoration: const InputDecoration(
                    hintText: 'Egzersiz adı (örn. Bench Press)',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Egzersiz adı gerekli' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'Ağırlık (kg)',
                          prefixIcon: Icon(Icons.scale),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Ağırlık gerekli';
                          final parsed = double.tryParse(v.replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) return 'Geçerli bir ağırlık girin';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Tekrar',
                          prefixIcon: Icon(Icons.repeat),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Tekrar gerekli';
                          final parsed = int.tryParse(v);
                          if (parsed == null || parsed <= 0) return 'Geçerli tekrar girin';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text('${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Not (opsiyonel)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.existing == null ? 'Kaydet' : 'Güncelle'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final weight = double.parse(_weightController.text.replaceAll(',', '.'));
    final reps = int.parse(_repsController.text);
    final note = WorkoutNote(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      exerciseName: _exerciseController.text.trim(),
      weight: weight,
      reps: reps,
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
    );
    Navigator.pop(context, note);
  }
}




