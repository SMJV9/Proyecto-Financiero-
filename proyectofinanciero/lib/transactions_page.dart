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

    if (_filterType == 'income') {
      final q = FirebaseFirestore.instance
          .collection('ingresos')
          .where('id_usuario', isEqualTo: uid)
          .orderBy('fecha', descending: true);
      return StreamBuilder<QuerySnapshot>(
        stream: q.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (kDebugMode) {
              debugPrint('Firestore ingresos error: ${snapshot.error}');
            }
            return _errorListPlaceholder();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No hay ingresos aún'));
          }
          return _buildListFromDocs(
            docs.map((d) => _TxnItem('ingresos', d)).toList(),
            uid,
          );
        },
      );
    }

    if (_filterType == 'expense') {
      final q = FirebaseFirestore.instance
          .collection('gastos')
          .where('id_usuario', isEqualTo: uid)
          .orderBy('fecha', descending: true);
      return StreamBuilder<QuerySnapshot>(
        stream: q.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (kDebugMode) {
              debugPrint('Firestore gastos error: ${snapshot.error}');
            }
            return _errorListPlaceholder();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No hay egresos aún'));
          }
          return _buildListFromDocs(
            docs.map((d) => _TxnItem('gastos', d)).toList(),
            uid,
          );
        },
      );
    }

    // all: combinar ingresos + gastos y ordenar en cliente
    final incomeQ = FirebaseFirestore.instance
        .collection('ingresos')
        .where('id_usuario', isEqualTo: uid)
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: incomeQ,
      builder: (context, incomeSnap) {
        if (incomeSnap.hasError) return _errorListPlaceholder();
        if (incomeSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenseQ = FirebaseFirestore.instance
            .collection('gastos')
            .where('id_usuario', isEqualTo: uid)
            .snapshots();
        return StreamBuilder<QuerySnapshot>(
          stream: expenseQ,
          builder: (context, expenseSnap) {
            if (expenseSnap.hasError) return _errorListPlaceholder();
            if (expenseSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = <_TxnItem>[];
            items.addAll(
              (incomeSnap.data?.docs ?? []).map((d) => _TxnItem('ingresos', d)),
            );
            items.addAll(
              (expenseSnap.data?.docs ?? []).map((d) => _TxnItem('gastos', d)),
            );

            // ordenar por createdAt desc en cliente
            items.sort((a, b) {
              final da =
                  ((a.doc.data() as Map<String, dynamic>)['fecha']
                          as Timestamp?)
                      ?.toDate();
              final db =
                  ((b.doc.data() as Map<String, dynamic>)['fecha']
                          as Timestamp?)
                      ?.toDate();
              final ad = da ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bd = db ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bd.compareTo(ad);
            });

            if (items.isEmpty) {
              return const Center(child: Text('No hay transacciones aún'));
            }
            return _buildListFromDocs(items, uid);
          },
        );
      },
    );
  }

  Widget _errorListPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.error_outline, size: 48, color: Colors.black45),
          SizedBox(height: 8),
          Text(
            'No se pueden cargar las transacciones en este momento.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListFromDocs(List<_TxnItem> items, String uid) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final data = item.doc.data() as Map<String, dynamic>;

        // Map fields based on collection type
        final double amount;
        final String category;
        final String note;

        if (item.collection == 'ingresos') {
          final rawAmount = data['monto_ingr'];
          amount = rawAmount is num
              ? rawAmount.toDouble()
              : double.tryParse('$rawAmount') ?? 0.0;
          category = data['tipo_ingr'] ?? '';
          note = data['descripcion'] ?? '';
        } else {
          final rawAmount = data['monto_gasto'];
          amount = rawAmount is num
              ? rawAmount.toDouble()
              : double.tryParse('$rawAmount') ?? 0.0;
          category = data['tipo_gasto'] ?? '';
          note = data['descripcion'] ?? '';
        }

        final type = item.collection == 'ingresos' ? 'income' : 'expense';
        final ts = data['fecha'] as Timestamp?;
        final date = ts != null ? ts.toDate() : DateTime.now();

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: _colorForCategory(category).withOpacity(0.18),
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
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
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
            onTap: () => _showEditModal(
              context,
              uid,
              item.collection,
              item.doc.id,
              type,
              amount,
              category,
              note,
              item.collection == 'ingresos'
                  ? data['frecuencia_ingr'] ?? 'única'
                  : data['frecuencia_gasto'] ?? 'única',
              date,
            ),
          ),
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

  void _showEditModal(
    BuildContext context,
    String uid,
    String collection,
    String docId,
    String type,
    double amount,
    String category,
    String note,
    String frecuencia,
    DateTime createdAt,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: EditTransactionForm(
          uid: uid,
          initialCollection: collection,
          docId: docId,
          initialType: type,
          initialAmount: amount,
          initialCategory: category,
          initialNote: note,
          initialFrecuencia: frecuencia,
          initialCreatedAt: createdAt,
        ),
      ),
    );
  }
}

class _TxnItem {
  final String collection; // 'ingresos' | 'gastos'
  final QueryDocumentSnapshot doc;
  _TxnItem(this.collection, this.doc);
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

    final incomesStream = FirebaseFirestore.instance
        .collection('ingresos')
        .where('id_usuario', isEqualTo: uid)
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: incomesStream,
      builder: (context, incomesSnap) {
        double incomeSum = 0;
        if (incomesSnap.hasData) {
          for (final d in incomesSnap.data!.docs) {
            final Map<String, dynamic> data = d.data() as Map<String, dynamic>;
            final raw = data['monto_ingr'];
            final amt = raw is num
                ? raw.toDouble()
                : double.tryParse('$raw') ?? 0.0;
            incomeSum += amt;
          }
        }

        final expensesStream = FirebaseFirestore.instance
            .collection('gastos')
            .where('id_usuario', isEqualTo: uid)
            .snapshots();

        return StreamBuilder<QuerySnapshot>(
          stream: expensesStream,
          builder: (context, expensesSnap) {
            double expenseSum = 0;
            if (expensesSnap.hasData) {
              for (final d in expensesSnap.data!.docs) {
                final Map<String, dynamic> data =
                    d.data() as Map<String, dynamic>;
                final raw = data['monto_gasto'];
                final amt = raw is num
                    ? raw.toDouble()
                    : double.tryParse('$raw') ?? 0.0;
                expenseSum += amt;
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
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white70,
                        ),
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
  final _noteCtrl = TextEditingController();
  final _frecuenciaCtrl = TextEditingController();
  bool _loading = false;
  String _selectedCategory = 'Other';
  final _customCategoryCtrl = TextEditingController();
  String _selectedFrecuencia = 'única';

  List<String> get _expenseCategories => const [
    'Food',
    'Shopping',
    'Entertainment',
    'Travel',
    'Transport',
    'Bills',
    'Health',
    'Education',
    'Gifts',
    'Other',
  ];

  List<String> get _incomeCategories => const [
    'Salary',
    'Bonus',
    'Freelance',
    'Investment',
    'Refund',
    'Other',
  ];

  List<String> get _frecuencias => const [
    'única',
    'semanal',
    'quincenal',
    'mensual',
    'bimestral',
    'anual',
  ];

  List<String> get _categories =>
      _type == 'income' ? _incomeCategories : _expenseCategories;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _customCategoryCtrl.dispose();
    _noteCtrl.dispose();
    _frecuenciaCtrl.dispose();
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
                onSelected: (_) => setState(() {
                  _type = 'income';
                  // Reiniciar selección cuando cambia el tipo
                  _selectedCategory = 'Other';
                  _customCategoryCtrl.clear();
                }),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Egreso'),
                selected: _type == 'expense',
                onSelected: (_) => setState(() {
                  _type = 'expense';
                  _selectedCategory = 'Other';
                  _customCategoryCtrl.clear();
                }),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((c) {
                    final selected = _selectedCategory == c;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _chipIconForCategory(c),
                            size: 16,
                            color: selected
                                ? Colors.white
                                : _chipColorForCategory(c),
                          ),
                          const SizedBox(width: 6),
                          Text(c),
                        ],
                      ),
                      selected: selected,
                      selectedColor: _chipColorForCategory(c),
                      backgroundColor: _chipColorForCategory(
                        c,
                      ).withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = c),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                if (_selectedCategory == 'Other')
                  TextFormField(
                    controller: _customCategoryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Otra categoría',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (v) {
                      if (_selectedCategory == 'Other') {
                        if (v == null || v.trim().isEmpty) {
                          return 'Escribe la categoría';
                        }
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Frecuencia',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedFrecuencia,
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: _frecuencias.map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(freq.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFrecuencia = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
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
      final category = _selectedCategory == 'Other'
          ? _customCategoryCtrl.text.trim()
          : _selectedCategory;
      final collection = _type == 'income' ? 'ingresos' : 'gastos';

      // Map fields to match your database structure
      final data = <String, dynamic>{'createdAt': FieldValue.serverTimestamp()};

      if (_type == 'income') {
        data.addAll({
          'id_usuario': widget.uid,
          'monto_ingr': amount,
          'tipo_ingr': category,
          'descripcion': _noteCtrl.text.trim(),
          'frecuencia_ingr': _selectedFrecuencia,
          'fecha': FieldValue.serverTimestamp(),
        });
      } else {
        data.addAll({
          'id_usuario': widget.uid,
          'monto_gasto': amount,
          'tipo_gasto': category,
          'descripcion': _noteCtrl.text.trim(),
          'frecuencia_gasto': _selectedFrecuencia,
          'fecha': FieldValue.serverTimestamp(),
        });
      }

      await FirebaseFirestore.instance.collection(collection).add(data);
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

  IconData _chipIconForCategory(String c) {
    final lc = c.toLowerCase();
    if (lc.contains('food') || lc.contains('comida')) return Icons.fastfood;
    if (lc.contains('shop') || lc.contains('shopping') || lc.contains('tienda'))
      return Icons.shopping_bag;
    if (lc.contains('enter') || lc.contains('movie') || lc.contains('ocio'))
      return Icons.movie;
    if (lc.contains('travel') || lc.contains('viaje')) return Icons.flight;
    if (lc.contains('transport') || lc.contains('taxi'))
      return Icons.directions_car;
    if (lc.contains('salary') ||
        lc.contains('bonus') ||
        lc.contains('freelance'))
      return Icons.payments;
    if (lc.contains('investment') || lc.contains('refund'))
      return Icons.savings;
    return Icons.receipt_long;
  }

  Color _chipColorForCategory(String c) {
    final lc = c.toLowerCase();
    if (lc.contains('food') || lc.contains('comida'))
      return const Color(0xFFFFC857);
    if (lc.contains('shop') || lc.contains('shopping') || lc.contains('tienda'))
      return const Color(0xFFB39DDB);
    if (lc.contains('enter') || lc.contains('movie') || lc.contains('ocio'))
      return const Color(0xFFFF8A80);
    if (lc.contains('travel') || lc.contains('viaje'))
      return const Color(0xFF80DEEA);
    if (lc.contains('transport') || lc.contains('taxi'))
      return const Color(0xFF90CAF9);
    if (lc.contains('salary') ||
        lc.contains('bonus') ||
        lc.contains('freelance'))
      return const Color(0xFF81C784);
    if (lc.contains('investment') || lc.contains('refund'))
      return const Color(0xFFA5D6A7);
    return const Color(0xFFD6D6D6);
  }
}

class EditTransactionForm extends StatefulWidget {
  final String uid;
  final String docId;
  final String initialCollection; // 'ingresos' | 'gastos'
  final String initialType; // 'income' | 'expense'
  final double initialAmount;
  final String initialCategory;
  final String initialNote;
  final String initialFrecuencia;
  final DateTime? initialCreatedAt;

  const EditTransactionForm({
    super.key,
    required this.uid,
    required this.docId,
    required this.initialCollection,
    required this.initialType,
    required this.initialAmount,
    required this.initialCategory,
    required this.initialNote,
    required this.initialFrecuencia,
    required this.initialCreatedAt,
  });

  @override
  State<EditTransactionForm> createState() => _EditTransactionFormState();
}

class _EditTransactionFormState extends State<EditTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  final _customCategoryCtrl = TextEditingController();
  String _selectedCategory = 'Other';
  late String _selectedFrecuencia;
  bool _loading = false;

  List<String> get _expenseCategories => const [
    'Food',
    'Shopping',
    'Entertainment',
    'Travel',
    'Transport',
    'Bills',
    'Health',
    'Education',
    'Gifts',
    'Other',
  ];

  List<String> get _incomeCategories => const [
    'Salary',
    'Bonus',
    'Freelance',
    'Investment',
    'Refund',
    'Other',
  ];

  List<String> get _frecuencias => const [
    'única',
    'semanal',
    'quincenal',
    'mensual',
    'bimestral',
    'anual',
  ];

  List<String> get _categories =>
      _type == 'income' ? _incomeCategories : _expenseCategories;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _selectedFrecuencia = widget.initialFrecuencia;
    _amountCtrl = TextEditingController(
      text: widget.initialAmount.toStringAsFixed(2),
    );
    _noteCtrl = TextEditingController(text: widget.initialNote);

    // Setup category selection
    final lc = widget.initialCategory.trim();
    if (lc.isEmpty) {
      _selectedCategory = 'Other';
    } else {
      final list = _type == 'income' ? _incomeCategories : _expenseCategories;
      if (list.map((e) => e.toLowerCase()).contains(lc.toLowerCase())) {
        _selectedCategory = list.firstWhere(
          (e) => e.toLowerCase() == lc.toLowerCase(),
        );
      } else {
        _selectedCategory = 'Other';
        _customCategoryCtrl.text = widget.initialCategory;
      }
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _customCategoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 44,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Ingreso'),
                selected: _type == 'income',
                onSelected: (_) => setState(() {
                  _type = 'income';
                  // If current selected category doesn't exist for the new type, switch to Other
                  if (!_incomeCategories
                      .map((e) => e.toLowerCase())
                      .contains(_selectedCategory.toLowerCase())) {
                    _selectedCategory = 'Other';
                    if (_customCategoryCtrl.text.isEmpty &&
                        widget.initialCategory.isNotEmpty) {
                      _customCategoryCtrl.text = widget.initialCategory;
                    }
                  }
                }),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Egreso'),
                selected: _type == 'expense',
                onSelected: (_) => setState(() {
                  _type = 'expense';
                  if (!_expenseCategories
                      .map((e) => e.toLowerCase())
                      .contains(_selectedCategory.toLowerCase())) {
                    _selectedCategory = 'Other';
                    if (_customCategoryCtrl.text.isEmpty &&
                        widget.initialCategory.isNotEmpty) {
                      _customCategoryCtrl.text = widget.initialCategory;
                    }
                  }
                }),
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
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa un monto';
                    }
                    final n = double.tryParse(v.replaceAll(',', '.'));
                    if (n == null || n <= 0) return 'Monto inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((c) {
                    final selected =
                        _selectedCategory.toLowerCase() == c.toLowerCase();
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _chipIconForCategory(c),
                            size: 16,
                            color: selected
                                ? Colors.white
                                : _chipColorForCategory(c),
                          ),
                          const SizedBox(width: 6),
                          Text(c),
                        ],
                      ),
                      selected: selected,
                      selectedColor: _chipColorForCategory(c),
                      backgroundColor: _chipColorForCategory(
                        c,
                      ).withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() {
                        _selectedCategory = c;
                        if (c.toLowerCase() != 'other') {
                          _customCategoryCtrl.clear();
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                if (_selectedCategory.toLowerCase() == 'other')
                  TextFormField(
                    controller: _customCategoryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Otra categoría',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (v) {
                      if (_selectedCategory.toLowerCase() == 'other') {
                        if (v == null || v.trim().isEmpty) {
                          return 'Escribe la categoría';
                        }
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedFrecuencia,
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: _frecuencias.map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(freq.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFrecuencia = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _onSave,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text('Guardar cambios'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Eliminar',
                      onPressed: _loading ? null : _onDelete,
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));
      final category = _selectedCategory.toLowerCase() == 'other'
          ? _customCategoryCtrl.text.trim()
          : _selectedCategory;
      final targetCollection = _type == 'income' ? 'ingresos' : 'gastos';
      final createdAtTs = widget.initialCreatedAt != null
          ? Timestamp.fromDate(widget.initialCreatedAt!)
          : FieldValue.serverTimestamp();

      if (targetCollection == widget.initialCollection) {
        // Update in the same collection
        final updateData = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (_type == 'income') {
          updateData.addAll({
            'monto_ingr': amount,
            'tipo_ingr': category,
            'descripcion': _noteCtrl.text.trim(),
            'frecuencia_ingr': _selectedFrecuencia,
          });
        } else {
          updateData.addAll({
            'monto_gasto': amount,
            'tipo_gasto': category,
            'descripcion': _noteCtrl.text.trim(),
            'frecuencia_gasto': _selectedFrecuencia,
          });
        }

        await FirebaseFirestore.instance
            .collection(widget.initialCollection)
            .doc(widget.docId)
            .update(updateData);
      } else {
        // Move between collections
        final db = FirebaseFirestore.instance;
        final batch = db.batch();
        final oldRef = db
            .collection(widget.initialCollection)
            .doc(widget.docId);
        final newRef = db.collection(targetCollection).doc();

        final newData = <String, dynamic>{
          'id_usuario': widget.uid,
          'fecha': createdAtTs,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (_type == 'income') {
          newData.addAll({
            'monto_ingr': amount,
            'tipo_ingr': category,
            'descripcion': _noteCtrl.text.trim(),
            'frecuencia_ingr': _selectedFrecuencia,
          });
        } else {
          newData.addAll({
            'monto_gasto': amount,
            'tipo_gasto': category,
            'descripcion': _noteCtrl.text.trim(),
            'frecuencia_gasto': _selectedFrecuencia,
          });
        }

        batch.set(newRef, newData);
        batch.delete(oldRef);
        await batch.commit();
      }
      if (mounted) Navigator.of(context).maybePop(true);
    } catch (e) {
      if (kDebugMode) debugPrint('Error al actualizar: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text('¿Seguro que deseas eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection(widget.initialCollection)
          .doc(widget.docId)
          .delete();
      if (mounted) {
        Navigator.of(context).maybePop(true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transacción eliminada')));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error al eliminar: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _chipIconForCategory(String c) {
    final lc = c.toLowerCase();
    if (lc.contains('food') || lc.contains('comida')) return Icons.fastfood;
    if (lc.contains('shop') || lc.contains('shopping') || lc.contains('tienda'))
      return Icons.shopping_bag;
    if (lc.contains('enter') || lc.contains('movie') || lc.contains('ocio'))
      return Icons.movie;
    if (lc.contains('travel') || lc.contains('viaje')) return Icons.flight;
    if (lc.contains('transport') || lc.contains('taxi'))
      return Icons.directions_car;
    if (lc.contains('salary') ||
        lc.contains('bonus') ||
        lc.contains('freelance'))
      return Icons.payments;
    if (lc.contains('investment') || lc.contains('refund'))
      return Icons.savings;
    return Icons.receipt_long;
  }

  Color _chipColorForCategory(String c) {
    final lc = c.toLowerCase();
    if (lc.contains('food') || lc.contains('comida'))
      return const Color(0xFFFFC857);
    if (lc.contains('shop') || lc.contains('shopping') || lc.contains('tienda'))
      return const Color(0xFFB39DDB);
    if (lc.contains('enter') || lc.contains('movie') || lc.contains('ocio'))
      return const Color(0xFFFF8A80);
    if (lc.contains('travel') || lc.contains('viaje'))
      return const Color(0xFF80DEEA);
    if (lc.contains('transport') || lc.contains('taxi'))
      return const Color(0xFF90CAF9);
    if (lc.contains('salary') ||
        lc.contains('bonus') ||
        lc.contains('freelance'))
      return const Color(0xFF81C784);
    if (lc.contains('investment') || lc.contains('refund'))
      return const Color(0xFFA5D6A7);
    return const Color(0xFFD6D6D6);
  }
}
