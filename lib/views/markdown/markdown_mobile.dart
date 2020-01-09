part of markdown_view;

class _MarkdownMobile extends StatelessWidget {
  final MarkdownViewModel viewModel;

  _MarkdownMobile(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viewer'),
      ),
      body: SafeArea(child: Markdown(data: viewModel.content)),
    );
  }
}