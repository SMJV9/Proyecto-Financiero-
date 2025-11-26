part of 'transactions_bloc.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionsEvent {
  final String userId;

  const LoadTransactions(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddTransaction extends TransactionsEvent {
  final Map<String, dynamic> transactionData;
  final String type; // 'ingresos' or 'gastos'

  const AddTransaction({required this.transactionData, required this.type});

  @override
  List<Object?> get props => [transactionData, type];
}

class UpdateTransaction extends TransactionsEvent {
  final String transactionId;
  final Map<String, dynamic> updatedData;
  final String type;

  const UpdateTransaction({
    required this.transactionId,
    required this.updatedData,
    required this.type,
  });

  @override
  List<Object?> get props => [transactionId, updatedData, type];
}

class DeleteTransaction extends TransactionsEvent {
  final String transactionId;
  final String type;

  const DeleteTransaction({required this.transactionId, required this.type});

  @override
  List<Object?> get props => [transactionId, type];
}
