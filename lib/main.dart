import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;

import 'app.dart';
import 'providers/providers.dart';
import 'providers/navigation_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create the Riverpod provider container
  final container = ProviderContainer();

  // Create the NavigationProvider
  final navigationProvider = NavigationProvider();

  try {
    // Initialize persistence and load data
    await container.read(initializationProvider.future);

    // Initialize NavigationProvider with GeoJSON data
    final graphService = container.read(navGraphServiceProvider);
    await navigationProvider.initialize(graphService);
  } catch (e) {
    debugPrint('Initialization error: $e');
    // Continue anyway - we can work without persisted data
  }

  runApp(
    // Hybrid setup: Provider + Riverpod
    p.MultiProvider(
      providers: [
        p.ChangeNotifierProvider<NavigationProvider>.value(
          value: navigationProvider,
        ),
      ],
      child: UncontrolledProviderScope(
        container: container,
        child: const CceMapApp(),
      ),
    ),
  );
}
