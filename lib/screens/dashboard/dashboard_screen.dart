import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthu/models/usuario.dart';
import 'package:healthu/services/asignacion_rutina_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../widgets/selector_dispersion.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/grafica_barras_calorias.dart';
import 'package:healthu/services/desafio_service.dart';
import 'package:healthu/widgets/nivel.dart';
import 'package:healthu/widgets/grafica_barras_semanal.dart';
import 'package:healthu/widgets/grafica_barras_apiladas.dart';



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

  late Future<List<CardDataModel>> _tarjetasFuture;

  @override
  void initState() {
    super.initState();
    usuario = widget.usuario;
    _tarjetasFuture = _cargarTarjetas();
    _actualizarNivel(); //  refrescar nivel automáticamente al entrar
  }

  //  Refrescar nivel actual desde backend
Future<void> _actualizarNivel() async {
  try {
    final rutina = await RutinaService.obtenerRutinaPorAprendiz(usuario.id);
    if (rutina != null) {
      setState(() {
        usuario = usuario.copyWith(nivelActual: rutina.nivel); 
        _tarjetasFuture = _cargarTarjetas();
      });
    }
  } catch (e) {
    debugPrint(" Error al actualizar nivel: $e");
  }
}
  // 🔹 Lógica para cargar las tarjetas con datos reales
Future<List<CardDataModel>> _cargarTarjetas() async {
  final lista = await DesafioService.obtenerDesafiosPorUsuario();

  // 🔹 Desafíos completados
  final completados = lista
      .where((d) => (d['estado'] ?? '').toString().toLowerCase() == 'finalizado')
      .length;

  // 🔹 Promedio diario (solo día actual)
  final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final hoyCount = lista.where((d) {
    final fecha = d['fechaFinDesafio'] ?? d['fechaInicioDesafio'];
    if (fecha == null) return false;
    final fechaNormalizada = fecha.toString().substring(0, 10);
    return fechaNormalizada == hoy;
  }).length;

  // 🔹 Nivel actual del usuario
  final nivel = usuario.nivelActual;

  return [
    CardDataModel(title: 'Desafíos completados', value: '$completados', icon: Icons.fitness_center),
    CardDataModel(title: 'Promedio diario', value: '$hoyCount', icon: Icons.bar_chart),
    CardDataModel(title: 'Nivel actual', value: nivel, icon: Icons.trending_up),
  ];
}

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

void _mostrarAlertaSinRutina({String mensaje = 'Todavía no tienes una rutina asignada.'}) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.info,
    animType: AnimType.bottomSlide,
    title: 'Sin rutina asignada',
    desc: mensaje,
    btnOkText: 'Entendido',
    btnOkOnPress: () {},
    btnOkColor: const Color.fromARGB(255, 0, 150, 22),
  ).show();
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

Future<void> _consultarAsignacion() async {
  try {
    setState(() => _cargandoAsignacion = true);

    final idPersona = await _resolverIdPersona();
    if (idPersona == null) throw Exception('No se pudo obtener el idPersona');

    final asignaciones = await AsignacionRutinaService.obtenerRutinasPorPersona(idPersona);

    if (!mounted) return;

    if (asignaciones.isEmpty) {
      _mostrarAlertaSinRutina();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RutinaAsignadaScreen(asignaciones: asignaciones),
      ),
    );

    _showSnack('Rutinas cargadas', bg: Colors.green, icon: Icons.check_circle);
  } catch (e) {
    debugPrint('Error al consultar rutinas: $e');
    _mostrarAlertaSinRutina(
      mensaje: 'No  tienes rutinas asignadas, consulta con tu entrenador.',
    );
  } finally {
    if (mounted) setState(() => _cargandoAsignacion = false);
  }
}



  Future<void> _generarRutina() async {
    final initial = {"nivel": usuario.nivelActual};

    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => QuickRutinaForm(initial: initial),
    );

    if (payload == null) return;

    try {
      setState(() => _generando = true);
      final resp = await RutinaService.generarRutina(payload);

      final textoPlan =
          (resp['raw'] ?? resp['descripcion'] ?? resp['message'] ?? '')
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
    } catch (e) {
      final msg = e.toString().toLowerCase().contains('timeoutexception')
          ? 'No se pudo contactar al servidor (timeout).'
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

return Scaffold(
  endDrawerEnableOpenDragGesture: false, 
  endDrawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(usuario.nombre),
          accountEmail: Text(usuario.email),
          currentAccountPicture: CircleAvatar(
            radius: 36,
            backgroundColor: Colors.grey[200],
            backgroundImage: usuario.fotoUrl.isNotEmpty
                ? CachedNetworkImageProvider(usuario.fotoUrl)
                : null,
            child: usuario.fotoUrl.isEmpty
                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                : null,
          ),
        ),
        ..._buildDrawerItems(),
        ListTile(
          leading: const Icon(Icons.history, color: Colors.red),
          title: const Text('Ver historial de mediciones'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/frecuencia-historial');
          },
        ),
        ListTile(
          leading: const Icon(Icons.analytics_outlined, color: Colors.green),
          title: const Text('Estadísticas Detalladas'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/progreso-estadisticas');
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications_outlined, color: Colors.green),
          title: const Text('Configurar Notificaciones'),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (c) => const NotificacionesWidget(),
            );
          },
        ),
      ],
    ),
  ),

  appBar: AppBar(
    title: const Text(
      'HealthU',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.green,
    automaticallyImplyLeading: false, 
    actions: [
      Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu), 
          onPressed: () {
            Scaffold.of(context).openEndDrawer(); 
          },
        ),
      ),
    ],
  ),

  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: RefreshIndicator(
      onRefresh: _actualizarNivel,
      child: ListView(
        children: [
          FichaIdentificacion(usuario: usuario),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Bienvenido, ${usuario.nombre.split(' ').first}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Center(
            child: Text(
              DateFormat('EEEE d MMMM', 'es').format(DateTime.now()),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _obtenerSaludo(),
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.green,
              ),
            ),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
          const SizedBox(height: 24),
          const ProgresoDesafiosCard(),
              const SizedBox(height: 24),

              // 🔹 Tarjetas dinámicas
              FutureBuilder<List<CardDataModel>>(
                future: _tarjetasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  if (!snapshot.hasData) {
                    return const Text("No hay datos disponibles");
                  }
                  return TarjetasDashboard(items: snapshot.data!);
                },
              ),

              const SizedBox(height: 32),
             const TextoSeccion('Progreso de Nivel'),
            Nivel(
           nivel: (usuario.nivelActual.isNotEmpty)
            ? usuario.nivelActual
            : 'Principiante',
             ),
              const SizedBox(height: 32),
              const TextoSeccion('Progreso semanal de desafíos'),
              const SizedBox(height: 16),
              const GraficaBarrasSemanal(),
              const SizedBox(height: 32),
              const TextoSeccion('Desafíos Finalizados vs En Progreso'),
              const SizedBox(height: 16),
              const GraficaDesafios(),
              const SizedBox(height: 32),
              const TextoSeccion('Calorías quemadas por día'),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, double>>(
                future: DesafioService.obtenerCaloriasQuemadasPorDia(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No hay datos disponibles");
                  }
                  return GraficaBarrasCalorias(caloriasPorDia: snapshot.data!);
                },
              ),

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
      ),
    );
  }
}
