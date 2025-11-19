import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> saveTranslation({
    required String sourceText,
    required String translatedText,
  }) async {
    try {
      await _client.from('translation_history').insert({
        'source_text': sourceText,
        'translated_text': translatedText,
        // 'user_id': _client.auth.currentUser?.id, // Uncomment if auth is enabled
      });
    } catch (e) {
      print('Error saving translation: $e');
      // Handle error (e.g., offline storage)
    }
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final response = await _client
          .from('translation_history')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }
}
