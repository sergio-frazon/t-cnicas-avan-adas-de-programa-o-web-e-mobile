import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CadastroPedido(),
    ),
  );
}

class CadastroPedido extends StatefulWidget {
  const CadastroPedido({super.key});

  @override
  State<CadastroPedido> createState() => _CadastroPedidoState();
}

class _CadastroPedidoState extends State<CadastroPedido> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _descontoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    _quantidadeController.dispose();
    _descontoController.dispose();
    super.dispose();
  }

  void salvar() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Pedido'),
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
                  labelText: 'Nome do cliente',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final nome = (value ?? '').trim();

                  if (nome.isEmpty) {
                    return 'Informe o nome do cliente.';
                  }

                  if (nome.length < 3 || nome.length > 60) {
                    return 'O nome deve ter entre 3 e 60 caracteres.';
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
                  labelText: 'Valor do pedido',
                  prefixText: 'R\$ ',
                  hintText: 'Ex.: 150,50 ou 150.50',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe o valor do pedido.';
                  }

                  // Aceita ponto ou vírgula e até duas casas decimais.
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

                  if (valor < 1 || valor > 99999.99) {
                    return 'O valor deve estar entre R\$ 1,00 e R\$ 99.999,99.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _quantidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade de itens',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe a quantidade de itens.';
                  }

                  final quantidade = int.tryParse(texto);

                  if (quantidade == null) {
                    return 'A quantidade deve ser um número inteiro.';
                  }

                  if (quantidade < 1 || quantidade > 100) {
                    return 'A quantidade deve estar entre 1 e 100.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _descontoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Percentual de desconto',
                  suffixText: '%',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe o percentual de desconto.';
                  }

                  final desconto = int.tryParse(texto);

                  if (desconto == null) {
                    return 'O desconto deve ser um número inteiro.';
                  }

                  if (desconto < 0 || desconto > 100) {
                    return 'O desconto deve estar entre 0 e 100.';
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