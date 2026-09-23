import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:intl/intl.dart';
import 'package:all_br_forms/all_br_forms.dart';
import 'package:all_br_validations/all_br_validations.dart';

// 1. Inicialização do exercício.
void main() {
  runApp(
    MaterialApp(
      title: 'Exercício 3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const CadastroEmpresaPage(),
    ),
  );
}


class CadastroEmpresaPage extends StatefulWidget {
  const CadastroEmpresaPage({super.key});

  @override
  State<CadastroEmpresaPage> createState() {
    return _CadastroEmpresaPageState();
  }
}

class _CadastroEmpresaPageState extends State<CadastroEmpresaPage> {
  // 3. Chave do formulário e controllers.
  final _formKey = GlobalKey<FormState>();

  final _razaoSocialController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _capitalSocialController = TextEditingController();

  // 4. Formatação monetária.
  final _moeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  String? _resumoCadastro;

  // 5. Liberação dos controllers.
  @override
  void dispose() {
    _razaoSocialController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _capitalSocialController.dispose();
    super.dispose();
  }

  // 6. Normalização do valor digitado.
  String _normalizarCapital(String valor) {
    return valor.trim().replaceAll(',', '.');
  }

  // 7. Validação do capital social.
  String? _validarCapitalSocial(String? valor) {
    final normalizado = _normalizarCapital(valor ?? '');

    return Validatorless.multiple([
      Validatorless.required('Informe o capital social.'),
      Validatorless.number('Digite um valor numérico válido.'),
      Validatorless.regex(
        RegExp(r'^[0-9]+(?:\.[0-9]{1,2})?$'),
        'Use no máximo duas casas decimais, sem milhar.',
      ),
      Validatorless.numbersBetweenInterval(
        1000,
        100000000,
        'O capital deve estar entre R\$ 1.000,00 e R\$ 100.000.000,00.',
      ),
    ])(normalizado);
  }

  // 8. Validação geral e apresentação do cadastro.
  void _cadastrar() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _resumoCadastro = null;
      });
      return;
    }

    final capitalSocial = double.parse(
      _normalizarCapital(_capitalSocialController.text),
    );

    setState(() {
      _resumoCadastro = [
        'Razão social: ${_razaoSocialController.text.trim()}',
        'CNPJ: ${_cnpjController.text.trim()}',
        'E-mail: ${_emailController.text.trim()}',
        'Telefone: ${_telefoneController.text.trim()}',
        'Capital social: ${_moeda.format(capitalSocial)}',
      ].join('\n');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Empresa cadastrada com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 9. Construção da interface.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro da Empresa'),
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
              // 10. Razão social.
              TextFormField(
                controller: _razaoSocialController,
                decoration: const InputDecoration(
                  labelText: 'Razão social',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (valor) {
                  return Validatorless.multiple([
                    Validatorless.required('Informe a razão social.'),
                    Validatorless.min(
                      3,
                      'A razão social deve ter pelo menos 3 caracteres.',
                    ),
                    Validatorless.max(
                      100,
                      'A razão social deve ter no máximo 100 caracteres.',
                    ),
                  ])(valor?.trim());
                },
              ),
              const SizedBox(height: 16),

              // 11. CNPJ.
              TextFormField(
                controller: _cnpjController,
                decoration: const InputDecoration(
                  labelText: 'CNPJ',
                  hintText: '00.000.000/0000-00',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: const [
                  CnpjMask(),
                ],
                validator: BrZod().required().cnpj().build,
              ),
              const SizedBox(height: 16),

              // 12. E-mail.
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'contato@empresa.com',
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

              // 13. Telefone.
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: '(11) 3456-7890',
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

              // 14. Capital social.
              TextFormField(
                controller: _capitalSocialController,
                decoration: const InputDecoration(
                  labelText: 'Capital social',
                  prefixText: 'R\$ ',
                  hintText: '15000,50',
                  helperText: 'Digite sem separador de milhar.',
                  errorMaxLines: 3,
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                validator: _validarCapitalSocial,
                onFieldSubmitted: (_) => _cadastrar(),
              ),
              const SizedBox(height: 24),

              // 15. Botão de cadastro.
              FilledButton.icon(
                onPressed: _cadastrar,
                icon: const Icon(Icons.business),
                label: const Text('Cadastrar empresa'),
              ),

              // 16. Resumo dos dados validados.
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