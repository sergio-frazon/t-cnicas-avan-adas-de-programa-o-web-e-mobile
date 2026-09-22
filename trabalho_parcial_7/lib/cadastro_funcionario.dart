import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CadastroFuncionario(),
    ),
  );
}

class CadastroFuncionario extends StatefulWidget {
  const CadastroFuncionario({super.key});

  @override
  State<CadastroFuncionario> createState() =>
      _CadastroFuncionarioState();
}

class _CadastroFuncionarioState extends State<CadastroFuncionario> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _idadeController = TextEditingController();
  final _salarioController = TextEditingController();
  final _dependentesController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _salarioController.dispose();
    _dependentesController.dispose();
    super.dispose();
  }

  void salvar() {
    // O Form executa os validators de todos os campos.
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionário salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Funcionário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final nome = (value ?? '').trim();

                  if (nome.isEmpty) {
                    return 'Informe o nome.';
                  }

                  if (nome.length < 3 || nome.length > 60) {
                    return 'O nome deve ter entre 3 e 60 caracteres.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _idadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe a idade.';
                  }

                  final idade = int.tryParse(texto);

                  if (idade == null) {
                    return 'A idade deve ser um número inteiro.';
                  }

                  if (idade < 18 || idade > 100) {
                    return 'A idade deve estar entre 18 e 100.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _salarioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Salário',
                  prefixText: 'R\$ ',
                  hintText: 'Ex.: 2500,50 ou 2500.50',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe o salário.';
                  }

                  // Aceita inteiros ou decimais com 1 ou 2 casas.
                  final formato = RegExp(r'^[0-9]+([.,][0-9]{1,2})?$');

                  if (!formato.hasMatch(texto)) {
                    return 'Use números com até 2 casas decimais, sem milhar.';
                  }

                  // double.tryParse precisa de ponto como separador.
                  final salario = double.tryParse(
                    texto.replaceAll(',', '.'),
                  );

                  if (salario == null) {
                    return 'Informe um salário válido.';
                  }

                  if (salario < 1000 || salario > 50000) {
                    return 'O salário deve estar entre R\$ 1.000 e R\$ 50.000.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _dependentesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade de dependentes',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe a quantidade de dependentes.';
                  }

                  final dependentes = int.tryParse(texto);

                  if (dependentes == null) {
                    return 'A quantidade deve ser um número inteiro.';
                  }

                  if (dependentes < 0 || dependentes > 10) {
                    return 'A quantidade deve estar entre 0 e 10.';
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