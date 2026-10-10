import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:limita/data/app_state.dart';
import 'package:limita/main.dart';

void main() {
  testWidgets('shows sign in screen', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => AppState(), child: const LimitaApp()),
    );
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
