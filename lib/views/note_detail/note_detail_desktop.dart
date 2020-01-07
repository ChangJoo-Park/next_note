part of note_detail_view;

class _NoteDetailDesktop extends StatelessWidget {
  final NoteDetailViewModel viewModel;

  _NoteDetailDesktop(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('NoteDetailDesktop')),
    );
  }
}