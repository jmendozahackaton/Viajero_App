import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Viajeros/data/repositories/user_repository_impl.dart';
import '/Users/dev/Flutter/hackaton_app/test/helpers/mocks.dart';

void main() {
  late UserRepositoryImpl userRepository;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late MockDocumentSnapshot mockDocumentSnapshot;
  late MockUser mockUser;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    mockUser = MockUser();

    userRepository = UserRepositoryImpl(
      firestore: mockFirestore,
      auth: mockAuth,
    );

    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocument);
  });

  group('UserRepositoryImpl Tests', () {
    test('Should get user by id successfully', () async {
      final userData = {
        'uid': 'test123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'userType': 'passenger',
        'phoneNumber': null,
        'photoURL': null,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'fcmToken': null,
        'preferences': {},
      };

      when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(userData);

      final user = await userRepository.getUserById('test123');

      expect(user.uid, 'test123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.userType, 'passenger');
    });

    test('Should throw exception when user not found', () async {
      when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      expect(() => userRepository.getUserById('nonexistent'), throwsException);
    });

    test('Should get current user when authenticated', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('current_user_123');

      final userData = {
        'uid': 'current_user_123',
        'email': 'current@example.com',
        'displayName': 'Current User',
        'userType': 'passenger',
        'phoneNumber': null,
        'photoURL': null,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'fcmToken': null,
        'preferences': {},
      };

      when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(userData);

      final user = await userRepository.getCurrentUser();

      expect(user.uid, 'current_user_123');
      expect(user.email, 'current@example.com');
    });

    test('Should throw exception when no user is authenticated', () async {
      when(mockAuth.currentUser).thenReturn(null);

      expect(() => userRepository.getCurrentUser(), throwsException);
    });
  });
}
