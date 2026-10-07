// Lógica de la calculadora, independiente de la interfaz.
class LogicaCalculadora {
  static const int _maxDigitos = 15;

  String _entrada = '0'; // Número que se está escribiendo / resultado
  double? _acumulado; // Primer operando
  String? _operador; // '+', '-', '×', '÷'
  String _expresion = ''; // Texto de la operación en curso (ej. "12 +")
  bool _nuevaEntrada = true; // El próximo dígito reemplaza la entrada
  bool _error = false;

  String get entrada => _entrada;
  String get expresion => _expresion;
  bool get hayError => _error;

  /// Valor numérico mostrado (null si hay error).
  double? get valor => _error ? null : double.tryParse(_entrada);

  void digito(String d) {
    if (_error) limpiar();
    if (_nuevaEntrada || _entrada == '0') {
      _entrada = d;
      _nuevaEntrada = false;
    } else if (_entrada.replaceAll(RegExp(r'[-.]'), '').length < _maxDigitos) {
      _entrada += d;
    }
  }

  void punto() {
    if (_error) limpiar();
    if (_nuevaEntrada) {
      _entrada = '0.';
      _nuevaEntrada = false;
    } else if (!_entrada.contains('.')) {
      _entrada += '.';
    }
  }

  void operador(String op) {
    if (_error) return;
    if (_operador != null && !_nuevaEntrada) {
      // Encadenar: 2 + 3 + ... calcula primero 2 + 3
      if (!_calcular()) return;
    }
    _acumulado = double.parse(_entrada);
    _operador = op;
    _expresion = '${formatear(_acumulado!)} $op';
    _nuevaEntrada = true;
  }

  void igual() {
    if (_error || _operador == null) return;
    final a = _acumulado!;
    final b = double.parse(_entrada);
    final op = _operador!;
    if (_calcular()) {
      _expresion = '${formatear(a)} $op ${formatear(b)} =';
    }
    _operador = null;
    _acumulado = null;
    _nuevaEntrada = true;
  }

  void limpiar() {
    _entrada = '0';
    _acumulado = null;
    _operador = null;
    _expresion = '';
    _nuevaEntrada = true;
    _error = false;
  }

  void borrar() {
    if (_error || _nuevaEntrada) return;
    _entrada = _entrada.length > 1 && _entrada != '-0'
        ? _entrada.substring(0, _entrada.length - 1)
        : '0';
    if (_entrada == '-') _entrada = '0';
  }

  void cambiarSigno() {
    if (_error || _entrada == '0') return;
    _entrada =
        _entrada.startsWith('-') ? _entrada.substring(1) : '-$_entrada';
  }

  /// Aplica el operador pendiente; deja el resultado en [_entrada].
  bool _calcular() {
    final a = _acumulado!;
    final b = double.parse(_entrada);
    final double r;
    switch (_operador) {
      case '+':
        r = a + b;
      case '-':
        r = a - b;
      case '×':
        r = a * b;
      case '÷':
        if (b == 0) {
          _entrada = 'Error';
          _expresion = 'No se puede dividir entre 0';
          _error = true;
          _operador = null;
          _acumulado = null;
          return false;
        }
        r = a / b;
      default:
        return false;
    }
    _entrada = formatear(r);
    return true;
  }

  /// Muestra enteros sin ".0" y corrige errores de punto flotante
  /// (0.1 + 0.2 → 0.3).
  static String formatear(double n) {
    if (n.isInfinite || n.isNaN) return 'Error';
    final redondeado = double.parse(n.toStringAsPrecision(12));
    if (redondeado == redondeado.truncateToDouble() && redondeado.abs() < 1e15) {
      return redondeado.toInt().toString();
    }
    return redondeado.toString();
  }
}
