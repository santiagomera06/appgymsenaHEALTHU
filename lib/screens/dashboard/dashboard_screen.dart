import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthu/models/usuario.dart';
import 'package:healthu/models/asignacion_rutina.dart';
import 'package:healthu/services/asignacion_rutina_service.dart';
import '../../widgets/selector_dispersion.dart';
import '../../widgets/graficas_extra.dart';
import '../../widgets/progreso_desafios_card.dart';
import '../../widgets/notificaciones_widget.dart';
import 'ficha_identificacion.dart';
import 'tarjetas_dashboard.dart';
import '../graficas/graficas_dashboard.dart';
import '../graficas/grafica_anillo.dart';
import '../editar usuario/editar_usuario_screen.dart';
import '../rutinas/rutina_asignada_screen.dart';
import 'package:healthu/services/rutina_service.dart';
import '../../widgets/quick_rutina_form.dart';
import '../rutinas/rutina_plan_tabs_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Usuario usuario;
  const DashboardScreen({super.key, required this.usuario});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Usuario usuario;
  bool _cargandoAsignacion = false;
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    usuario = widget.usuario;
  }

  // --- UI helpers ---
  void _showSnack(String msg, {Color? bg, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg ?? Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(icon, color: Colors.white),
              ),
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
  }

  void _mostrarAlertaSinRutina() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: const [
              Icon(Icons.info_outline, color: Colors.orange, size: 48),
              SizedBox(height: 12),
              Text('Sin rutina asignada',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: const Text('Todavía no tienes una rutina asignada.',
              textAlign: TextAlign.center),
        );
      },
    );
  }

  List<Widget> _buildDrawerItems() => [
        ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () => Navigator.pop(context)),
        ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () => Navigator.pop(context)),
        ListTile(
          leading: const Icon(Icons.monitor_heart, color: Colors.red),
          title: const Text('Mide tu frecuencia'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/medicion-frecuencia');
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            onPressed: _generando ? null : _generarRutina,
            icon: _generando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: const Text('Generar rutina personalizada'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('Actualizar datos'),
          onTap: () async {
            Navigator.pop(context);
            final actualizado = await Navigator.push<Usuario>(
              context,
              MaterialPageRoute(
                  builder: (_) => EditarUsuarioScreen(usuario: usuario)),
            );
            if (actualizado != null) setState(() => usuario = actualizado);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar sesión'),
          onTap: () async {
            Navigator.pop(context);
            final p = await SharedPreferences.getInstance();
            await p.clear();
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ];

  String _obtenerSaludo() {
    final h = DateTime.now().hour;
    return h < 12
        ? '¡Buenos días!'
        : h < 18
            ? '¡Buenas tardes!'
            : '¡Buenas noches!';
  }

  String _fmt(DateTime? dt) =>
      dt == null ? '-' : DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
  Future<int?> _resolverIdPersona() async {
    final prefs = await SharedPreferences.getInstance();
    final dynamic raw = prefs.get('id_persona'); 
    int? idFromPrefs;
    if (raw is int) {
      idFromPrefs = raw;
    } else if (raw is String) {
      idFromPrefs = int.tryParse(raw);
    }
    if (idFromPrefs != null) return idFromPrefs;

    try {
      final dyn = usuario as dynamic;
      final any = (dyn.idPersona ?? dyn.id);
      final n = int.tryParse('$any');
      if (n != null) return n;
    } catch (_) {}
    return null;
  }

  /// Consulta asignación y navega a la pantalla con PESTAÑAS
  Future<void> _consultarAsignacion() async {
    final idPersona = await _resolverIdPersona();
    if (idPersona == null) {
      _showSnack('No se encontró idPersona',
          bg: Colors.redAccent, icon: Icons.error_outline);
      return;
    }
    try {
      setState(() => _cargandoAsignacion = true);
      final AsignacionRutina? a =
          await AsignacionRutinaService.obtenerPorPersona(idPersona);

      print(" Respuesta AsignacionRutinaService: $a");

      if (!mounted) return;
      if (a == null) {
        _mostrarAlertaSinRutina();
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RutinaAsignadaScreen(asignacion: a)),
      );
      _showSnack('Rutina cargada',
          bg: Colors.green, icon: Icons.check_circle_outline);
    } catch (e, st) {
      print(" Error en _consultarAsignacion: $e");
      print(" StackTrace: $st");

      if (!mounted) return;
      _showSnack('Error al consultar rutina. Revisa consola.',
          bg: Colors.redAccent, icon: Icons.error_outline);
    } finally {
      if (mounted) setState(() => _cargandoAsignacion = false);
    }
  }

  // POST /rutina/generar
  Future<void> _generarRutina() async {
    final initial = {
      "nivel": usuario.nivelActual,
    };

    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => QuickRutinaForm(initial: initial),
    );

    if (payload == null) return;

    try {
      setState(() => _generando = true);
      final resp = await RutinaService.generarRutina(payload);

      print(" Respuesta completa del backend: $resp"); // log detallado

      //  Extraer texto del plan y navegar a pestañas por día
      final textoPlan = (resp['raw'] ?? resp['descripcion'] ?? resp['message'] ?? '')
          .toString()
          .trim();

      if (textoPlan.isNotEmpty) {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RutinaPlanTabsScreen(planTexto: textoPlan),
          ),
        );
      } else {
        _showSnack('Rutina generada correctamente',
            bg: Colors.teal, icon: Icons.check);
      }
    } catch (e, st) {

      print(" Error en _generarRutina: $e");
      print(" StackTrace: $st");

      final isTimeout = e.toString().toLowerCase().contains('timeoutexception');
      final msg = isTimeout
          ? 'No se pudo contactar al servidor (timeout). Verifica conexión o puerto 8080.'
          : 'Error al generar rutina. Revisa consola para detalles';

      _showSnack(msg, bg: Colors.redAccent, icon: Icons.error_outline);
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaHoy =
        DateFormat('EEEE d MMMM', 'es').format(DateTime.now()).toString();

    final datosSemana = <double>[2, 3, 1, 4, 5, 2, 0];
    final actividades = <PieSectionDataModel>[
      PieSectionDataModel(
          value: 35, color: Colors.green, label: 'Cardio', textColor: Colors.white),
      PieSectionDataModel(
          value: 35,
          color: Colors.lightGreen,
          label: 'Fuerza',
          textColor: Colors.black),
      PieSectionDataModel(
          value: 30,
          color: Colors.grey.shade300,
          label: 'Descanso',
          textColor: Colors.black),
    ];
    final tarjetas = <CardDataModel>[
      CardDataModel(title: 'Puntos totales', value: '1 200', icon: Icons.star),
      CardDataModel(
          title: 'Desafíos completados', value: '45', icon: Icons.fitness_center),
      CardDataModel(title: 'Promedio diario', value: '3', icon: Icons.bar_chart),
      CardDataModel(title: 'Nivel actual', value: 'Avanzado', icon: Icons.trending_up),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard del Aprendiz'),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(usuario.nombre),
              accountEmail: Text(usuario.email),
              currentAccountPicture:
                  CircleAvatar(backgroundImage: NetworkImage(usuario.fotoUrl)),
              decoration: const BoxDecoration(color: Colors.green),
            ),
            ..._buildDrawerItems(),
            ListTile(
              leading:
                  const Icon(Icons.analytics_outlined, color: Colors.green),
              title: const Text('Estadísticas Detalladas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/progreso-estadisticas');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined,
                  color: Colors.green),
              title: const Text('Configurar Notificaciones'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (c) => const NotificacionesWidget());
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            FichaIdentificacion(usuario: usuario),
            const SizedBox(height: 12),
            Center(
              child: Text('Bienvenido, ${usuario.nombre.split(' ').first}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
            ),
            Center(
                child: Text(fechaHoy,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.grey))),
            const SizedBox(height: 8),
            Center(
              child: Text(_obtenerSaludo(),
                  style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.green)),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _cargandoAsignacion ? null : _consultarAsignacion,
                icon: _cargandoAsignacion
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.assignment_outlined),
                label: const Text('Ver rutina asignada'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
            const SizedBox(height: 24),
            const ProgresoDesafiosCard(),
            const SizedBox(height: 24),
            TarjetasDashboard(items: tarjetas),
            const SizedBox(height: 32),
            const TextoSeccion('Progreso de Nivel'),
            const BarraProgreso(),
            const SizedBox(height: 32),
            const TextoSeccion('Progreso semanal de desafíos'),
            const SizedBox(height: 16),
            GraficaBarras(valores: datosSemana),
            const SizedBox(height: 32),
            GraficaCircular(sections: actividades),
            const SizedBox(height: 32),
            const TextoSeccion('Calorías por actividad (semana)'),
            const SizedBox(height: 16),
            const GraficaBarrasApiladas(),
            const SizedBox(height: 32),
            const TextoSeccion('Comparar variables'),
            const SelectorDispersion(),
          ],
        ),
      ),
    );
  }
}
