import 'package:flutter/material.dart';
import 'package:supanotes/data/constants/app_strings.dart';
import 'package:supanotes/data/constants/app_constants.dart';
import 'package:supanotes/data/models/note.dart';
import 'package:supanotes/data/services/services.dart';
import 'package:supanotes/ui/pages/profile_page.dart';
import 'package:supanotes/ui/widgets/note_editor_sheet.dart';
import 'package:supanotes/ui/widgets/custom_snack_bar.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool _isSelectionMode = false;
  final Set<int> _selectedNoteIds = {};
  final Set<int> _hiddenNoteIds = {}; 

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteNote(int noteId) async {
    final success = await Services.of(context).databaseService.deleteNote(noteId);
    if (!success && mounted) {
      setState(() => _hiddenNoteIds.remove(noteId));
    }
  }

  Future<void> _deleteSelectedNotes() async {
    final idsToDelete = _selectedNoteIds.toList();
    setState(() {
      _isSelectionMode = false;
      _hiddenNoteIds.addAll(idsToDelete);
      _selectedNoteIds.clear();
    });
    final success = await Services.of(context).databaseService.deleteNotes(idsToDelete);
    if (!success && mounted) {
      setState(() => _hiddenNoteIds.removeAll(idsToDelete));
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedNoteIds.contains(id)) {
        _selectedNoteIds.remove(id);
        if (_selectedNoteIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedNoteIds.add(id);
      }
    });
  }

  void _openEditor(BuildContext context, {Note? note}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.r24)),
      ),
      builder: (_) => NoteEditorSheet(existingNote: note),
    );
  }

  Future<void> _synthesizeSelectedThoughts(List<Note> allNotes) async {
    final selectedNotes = allNotes.where((n) => _selectedNoteIds.contains(n.id)).toList();
    if (selectedNotes.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final synthesis = await Services.of(context).aiService.generateMacroSynthesis(selectedNotes);
    
    if (mounted) {
      Navigator.pop(context);
      setState(() {
        _isSelectionMode = false;
        _selectedNoteIds.clear();
      });
      _showSynthesisResult(synthesis);
    }
  }

  void _showSynthesisResult(String? synthesis) {
    if (synthesis == null) {
      CustomSnackBar.show(context, message: AppStrings.synthesisFailed, type: SnackBarType.error);
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.r24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.hub_rounded, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    AppStrings.macroSynthesis, 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    synthesis, 
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: AppLayout.textLineHeight),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(AppAlphas.a100),
        borderRadius: BorderRadius.circular(AppRadii.r16),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(_searchQuery.isNotEmpty ? AppAlphas.a100 : AppAlphas.a20), 
          width: AppLayout.borderWidthStandard,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          prefixIcon: Icon(
            Icons.search_rounded, 
            color: theme.colorScheme.primary.withAlpha(AppAlphas.a150),
          ),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded, 
                  color: theme.colorScheme.onSurface.withAlpha(AppAlphas.a150),
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ) 
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20, 
            vertical: AppSpacing.s16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final database = Services.of(context).databaseService;
    final currentUser = Services.of(context).authService.auth.currentUser;

    return StreamBuilder<List<Note>>(
      stream: database.streamNotes(),
      builder: (context, snapshot) {
        final rawNotes = snapshot.data ?? [];
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: _isSelectionMode
                ? Text(
                    '${_selectedNoteIds.length} ${AppStrings.selected}', 
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : const Text(
                    AppStrings.workspace, 
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: _isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _isSelectionMode = false;
                      _selectedNoteIds.clear();
                    }),
                  )
                : null,
            actions: _isSelectionMode
                ? [
                    if (_selectedNoteIds.length >= 2)
                      IconButton(
                        icon: const Icon(Icons.hub_rounded),
                        tooltip: AppStrings.synthesizeThoughts,
                        onPressed: () => _synthesizeSelectedThoughts(rawNotes),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: AppStrings.deleteSelected,
                      onPressed: _deleteSelectedNotes,
                    ),
                  ]
                : [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.s12),
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withAlpha(AppAlphas.a40),
                          child: Icon(Icons.person, color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                  ],
          ),
          body: Column(
            children: [
              if (!_isSelectionMode) _buildSearchBar(theme),
              Expanded(
                child: _buildNotesList(snapshot, theme, currentUser?.id),
              ),
            ],
          ),
          floatingActionButton: _isSelectionMode ? null : GestureDetector(
            onTap: () => _openEditor(context),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(0, AppLayout.fabOffsetShadowY), 
                  child: Container(
                    width: AppSpacing.s60, 
                    height: AppSpacing.s60, 
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(AppAlphas.a60), 
                      borderRadius: BorderRadius.circular(AppRadii.r18),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, AppLayout.fabOffsetMidY), 
                  child: Container(
                    width: AppSpacing.s60, 
                    height: AppSpacing.s60, 
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer, 
                      borderRadius: BorderRadius.circular(AppRadii.r18),
                    ),
                  ),
                ),
                Container(
                  width: AppSpacing.s60, 
                  height: AppSpacing.s60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary, 
                    borderRadius: BorderRadius.circular(AppRadii.r18), 
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, 
                      end: Alignment.bottomRight, 
                      colors: [
                        theme.colorScheme.primary, 
                        theme.colorScheme.primary.withAlpha(AppAlphas.a200),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.add, 
                    color: theme.colorScheme.onPrimary, 
                    size: AppLayout.iconLarge,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildNotesList(AsyncSnapshot<List<Note>> snapshot, ThemeData theme, String? currentUserId) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(
        child: Text(AppStrings.errorLoading, style: TextStyle(color: theme.colorScheme.error)),
      );
    }

    var notes = (snapshot.data ?? []).where((n) => !_hiddenNoteIds.contains(n.id)).toList();

    if (_searchQuery.isNotEmpty) {
      notes = notes.where((n) {
        final matchTitle = n.title.toLowerCase().contains(_searchQuery);
        final matchContent = n.content?.toLowerCase().contains(_searchQuery) ?? false;
        final matchTags = n.tags.any((t) => t.toLowerCase().contains(_searchQuery));
        return matchTitle || matchContent || matchTags;
      }).toList();
    }

    if (notes.isEmpty) return const Center(child: Text(AppStrings.noNotesFound));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s4),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final isSelected = _selectedNoteIds.contains(note.id);
        final isSharedWithMe = currentUserId != null && note.userId != currentUserId;
        
        return Dismissible(
          key: ValueKey(note.id),
          direction: _isSelectionMode || isSharedWithMe ? DismissDirection.none : DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight, 
            padding: const EdgeInsets.only(right: AppSpacing.s20),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withAlpha(AppAlphas.a200), 
              borderRadius: BorderRadius.circular(AppRadii.r12),
            ),
            child: Icon(Icons.delete_sweep_rounded, color: theme.colorScheme.onError),
          ),
          onDismissed: (_) {
            setState(() => _hiddenNoteIds.add(note.id)); 
            _deleteNote(note.id);
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.s12),
            color: isSelected ? theme.colorScheme.primary.withAlpha(AppAlphas.a25) : theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r12),
              side: isSelected 
                  ? BorderSide(color: theme.colorScheme.primary, width: AppLayout.borderWidthActive) 
                  : BorderSide.none,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppSpacing.s16),
              onLongPress: () {
                if (!_isSelectionMode) {
                  setState(() { 
                    _isSelectionMode = true; 
                    _selectedNoteIds.add(note.id); 
                  });
                }
              },
              onTap: () {
                if (_isSelectionMode) {
                  _toggleSelection(note.id);
                } else {
                  _openEditor(context, note: note);
                }
              },
              leading: _isSelectionMode 
                ? Checkbox(
                    value: isSelected, 
                    onChanged: (_) => _toggleSelection(note.id), 
                    activeColor: theme.colorScheme.primary,
                  )
                : null,
              title: Row(
                children: [
                  if (isSharedWithMe)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.s8),
                      child: Icon(
                        Icons.folder_shared_rounded, 
                        size: AppLayout.iconSmall, 
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      note.title, 
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.s8, bottom: AppSpacing.s4),
                      child: Wrap(
                        spacing: AppSpacing.s4,
                        children: note.tags.map((t) => Text(
                          '#$t', 
                          style: TextStyle(
                            color: theme.colorScheme.primary, 
                            fontSize: AppLayout.tagFontSize, 
                            fontWeight: FontWeight.bold,
                          ),
                        )).toList(),
                      ),
                    ),
                  if (note.content != null && note.content!.isNotEmpty)
                    Text(
                      note.content!, 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis, 
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(AppAlphas.a160),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}