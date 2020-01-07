part of note_detail_view;

class _NoteDetailTablet extends StatelessWidget {
  final NoteDetailViewModel viewModel;

  _NoteDetailTablet(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('NoteDetailTablet')),
    );
  }
}