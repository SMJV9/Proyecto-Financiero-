import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _filterType = 'all'; // all | income | expense

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Transacciones')),
      body: Column(
        children: [
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddModal(context, uid),
        child: const Icon(Icons.account_balance_wallet_outlined),
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
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return const Center(child: Text('No hay transacciones aún'));

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final d = docs[index];
            final data = d.data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0).toDouble();
            final type = data['type'] ?? 'expense';
            final category = data['category'] ?? '';
            final note = data['note'] ?? '';
            final ts = data['createdAt'] as Timestamp?;
            final date = ts != null ? ts.toDate() : DateTime.now();

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: type == 'income'
                    ? Colors.green[100]
                    : Colors.red[100],
                child: Icon(
                  type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: type == 'income' ? Colors.green[800] : Colors.red[800],
                ),
              ),
              title: Text(
                '${type == 'income' ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
              ),
              subtitle: Text('$category • $note'),
              trailing: Text('${date.day}/${date.month}/${date.year}'),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddModal(BuildContext context, String? uid) async {
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
  const _BalanceCard({this.uid, super.key});

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
        double balance = 0;
        if (snapshot.hasData) {
          for (final d in snapshot.data!.docs) {
            final Map<String, dynamic> data = d.data() as Map<String, dynamic>;
            final amt = (data['amount'] ?? 0).toDouble();
            final type = data['type'] ?? 'expense';
            balance += (type == 'income') ? amt : -amt;
          }
        }

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: const [Icon(Icons.pie_chart_outline, size: 36)],
                ),
              ],
            ),
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
