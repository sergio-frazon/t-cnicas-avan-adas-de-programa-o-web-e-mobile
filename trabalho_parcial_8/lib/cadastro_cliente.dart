import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:intl/intl.dart';
import 'package:all_br_forms/all_br_forms.dart';
import 'package:all_br_validations/all_br_validations.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Exercício 2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const CadastroClientePage(),
    ),
  );
}

class CadastroClientePage extends StatefulWidget {
  const CadastroClientePage({super.key});

  @override
  State<CadastroClientePage> createState() {
    return _CadastroClientePageState();
  }
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  // Chave utilizada para validar o formulário.
  final _formKey = GlobalKey<FormState>();

  // Controllers dos campos.
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _nascimentoController = TextEditingController();

  // O padrão explícito define a ordem dia/mês/ano.
  final _formatoData = DateFormat('dd/MM/yyyy', 'en_US');

  String? _resumoCadastro;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _nascimentoController.dispose();
    super.dispose();
  }

  // Calcula a idade considerando se o aniversário já aconteceu.
  int _calcularIdade(DateTime nascimento, DateTime hoje) {
    var idade = hoje.year - nascimento.year;

    final aindaNaoFezAniversario =
        hoje.month < nascimento.month ||
        (hoje.month == nascimento.month &&
            hoje.day < nascimento.day);

    if (aindaNaoFezAniversario) {
      idade--;
    }

    return idade;
  }

  // Valida preenchimento, formato, data real e idade mínima.
  String? _validarNascimento(String? valor) {
    final texto = valor?.trim() ?? '';

    final erroObrigatorio =
        Validatorless.required('Informe a data de nascimento.')(texto);

    if (erroObrigatorio != null) {
      return erroObrigatorio;
    }

    try {
      final nascimento = _formatoData.parseStrict(texto);

      if (_formatoData.format(nascimento) != texto) {
        return 'Use o formato dd/MM/yyyy.';
      }

      final agora = DateTime.now();
      final hoje = DateTime(agora.year, agora.month, agora.day);

      if (nascimento.isAfter(hoje)) {
        return 'A data de nascimento não pode estar no futuro.';
      }

      final idade = _calcularIdade(nascimento, hoje);

      if (idade < 18) {
        return 'O cliente deve possuir pelo menos 18 anos.';
      }

      return null;
    } on FormatException {
      return 'Informe uma data válida no formato dd/MM/yyyy.';
    }
  }

  // Valida o formulário e apresenta os dados do cliente.
  void _cadastrar() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _resumoCadastro = null;
      });
      return;
    }

    final nascimento = _formatoData.parseStrict(
      _nascimentoController.text.trim(),
    );

    setState(() {
      _resumoCadastro = [
        'Nome: ${_nomeController.text.trim()}',
        'CPF: ${_cpfController.text.trim()}',
        'E-mail: ${_emailController.text.trim()}',
        'Telefone: ${_telefoneController.text.trim()}',
        'Nascimento: ${_formatoData.format(nascimento)}',
      ].join('\n');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cliente cadastrado com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro do Cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            // Remove o resumo anterior quando os dados são alterados.
            if (_resumoCadastro != null) {
              setState(() {
                _resumoCadastro = null;
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nome: obrigatório, entre 3 e 80 caracteres.
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
                      80,
                      'O nome deve ter no máximo 80 caracteres.',
                    ),
                  ])(valor?.trim());
                },
              ),
              const SizedBox(height: 16),

              // CPF: máscara e validação dos dígitos.
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

              // E-mail: obrigatório e com formato válido.
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'nome@exemplo.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enableSuggestions: false,
                validator: (valor) {
                  return Validatorless.multiple([
                    Validatorless.required('Informe o e-mail.'),
                    Validatorless.email('Informe um e-mail válido.'),
                  ])(valor?.trim());
                },
              ),
              const SizedBox(height: 16),

              // Telefone: máscara e validação do padrão brasileiro.
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: '(11) 91234-5678',
                  helperText: 'Informe o telefone com DDD.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: const [
                  PhoneMask(),
                ],
                validator: BrZod().required().phone().build,
              ),
              const SizedBox(height: 16),

              // Nascimento: data válida e idade mínima de 18 anos.
              TextFormField(
                controller: _nascimentoController,
                decoration: const InputDecoration(
                  labelText: 'Data de nascimento',
                  hintText: 'dd/MM/yyyy',
                  helperText: 'O cliente deve ter pelo menos 18 anos.',
                  errorMaxLines: 3,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: const [
                  DateMask(),
                ],
                validator: _validarNascimento,
                onFieldSubmitted: (_) => _cadastrar(),
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _cadastrar,
                icon: const Icon(Icons.person_add),
                label: const Text('Cadastrar cliente'),
              ),

              // Exibe o resumo somente após a validação bem-sucedida.
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