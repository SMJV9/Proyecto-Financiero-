import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TransactionsBloc() : super(TransactionsInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      emit(TransactionsLoading());

      // Obtener ingresos
      final ingresosSnapshot = await _firestore
          .collection('ingresos')
          .where('id_usuario', isEqualTo: event.userId)
          .get();

      // Obtener gastos
      final gastosSnapshot = await _firestore
          .collection('gastos')
          .where('id_usuario', isEqualTo: event.userId)
          .get();

      final ingresos = ingresosSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      final gastos = gastosSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      // Calcular totales
      double totalIngresos = 0;
      for (final ingreso in ingresos) {
        final monto = ingreso['monto_ingr'];
        if (monto != null) {
          totalIngresos += (monto is num)
              ? monto.toDouble()
              : double.tryParse(monto.toString()) ?? 0;
        }
      }

      double totalGastos = 0;
      for (final gasto in gastos) {
        final monto = gasto['monto_gasto'];
        if (monto != null) {
          totalGastos += (monto is num)
              ? monto.toDouble()
              : double.tryParse(monto.toString()) ?? 0;
        }
      }

      emit(
        TransactionsLoaded(
          ingresos: ingresos,
          gastos: gastos,
          totalIngresos: totalIngresos,
          totalGastos: totalGastos,
        ),
      );
    } catch (e) {
      emit(TransactionsError('Error al cargar transacciones: ${e.toString()}'));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      emit(TransactionOperationLoading());

      await _firestore.collection(event.type).add(event.transactionData);

      emit(
        const TransactionOperationSuccess('Transacción agregada exitosamente'),
      );

      // Recargar transacciones
      final userId = event.transactionData['id_usuario'] as String;
      add(LoadTransactions(userId));
    } catch (e) {
      emit(
        TransactionOperationError(
          'Error al agregar transacción: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      emit(TransactionOperationLoading());

      await _firestore
          .collection(event.type)
          .doc(event.transactionId)
          .update(event.updatedData);

      emit(
        const TransactionOperationSuccess(
          'Transacción actualizada exitosamente',
        ),
      );

      // Recargar transacciones
      final userId = event.updatedData['id_usuario'] as String;
      add(LoadTransactions(userId));
    } catch (e) {
      emit(
        TransactionOperationError(
          'Error al actualizar transacción: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      emit(TransactionOperationLoading());

      await _firestore.collection(event.type).doc(event.transactionId).delete();

      emit(
        const TransactionOperationSuccess('Transacción eliminada exitosamente'),
      );
    } catch (e) {
      emit(
        TransactionOperationError(
          'Error al eliminar transacción: ${e.toString()}',
        ),
      );
    }
  }
}
