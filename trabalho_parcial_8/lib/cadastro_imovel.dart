import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:intl/intl.dart';
import 'package:all_br_forms/all_br_forms.dart';
import 'package:all_br_validations/all_br_validations.dart';

// 1. Inicialização do exercício.
void main() {
  runApp(
    MaterialApp(
      title: 'Exercício 5',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const CadastroImovelPage(),
    ),
  );
}

// 2. Declaração da tela.
class CadastroImovelPage extends StatefulWidget {
  const CadastroImovelPage({super.key});

  @override
  State<CadastroImovelPage> createState() {
    return _CadastroImovelPageState();
  }
}

class _CadastroImovelPageState extends State<CadastroImovelPage> {
  // 3. Chave do formulário e controllers.
  final _formKey = GlobalKey<FormState>();

  final _proprietarioController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _areaController = TextEditingController();
  final _valorController = TextEditingController();

  // 4. Formatação dos valores.
  final _moeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  final _formatoArea = NumberFormat('#,##0.##', 'pt_BR');

  String? _resumoCadastro;

  // 5. Liberação dos controllers.
  @override
  void dispose() {
    _proprietarioController.dispose();
    _cpfController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _areaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  // 6. Validação do número do imóvel.
  String? _validarNumero(String? valor) {
    return Validatorless.multiple([
      Validatorless.required('Informe o número do imóvel.'),
      Validatorless.number('Digite um número válido.'),
      Validatorless.regex(
        RegExp(r'^[0-9]+$'),
        'Digite um número inteiro, sem casas decimais.',
      ),
      Validatorless.numbersBetweenInterval(
        1,
        99999,
        'O número deve estar entre 1 e 99.999.',
      ),
    ])(valor?.trim());
  }

  // 7. Normalização dos valores decimais.
  String _normalizarDecimal(String valor) {
    return valor.trim().replaceAll(',', '.');
  }

  // 8. Validação reutilizável para área e valor do imóvel.
  String? _validarDecimal(
    String? valor, {
    required String mensagemObrigatorio,
    required double minimo,
    required double maximo,
    required String mensagemIntervalo,
  }) {
    final normalizado = _normalizarDecimal(valor ?? '');

    return Validatorless.multiple([
      Validatorless.required(mensagemObrigatorio),
      Validatorless.number('Digite um valor numérico válido.'),
      Validatorless.regex(
        RegExp(r'^[0-9]+(?:\.[0-9]{1,2})?$'),
        'Use no máximo duas casas decimais, sem milhar.',
      ),
      Validatorless.numbersBetweenInterval(
        minimo,
        maximo,
        mensagemIntervalo,
      ),
    ])(normalizado);
  }

  // 9. Cadastro e apresentação dos dados.
  void _cadastrar() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _resumoCadastro = null;
      });
      return;
    }

    final numero = int.parse(_numeroController.text.trim());

    final area = double.parse(
      _normalizarDecimal(_areaController.text),
    );

    final valorImovel = double.parse(
      _normalizarDecimal(_valorController.text),
    );

    setState(() {
      _resumoCadastro = [
        'Proprietário: ${_proprietarioController.text.trim()}',
        'CPF: ${_cpfController.text.trim()}',
        'CEP: ${_cepController.text.trim()}',
        'Endereço: ${_enderecoController.text.trim()}',
        'Número: $numero',
        'Área: ${_formatoArea.format(area)} m²',
        'Valor: ${_moeda.format(valorImovel)}',
      ].join('\n');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imóvel cadastrado com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 10. Construção da interface.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercício 5 — Imóvel'),
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
              // 11. Nome do proprietário.
              TextFormField(
                controller: _proprietarioController,
                decoration: const InputDecoration(
                  labelText: 'Nome do proprietário',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (valor) {
                  return Validatorless.multiple([
                    Validatorless.required(
                      'Informe o nome do proprietário.',
                    ),
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

              // 12. CPF do proprietário.
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF do proprietário',
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

              // 13. CEP.
              TextFormField(
                controller: _cepController,
                decoration: const InputDecoration(
                  labelText: 'CEP',
                  hintText: '00000-000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: const [
                  CepMask(),
                ],
                validator: BrZod().required().cep().build,
              ),
              const SizedBox(height: 16),

              // 14. Endereço.
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  hintText: 'Rua ou avenida',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (valor) {
                  return Validatorless.multiple([
                    Validatorless.required('Informe o endereço.'),
                    Validatorless.min(
                      5,
                      'O endereço deve ter pelo menos 5 caracteres.',
                    ),
                    Validatorless.max(
                      100,
                      'O endereço deve ter no máximo 100 caracteres.',
                    ),
                  ])(valor?.trim());
                },
              ),
              const SizedBox(height: 16),

              // 15. Número do imóvel.
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Número',
                  helperText: 'De 1 a 99.999. Digite somente os dígitos.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: _validarNumero,
              ),
              const SizedBox(height: 16),

              // 16. Área do imóvel.
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Área do imóvel',
                  suffixText: 'm²',
                  hintText: '120,50',
                  helperText: 'De 10 a 10.000 m². Sem separador de milhar.',
                  helperMaxLines: 2,
                  errorMaxLines: 3,
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: (valor) {
                  return _validarDecimal(
                    valor,
                    mensagemObrigatorio: 'Informe a área do imóvel.',
                    minimo: 10,
                    maximo: 10000,
                    mensagemIntervalo:
                        'A área deve estar entre 10 e 10.000 m².',
                  );
                },
              ),
              const SizedBox(height: 16),

              // 17. Valor do imóvel.
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor do imóvel',
                  prefixText: 'R\$ ',
                  hintText: '250000,50',
                  helperText: 'Digite sem separador de milhar.',
                  errorMaxLines: 3,
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                validator: (valor) {
                  return _validarDecimal(
                    valor,
                    mensagemObrigatorio: 'Informe o valor do imóvel.',
                    minimo: 20000,
                    maximo: 10000000,
                    mensagemIntervalo:
                        'O valor deve estar entre '
                        'R\$ 20.000,00 e R\$ 10.000.000,00.',
                  );
                },
                onFieldSubmitted: (_) => _cadastrar(),
              ),
              const SizedBox(height: 24),

              // 18. Botão e resumo.
              FilledButton.icon(
                onPressed: _cadastrar,
                icon: const Icon(Icons.home),
                label: const Text('Cadastrar imóvel'),
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