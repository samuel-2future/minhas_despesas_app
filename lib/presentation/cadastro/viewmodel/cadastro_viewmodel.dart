import 'package:flutter/material.dart';
import 'package:minhas_despesas_app/data/datasources/transactions_datasource.dart';
import 'package:minhas_despesas_app/domain/entities/transaction.dart';

class CadastroViewModel extends ChangeNotifier {
  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController installmentsController = TextEditingController();

  // Services
  final TransactionsDataSource _dataSource = TransactionsDataSource();

  // Form state
  TransactionType? _selectedType = TransactionType.despesa;
  PaymentType? _selectedPaymentType = PaymentType.creditCardSpot;
  String? _selectedCategory;
  DateTime? _selectedDate;
  bool _isPaid = false;
  Transaction? _lastSavedTransaction;
  bool _isSaving = false;

  // Getters
  TransactionType? get selectedType => _selectedType;
  PaymentType? get selectedPaymentType => _selectedPaymentType;
  String? get selectedCategory => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;
  bool get isPaid => _isPaid;
  Transaction? get lastSavedTransaction => _lastSavedTransaction;
  bool get isSaving => _isSaving;
  bool get showInstallmentsField =>
      _selectedPaymentType == PaymentType.creditCardInstallments;

  // Disponible categories
  final List<String> categories = [
    'Alimentação',
    'Transporte',
    'Saúde',
    'Educação',
    'Lazer',
    'Moradia',
    'Utilidades',
    'Outras',
  ];

  CadastroViewModel() {
    _selectedDate = DateTime.now();
  }

  void setTransactionType(TransactionType type) {
    _selectedType = type;
    notifyListeners();
  }

  void setPaymentType(PaymentType paymentType) {
    _selectedPaymentType = paymentType;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Selecionar data',
    );

    if (picked != null) {
      _selectedDate = picked;
      notifyListeners();
    }
  }

  void setIsPaid(bool value) {
    _isPaid = value;
    notifyListeners();
  }

  bool validateForm() {
    return titleController.text.isNotEmpty &&
        valueController.text.isNotEmpty &&
        _selectedCategory != null &&
        _selectedDate != null &&
        _selectedType != null &&
        _selectedPaymentType != null;
  }

  Transaction buildTransaction() {
    return Transaction(
      title: titleController.text,
      category: _selectedCategory ?? 'Outras',
      month: _selectedDate ?? DateTime.now(),
      isPaid: _isPaid,
      type: _selectedType ?? TransactionType.despesa,
      paymentType: _selectedPaymentType ?? PaymentType.creditCardSpot,
      value: double.tryParse(valueController.text) ?? 0.0,
      createdAt: DateTime.now(),
    );
  }

  void resetForm() {
    titleController.clear();
    valueController.clear();
    installmentsController.clear();
    _selectedType = TransactionType.despesa;
    _selectedPaymentType = PaymentType.creditCardSpot;
    _selectedCategory = null;
    _selectedDate = DateTime.now();
    _isPaid = false;
    notifyListeners();
  }

  Future<void> saveTransaction() async {
    if (!validateForm()) {
      return;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final transaction = buildTransaction();
      await _dataSource.insertTransaction(transaction);
      _lastSavedTransaction = transaction;
      resetForm();
    } catch (e) {
      debugPrint('Erro ao salvar transação: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    valueController.dispose();
    installmentsController.dispose();
    super.dispose();
  }
}
