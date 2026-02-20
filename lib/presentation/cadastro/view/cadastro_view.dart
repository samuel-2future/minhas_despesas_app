import 'package:flutter/material.dart';
import 'package:minhas_despesas_app/domain/entities/transaction.dart';
import 'package:minhas_despesas_app/presentation/cadastro/viewmodel/cadastro_viewmodel.dart';


class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  late final CadastroViewModel _viewModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = CadastroViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Lançamento'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTransactionTypeSelector(),
            const SizedBox(height: 24),
            _buildForm(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  label: 'Despesa',
                  type: TransactionType.despesa,
                  isSelected: _viewModel.selectedType == TransactionType.despesa,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTypeButton(
                  label: 'Receita',
                  type: TransactionType.receita,
                  isSelected: _viewModel.selectedType == TransactionType.receita,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeButton({
    required String label,
    required TransactionType type,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _viewModel.setTransactionType(type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informações Básicas'),
          const SizedBox(height: 12),
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildValueField(),
          const SizedBox(height: 24),
          _buildSectionTitle('Categorização'),
          const SizedBox(height: 12),
          _buildCategoryDropdown(),
          const SizedBox(height: 24),
          _buildSectionTitle('Data e Forma de Pagamento'),
          const SizedBox(height: 12),
          _buildDatePicker(),
          const SizedBox(height: 16),
          _buildPaymentTypeDropdown(),
          const SizedBox(height: 16),
          _buildInstallmentsField(),
          const SizedBox(height: 24),
          _buildSectionTitle('Situação do Pagamento'),
          const SizedBox(height: 12),
          _buildPaidCheckbox(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _viewModel.titleController,
      decoration: InputDecoration(
        labelText: 'Título',
        hintText: 'Ex: Compra no supermercado',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.edit),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Por favor, digite um título';
        }
        return null;
      },
    );
  }

  Widget _buildValueField() {
    return TextFormField(
      controller: _viewModel.valueController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Valor',
        hintText: '0,00',
        prefix: const Text('R\$ '),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.attach_money),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Por favor, digite um valor';
        }
        if (double.tryParse(value!) == null) {
          return 'Por favor, digite um valor válido';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return DropdownButtonFormField<String>(
          initialValue: _viewModel.selectedCategory,
          items: _viewModel.categories
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          onChanged: (value) => _viewModel.setCategory(value),
          decoration: InputDecoration(
            labelText: 'Categoria',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.category),
          ),
          validator: (value) {
            if (value == null) {
              return 'Por favor, selecione uma categoria';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final formattedDate = _viewModel.selectedDate != null
            ? '${_viewModel.selectedDate!.day.toString().padLeft(2, '0')}/${_viewModel.selectedDate!.month.toString().padLeft(2, '0')}/${_viewModel.selectedDate!.year}'
            : 'Selecionar data';

        return GestureDetector(
          onTap: () => _viewModel.selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentTypeDropdown() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return DropdownButtonFormField<PaymentType>(
          initialValue: _viewModel.selectedPaymentType,
          items: PaymentType.values
              .map((paymentType) => DropdownMenuItem(
                    value: paymentType,
                    child: Text(paymentType.label),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              _viewModel.setPaymentType(value);
            }
          },
          decoration: InputDecoration(
            labelText: 'Forma de Pagamento',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.payment),
          ),
          validator: (value) {
            if (value == null) {
              return 'Por favor, selecione uma forma de pagamento';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildInstallmentsField() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (!_viewModel.showInstallmentsField) {
          return const SizedBox.shrink();
        }

        return TextFormField(
          controller: _viewModel.installmentsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantidade de Parcelas',
            hintText: 'Ex: 12',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.payment),
          ),
          validator: (value) {
            if (_viewModel.showInstallmentsField) {
              if (value?.isEmpty ?? true) {
                return 'Por favor, digite a quantidade de parcelas';
              }
              if (int.tryParse(value!) == null || int.parse(value) < 1) {
                return 'Por favor, digite um número válido (mínimo 1)';
              }
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildPaidCheckbox() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CheckboxListTile(
            value: _viewModel.isPaid,
            onChanged: (value) => _viewModel.setIsPaid(value ?? false),
            title: const Text('Pagamento realizado'),
            subtitle: const Text(
              'Marque se o pagamento já foi efetuado',
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final isSaving = _viewModel.isSaving;

        return SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isSaving
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // Store context reference before async operation
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        
                        await _viewModel.saveTransaction();
                        
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Lançamento salvo com sucesso!'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                          navigator.pop();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao salvar: $e'),
                              duration: const Duration(seconds: 3),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Salvar Lançamento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
