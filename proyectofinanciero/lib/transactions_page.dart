import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// firebase_analytics removed: not used in this screen
import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _filterType = 'all'; // all | income | expense

  IconData _iconForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('food') || c.contains('comida')) return Icons.fastfood;
    if (c.contains('shop') || c.contains('shopping') || c.contains('tienda'))
      return Icons.shopping_bag;
    if (c.contains('enter') || c.contains('movie') || c.contains('ocio'))
      return Icons.movie;
    if (c.contains('travel') || c.contains('viaje') || c.contains('transporte'))
      return Icons.flight;
    if (c.contains('transport') || c.contains('taxi'))
      return Icons.directions_car;
    return Icons.receipt_long;
  }

  Color _colorForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('food') || c.contains('comida'))
      return const Color(0xFFFFC857); // amber
    if (c.contains('shop') || c.contains('shopping') || c.contains('tienda'))
      return const Color(0xFFB39DDB); // purple
    if (c.contains('enter') || c.contains('movie') || c.contains('ocio'))
      return const Color(0xFFFF8A80); // red/pink
    if (c.contains('travel') || c.contains('viaje') || c.contains('transporte'))
      return const Color(0xFF80DEEA); // teal
    if (c.contains('transport') || c.contains('taxi'))
      return const Color(0xFF90CAF9); // blue
    return const Color(0xFFD6D6D6); // neutral
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 18),
          // Header: avatar + welcome
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
                      'Welcome!',
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
                const Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _BalanceCard(uid: uid),
          ),
          const SizedBox(height: 12),
          _buildFilterRow(),
          const SizedBox(height: 8),
          Expanded(child: _buildTransactionList(uid)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: GestureDetector(
          onTap: () => _showAddModal(context, uid),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00B2E7),
                  Color(0xFFE064F7),
                  Color(0xFFFFB6DC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: _filterType == 'all',
            onSelected: (_) => setState(() => _filterType = 'all'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Ingresos'),
            selected: _filterType == 'income',
            onSelected: (_) => setState(() => _filterType = 'income'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Egresos'),
            selected: _filterType == 'expense',
            onSelected: (_) => setState(() => _filterType = 'expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(String? uid) {
    if (uid == null) {
      return const Center(
        child: Text('Inicia sesión para ver tus transacciones'),
      );
    }

    Query q = FirebaseFirestore.instance
        .collection('transacciones')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    if (_filterType == 'income') {
      q = q.where('type', isEqualTo: 'income');
    } else if (_filterType == 'expense') {
      q = q.where('type', isEqualTo: 'expense');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Ocultar el mensaje crudo de error para el usuario final.
          // En modo debug imprimimos el error completo en consola.
          if (kDebugMode)
            debugPrint('Firestore snapshot error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.black45,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No se pueden cargar las transacciones en este momento.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty)
          return const Center(child: Text('No hay transacciones aún'));

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final d = docs[index];
            final data = d.data() as Map<String, dynamic>;
            final rawAmount = data['amount'];
            final amount = rawAmount is num
                ? rawAmount.toDouble()
                : double.tryParse('$rawAmount') ?? 0.0;
            final type = data['type'] ?? 'expense';
            final category = data['category'] ?? '';
            final note = data['note'] ?? '';
            final ts = data['createdAt'] as Timestamp?;
            final date = ts != null ? ts.toDate() : DateTime.now();

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: _colorForCategory(
                    category,
                  ).withOpacity(0.18),
                  child: Icon(
                    _iconForCategory(category),
                    color: _colorForCategory(category),
                    size: 20,
                  ),
                ),
                title: Text(
                  category.isNotEmpty
                      ? category
                      : (note.isNotEmpty ? note : 'Movimiento'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    note.isNotEmpty ? note : (category.isNotEmpty ? '' : ''),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      type == 'income'
                          ? '+\$${amount.toStringAsFixed(2)}'
                          : '-\$${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: type == 'income'
                            ? const Color(0xFF00B2E7)
                            : const Color(0xFFE064F7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddModal(BuildContext context, String? uid) {
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Inicia sesión primero')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: AddTransactionForm(uid: uid),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String? uid;
  const _BalanceCard({Key? key, this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Balance',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 8),
              Text(
                '\$0.00',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('transacciones')
        .where('uid', isEqualTo: uid)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        double incomeSum = 0;
        double expenseSum = 0;
        if (snapshot.hasData) {
          for (final d in snapshot.data!.docs) {
            final Map<String, dynamic> data = d.data() as Map<String, dynamic>;
            final raw = data['amount'];
            final amt = raw is num
                ? raw.toDouble()
                : double.tryParse('$raw') ?? 0.0;
            final type = data['type'] ?? 'expense';
            if (type == 'income') {
              incomeSum += amt;
            } else {
              expenseSum += amt;
            }
          }
        }

        final balanceDisplay = (incomeSum - expenseSum).toStringAsFixed(2);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF00B2E7), Color(0xFFE064F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(color: Colors.white70),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$ $balanceDisplay',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ingresos',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '+\$${incomeSum.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Egresos',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '-\$${expenseSum.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddTransactionForm extends StatefulWidget {
  final String uid;
  const AddTransactionForm({required this.uid, super.key});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'expense';
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Ingreso'),
                selected: _type == 'income',
                onSelected: (_) => setState(() => _type = 'income'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Egreso'),
                selected: _type == 'expense',
                onSelected: (_) => setState(() => _type = 'expense'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Ingresa un monto';
                    final n = double.tryParse(v.replaceAll(',', '.'));
                    if (n == null || n <= 0) return 'Monto inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onSubmit,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));
      await FirebaseFirestore.instance.collection('transacciones').add({
        'uid': widget.uid,
        'amount': amount,
        'type': _type,
        'category': _categoryCtrl.text.trim(),
        'note': _noteCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      if (kDebugMode) debugPrint('Error al guardar transacción: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
