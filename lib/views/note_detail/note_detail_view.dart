library note_detail_view;

import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:logger/logger.dart';
import 'package:next_page/core/logger.dart';
import 'package:next_page/models/note.dart';
import 'package:next_page/widgets/bottom_action_bar.dart';
import 'package:next_page/widgets/no_glow_scroll_behavior.dart';
import 'package:provider_architecture/provider_architecture.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:share/share.dart';

import 'note_detail_view_model.dart';

part 'note_detail_desktop.dart';
part 'note_detail_mobile.dart';
part 'note_detail_tablet.dart';

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
