// Mocks manuales con tipos exactos para Firebase
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Mock de FirebaseFirestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return super.noSuchMethod(
          Invocation.method(#collection, [collectionPath]),
          returnValue: MockCollectionReference(),
          returnValueForMissingStub: MockCollectionReference(),
        )
        as CollectionReference<Map<String, dynamic>>;
  }
}

// Mock de FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  User? get currentUser => super.noSuchMethod(
    Invocation.getter(#currentUser),
    returnValue: null,
    returnValueForMissingStub: null,
  );
}

// Mock de CollectionReference con tipo genérico
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return super.noSuchMethod(
          Invocation.method(#doc, [path]),
          returnValue: MockDocumentReference(),
          returnValueForMissingStub: MockDocumentReference(),
        )
        as DocumentReference<Map<String, dynamic>>;
  }
}

// Mock de DocumentReference con tipo genérico
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {
  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) {
    return super.noSuchMethod(
          Invocation.method(#get, [options]),
          returnValue: Future.value(MockDocumentSnapshot()),
          returnValueForMissingStub: Future.value(MockDocumentSnapshot()),
        )
        as Future<DocumentSnapshot<Map<String, dynamic>>>;
  }

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) {
    return super.noSuchMethod(
      Invocation.method(#set, [data, options]),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }

  @override
  Future<void> update(Map<Object, Object?> data) {
    // Tipo CORRECTO para update
    return super.noSuchMethod(
      Invocation.method(#update, [data]),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }

  @override
  Future<void> delete() {
    return super.noSuchMethod(
      Invocation.method(#delete, []),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}

// Mock de DocumentSnapshot con tipo genérico
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  bool get exists => super.noSuchMethod(
    Invocation.getter(#exists),
    returnValue: false,
    returnValueForMissingStub: false,
  );

  @override
  Map<String, dynamic>? data() {
    return super.noSuchMethod(
      Invocation.method(#data, []),
      returnValue: null,
      returnValueForMissingStub: null,
    );
  }

  @override
  String get id => super.noSuchMethod(
    Invocation.getter(#id),
    returnValue: '',
    returnValueForMissingStub: '',
  );
}

// Mock para User de Firebase Auth
class MockUser extends Mock implements User {
  @override
  String get uid => super.noSuchMethod(
    Invocation.getter(#uid),
    returnValue: 'test_uid',
    returnValueForMissingStub: 'test_uid',
  );

  @override
  String get email => super.noSuchMethod(
    Invocation.getter(#email),
    returnValue: 'test@example.com',
    returnValueForMissingStub: 'test@example.com',
  );

  @override
  String get displayName => super.noSuchMethod(
    Invocation.getter(#displayName),
    returnValue: 'Test User',
    returnValueForMissingStub: 'Test User',
  );

  @override
  String? get phoneNumber => super.noSuchMethod(
    Invocation.getter(#phoneNumber),
    returnValue: null,
    returnValueForMissingStub: null,
  );

  @override
  String? get photoURL => super.noSuchMethod(
    Invocation.getter(#photoURL),
    returnValue: null,
    returnValueForMissingStub: null,
  );
}
