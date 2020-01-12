library setting_view;

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:next_page/core/logger.dart';
import 'package:next_page/themes.dart';
import 'package:next_page/utils/string_utils.dart';
import 'package:provider_architecture/provider_architecture.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'setting_view_model.dart';

part 'setting_mobile.dart';
part 'setting_tablet.dart';
part 'setting_desktop.dart';

class SettingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SettingViewModel viewModel = SettingViewModel();
    return ViewModelProvider<SettingViewModel>.withConsumer(
      viewModel: viewModel,
      onModelReady: (viewModel) {},
      builder: (context, viewModel, child) {
        return FutureBuilder(
          future: viewModel.loadBaseSettings(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ScreenTypeLayout(
                mobile: _SettingMobile(viewModel),
                desktop: _SettingDesktop(viewModel),
                tablet: _SettingTablet(viewModel),
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}
