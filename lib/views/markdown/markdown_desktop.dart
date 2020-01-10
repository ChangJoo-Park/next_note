part of markdown_view;

class _MarkdownDesktop extends StatelessWidget {
  final MarkdownViewModel viewModel;

  _MarkdownDesktop(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('MarkdownDesktop')),
    );
  }
}