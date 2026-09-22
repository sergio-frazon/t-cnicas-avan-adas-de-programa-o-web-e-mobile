import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CadastroContaBancaria(),
    ),
  );
}

class CadastroContaBancaria extends StatefulWidget {
  const CadastroContaBancaria({super.key});

  @override
  State<CadastroContaBancaria> createState() =>
      _CadastroContaBancariaState();
}

class _CadastroContaBancariaState extends State<CadastroContaBancaria> {
  final _formKey = GlobalKey<FormState>();

  final _titularController = TextEditingController();
  final _bancoController = TextEditingController();
  final _agenciaController = TextEditingController();
  final _contaController = TextEditingController();
  final _saldoController = TextEditingController();

  @override
  void dispose() {
    _titularController.dispose();
    _bancoController.dispose();
    _agenciaController.dispose();
    _contaController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  void salvar() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta cadastrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Conta Bancária'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titularController,
                decoration: const InputDecoration(
                  labelText: 'Nome do titular',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final nome = (value ?? '').trim();

                  if (nome.isEmpty) {
                    return 'Informe o nome do titular.';
                  }

                  if (nome.length < 3 || nome.length > 80) {
                    return 'O nome deve ter entre 3 e 80 caracteres.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _bancoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número do banco',
                  hintText: 'Ex.: 001',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe o número do banco.';
                  }

                  final banco = int.tryParse(texto);

                  if (banco == null) {
                    return 'O número do banco deve ser um inteiro.';
                  }

                  if (!RegExp(r'^[0-9]{3}$').hasMatch(texto)) {
                    return 'O banco deve conter exatamente 3 dígitos.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _agenciaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Agência',
                  hintText: 'Ex.: 0123',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe a agência.';
                  }

                  final agencia = int.tryParse(texto);

                  if (agencia == null) {
                    return 'A agência deve ser um número inteiro.';
                  }

                  if (!RegExp(r'^[0-9]{4,5}$').hasMatch(texto)) {
                    return 'A agência deve conter de 4 a 5 dígitos.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _contaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número da conta',
                  hintText: 'Ex.: 0012345',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe o número da conta.';
                  }

                  final conta = int.tryParse(texto);

                  if (conta == null) {
                    return 'O número da conta deve ser um inteiro.';
                  }

                  if (!RegExp(r'^[0-9]{5,10}$').hasMatch(texto)) {
                    return 'A conta deve conter de 5 a 10 dígitos.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _saldoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Saldo inicial',
                  prefixText: 'R\$ ',
                  hintText: 'Ex.: 1500,50 ou 1500.50',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe o saldo inicial.';
                  }

                  // O sinal é aceito no formato para permitir
                  // uma mensagem específica para saldo negativo.
                  final formato = RegExp(
                    r'^-?[0-9]+([.,][0-9]{1,2})?$',
                  );

                  if (!formato.hasMatch(texto)) {
                    return 'Use números com até 2 casas decimais, sem milhar.';
                  }

                  final saldo = double.tryParse(
                    texto.replaceAll(',', '.'),
                  );

                  if (saldo == null) {
                    return 'Informe um saldo válido.';
                  }

                  if (saldo < 0) {
                    return 'O saldo inicial não pode ser negativo.';
                  }

                  if (saldo > 1000000) {
                    return 'O saldo deve ser no máximo R\$ 1.000.000,00.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: salvar,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}