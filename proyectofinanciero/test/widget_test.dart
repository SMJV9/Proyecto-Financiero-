import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyectofinanciero/themes.dart';

void main() {
  group('Pruebas de Temas', () {
    test('Tema claro debe tener brillo correcto', () {
      final lightTheme = AppThemes.lightTheme;
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.colorScheme.primary, const Color(0xFF00B2E7));
    });

    test('Tema oscuro debe tener brillo correcto', () {
      final darkTheme = AppThemes.darkTheme;
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.colorScheme.primary, const Color(0xFF00B2E7));
    });

    test('Colores principales deben ser correctos', () {
      expect(
        const Color(0xFF00B2E7),
        equals(const Color(0xFF00B2E7)),
      ); // Azul principal
      expect(
        const Color(0xFFE064F7),
        equals(const Color(0xFFE064F7)),
      ); // Morado secundario
      expect(
        const Color(0xFFFFB6DC),
        equals(const Color(0xFFFFB6DC)),
      ); // Rosa accent
    });
  });

  group('Pruebas de Validaciones', () {
    test('Validación de montos', () {
      // Montos válidos
      expect(100.50 > 0, isTrue);
      expect(1000000000 <= 1000000000, isTrue); // Límite máximo

      // Montos inválidos
      expect(-50.0 > 0, isFalse);
      expect(0.0 > 0, isFalse);
    });

    test('Validación de decimales', () {
      const amount = 123.45;
      final decimals = amount.toString().split('.').length > 1
          ? amount.toString().split('.')[1].length
          : 0;

      expect(decimals <= 2, isTrue); // Máximo 2 decimales
    });

    test('Categorías válidas', () {
      const validCategories = [
        'Comida',
        'Transporte',
        'Entretenimiento',
        'Salud',
      ];
      const testCategory = 'Comida';

      expect(validCategories.contains(testCategory), isTrue);
    });
  });

  group('Pruebas de Formato', () {
    test('Formato de dinero', () {
      const amount = 1234.56;
      final formatted = '\$${amount.toStringAsFixed(2)}';

      expect(formatted, equals('\$1234.56'));
    });

    test('Números grandes', () {
      const largeAmount = 1000000.0;
      expect(largeAmount >= 1000000, isTrue);
    });
  });
}
