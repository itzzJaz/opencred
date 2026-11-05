import 'package:flutter/material.dart';
import 'app.dart';
import 'demo_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final applicants = await DemoRepository.loadApplicants();
  runApp(OpenCredApp(applicants: applicants));
}
