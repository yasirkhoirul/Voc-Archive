import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RouterListener extends ChangeNotifier {
  final BlocBase authBloc;
  late final StreamSubscription authSubscription;
  RouterListener(this.authBloc){
    authSubscription = authBloc.stream.listen((state) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    authSubscription.cancel();
    super.dispose();
  }
}