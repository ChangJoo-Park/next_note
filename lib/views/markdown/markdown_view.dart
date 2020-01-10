library markdown_view;

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider_architecture/provider_architecture.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'markdown_view_model.dart';

part 'markdown_mobile.dart';
part 'markdown_tablet.dart';
part 'markdown_desktop.dart';

class MarkdownView extends StatelessWidget {
  final String content;
  MarkdownView(this.content);
  @override
  Widget build(BuildContext context) {
    MarkdownViewModel viewModel = MarkdownViewModel();
    return ViewModelProvider<MarkdownViewModel>.withConsumer(
        viewModel: viewModel,
        onModelReady: (viewModel) {
          viewModel.content = this.content;
        },
        builder: (context, viewModel, child) {
          return ScreenTypeLayout(
            mobile: _MarkdownMobile(viewModel),
            desktop: _MarkdownDesktop(viewModel),
            tablet: _MarkdownTablet(viewModel),
          );
        });
  }
}
