import 'package:flutter/material.dart';
import 'package:healthu/models/usuario.dart';
import 'package:healthu/screens/dashboard/ficha_identificacion.dart';

class EditarUsuarioScreen extends StatefulWidget {
  final Usuario usuario;                       // ← recibe el usuario actual
  const EditarUsuarioScreen({super.key, required this.usuario});

  @override
  State<EditarUsuarioScreen> createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nombreCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController fotoCtrl;

  late Usuario usuarioVista;                  // copia mutable para la vista

  @override
  void initState() {
    super.initState();
    usuarioVista = widget.usuario;
    nombreCtrl = TextEditingController(text: widget.usuario.nombre);
    emailCtrl  = TextEditingController(text: widget.usuario.email);
    fotoCtrl   = TextEditingController(text: widget.usuario.fotoUrl);

    // Escucha cambios y refresca la ficha
    nombreCtrl.addListener(_actualizarVista);
    emailCtrl .addListener(_actualizarVista);
    fotoCtrl  .addListener(_actualizarVista);
  }

  void _actualizarVista() {
    setState(() {
      usuarioVista = Usuario(
        id: widget.usuario.id,
        nombre: nombreCtrl.text,
        email:  emailCtrl.text,
        fotoUrl: fotoCtrl.text,
        nivelActual: widget.usuario.nivelActual,
      );
    });
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    emailCtrl.dispose();
    fotoCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, usuarioVista);   // devuelve el usuario editado
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actualizar datos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ─── Ficha de identificación (vista previa) ───
              FichaIdentificacion(usuario: usuarioVista),
              const SizedBox(height: 24),

              TextFormField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'E-mail inválido',
              ),
              TextFormField(
                controller: fotoCtrl,
                decoration: const InputDecoration(labelText: 'URL de foto'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
