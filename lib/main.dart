import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the provider container
  final container = ProviderContainer();

  try {
    // Initialize persistence and load data
    await container.read(initializationProvider.future);
  } catch (e) {
    print('Initialization error: $e');
    // Continue anyway - we can work without persisted data
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const CceMapApp()),
  );
}
