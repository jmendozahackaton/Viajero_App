import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackaton_app/domain/usecases/get_current_user_usecase.dart';

class DependencyTestWidget extends StatelessWidget {
  const DependencyTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final getCurrentUserUseCase = context.read<GetCurrentUserUseCase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Test Dependencias')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✅ Inyección de dependencias configurada correctamente'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = await getCurrentUserUseCase.execute();
                  print('Usuario actual: ${user.uid}');
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: const Text('Test GetCurrentUserUseCase'),
            ),
          ],
        ),
      ),
    );
  }
}
