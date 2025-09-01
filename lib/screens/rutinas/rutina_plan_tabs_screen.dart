import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class RutinaPlanTabsScreen extends StatelessWidget {
  final String planTexto; 
  const RutinaPlanTabsScreen({super.key, required this.planTexto});

  List<_DiaPlan> _parsearDias(String raw) {
    final texto = raw.replaceAll('\r\n', '\n');

    final reConDosPuntos = RegExp(
      r'^\s*D[íiI]a\s+(\d+)\s*(?:[-–]\s*(.*?))?\s*:\s*$',
      multiLine: true,
    );
    final reSinDosPuntos = RegExp(
      r'^\s*D[íiI]a\s+(\d+)\b(?:\s*[-–]\s*(.*))?$',
      multiLine: true,
    );

    final matches = reConDosPuntos.hasMatch(texto)
        ? reConDosPuntos.allMatches(texto).toList()
        : reSinDosPuntos.allMatches(texto).toList();

    if (matches.isEmpty) {
      return [_DiaPlan(titulo: 'Plan', contenido: texto.trim())];
    }

    final dias = <_DiaPlan>[];
    for (var i = 0; i < matches.length; i++) {
      final m = matches[i];
      final diaN = m.group(1) ?? '';
      final tituloExtra = (m.group(2) ?? '').trim();
      final start = m.end;
      final end = (i < matches.length - 1) ? matches[i + 1].start : texto.length;
      final body = texto.substring(start, end).trim();

      final tituloTab =
          tituloExtra.isNotEmpty ? 'Día $diaN: $tituloExtra' : 'Día $diaN';

      dias.add(_DiaPlan(titulo: tituloTab, contenido: body));
    }
    return dias;
  }

  // Separa “Advertencias”
  (String contenido, String advertencias) _splitAdvertencias(String text) {
    final idx = text.indexOf('**Advertencias**');
    if (idx == -1) return (text.trim(), '');
    final contenido = text.substring(0, idx).trim();
    final adv = text.substring(idx).trim();
    return (contenido, adv);
  }

  // Convierte líneas con guion 
  List<Widget> _buildBulleted(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trimRight())
        .where((l) => l.isNotEmpty)
        .toList();

    return lines.map((l) {
      if (l.startsWith('- ')) {
        final clean = l.substring(2).trim();
        return ListTile(
          dense: true,
          leading: const Icon(Icons.circle, size: 8),
          title: Text(clean),
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: -2),
        );
      }
      // títulos se ven como subtítulos
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(
          l,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dias = _parsearDias(planTexto);

    return DefaultTabController(
      length: dias.length,
      child: Scaffold(
        //  APPBAR CON GRADIENTE Y TABS CHIDOS ======
        appBar: AppBar(
          elevation: 0,
          title: const Text('Rutina generada'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF34C759), Color(0xFF0BA360)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: _StylishTabs(dias: dias),
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Copiar todo',
              icon: const Icon(Icons.copy_all_rounded),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: planTexto));
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plan copiado al portapapeles')),
                );
              },
            ),
            
          ],
        ),

        // ====== CUERPO ======
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7FFF9), Color(0xFFEAFBF0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: TabBarView(
            children: [
              for (final d in dias)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _DayCard(
                    titulo: d.titulo,
                    contenidoBuilder: () {
                      final (contenido, advert) = _splitAdvertencias(d.contenido);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionCard(
                            icon: Icons.fitness_center,
                            title: 'Plan del día',
                            children: _buildBulleted(contenido),
                          ),
                          if (advert.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _WarningCard(text: advert),
                          ],
                        ],
                      );
                    }(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// WIDGETS DE PRESENTACIÓN 

class _StylishTabs extends StatelessWidget {
  final List<_DiaPlan> dias;
  const _StylishTabs({required this.dias});

  @override
  Widget build(BuildContext context) {
    final tabs = [for (final d in dias) Tab(text: d.titulo)];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        isScrollable: true,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
        ),
        labelColor: const Color(0xFF0B7A55),
        unselectedLabelColor: Colors.white,
        tabs: tabs,
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String titulo;
  final Widget contenidoBuilder;
  const _DayCard({required this.titulo, required this.contenidoBuilder});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today_rounded),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                contenidoBuilder,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ]),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final String text;
  const _WarningCard({required this.text});

  @override
  Widget build(BuildContext context) {
    // Quitar el ** de los títulos si vienen en markdown
    final clean = text.replaceAll('**', '');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD7A8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              clean,
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaPlan {
  final String titulo;
  final String contenido;
  _DiaPlan({required this.titulo, required this.contenido});
}
