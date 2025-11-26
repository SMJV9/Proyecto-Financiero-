part of 'transactions_bloc.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<Map<String, dynamic>> ingresos;
  final List<Map<String, dynamic>> gastos;
  final double totalIngresos;
  final double totalGastos;

  const TransactionsLoaded({
    required this.ingresos,
    required this.gastos,
    required this.totalIngresos,
    required this.totalGastos,
  });

  @override
  List<Object?> get props => [ingresos, gastos, totalIngresos, totalGastos];
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionOperationLoading extends TransactionsState {}

class TransactionOperationSuccess extends TransactionsState {
  final String message;

  const TransactionOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionOperationError extends TransactionsState {
  final String message;

  const TransactionOperationError(this.message);

  @override
  List<Object?> get props => [message];
}
