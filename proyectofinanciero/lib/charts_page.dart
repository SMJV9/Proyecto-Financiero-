import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  String _selectedPeriod = 'Este mes';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 18),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B2E7), Color(0xFFE064F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: Icon(Icons.person, color: Color(0xFF00B2E7)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gráficos',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.displayName ?? user?.email ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Period selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedPeriod = 'Esta semana'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedPeriod == 'Esta semana'
                              ? const Color(0xFF00B2E7)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Esta semana',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedPeriod == 'Esta semana'
                                ? Colors.white
                                : Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = 'Este mes'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedPeriod == 'Este mes'
                              ? const Color(0xFF00B2E7)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Este mes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedPeriod == 'Este mes'
                                ? Colors.white
                                : Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = 'Este año'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedPeriod == 'Este año'
                              ? const Color(0xFF00B2E7)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Este año',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedPeriod == 'Este año'
                                ? Colors.white
                                : Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Summary cards
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard(uid, 'ingresos')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSummaryCard(uid, 'gastos')),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Bar chart showing transactions over time
                  Expanded(child: _buildTransactionBarChart(uid)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String? uid, String type) {
    if (uid == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == 'ingresos' ? 'Ingresos' : 'Gastos',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '\$0.00',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection(type)
        .where('id_usuario', isEqualTo: uid)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        double total = 0;
        if (snapshot.hasData) {
          for (final d in snapshot.data!.docs) {
            final Map<String, dynamic> data = d.data() as Map<String, dynamic>;
            final raw = data[type == 'ingresos' ? 'monto_ingr' : 'monto_gasto'];
            final amt = raw is num
                ? raw.toDouble()
                : double.tryParse('$raw') ?? 0.0;
            total += amt;
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    type == 'ingresos'
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: type == 'ingresos'
                        ? const Color(0xFF00B2E7)
                        : const Color(0xFFE064F7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type == 'ingresos' ? 'Ingresos' : 'Gastos',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: type == 'ingresos'
                      ? const Color(0xFF00B2E7)
                      : const Color(0xFFE064F7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionBarChart(String? uid) {
    if (uid == null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Transacciones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    _selectedPeriod,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Inicia sesión para ver tus transacciones',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ingresos')
          .where('id_usuario', isEqualTo: uid)
          .snapshots(),
      builder: (context, ingresosSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('gastos')
              .where('id_usuario', isEqualTo: uid)
              .snapshots(),
          builder: (context, gastosSnapshot) {
            if (ingresosSnapshot.connectionState == ConnectionState.waiting ||
                gastosSnapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            // Process data for bar chart
            Map<DateTime, double> dailyIngresos = {};
            Map<DateTime, double> dailyGastos = {};
            double totalAmount = 0;

            if (ingresosSnapshot.hasData) {
              for (final doc in ingresosSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final amount = data['monto_ingr'];
                final amountDouble = amount is num
                    ? amount.toDouble()
                    : double.tryParse('$amount') ?? 0.0;

                final fecha = data['fecha'];
                DateTime date;
                if (fecha is Timestamp) {
                  date = fecha.toDate();
                } else if (fecha is String) {
                  date = DateTime.tryParse(fecha) ?? DateTime.now();
                } else {
                  date = DateTime.now();
                }

                // Group by day
                final dayKey = DateTime(date.year, date.month, date.day);
                dailyIngresos[dayKey] =
                    (dailyIngresos[dayKey] ?? 0) + amountDouble;
                totalAmount += amountDouble;
              }
            }

            if (gastosSnapshot.hasData) {
              for (final doc in gastosSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final amount = data['monto_gasto'];
                final amountDouble = amount is num
                    ? amount.toDouble()
                    : double.tryParse('$amount') ?? 0.0;

                final fecha = data['fecha'];
                DateTime date;
                if (fecha is Timestamp) {
                  date = fecha.toDate();
                } else if (fecha is String) {
                  date = DateTime.tryParse(fecha) ?? DateTime.now();
                } else {
                  date = DateTime.now();
                }

                // Group by day
                final dayKey = DateTime(date.year, date.month, date.day);
                dailyGastos[dayKey] = (dailyGastos[dayKey] ?? 0) + amountDouble;
                totalAmount += amountDouble;
              }
            }

            if (totalAmount == 0) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Text(
                            'Transacciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _selectedPeriod,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 48,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No hay transacciones',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Get last 7 days or available data
            final allDates = <DateTime>{
              ...dailyIngresos.keys,
              ...dailyGastos.keys,
            }.toList();
            allDates.sort();

            // Take last 7 days or all available
            final displayDates = allDates.length > 7
                ? allDates.sublist(allDates.length - 7)
                : allDates;

            final barChartData = displayDates.map((date) {
              final ingresos = dailyIngresos[date] ?? 0;
              final gastos = dailyGastos[date] ?? 0;
              return TransactionBarData(
                date: date,
                ingresos: ingresos,
                gastos: gastos,
              );
            }).toList();

            final total =
                dailyIngresos.values.fold(0.0, (sum, val) => sum + val) +
                dailyGastos.values.fold(0.0, (sum, val) => sum + val);

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Text(
                          'Transacciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Text(
                              'Income',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Expenses',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: [
                          // Period and total
                          Row(
                            children: [
                              Text(
                                '01 Jan 2021 - 01 Apr 2021', // This would be dynamic based on selected period
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Bar chart
                          Expanded(
                            child: CustomPaint(
                              painter: TransactionBarChartPainter(barChartData),
                              child: Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIncomeExpensePieChart(String? uid) {
    if (uid == null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Ingresos vs Gastos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    _selectedPeriod,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Inicia sesión para ver tus gráficos',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ingresos')
          .where('id_usuario', isEqualTo: uid)
          .snapshots(),
      builder: (context, ingresosSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('gastos')
              .where('id_usuario', isEqualTo: uid)
              .snapshots(),
          builder: (context, gastosSnapshot) {
            if (ingresosSnapshot.connectionState == ConnectionState.waiting ||
                gastosSnapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            double totalIngresos = 0;
            double totalGastos = 0;

            if (ingresosSnapshot.hasData) {
              for (final doc in ingresosSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final amount = data['monto_ingr'];
                final amountDouble = amount is num
                    ? amount.toDouble()
                    : double.tryParse('$amount') ?? 0.0;
                totalIngresos += amountDouble;
              }
            }

            if (gastosSnapshot.hasData) {
              for (final doc in gastosSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final amount = data['monto_gasto'];
                final amountDouble = amount is num
                    ? amount.toDouble()
                    : double.tryParse('$amount') ?? 0.0;
                totalGastos += amountDouble;
              }
            }

            final total = totalIngresos + totalGastos;

            if (total == 0) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Text(
                            'Ingresos vs Gastos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _selectedPeriod,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pie_chart_outline,
                              size: 48,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No hay transacciones aún',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Agrega ingresos y gastos para ver el gráfico',
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final pieData = PieChartData(
              totalIngresos: totalIngresos,
              totalGastos: totalGastos,
              ingresosPercentage: totalIngresos / total,
              gastosPercentage: totalGastos / total,
            );

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Text(
                          'Ingresos vs Gastos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _selectedPeriod,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          // Pie Chart
                          Expanded(
                            flex: 3,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CustomPaint(
                                painter: PieChartPainter(pieData),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Legend
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(
                                  'Ingresos',
                                  totalIngresos,
                                  pieData.ingresosPercentage,
                                  const Color(0xFF00B2E7),
                                ),
                                const SizedBox(height: 16),
                                _buildLegendItem(
                                  'Gastos',
                                  totalGastos,
                                  pieData.gastosPercentage,
                                  const Color(0xFFE064F7),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F3FB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Balance',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${(totalIngresos - totalGastos).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              (totalIngresos - totalGastos) >= 0
                                              ? const Color(0xFF4CAF50)
                                              : const Color(0xFFE64545),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLegendItem(
    String label,
    double amount,
    double percentage,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TransactionBarData {
  final DateTime date;
  final double ingresos;
  final double gastos;

  TransactionBarData({
    required this.date,
    required this.ingresos,
    required this.gastos,
  });
}

class TransactionBarChartPainter extends CustomPainter {
  final List<TransactionBarData> data;

  TransactionBarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;

    // Colors
    const ingresosColor = Color(0xFF00B2E7);
    const gastosColor = Color(0xFFE064F7);

    final barWidth = (size.width - 40) / (data.length * 2);
    final maxAmount = data.fold<double>(0, (max, item) {
      final itemMax = item.ingresos > item.gastos ? item.ingresos : item.gastos;
      return itemMax > max ? itemMax : max;
    });

    if (maxAmount == 0) return;

    final chartHeight = size.height - 40; // Leave space for labels

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final x = 20 + i * barWidth * 2;

      // Draw ingresos bar
      if (item.ingresos > 0) {
        paint.color = ingresosColor;
        final barHeight = (item.ingresos / maxAmount) * chartHeight * 0.8;
        final rect = Rect.fromLTWH(
          x,
          chartHeight - barHeight,
          barWidth * 0.8,
          barHeight,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          paint,
        );
      }

      // Draw gastos bar
      if (item.gastos > 0) {
        paint.color = gastosColor;
        final barHeight = (item.gastos / maxAmount) * chartHeight * 0.8;
        final rect = Rect.fromLTWH(
          x + barWidth * 0.8 + 2,
          chartHeight - barHeight,
          barWidth * 0.8,
          barHeight,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          paint,
        );
      }

      // Draw day label
      final dayLabel = _getDayLabel(item.date.weekday);
      final textPainter = TextPainter(
        text: TextSpan(
          text: dayLabel,
          style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth - textPainter.width / 2, size.height - 15),
      );
    }

    // Draw amount scale on left
    for (int i = 0; i <= 4; i++) {
      final amount = (maxAmount / 4) * i;
      final y = chartHeight - (chartHeight * 0.8 * i / 4);

      final textPainter = TextPainter(
        text: TextSpan(
          text: amount > 1000
              ? '${(amount / 1000).toStringAsFixed(1)}k'
              : amount.toStringAsFixed(0),
          style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }
  }

  String _getDayLabel(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lu';
      case 2:
        return 'Ma';
      case 3:
        return 'Mi';
      case 4:
        return 'Ju';
      case 5:
        return 'Vi';
      case 6:
        return 'Sa';
      case 7:
        return 'Do';
      default:
        return '';
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartData {
  final double totalIngresos;
  final double totalGastos;
  final double ingresosPercentage;
  final double gastosPercentage;

  PieChartData({
    required this.totalIngresos,
    required this.totalGastos,
    required this.ingresosPercentage,
    required this.gastosPercentage,
  });
}

class PieChartPainter extends CustomPainter {
  final PieChartData data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (size.width < size.height ? size.width : size.height) / 2 * 0.8;

    final paint = Paint()..style = PaintingStyle.fill;

    // Colors
    const ingresosColor = Color(0xFF00B2E7);
    const gastosColor = Color(0xFFE064F7);

    // Draw ingresos section
    paint.color = ingresosColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * data.ingresosPercentage, // Angle based on percentage
      true,
      paint,
    );

    // Draw gastos section
    paint.color = gastosColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + 2 * pi * data.ingresosPercentage, // Start where ingresos ended
      2 * pi * data.gastosPercentage, // Angle based on percentage
      true,
      paint,
    );

    // Draw center circle (donut effect)
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.5, paint);

    // Draw total amount in center
    final total = data.totalIngresos + data.totalGastos;
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Total\n',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          TextSpan(
            text: '\$${total.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}