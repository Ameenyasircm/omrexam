import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  FirebaseApp? _app;
  FirebaseFirestore? _firestore;

  FirebaseApp? get app => _app;
  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  bool get isInitialized => _app != null;

  /// Initializes Firebase with the platform options
  Future<void> initialize() async {
    if (_app != null) return;

    _app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firestore = FirebaseFirestore.instance;
  }

  /// Tests Firestore connection by attempting a lightweight read/write check
  Future<ConnectionTestResult> testDatabaseConnection() async {
    try {
      if (!isInitialized) {
        await initialize();
      }

      final startTime = DateTime.now();
      final testDocRef = firestore.collection('_connection_tests').doc('status_check');

      // Attempt write timestamp
      await testDocRef.set({
        'lastPing': FieldValue.serverTimestamp(),
        'platform': 'flutter_web',
        'status': 'connected',
      }, SetOptions(merge: true));

      // Attempt read
      final snapshot = await testDocRef.get();
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      return ConnectionTestResult(
        isSuccess: true,
        message: 'Successfully connected and verified read/write with Firestore!',
        latencyMs: duration,
        projectId: _app?.options.projectId ?? 'omr-exam-f45b4',
        data: snapshot.data(),
      );
    } on FirebaseException catch (e) {
      // Check for security rules or network issues
      if (e.code == 'permission-denied') {
        return ConnectionTestResult(
          isSuccess: true, // DB is reachable, security rules restricted write
          message: 'Connected to Firestore! (Note: Firestore Security Rules active: ${e.message})',
          projectId: _app?.options.projectId ?? 'omr-exam-f45b4',
          warning: 'Permission restricted by security rules. DB is reachable.',
        );
      }
      return ConnectionTestResult(
        isSuccess: false,
        message: 'Firestore error [${e.code}]: ${e.message}',
        projectId: _app?.options.projectId ?? 'omr-exam-f45b4',
        error: e.toString(),
      );
    } catch (e) {
      return ConnectionTestResult(
        isSuccess: false,
        message: 'Connection failed: $e',
        projectId: _app?.options.projectId ?? 'omr-exam-f45b4',
        error: e.toString(),
      );
    }
  }
}

class ConnectionTestResult {
  final bool isSuccess;
  final String message;
  final String projectId;
  final int? latencyMs;
  final String? warning;
  final String? error;
  final Map<String, dynamic>? data;

  ConnectionTestResult({
    required this.isSuccess,
    required this.message,
    required this.projectId,
    this.latencyMs,
    this.warning,
    this.error,
    this.data,
  });
}
