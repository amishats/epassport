import 'package:epassport/pages/home/controller/qr_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => QrResultsProvider()),
];
