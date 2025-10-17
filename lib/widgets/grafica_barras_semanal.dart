import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:healthu/services/desafio_service.dart';

class GraficaBarrasSemanal extends StatefulWidget {
  const GraficaBarrasSemanal({super.key});

  @override
  State<GraficaBarrasSemanal> createState() => _GraficaBarrasSemanalState();
}

class _GraficaBarrasSemanalState extends State<GraficaBarrasSemanal> {
  Map<String, int> _desafiosPorDia = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final lista = await DesafioService.obtenerDesafiosPorUsuario();

      // 🔹 Calcular la semana actual (Lunes a Domingo)
      DateTime hoy = DateTime.now();
      DateTime lunes = hoy.subtract(Duration(days: hoy.weekday - 1));
      List<DateTime> semana = List.generate(7, (i) => lunes.add(Duration(days: i)));

      Map<String, int> conteo = {
        for (var d in semana) DateFormat('yyyy-MM-dd').format(d): 0
      };

      // 🔹 Contar los desafíos finalizados por día
      for (var desafio in lista) {
        final estado = (desafio['estado'] ?? '').toString().toLowerCase();
        if (estado == 'finalizado') {
          final fecha = desafio['fechaFinDesafio'] ?? desafio['fechaInicioDesafio'];
          if (fecha != null) {
            final fechaStr = fecha.toString().substring(0, 10);
            if (conteo.containsKey(fechaStr)) {
              conteo[fechaStr] = conteo[fechaStr]! + 1;
            }
          }
        }
      }

      setState(() {
        _desafiosPorDia = conteo;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error al cargar desafíos semanales: $e');
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_desafiosPorDia.isEmpty) {
      return const Text("No hay datos de desafíos esta semana");
    }

    final diasSemana = _desafiosPorDia.keys.toList();
    final valores = _desafiosPorDia.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Mostrar días con fechas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: diasSemana.map((f) {
            final fecha = DateTime.parse(f);
            final dia = DateFormat('E', 'es').format(fecha).toUpperCase();
            final num = DateFormat('d').format(fecha);
            final esHoy = DateFormat('yyyy-MM-dd').format(DateTime.now()) == f;

            return Column(
              children: [
                Text(
                  dia,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: esHoy ? Colors.green : Colors.black87,
                  ),
                ),
                Text(
                  num,
                  style: TextStyle(
                    fontSize: 11,
                    color: esHoy ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // 🔹 Barras animadas
        SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(diasSemana.length, (i) {
              final valor = valores[i].toDouble();
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        height: valor * 25, // Cada desafío = 25px
                        width: 16,
                        decoration: BoxDecoration(
                          color: valor > 0 ? Colors.green : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${valores[i]}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
