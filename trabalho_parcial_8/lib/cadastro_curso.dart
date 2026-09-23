import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:intl/intl.dart';
import 'package:all_br_forms/all_br_forms.dart';

// 1. Inicialização do exercício.
void main() {
  runApp(
    MaterialApp(
      title: 'Exercício 4',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const CadastroCursoPage(),
    ),
  );
}

// 2. Tela com estado.
class CadastroCursoPage extends StatefulWidget {
  const CadastroCursoPage({super.key});

  @override
  State<CadastroCursoPage> createState() {
    return _CadastroCursoPageState();
  }
}

class _CadastroCursoPageState extends State<CadastroCursoPage> {
  // 3. Chave e controllers.
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _emailController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _vagasController = TextEditingController();
  final _mensalidadeController = TextEditingController();

  // 4. Formatação da data e da moeda.
  final _formatoData = DateFormat('dd/MM/yyyy', 'en_US');

  final _moeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  String? _resumoCadastro;

  // 5. Liberação dos controllers.
  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _emailController.dispose();
    _dataInicioController.dispose();
    _vagasController.dispose();
    _mensalidadeController.dispose();
    super.dispose();
  }

  // 6. Validação da data de início.
  String? _validarDataInicio(String? valor) {
    final texto = valor?.trim() ?? '';

    final erroObrigatorio =
        Validatorless.required('Informe a data de início.')(texto);

    if (erroObrigatorio != null) {
      return erroObrigatorio;
    }

    try {
      final dataInicio = _formatoData.parseStrict(texto);

      if (_formatoData.format(dataInicio) != texto) {
        return 'Use o formato dd/MM/yyyy.';
      }

      final agora = DateTime.now();
      final hoje = DateTime(agora.year, agora.month, agora.day);

      if (!dataInicio.isAfter(hoje)) {
        return 'A data de início deve ser posterior à data atual.';
      }

      return null;
    } on FormatException {
      return 'Informe uma data válida no formato dd/MM/yyyy.';
    }
  }

  // 7. Validação do número de vagas.
  String? _validarVagas(String? valor) {
    return Validatorless.multiple([
      Validatorless.required('Informe o número de vagas.'),
      Validatorless.number('Digite um número válido.'),
      Validatorless.regex(
        RegExp(r'^[0-9]+$'),
        'Digite um número inteiro, sem casas decimais.',
      ),
      Validatorless.numbersBetweenInterval(
        1,
        500,
        'O número de vagas deve estar entre 1 e 500.',
      ),
    ])(valor?.trim());
  }

  // 8. Normalização e validação da mensalidade.
  String _normalizarMensalidade(String valor) {
    return valor.trim().replaceAll(',', '.');
  }

  String? _validarMensalidade(String? valor) {
    final normalizado = _normalizarMensalidade(valor ?? '');

    return Validatorless.multiple([
      Validatorless.required('Informe a mensalidade.'),
      Validatorless.number('Digite um valor numérico válido.'),
      Validatorless.regex(
        RegExp(r'^[0-9]+(?:\.[0-9]{1,2})?$'),
        'Use no máximo duas casas decimais, sem milhar.',
      ),
      Validatorless.numbersBetweenInterval(
        50,
        10000,
        'A mensalidade deve estar entre R\$ 50,00 e R\$ 10.000,00.',
      ),
    ])(normalizado);
  }

  // 9. Cadastro e mensagem de sucesso.
  void _cadastrar() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _resumoCadastro = null;
      });
      return;
    }

    final dataInicio = _formatoData.parseStrict(
      _dataInicioController.text.trim(),
    );

    final vagas = int.parse(_vagasController.text.trim());

    final mensalidade = double.parse(
      _normalizarMensalidade(_mensalidadeController.text),
    );

    setState(() {
      _resumoCadastro = [
        'Curso: ${_nomeController.text.trim()}',
        'Descrição: ${_descricaoController.text.trim()}',
        'E-mail do responsável: ${_emailController.text.trim()}',
        'Data de início: ${_formatoData.format(dataInicio)}',
        'Número de vagas: $vagas',
        'Mensalidade: ${_moeda.format(mensalidade)}',
      ].join('\n');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Curso cadastrado com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 10. Construção da interface.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercício 4 — Curso'),
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
              // 11. Nome do curso.
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do curso',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (valor) {
                  return Validatorless.multiple([
                    Validatorless.required('Informe o nome do curso.'),
                    Validatorless.min(
                      5,
                      'O nome deve ter pelo menos 5 caracteres.',
                    ),
                    Validatorless.max(
                      100,
                      'O nome deve ter no máximo 100 caracteres.',
                    ),
                  ])(valor?.trim());
                },
              ),
              const SizedBox(height: 16),

              // 12. Descrição.
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  alignLabelWithHint: true,
                  helperText: 'Entre 10 e 500 caracteres.',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                validator: (valor) {
                  return Validatorless.multiple([
                    Validatorless.required('Informe a descrição.'),
                    Validatorless.min(
                      10,
                      'A descrição deve ter pelo menos 10 caracteres.',
                    ),
                    Validatorless.max(
                      500,
                      'A descrição deve ter no máximo 500 caracteres.',
                    ),
                  ])(valor?.trim());
                },
              ),
              const SizedBox(height: 16),

              // 13. E-mail do responsável.
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail do responsável',
                  hintText: 'responsavel@exemplo.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enableSuggestions: false,
                validator: (valor) {
                  return Validatorless.multiple([
                    Validatorless.required(
                      'Informe o e-mail do responsável.',
                    ),
                    Validatorless.email('Informe um e-mail válido.'),
                  ])(valor?.trim());
                },
              ),
              const SizedBox(height: 16),

              // 14. Data de início.
              TextFormField(
                controller: _dataInicioController,
                decoration: const InputDecoration(
                  labelText: 'Data de início',
                  hintText: 'dd/MM/yyyy',
                  helperText: 'Informe uma data a partir de amanhã.',
                  errorMaxLines: 3,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: const [
                  DateMask(),
                ],
                validator: _validarDataInicio,
              ),
              const SizedBox(height: 16),

              // 15. Número de vagas.
              TextFormField(
                controller: _vagasController,
                decoration: const InputDecoration(
                  labelText: 'Número de vagas',
                  helperText: 'De 1 a 500 vagas.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: _validarVagas,
              ),
              const SizedBox(height: 16),

              // 16. Mensalidade.
              TextFormField(
                controller: _mensalidadeController,
                decoration: const InputDecoration(
                  labelText: 'Mensalidade',
                  prefixText: 'R\$ ',
                  hintText: '250,50',
                  helperText: 'Digite sem separador de milhar.',
                  errorMaxLines: 3,
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                validator: _validarMensalidade,
                onFieldSubmitted: (_) => _cadastrar(),
              ),
              const SizedBox(height: 24),

              // 17. Botão e resumo.
              FilledButton.icon(
                onPressed: _cadastrar,
                icon: const Icon(Icons.school),
                label: const Text('Cadastrar curso'),
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