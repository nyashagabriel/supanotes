import 'package:flutter/material.dart';
import 'package:supanotes/data/models/note.dart';
import 'package:supanotes/data/services/services.dart';
import 'package:supanotes/ui/widgets/custom_button.dart';
import 'package:supanotes/ui/widgets/custom_text_field.dart';
import 'package:supanotes/ui/widgets/custom_snack_bar.dart';

class NoteEditorSheet extends StatefulWidget {
  final Note? existingNote;

  const NoteEditorSheet({
    super.key,
    this.existingNote,
  });

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _editorEmailController = TextEditingController();
  
  TextEditingController? _tagFieldController;
  
  String? _aiSummary;
  List<String> _tags = [];
  List<String> _sharedEmails = [];
  List<String> _sharedEditorEmails = [];
  List<String> _availableGlobalTags = [];
  
  bool _isSaving = false;
  bool _isGeneratingAi = false;
  bool _hasFetchedTags = false;

  bool get _isEditMode => widget.existingNote != null;

  // Authorization Flags Evaluated in build()
  late bool _isOwner;
  late bool _isEditor;
  late bool _isReadOnly;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController = TextEditingController(text: widget.existingNote?.content ?? '');
    _aiSummary = widget.existingNote?.aiSummary;
    _tags = List.from(widget.existingNote?.tags ?? []);
    _sharedEmails = List.from(widget.existingNote?.sharedWithEmails ?? []);
    _sharedEditorEmails = List.from(widget.existingNote?.sharedWithEditorEmails ?? []);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetchedTags) {
      _hasFetchedTags = true;
      Services.of(context).databaseService.getUniqueTags().then((tags) {
        if (mounted) setState(() => _availableGlobalTags = tags);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _emailController.dispose();
    _editorEmailController.dispose();
    super.dispose();
  }

  void _handleCommaSeparatedInput(String value, Function(String) onAdd, TextEditingController controller) {
    if (value.contains(',')) {
      final parts = value.split(',');
      for (var i = 0; i < parts.length - 1; i++) {
        onAdd(parts[i]);
      }
      controller.text = parts.last;
      controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    }
  }

  void _addTag(String tag) {
    final cleanTag = tag.trim().toLowerCase();
    if (cleanTag.isNotEmpty && !_tags.contains(cleanTag)) {
      setState(() {
        _tags.add(cleanTag);
        if (!_availableGlobalTags.contains(cleanTag)) {
          _availableGlobalTags.add(cleanTag);
        }
      });
    }
  }

  void _addEmail(String email) {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isNotEmpty && !_sharedEmails.contains(cleanEmail)) {
      setState(() => _sharedEmails.add(cleanEmail));
    }
  }

  void _addEditorEmail(String email) {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isNotEmpty && !_sharedEditorEmails.contains(cleanEmail)) {
      setState(() => _sharedEditorEmails.add(cleanEmail));
    }
  }

  Future<void> _generateSmartSummary() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) return;
    setState(() => _isGeneratingAi = true);
    final result = await Services.of(context).aiService.generateSmartSummary(title, content);
    if (!mounted) return;
    setState(() {
      _isGeneratingAi = false;
      if (result != null) _aiSummary = result;
    });
  }

  Future<void> _saveNote() async {
    if (_tagFieldController != null && _tagFieldController!.text.trim().isNotEmpty) {
      _addTag(_tagFieldController!.text);
    }
    if (_emailController.text.trim().isNotEmpty) {
      _addEmail(_emailController.text);
    }
    if (_editorEmailController.text.trim().isNotEmpty) {
      _addEditorEmail(_editorEmailController.text);
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      CustomSnackBar.show(context, message: 'A title is required.', type: SnackBarType.error);
      return;
    }

    setState(() => _isSaving = true);
    final dbService = Services.of(context).databaseService;
    final bool success;

    if (_isEditMode) {
      success = await dbService.updateNote(
        widget.existingNote!.id, title, content,
        aiSummary: _aiSummary, tags: _tags, sharedWithEmails: _sharedEmails, sharedWithEditorEmails: _sharedEditorEmails,
      );
    } else {
      success = await dbService.createNote(
        title, content,
        aiSummary: _aiSummary, tags: _tags, sharedWithEmails: _sharedEmails, sharedWithEditorEmails: _sharedEditorEmails,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) Navigator.pop(context);
  }

  Widget _buildChips(List<String> items, Function(String) onDeleted, IconData icon, ThemeData theme, bool readOnly) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: items.map((item) {
          return Chip(
            avatar: Icon(icon, size: 16, color: theme.colorScheme.primary),
            label: Text(item, style: theme.textTheme.labelMedium),
            backgroundColor: theme.colorScheme.primaryContainer.withAlpha(50),
            side: BorderSide(color: theme.colorScheme.primary.withAlpha(50)),
            deleteIcon: readOnly ? null : const Icon(Icons.close, size: 16),
            onDeleted: readOnly ? null : () => onDeleted(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildParsedAiInsights(ThemeData theme) {
    if (_aiSummary == null || _aiSummary!.isEmpty) return const SizedBox.shrink();

    String direct = '';
    String coherent = '';

    if (_aiSummary!.contains('COHERENT BREAKDOWN:')) {
      final parts = _aiSummary!.split('COHERENT BREAKDOWN:');
      direct = parts[0].replaceAll('DIRECT SUMMARY:', '').trim();
      coherent = parts[1].trim();
    } else {
      direct = _aiSummary!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(60), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('AI Analysis', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (direct.isNotEmpty) ...[
            Text('DIRECT SUMMARY', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary.withAlpha(200), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(direct, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(220), height: 1.5)),
          ],
          if (coherent.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('COHERENT BREAKDOWN', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary.withAlpha(200), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(coherent, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(220), height: 1.5)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = Services.of(context).authService.auth.currentUser;
    final currentEmail = currentUser?.email ?? '';
    
    _isOwner = !_isEditMode || widget.existingNote?.userId == currentUser?.id;
    _isEditor = _isEditMode && _sharedEditorEmails.contains(currentEmail);
    _isReadOnly = _isEditMode && !_isOwner && !_isEditor;
    
    final isProcessing = _isSaving || _isGeneratingAi;
    final inputsDisabled = isProcessing || _isReadOnly;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24, right: 24, top: 24,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditMode ? 'Workspace' : 'New Note',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_isReadOnly)
                      Text(
                        'Read-Only Access',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                if (!_isReadOnly && !_isGeneratingAi)
                  IconButton(
                    onPressed: _generateSmartSummary,
                    icon: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary),
                    tooltip: 'AI Analysis',
                  )
                else if (_isGeneratingAi)
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(controller: _titleController, hintText: 'Title', enabled: !inputsDisabled),
                    CustomTextField(controller: _contentController, hintText: 'Thoughts...', keyboardType: TextInputType.multiline, enabled: !inputsDisabled),
                    
                    _buildParsedAiInsights(theme),

                    // Tags Input
                    if (!_isReadOnly)
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          final text = textEditingValue.text.trim();
                          if (text.isEmpty || text.contains(',')) return const Iterable<String>.empty();
                          return _availableGlobalTags.where((tag) => tag.toLowerCase().contains(text.toLowerCase()) && !_tags.contains(tag));
                        },
                        onSelected: (String selection) {
                          _addTag(selection);
                          Future.microtask(() => _tagFieldController?.clear());
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          _tagFieldController = controller;
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            enabled: !inputsDisabled,
                            decoration: InputDecoration(
                              hintText: 'Add a tag (comma or Enter)',
                              prefixIcon: Icon(Icons.tag_rounded, color: theme.colorScheme.primary),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) => _handleCommaSeparatedInput(val, _addTag, controller),
                            onSubmitted: (val) {
                              _addTag(val);
                              controller.clear();
                              focusNode.requestFocus();
                            },
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                width: 200, margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.colorScheme.onSurface.withAlpha(20)),
                                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 8, offset: const Offset(0, 4))],
                                ),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Text('#$option', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    _buildChips(_tags, (t) => setState(() => _tags.remove(t)), Icons.tag, theme, _isReadOnly),
                    
                    // Viewers Input
                    if (!_isReadOnly)
                      TextField(
                        controller: _emailController,
                        enabled: !inputsDisabled,
                        decoration: InputDecoration(
                          hintText: 'Invite Viewers via email',
                          prefixIcon: Icon(Icons.person_add_alt_1_rounded, color: theme.colorScheme.primary),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => _handleCommaSeparatedInput(val, _addEmail, _emailController),
                        onSubmitted: (val) {
                          _addEmail(val);
                          _emailController.clear();
                        },
                      ),
                    _buildChips(_sharedEmails, (e) => setState(() => _sharedEmails.remove(e)), Icons.visibility, theme, _isReadOnly),

                    // Editors Input
                    if (!_isReadOnly)
                      TextField(
                        controller: _editorEmailController,
                        enabled: !inputsDisabled,
                        decoration: InputDecoration(
                          hintText: 'Invite Editors via email',
                          prefixIcon: Icon(Icons.edit_document, color: theme.colorScheme.primary),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => _handleCommaSeparatedInput(val, _addEditorEmail, _editorEmailController),
                        onSubmitted: (val) {
                          _addEditorEmail(val);
                          _editorEmailController.clear();
                        },
                      ),
                    _buildChips(_sharedEditorEmails, (e) => setState(() => _sharedEditorEmails.remove(e)), Icons.edit, theme, _isReadOnly),
                  ],
                ),
              ),
            ),
            if (!_isReadOnly) ...[
              const SizedBox(height: 16),
              CustomButton(
                label: _isEditMode ? 'Update Note' : 'Save Note',
                icon: _isEditMode ? Icons.edit_note_rounded : Icons.save_rounded,
                isLoading: _isSaving,
                onPressed: isProcessing ? null : _saveNote,
              ),
            ]
          ],
        ),
      ),
    );
  }
}