part of markdown_view;

class _MarkdownTablet extends StatelessWidget {
  final MarkdownViewModel viewModel;

  _MarkdownTablet(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('MarkdownTablet')),
    );
  }
}