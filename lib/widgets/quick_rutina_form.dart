import 'package:flutter/material.dart';

class QuickRutinaForm extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const QuickRutinaForm({super.key, this.initial});

  @override
  State<QuickRutinaForm> createState() => _QuickRutinaFormState();
}

class _QuickRutinaFormState extends State<QuickRutinaForm> {
  final _form = GlobalKey<FormState>();

  // Controladores que siguen siendo de texto
  final _edad = TextEditingController();
  final _lesiones = TextEditingController();
  final _altura = TextEditingController();
  final _peso = TextEditingController();
  final _ubicacion = TextEditingController();
  final _frecuenciaCardio = TextEditingController();

  // Estados para los nuevos selects
  String? _sexo;                      
  String? _objetivo;                  
  String? _nivel;                     
  final Set<String> _diasSel = {};   

  // Catálogos
  static const _sexoOpts = ['Masculino', 'Femenino'];
  static const _objetivoOpts = ['Volumen', 'Definición', 'Mantenimiento', 'Resistencia'];
  static const _nivelOpts = ['Principiante', 'Intermedio', 'Avanzado'];
  static const _diasSemana = [
    'Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'
  ];

  @override
  void initState() {
    super.initState();
    final i = widget.initial ?? {};

    _sexo = _matchOrNull(i['sexo'], _sexoOpts);
    _objetivo = _matchOrNull(i['objetivo'], _objetivoOpts);
    _nivel = _matchOrNull(i['nivel'], _nivelOpts);

    // Permite inicializar días si viene una lista previa
    final diasIni = (i['dias'] as List?)?.map((e) => e.toString()).toSet() ?? {};
    _diasSel
      ..clear()
      ..addAll(diasIni.where((d) => _diasSemana.contains(d)));

    _edad.text = (i['edad']?.toString() ?? '');
    _lesiones.text = i['lesiones'] ?? '';
    _altura.text = (i['altura']?.toString() ?? '');
    _peso.text = (i['peso']?.toString() ?? '');
    _ubicacion.text = i['ubicacion'] ?? '';
    _frecuenciaCardio.text = (i['frecuenciaCardio']?.toString() ?? '');
  }

  String? _matchOrNull(dynamic value, List<String> options) {
    if (value == null) return null;
    final v = value.toString();
    final match = options.firstWhere(
      (o) => o.toLowerCase() == v.toLowerCase(),
      orElse: () => '', 
    );
    return match.isEmpty ? null : match;
  }

  @override
  void dispose() {
    _edad.dispose();
    _lesiones.dispose();
    _altura.dispose();
    _peso.dispose();
    _ubicacion.dispose();
    _frecuenciaCardio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration deco(String t) =>
        InputDecoration(labelText: t, border: const OutlineInputBorder());

    return AlertDialog(
      title: const Text('Datos para generar rutina'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            children: [
              // SEXO
              DropdownButtonFormField<String>(
                value: _sexo,
                decoration: deco('Sexo'),
                items: _sexoOpts
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sexo = v),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),

              // EDAD
              TextFormField(
                controller: _edad,
                decoration: deco('Edad'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),

              // OBJETIVO
              DropdownButtonFormField<String>(
                value: _objetivo,
                decoration: deco('Objetivo'),
                items: _objetivoOpts
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (v) => setState(() => _objetivo = v),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),

              // LESIONES
              TextFormField(controller: _lesiones, decoration: deco('Lesiones (opcional)')),
              const SizedBox(height: 8),

              // NIVEL
              DropdownButtonFormField<String>(
                value: _nivel,
                decoration: deco('Nivel'),
                items: _nivelOpts
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (v) => setState(() => _nivel = v),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),

              // ALTURA / PESO
              TextFormField(
                controller: _altura,
                decoration: deco('Altura (cm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _peso,
                decoration: deco('Peso (kg)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),

              // FRECUENCIA -> DÍAS DE LA SEMANA
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Frecuencia (días/semana)', style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _diasSemana.map((d) {
                  final selected = _diasSel.contains(d);
                  return FilterChip(
                    label: Text(d),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _diasSel.add(d);
                        } else {
                          _diasSel.remove(d);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // UBICACIÓN (actualizado)
              DropdownButtonFormField<String>(
                value: _ubicacion.text.isNotEmpty ? _ubicacion.text : null,
                decoration: deco('Ubicación'),
                items: const [
                  DropdownMenuItem(value: 'Casa', child: Text('Casa')),
                  DropdownMenuItem(value: 'Gimnasio', child: Text('Gimnasio')),
                  DropdownMenuItem(value: 'Aire libre', child: Text('Aire libre')),
                ],
                onChanged: (v) => setState(() => _ubicacion.text = v ?? ''),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),

              // FRECUENCIA CARDIO
              TextFormField(
                controller: _frecuenciaCardio,
                decoration: deco('Frecuencia Cardio (min/semana)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          child: const Text('Generar'),
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            if (_diasSel.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selecciona al menos un día')),
              );
              return;
            }

            Navigator.pop(context, {
              "sexo": _sexo,
              "edad": int.tryParse(_edad.text.trim()) ?? 0,
              "objetivo": _objetivo,
              "lesiones": _lesiones.text.trim(),
              "nivel": _nivel,
              "altura": int.tryParse(_altura.text.trim()) ?? 0,
              "peso": int.tryParse(_peso.text.trim()) ?? 0,
              "frecuencia": _diasSel.length,
              "dias": _diasSel.toList(),
              "ubicacion": _ubicacion.text.trim(),
              "frecuenciaCardio": int.tryParse(_frecuenciaCardio.text.trim()) ?? 0,
            });
          },
        ),
      ],
    );
  }
}
