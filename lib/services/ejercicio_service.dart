  import '../models/ejercicio_model.dart';

  class EjercicioService {
    static final List<Ejercicio> ejerciciosPredefinidos = [
      Ejercicio(
        id: '1',
        nombre: 'Sentadillas',
        descripcion: 'Ejercicio para piernas y glúteos',
        imagenUrl: '',
        duracion: 30,
        calorias: 100,
      ),
      Ejercicio(
        id: '2',
        nombre: 'Press de banca',
        descripcion: 'Ejercicio para pecho y brazos',
        imagenUrl: '',
        duracion: 45,
        calorias: 120,
      ),
      Ejercicio(
        id: '3',
        nombre: 'Peso muerto',
        descripcion: 'Ejercicio para espalda y piernas',
        imagenUrl: '',
        duracion: 40,
        calorias: 150,
      ),
      Ejercicio(
        id: '4',
        nombre: 'Curl de bíceps',
        descripcion: 'Ejercicio para brazos',
        imagenUrl: '',
        duracion: 35,
        calorias: 80,
      ),
    ];

    static List<Ejercicio> obtenerEjerciciosPredefinidos() {
      return ejerciciosPredefinidos;
    }
  }