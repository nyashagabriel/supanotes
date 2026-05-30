import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supanotes/data/models/note.dart';

class DatabaseService {
  final SupabaseClient _client;

  DatabaseService(this._client);

  Stream<List<Note>> streamNotes() {
    developer.log('Initializing real-time stream for notes', name: 'DB_SERVICE');
    return _client
        .schema('supanotes')
        .from('notes')
        .stream(primaryKey: ['id'])
        .order('create_time', ascending: false)
        .handleError((error, stackTrace) {
          developer.log('Stream Error', error: error, stackTrace: stackTrace, name: 'DB_SERVICE');
        })
        .map((data) {
          developer.log('Stream emitted ${data.length} records', name: 'DB_SERVICE');
          return data.map((json) => Note.fromJson(json)).toList();
        });
  }

  Future<List<String>> getUniqueTags() async {
    developer.log('Fetching global unique tags for Autocomplete', name: 'DB_SERVICE');
    try {
      final response = await _client.schema('supanotes').from('notes').select('tags');
      final Set<String> uniqueTags = {};
      
      for (final row in response) {
        if (row['tags'] != null) {
          uniqueTags.addAll(List<String>.from(row['tags']));
        }
      }
      return uniqueTags.toList();
    } catch (e, stackTrace) {
      developer.log('Error fetching global tags', error: e, stackTrace: stackTrace, name: 'DB_SERVICE');
      return [];
    }
  }

  Future<bool> createNote(String title, String content, {String? aiSummary, List<String> tags = const [], List<String> sharedWithEmails = const [], List<String> sharedWithEditorEmails = const []}) async {
    developer.log('Attempting to create note: $title', name: 'DB_SERVICE');
    try {
      await _client.schema('supanotes').from('notes').insert({
        'title': title,
        'content': content,
        'ai_summary': aiSummary,
        'tags': tags,
        'shared_with_emails': sharedWithEmails,
        'shared_with_editor_emails': sharedWithEditorEmails,
      });
      return true;
    } catch (e, stackTrace) {
      developer.log('Insert Error', error: e, stackTrace: stackTrace, name: 'DB_SERVICE');
      return false;
    }
  }

  Future<bool> updateNote(int noteId, String title, String content, {String? aiSummary, List<String>? tags, List<String>? sharedWithEmails, List<String>? sharedWithEditorEmails}) async {
    developer.log('Attempting to update note ID: $noteId', name: 'DB_SERVICE');
    try {
      final Map<String, dynamic> updates = {
        'title': title,
        'content': content,
        'ai_summary': aiSummary,
        'modify_time': DateTime.now().toIso8601String(),
      };
      
      if (tags != null) updates['tags'] = tags;
      if (sharedWithEmails != null) updates['shared_with_emails'] = sharedWithEmails;
      if (sharedWithEditorEmails != null) updates['shared_with_editor_emails'] = sharedWithEditorEmails;

      await _client.schema('supanotes').from('notes').update(updates).eq('id', noteId);
      return true;
    } catch (e, stackTrace) {
      developer.log('Update Error', error: e, stackTrace: stackTrace, name: 'DB_SERVICE');
      return false;
    }
  }

  Future<bool> deleteNote(int noteId) async {
    try {
      await _client.schema('supanotes').from('notes').delete().eq('id', noteId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteNotes(List<int> noteIds) async {
    if (noteIds.isEmpty) return true;
    try {
      await _client.schema('supanotes').from('notes').delete().inFilter('id', noteIds);
      return true;
    } catch (_) {
      return false;
    }
  }
}