library home_view;

import 'dart:async';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:logger/logger.dart';
import 'package:next_page/core/logger.dart';
import 'package:next_page/models/note.dart';
import 'package:next_page/views/note_detail/note_detail_view.dart';
import 'package:next_page/views/setting/setting_view.dart';
import 'package:next_page/widgets/bottom_action_bar.dart';
import 'package:provider_architecture/provider_architecture.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:unicorndial/unicorndial.dart';

import 'home_view_model.dart';

part 'home_desktop.dart';
part 'home_mobile.dart';
part 'home_tablet.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeViewModel viewModel = HomeViewModel();
    return ViewModelProvider<HomeViewModel>.withConsumer(
        viewModel: viewModel,
        onModelReady: (viewModel) async {
          await viewModel.initialize();
        },
        builder: (context, viewModel, child) {
          return ScreenTypeLayout(
            mobile: _HomeMobile(viewModel),
            desktop: _HomeDesktop(viewModel),
            tablet: _HomeTablet(viewModel),
          );
        });
  }
}
