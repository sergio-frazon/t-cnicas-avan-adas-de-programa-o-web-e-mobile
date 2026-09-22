import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CadastroCurso(),
    ),
  );
}

class CadastroCurso extends StatefulWidget {
  const CadastroCurso({super.key});

  @override
  State<CadastroCurso> createState() => _CadastroCursoState();
}

class _CadastroCursoState extends State<CadastroCurso> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _codigoController = TextEditingController();
  final _cargaHorariaController = TextEditingController();
  final _vagasController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    _cargaHorariaController.dispose();
    _vagasController.dispose();
    super.dispose();
  }

  void salvar() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Curso cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Curso'),
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
                  labelText: 'Nome do curso',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final nome = (value ?? '').trim();

                  if (nome.isEmpty) {
                    return 'Informe o nome do curso.';
                  }

                  if (nome.length < 5 || nome.length > 100) {
                    return 'O nome deve ter entre 5 e 100 caracteres.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código do curso',
                  hintText: 'Ex.: CUR-0001',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final codigo = (value ?? '').trim();

                  if (codigo.isEmpty) {
                    return 'Informe o código do curso.';
                  }

                  // Três letras, um hífen e quatro números.
                  final formato = RegExp(r'^[A-Za-z]{3}-[0-9]{4}$');

                  if (!formato.hasMatch(codigo)) {
                    return 'Use 3 letras, hífen e 4 números: CUR-0001.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _cargaHorariaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Carga horária',
                  suffixText: 'horas',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe a carga horária.';
                  }

                  final cargaHoraria = int.tryParse(texto);

                  if (cargaHoraria == null) {
                    return 'A carga horária deve ser um número inteiro.';
                  }

                  if (cargaHoraria < 20 || cargaHoraria > 2000) {
                    return 'A carga horária deve estar entre 20 e 2000 horas.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _vagasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número de vagas',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = (value ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Informe o número de vagas.';
                  }

                  final vagas = int.tryParse(texto);

                  if (vagas == null) {
                    return 'O número de vagas deve ser um inteiro.';
                  }

                  if (vagas < 1 || vagas > 500) {
                    return 'O número de vagas deve estar entre 1 e 500.';
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