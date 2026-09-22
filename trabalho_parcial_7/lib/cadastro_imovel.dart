import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CadastroImovel(),
    ),
  );
}

class CadastroImovel extends StatefulWidget {
  const CadastroImovel({super.key});

  @override
  State<CadastroImovel> createState() => _CadastroImovelState();
}

class _CadastroImovelState extends State<CadastroImovel> {
  final _formKey = GlobalKey<FormState>();

  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _areaController = TextEditingController();
  final _valorController = TextEditingController();

  @override
  void dispose() {
    _enderecoController.dispose();
    _numeroController.dispose();
    _areaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void salvar() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imóvel cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Imóvel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  hintText: 'Ex.: Rua das Flores',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final endereco = (value ?? '').trim();

                  if (endereco.isEmpty) {
                    return 'Informe o endereço.';
                  }

                  if (endereco.length < 5 || endereco.length > 100) {
                    return 'O endereço deve ter entre 5 e 100 caracteres.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _numeroController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe o número do imóvel.';
                  }

                  final numero = int.tryParse(texto);

                  if (numero == null) {
                    return 'O número do imóvel deve ser um inteiro.';
                  }

                  if (numero < 1 || numero > 99999) {
                    return 'O número deve estar entre 1 e 99.999.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _areaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Área',
                  suffixText: 'm²',
                  hintText: 'Ex.: 120,50 ou 120.50',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe a área do imóvel.';
                  }

                  final formato = RegExp(r'^[0-9]+([.,][0-9]{1,2})?$');

                  if (!formato.hasMatch(texto)) {
                    return 'Use números com até 2 casas decimais, sem milhar.';
                  }

                  final area = double.tryParse(
                    texto.replaceAll(',', '.'),
                  );

                  if (area == null) {
                    return 'Informe uma área válida.';
                  }

                  if (area < 10 || area > 10000) {
                    return 'A área deve estar entre 10 e 10.000 m².';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor do imóvel',
                  prefixText: 'R\$ ',
                  hintText: 'Ex.: 250000,50 ou 250000.50',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe o valor do imóvel.';
                  }

                  final formato = RegExp(r'^[0-9]+([.,][0-9]{1,2})?$');

                  if (!formato.hasMatch(texto)) {
                    return 'Use números com até 2 casas decimais, sem milhar.';
                  }

                  final valor = double.tryParse(
                    texto.replaceAll(',', '.'),
                  );

                  if (valor == null) {
                    return 'Informe um valor válido.';
                  }

                  if (valor < 20000 || valor > 10000000) {
                    return 'O valor deve estar entre R\$ 20.000 e R\$ 10.000.000.';
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