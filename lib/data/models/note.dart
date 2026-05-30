class Note {
  final int id;
  final String userId;
  final String title;
  final String? content;
  final String? aiSummary;
  final List<String> tags;
  final List<String> sharedWithEmails;
  final List<String> sharedWithEditorEmails;
  final DateTime createTime;
  final DateTime modifyTime;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    this.content,
    this.aiSummary,
    this.tags = const [],
    this.sharedWithEmails = const [],
    this.sharedWithEditorEmails = const [],
    required this.createTime,
    required this.modifyTime,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      aiSummary: json['ai_summary'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      sharedWithEmails: List<String>.from(json['shared_with_emails'] ?? []),
      sharedWithEditorEmails: List<String>.from(json['shared_with_editor_emails'] ?? []),
      createTime: DateTime.parse(json['create_time'] as String),
      modifyTime: DateTime.parse(json['modify_time'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'ai_summary': aiSummary,
      'tags': tags,
      'shared_with_emails': sharedWithEmails,
      'shared_with_editor_emails': sharedWithEditorEmails,
    };
  }
}