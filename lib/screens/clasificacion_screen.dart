import 'package:flutter/material.dart';
import 'package:healthu/services/clasificacion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ClasificacionScreen extends StatefulWidget {
  const ClasificacionScreen({super.key});

  @override
  State<ClasificacionScreen> createState() => _ClasificacionScreenState();
}

class _ClasificacionScreenState extends State<ClasificacionScreen> {
  Future<List<dynamic>>? _topAprendicesFuture;
  int? idPersonaLogueada;
  double? puntosUsuario;
  String? nombreUsuarioToken;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _cargarUsuario();
    setState(() {
      _topAprendicesFuture = ClasificacionService.obtenerTop10Aprendices();
    });
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final payload = _decodeJwt(token);
      idPersonaLogueada = payload['id_persona'];
      nombreUsuarioToken = payload['nombre_usuario'] ?? 'Usuario';
      debugPrint('✅ Usuario logueado con idPersona=$idPersonaLogueada');
      debugPrint('🧩 Nombre desde token: $nombreUsuarioToken');
    }
  }

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return json.decode(payload);
  }

  @override
  Widget build(BuildContext context) {
    if (_topAprendicesFuture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: _topAprendicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('❌ Error: ${snapshot.error}'));
            }

            final data = snapshot.data ?? [];
            debugPrint('📦 Clasificación recibida (${data.length}) registros');

            // 🔹 Filtrar aprendices válidos
            final aprendicesValidos = data
                .where((a) =>
                    (a['nombres'] != null &&
                        a['nombres'].toString().trim().isNotEmpty))
                .toList();

            // 🔹 Tomar máximo 20 registros
            final top20 = aprendicesValidos.take(20).toList();

            if (top20.isEmpty) {
              return const Center(child: Text('No hay aprendices registrados'));
            }

            // 🔹 Buscar si el usuario logueado está en el top
            final indexUsuario =
                top20.indexWhere((a) => a['idPersona'] == idPersonaLogueada);

            String mensaje = '';
            Color colorFondo = Colors.transparent;

            // 🔹 Usuario dentro del top
            if (indexUsuario != -1) {
              final puntosActual =
                  (top20[indexUsuario]['puntosAcumulados'] ?? 0).toDouble();

              if (indexUsuario == 0) {
                mensaje = '👑 ¡Eres el número 1 del ranking!';
                colorFondo = Colors.amber[50]!;
              } else {
                final puntosSuperior =
                    (top20[indexUsuario - 1]['puntosAcumulados'] ?? 0)
                        .toDouble();
                final diferencia = puntosSuperior - puntosActual;

                if (diferencia > 0) {
                  mensaje =
                      '🏆 ¡Estás en el top ${indexUsuario + 1}! Te faltan ${diferencia.toInt()} puntos para alcanzar el puesto ${indexUsuario}.';
                } else {
                  mensaje =
                      '🏆 ¡Estás en el top ${indexUsuario + 1}! Muy cerca del siguiente puesto.';
                }
                colorFondo = Colors.lightBlue[50]!;
              }
            } else {
              // 🔹 Usuario fuera del top
              final usuario = data.firstWhere(
                (a) => a['idPersona'] == idPersonaLogueada,
                orElse: () => {},
              );

              puntosUsuario = (usuario['puntosAcumulados'] ?? 0).toDouble();
              final puntosUltimoTop =
                  (top20.isNotEmpty ? (top20.last['puntosAcumulados'] ?? 0) : 0)
                      .toDouble();

              if (puntosUsuario! < puntosUltimoTop) {
                final faltantes = (puntosUltimoTop - puntosUsuario!) + 1;
                mensaje =
                    '🔥 Te faltan ${faltantes.toInt()} puntos para alcanzar el top ${top20.length}.';
                colorFondo = Colors.orange[50]!;
              } else {
                mensaje =
                    '💪 ¡Ya superaste el top ${top20.length}, pronto estarás en el ranking!';
                colorFondo = Colors.green[50]!;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💪 CLASIFICACIÓN GENERAL DE APRENDICES',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Mensaje superior
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: colorFondo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      mensaje,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // 🔹 Lista del top
                Expanded(
                  child: ListView.builder(
                    itemCount: top20.length,
                    itemBuilder: (context, index) {
                      final aprendiz = top20[index];

                      // 🔸 Mostrar nombre real o nombre del token si está logueado y viene null
                      String nombreCompleto;
                      if ((aprendiz['nombres'] == null ||
                              aprendiz['nombres'].toString().isEmpty) &&
                          aprendiz['idPersona'] == idPersonaLogueada) {
                        nombreCompleto = nombreUsuarioToken ?? 'Usuario';
                      } else {
                        nombreCompleto =
                            '${aprendiz['nombres'] ?? ''} ${aprendiz['apellidos'] ?? ''}'
                                .trim();
                      }

                      final puntos = aprendiz['puntosAcumulados'] ?? 0;
                      final horas = aprendiz['horasAcumuladas'] ?? 0;
                      final esUsuario =
                          aprendiz['idPersona'] == idPersonaLogueada;

                      Color? bgColor;
                      if (index == 0)
                        bgColor = Colors.amber[600];
                      else if (index == 1)
                        bgColor = Colors.grey[400];
                      else if (index == 2)
                        bgColor = Colors.brown[400];
                      else
                        bgColor = Colors.green[700];

                      return Card(
                        color: esUsuario ? Colors.teal[50] : Colors.white,
                        elevation: esUsuario ? 6 : 3,
                        shape: RoundedRectangleBorder(
                          side: esUsuario
                              ? const BorderSide(color: Colors.teal, width: 2)
                              : BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: bgColor,
                            radius: 22,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            nombreCompleto.isNotEmpty
                                ? nombreCompleto
                                : 'Sin nombre',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Horas acumuladas: $horas',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          trailing: Text(
                            '$puntos pts',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
