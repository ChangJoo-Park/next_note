library note_detail_view;

import 'package:next_page/models/note.dart';
import 'package:provider_architecture/provider_architecture.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'note_detail_view_model.dart';

part 'note_detail_mobile.dart';
part 'note_detail_tablet.dart';
part 'note_detail_desktop.dart';

class NoteDetailView extends StatelessWidget {
  final Note note;
  NoteDetailView({@required this.note});

  @override
  Widget build(BuildContext context) {
    NoteDetailViewModel viewModel = NoteDetailViewModel(this.note);
    return ViewModelProvider<NoteDetailViewModel>.withConsumer(
      viewModel: viewModel,
      onModelReady: (viewModel) async {
        // Do something once your viewModel is initialized
        await viewModel.initialize();
      },
      builder: (context, viewModel, child) {
        return ScreenTypeLayout(
          mobile: _NoteDetailMobile(viewModel),
          desktop: _NoteDetailDesktop(viewModel),
          tablet: _NoteDetailTablet(viewModel),
        );
      },
    );
  }
}