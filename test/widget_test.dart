import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculadora/logica_calculadora.dart';
import 'package:calculadora/main.dart';

LogicaCalculadora teclear(String teclas) {
  final c = LogicaCalculadora();
  for (final t in teclas.split(' ')) {
    switch (t) {
      case '=':
        c.igual();
      case '.':
        c.punto();
      case 'C':
        c.limpiar();
      case '+' || '-' || '×' || '÷':
        c.operador(t);
      default:
        for (final d in t.split('')) {
          c.digito(d);
        }
    }
  }
  return c;
}

void main() {
  group('Lógica', () {
    test('suma, resta, multiplicación y división', () {
      expect(teclear('12 + 5 =').entrada, '17');
      expect(teclear('3 - 10 =').entrada, '-7');
      expect(teclear('6 × 7 =').entrada, '42');
      expect(teclear('7 ÷ 2 =').entrada, '3.5');
    });

    test('decimales sin error de punto flotante', () {
      expect(teclear('0 . 1 + 0 . 2 =').entrada, '0.3');
    });

    test('encadena operaciones', () {
      expect(teclear('2 + 3 × 4 =').entrada, '20');
    });

    test('muestra la expresión', () {
      expect(teclear('12 + 5 =').expresion, '12 + 5 =');
    });

    test('división entre cero da error y C limpia', () {
      final c = teclear('5 ÷ 0 =');
      expect(c.hayError, isTrue);
      c.limpiar();
      expect(c.entrada, '0');
    });

    test('un solo punto decimal', () {
      expect(teclear('1 . . 5').entrada, '1.5');
    });
  });

  testWidgets('color del display: gris, azul y rojo', (tester) async {
    await tester.pumpWidget(const CalculadoraApp());
    Color color() =>
        tester.widget<AnimatedDefaultTextStyle>(find.ancestor(
            of: find.byKey(const Key('display')),
            matching: find.byType(AnimatedDefaultTextStyle)).first).style.color!;

    expect(color(), Colors.grey);

    await tester.tap(find.text('8'));
    await tester.pump();
    expect(color(), Colors.blue);

    await tester.tap(find.text('-'));
    await tester.tap(find.text('9'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(find.text('-1'), findsOneWidget);
    expect(color(), Colors.red);
  });
}
