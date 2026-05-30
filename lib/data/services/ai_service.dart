import 'dart:developer' as developer;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supanotes/data/models/note.dart';

class AiService {
  late final GenerativeModel _model;

  AiService({required String apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String?> generateSmartSummary(String title, String content) async {
    developer.log('Requesting Smart Summary for: $title', name: 'AI_SERVICE');
    
    final prompt = '''
    Analyze the following note.
    Title: $title
    Content: $content

    You MUST output your response in EXACTLY this format, using these exact two uppercase headings. Do not include any introductory filler.

    DIRECT SUMMARY:
    Provide an extremely concise, 1-to-2 sentence direct summary of exactly what the raw note says, even if the note is vague. Get straight to the point.

    COHERENT BREAKDOWN:
    Expand on the vague ideas. Break them down logically, infer the actual intent, and provide structured data, context, or actionable steps to make it useful. Keep it brief.

    CRITICAL RULE: Do not use markdown symbols like * or #. Use plain text and spacing only.
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e, stackTrace) {
      developer.log('Gemini API Error', error: e, stackTrace: stackTrace, name: 'AI_SERVICE');
      return null;
    }
  }

  /// Synthesizes multiple disparate notes to find connective themes and overarching insights.
  Future<String?> generateMacroSynthesis(List<Note> notes) async {
    developer.log('Requesting Macro-Synthesis for ${notes.length} notes', name: 'AI_SERVICE');
    
    final buffer = StringBuffer();
    for (var i = 0; i < notes.length; i++) {
      buffer.writeln('NOTE ${i + 1}:');
      buffer.writeln('Title: ${notes[i].title}');
      buffer.writeln('Content: ${notes[i].content ?? "N/A"}');
      buffer.writeln('---');
    }

    final prompt = '''
    You are a strategic intelligence engine. Analyze the following collection of notes and find the hidden connections.

    NOTES DATA:
    $buffer

    Output your response in EXACTLY this format:

    CORE THEMES:
    [Identify 2-3 overarching themes connecting these thoughts. Keep it sharp.]

    SYNTHESIS & DIRECTION:
    [Provide a unified executive summary of what the user is trying to build, learn, or achieve based on the combined data. Provide one strong strategic recommendation.]

    CRITICAL RULE: Do not use markdown symbols like * or #. Use plain text and spacing only.
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e, stackTrace) {
      developer.log('Gemini Synthesis Error', error: e, stackTrace: stackTrace, name: 'AI_SERVICE');
      return null;
    }
  }
}