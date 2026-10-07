import 'package:flutter/material.dart';

import 'logica_calculadora.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PantallaCalculadora(),
    );
  }
}

class PantallaCalculadora extends StatefulWidget {
  const PantallaCalculadora({super.key});

  @override
  State<PantallaCalculadora> createState() => _PantallaCalculadoraState();
}

class _PantallaCalculadoraState extends State<PantallaCalculadora> {
  final _calc = LogicaCalculadora();

  // Azul si es positivo, rojo si es negativo (o error), gris si es cero
  Color get _colorDisplay {
    final v = _calc.valor;
    if (v == null || v < 0) return Colors.red;
    if (v > 0) return Colors.blue;
    return Colors.grey;
  }

  void _pulsar(String tecla) {
    setState(() {
      switch (tecla) {
        case 'C':
          _calc.limpiar();
        case '⌫':
          _calc.borrar();
        case '±':
          _calc.cambiarSigno();
        case '.':
          _calc.punto();
        case '=':
          _calc.igual();
        case '+' || '-' || '×' || '÷':
          _calc.operador(tecla);
        default:
          _calc.digito(tecla);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(flex: 2, child: _display()),
              const SizedBox(height: 16),
              Expanded(flex: 5, child: _teclado()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _display() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _colorDisplay.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colorDisplay, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Operación en curso
          Text(
            _calc.expresion,
            key: const Key('expresion'),
            style: TextStyle(fontSize: 22, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          // Número actual / resultado
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: _colorDisplay,
              ),
              child: Text(_calc.entrada, key: const Key('display')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teclado() {
    const filas = [
      ['C', '⌫', '±', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];
    return Column(
      children: [
        for (final fila in filas)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final tecla in fila)
                  Expanded(
                    // El 0 ocupa dos columnas
                    flex: tecla == '0' ? 2 : 1,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: _boton(tecla),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _boton(String tecla) {
    final esOperador = '+-×÷'.contains(tecla);
    final esIgual = tecla == '=';
    final esFuncion = 'C⌫±'.contains(tecla);

    final Color fondo;
    final Color texto;
    if (esIgual) {
      fondo = Colors.blue.shade700;
      texto = Colors.white;
    } else if (esOperador) {
      fondo = Colors.blue.shade100;
      texto = Colors.blue.shade900;
    } else if (tecla == 'C') {
      fondo = Colors.red.shade400;
      texto = Colors.white;
    } else if (esFuncion) {
      fondo = Colors.grey.shade300;
      texto = Colors.black87;
    } else {
      fondo = Colors.white;
      texto = Colors.black87;
    }

    return ElevatedButton(
      onPressed: () => _pulsar(tecla),
      style: ElevatedButton.styleFrom(
        backgroundColor: fondo,
        foregroundColor: texto,
        elevation: 2,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        tecla,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
      ),
    );
  }
}
