import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:Viajeros/core/providers/app_providers.dart';
import 'package:Viajeros/domain/repositories/user_repository.dart';
import 'package:Viajeros/domain/usecases/get_current_user_usecase.dart';

void main() {
  test('AppProviders should provide all dependencies', () {
    final providers = AppProviders.providers;

    expect(providers.length, greaterThan(0));

    // Verificar que tenemos los providers esenciales
    final hasUserRepository = providers.any((provider) {
      return provider is Provider<UserRepository>;
    });

    final hasGetCurrentUserUseCase = providers.any((provider) {
      return provider is Provider<GetCurrentUserUseCase>;
    });

    expect(hasUserRepository, isTrue);
    expect(hasGetCurrentUserUseCase, isTrue);
  });

  test('Dependencies can be resolved in widget tree', () async {
    await expectLater(() async {
      final testApp = MaterialApp(
        home: MultiProvider(
          providers: AppProviders.providers,
          child: Builder(
            builder: (context) {
              // Intentar resolver las dependencias
              context.read<UserRepository>();
              context.read<GetCurrentUserUseCase>();
              return const Placeholder();
            },
          ),
        ),
      );
      return testApp;
    }, returnsNormally);
  });
}
