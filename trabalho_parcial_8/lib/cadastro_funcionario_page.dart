import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:intl/intl.dart';
import 'package:all_br_forms/all_br_forms.dart';
import 'package:all_br_validations/all_br_validations.dart';


  void main() {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        home: const CadastroFuncionarioPage(),
      ),
    );
  }

  class CadastroFuncionarioPage extends StatefulWidget {
    const CadastroFuncionarioPage({super.key});

    @override
    State<CadastroFuncionarioPage> createState() {
      return _CadastroFuncionarioPageState();
    } 
  }
  class _CadastroFuncionarioPageState
      extends State<CadastroFuncionarioPage> {
    final _formKey = GlobalKey<FormState>();

    final _nomeController = TextEditingController();
    final _cpfController = TextEditingController();
    final _idadeController = TextEditingController();
    final _salarioController = TextEditingController();
    final _dependentesController = TextEditingController();

    final _moeda = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
      String? _resumoCadastro;

    @override
    void dispose() {
      _nomeController.dispose();
      _cpfController.dispose();
      _idadeController.dispose();
      _salarioController.dispose();
      _dependentesController.dispose();
      super.dispose();
    }
      String? _validarInteiro(
    String? valor, {
    required int minimo,
    required int maximo,
    required String campo,
  }) {
    return Validatorless.multiple([
      Validatorless.required('Informe $campo.'),
      Validatorless.number('Digite um número válido.'),
      Validatorless.regex(
        RegExp(r'^[0-9]+$'),
        'Digite um número inteiro, sem casas decimais.',
      ),
      Validatorless.numbersBetweenInterval(
        minimo.toDouble(),
        maximo.toDouble(),
        'O valor deve estar entre $minimo e $maximo.',
      ),
    ])(valor?.trim());
  }

  String _normalizarSalario(String valor) {
    return valor.trim().replaceAll(',', '.');
  }

  String? _validarSalario(String? valor) {
    final normalizado = _normalizarSalario(valor ?? '');

    return Validatorless.multiple([
      Validatorless.required('Informe o salário.'),
      Validatorless.number('Digite um valor numérico válido.'),
      Validatorless.regex(
        RegExp(r'^[0-9]+(?:\.[0-9]{1,2})?$'),
        'Use no máximo duas casas decimais, sem milhar.',
      ),
      Validatorless.numbersBetweenInterval(
        1000,
        50000,
        'O salário deve estar entre R\$ 1.000,00 e R\$ 50.000,00.',
      ),
    ])(normalizado);
  }

  void _cadastrar() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _resumoCadastro = null;
      });
      return;
    }

    final nome = _nomeController.text.trim();
    final cpf = _cpfController.text.trim();
    final idade = int.parse(_idadeController.text.trim());
    final dependentes = int.parse(
      _dependentesController.text.trim(),
    );

    final salario = double.parse(
      _normalizarSalario(_salarioController.text),
    );

    setState(() {
      _resumoCadastro = [
        'Nome: $nome',
        'CPF: $cpf',
        'Idade: $idade anos',
        'Salário: ${_moeda.format(salario)}',
        'Dependentes: $dependentes',
      ].join('\n');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionário cadastrado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Funcionário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            if (_resumoCadastro != null) {
              setState(() {
                _resumoCadastro = null;
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (valor) {
                  return Validatorless.multiple([
                    Validatorless.required('Informe o nome.'),
                    Validatorless.min(
                      3,
                      'O nome deve ter pelo menos 3 caracteres.',
                    ),
                    Validatorless.max(
                      60,
                      'O nome deve ter no máximo 60 caracteres.',
                    ),
                  ])(valor?.trim());
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  hintText: '000.000.000-00',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: const [
                  CpfMask(),
                ],
                validator: BrZod().required().cpf().build,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _idadeController,
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  helperText: 'De 18 a 100 anos.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (valor) {
                  return _validarInteiro(
                    valor,
                    minimo: 18,
                    maximo: 100,
                    campo: 'a idade',
                  );
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _salarioController,
                decoration: const InputDecoration(
                  labelText: 'Salário',
                  prefixText: 'R\$ ',
                  hintText: '2500,50',
                  helperText: 'Sem separador de milhar.',
                  errorMaxLines: 3,
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: _validarSalario,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _dependentesController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade de dependentes',
                  helperText: 'De 0 a 10 dependentes.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _cadastrar(),
                validator: (valor) {
                  return _validarInteiro(
                    valor,
                    minimo: 0,
                    maximo: 10,
                    campo: 'a quantidade de dependentes',
                  );
                },
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _cadastrar,
                icon: const Icon(Icons.person_add),
                label: const Text('Cadastrar funcionário'),
              ),

              if (_resumoCadastro != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_resumoCadastro!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}