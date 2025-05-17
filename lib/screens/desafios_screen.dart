import 'package:flutter/material.dart';
import 'package:healthu/models/desafio_model.dart';
import 'package:healthu/routes/desafios_routes.dart';
import 'package:healthu/styles/desafios_styles.dart';
import 'package:healthu/widgets/desafio_card.dart';
import 'package:healthu/screens/ejercicios_principiante_screen.dart';

class DesafiosScreen extends StatefulWidget {
  const DesafiosScreen({super.key});

  @override
  State<DesafiosScreen> createState() => _DesafiosScreenState();
}

class _DesafiosScreenState extends State<DesafiosScreen> {
  int puntuacionActual = 2500;
  final int objetivo = 5000;
  List<Desafio> desafios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDesafios();
  }

  Future<void> _cargarDesafios() async {
    final desafiosBase = [
      Desafio(
        id: '1',
        nombre: 'Desafio 1',
        descripcion: 'Rutina básica para principiantes',
        desbloqueado: true,
        completado: false,
        ejerciciosIds: ['1', '2', '3'],
      ),
      Desafio(
        id: '2',
        nombre: 'Desafio 2',
        descripcion: 'Rutina intermedia',
        desbloqueado: false,
        completado: false,
        ejerciciosIds: ['4', '5', '6'],
      ),
      Desafio(
        id: '3',
        nombre: 'Desafio 3',
        descripcion: 'Rutina avanzada',
        desbloqueado: false,
        completado: false,
        ejerciciosIds: ['7', '8', '9'],
      ),
      Desafio(
        id: '4',
        nombre: 'Desafio 4',
        descripcion: 'Rutina experta',
        desbloqueado: false,
        completado: false,
        ejerciciosIds: ['10', '11', '12'],
      ),
      Desafio(
        id: '5',
        nombre: 'Desafio 5',
        descripcion: 'Rutina expertaa',
        desbloqueado: false,
        completado: false,
        ejerciciosIds: ['10', '11', '12'],
      ),
      Desafio(
        id: '6',
        nombre: 'Desafio 6',
        descripcion: 'Rutina expertaa',
        desbloqueado: false,
        completado: false,
        ejerciciosIds: ['10', '11', '12'],
      ),
    ];

    final desafiosCargados = await DesafiosRoutes.cargarProgresoDesafios(desafiosBase);
    
    setState(() {
      desafios = desafiosCargados;
      isLoading = false;
    });
  }

  void _completarDesafio(String desafioId) async {
    final index = desafios.indexWhere((d) => d.id == desafioId);
    if (index == -1) return;

    setState(() {
      desafios[index] = desafios[index].copyWith(completado: true);
      
      if (index + 1 < desafios.length) {
        desafios[index + 1] = desafios[index + 1].copyWith(desbloqueado: true);
      }
    });

    await DesafiosRoutes.guardarProgresoDesafios(desafios);

    if (desafios.every((d) => d.completado)) {
      _mostrarMensaje('¡Felicidades! Has completado todos los desafíos.');
    } else if (index + 1 < desafios.length) {
      _mostrarMensaje('¡Desafío completado! Puedes continuar con el siguiente.');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Text('Santiago mera', style: TextStyle(fontSize: 16, color: Colors.black),),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Configuración'),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text('Cerrar sesión'),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPuntuacionYObjetivoRow(),
            const SizedBox(height: 20),
            const Text(
              'Desafios Sena Healthu',
              style: DesafiosStyles.titulo,
            ),
            const SizedBox(height: 15),
            _buildDesafiosGrid(),
            const SizedBox(height: 20),
            _buildMensajeProgreso(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildMensajeProgreso() {
    if (desafios.every((d) => d.completado)) {
      return const Text(
        '¡Has completado todos los desafíos!',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      );
    }

    final primerDesafioNoCompletado = desafios.firstWhere(
      (d) => !d.completado,
      orElse: () => desafios.first,
    );

    if (!primerDesafioNoCompletado.desbloqueado) {
      return const Text(
        'Comienza por el primer desafío para desbloquear los siguientes.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.orange,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPuntuacionYObjetivoRow() {
    return Row(
      children: [
        Expanded(
          child: _buildPuntuacionCard(),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildObjetivoCard(),
        ),
      ],
    );
  }

  Widget _buildPuntuacionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Puntuacion',
              style: DesafiosStyles.puntuacionTitulo,
            ),
            const SizedBox(height: 10),
            Text(
              puntuacionActual.toString(),
              style: DesafiosStyles.puntuacionValor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjetivoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Objetivo',
              style: DesafiosStyles.puntuacionTitulo,
            ),
            const SizedBox(height: 10),
            Text(
              objetivo.toString(),
              style: DesafiosStyles.puntuacionValor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesafiosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: desafios.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          if (!desafios[index].desbloqueado) {
            _mostrarMensaje('Debes completar el desafío anterior para acceder a este.');
            return;
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EjerciciosPrincipianteScreen(
                nombreDesafio: desafios[index].nombre,
                desafio: desafios[index],
                onCompletado: () => _completarDesafio(desafios[index].id),
              ),
            ),
          );
        },
        child: DesafioCard(desafio: desafios[index]),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Desafíos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Clasificación',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      currentIndex: 0,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      backgroundColor: Colors.green[800],
    );
  }
}