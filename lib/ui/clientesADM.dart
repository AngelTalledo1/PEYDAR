import 'package:flutter/material.dart';
import 'package:apppeydar/ui/admCrearusuario.dart';
import 'package:apppeydar/ui/detalleCliente.dart';
import 'package:apppeydar/services/user_service.dart';

class DirectorioClientesScreen extends StatefulWidget {
  const DirectorioClientesScreen({super.key});

  @override
  State<DirectorioClientesScreen> createState() =>
      _DirectorioClientesScreenState();
}

class _DirectorioClientesScreenState
    extends State<DirectorioClientesScreen> {
  final Color primaryBlue    = const Color(0xFF003DA5);
  final Color backgroundGrey = const Color(0xFFF8FAFC);
  final Color textNavy       = const Color(0xFF002855);

  bool _loading = true;
  List<Map<String, dynamic>> _clientes = [];
  String _filter = 'ACTIVOS'; // ACTIVOS | INACTIVOS | TODOS
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchClientes();
  }

  Future<void> _fetchClientes() async {
    setState(() => _loading = true);
    try {
      final list = await UserService.obtenerClientes();
      setState(() => _clientes = list);
    } catch (e) {
      setState(() => _clientes = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  // ─── Desactivar cliente ──────────────────────────────────────────────────
  Future<void> _desactivarCliente(Map<String, dynamic> cliente) async {
    final dni = (cliente['dni'] ?? cliente['usuario'] ?? cliente['usuario_id'])?.toString();
    if (dni == null || dni.isEmpty) return;

    final nombre = '${cliente['nombre'] ?? ''} ${cliente['apellido'] ?? ''}'.trim();

    final ok = await showDialog<bool?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desactivar cliente'),
        content: Text(
            '¿Deseas desactivar a ${nombre.isNotEmpty ? nombre : 'este cliente'}? Su cuenta quedará inactiva.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Desactivar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await UserService.desactivarCliente(dni: dni);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente desactivado correctamente')));
        await _fetchClientes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al desactivar: ${e.toString()}')));
      }
    }
  }

  Future<void> _activarCliente(Map<String, dynamic> cliente) async {
    final dni = (cliente['dni'] ?? cliente['usuario'] ?? cliente['usuario_id'])?.toString();
    if (dni == null || dni.isEmpty) return;

    final ok = await showDialog<bool?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Activar cliente'),
        content: const Text('¿Deseas activar nuevamente a este cliente? El cliente podrá ingresar a la app.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Activar')),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await UserService.activarCliente(dni: dni);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente activado correctamente')));
        await _fetchClientes();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al activar: ${e.toString()}')));
    }
  }

  // ─── Navegar a editar ────────────────────────────────────────────────────
  Future<void> _editarCliente(Map<String, dynamic> cliente) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegistrarUsuarioScreen(clienteEditar: cliente),
      ),
    );
    if (result == true) await _fetchClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Clientes',
            style: TextStyle(
                color: textNavy, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Builder(builder: (ctx) {
              final args = ModalRoute.of(ctx)?.settings.arguments
                  as Map<String, dynamic>?;
              final nombreRaw = (args?['nombre'] ?? '') as String? ?? '';
              String initials = 'AP';
              try {
                final parts =
                    nombreRaw.split(' ').where((s) => s.isNotEmpty).toList();
                final a = parts.isNotEmpty ? parts[0][0] : '';
                final b = parts.length > 1 ? parts[1][0] : '';
                final combo = '$a$b'.toUpperCase();
                if (combo.trim().isNotEmpty) initials = combo;
              } catch (_) {}
              return CircleAvatar(
                backgroundColor: primaryBlue,
                child: Text(initials,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              );
            }),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchClientes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Directorio de Clientes',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textNavy)),
              const Text(
                  'Gestiona la base de datos de consumidores activos.',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // ── Botón NUEVO CLIENTE ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Sin clienteEditar → campos vacíos, título "Nuevo Cliente"
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const RegistrarUsuarioScreen(clienteEditar: null),
                      ),
                    );
                    if (result == true) await _fetchClientes();
                  },
                  icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                  label: const Text('Nuevo Cliente',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // ── Buscador ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o DNI...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF1F4F8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // ── Filtros: Activos / Inactivos / Todos ─────────────────
              Row(
                children: [
                  _filterButton('ACTIVOS'),
                  const SizedBox(width: 8),
                  _filterButton('INACTIVOS'),
                  const SizedBox(width: 8),
                  _filterButton('TODOS'),
                ],
              ),
              const SizedBox(height: 16),

              // ── Lista ────────────────────────────────────────────────────
              _buildCustomerList(),
              const SizedBox(height: 25),

              // ── Métrica ──────────────────────────────────────────────────
              _buildStatCard(
                title: 'TOTAL CLIENTES',
                value: _visibleCount().toString(),
                subtitle: '+0% este mes',
                color: primaryBlue,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Lista de clientes ───────────────────────────────────────────────────
  Widget _buildCustomerList() {
    if (_loading) {
      return Container(
          height: 240,
          alignment: Alignment.center,
          child: const CircularProgressIndicator());
    }
    if (_clientes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: const Center(
            child: Text('No se encontraron clientes',
                style: TextStyle(color: Colors.grey))),
      );
    }

    // aplicar filtro y búsqueda localmente
    final q = _searchQuery.toString().toLowerCase();
    final filtered = _clientes.where((c) {
      final est = (c['estado'] ?? 'ACTIVO').toString().toUpperCase();
      if (_filter == 'ACTIVOS' && est != 'ACTIVO') return false;
      if (_filter == 'INACTIVOS' && est == 'ACTIVO') return false;

      if (q.isEmpty) return true;

      final nombre = '${c['nombre'] ?? ''} ${c['apellido'] ?? ''}'.toString().toLowerCase();
      final dni = (c['dni'] ?? c['usuario'] ?? c['usuario_id'] ?? '').toString().toLowerCase();
      return nombre.contains(q) || dni.contains(q);
    }).toList();

    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          // Encabezado
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                Expanded(
                  child: Text('CLIENTE',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                ),
                Text('EDITAR',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = filtered[i];
              final nombre   = (c['nombre']   ?? '').toString();
              final apellido = (c['apellido'] ?? '').toString();
              final displayName =
                  (nombre.isNotEmpty || apellido.isNotEmpty)
                      ? '$nombre $apellido'.trim()
                      : 'Cliente ${c['dni'] ?? c['usuario_id'] ?? ''}';
                final initials = displayName
                  .split(' ')
                  .map((s) => s.isNotEmpty ? s[0] : '')
                  .take(2)
                  .join()
                  .toUpperCase();

                final est = (c['estado'] ?? 'ACTIVO').toString().toUpperCase();

              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE3F2FD),
                      child: Text(initials,
                          style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                    const SizedBox(width: 12),

                    // Nombre + último pedido (toca para ver perfil)
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PerfilClienteInfoScreen(cliente: c),
                            ),
                          );
                          if (result == true) await _fetchClientes();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              'Último pedido: ${c['last_order'] ?? '-'}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Botones EDITAR / DESACTIVAR
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Editar
                        GestureDetector(
                          onTap: () => _editarCliente(c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 13, color: primaryBlue),
                                const SizedBox(width: 3),
                                Text('Editar',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: primaryBlue,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Activar o Desactivar según estado
                        est == 'ACTIVO'
                            ? GestureDetector(
                                onTap: () => _desactivarCliente(c),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.block_outlined, size: 13, color: Colors.red),
                                      SizedBox(width: 3),
                                      Text('Desactivar', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () => _activarCliente(c),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_outline, size: 13, color: Colors.green.shade700),
                                      const SizedBox(width: 3),
                                      Text('Activar', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Text('Mostrando ${_visibleCount()} clientes',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
        ],
      ),
    );
  }

  int _visibleCount() {
    if (_filter == 'ACTIVOS') {
      return _clientes.where((c) {
        final est = (c['estado'] ?? 'ACTIVO').toString().toUpperCase();
        return est == 'ACTIVO';
      }).length;
    }
    if (_filter == 'INACTIVOS') {
      return _clientes.where((c) {
        final est = (c['estado'] ?? 'ACTIVO').toString().toUpperCase();
        return est != 'ACTIVO';
      }).length;
    }
    return _clientes.length;
  }

  Widget _filterButton(String key) {
    final selected = _filter == key;
    final label = key == 'ACTIVOS' ? 'Activos' : (key == 'INACTIVOS' ? 'Inactivos' : 'Todos');
    return ElevatedButton(
      onPressed: () => setState(() => _filter = key),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? primaryBlue : Colors.white,
        elevation: 0,
        side: BorderSide(color: selected ? primaryBlue : Colors.grey.shade300),
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : textNavy, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Text(subtitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping), label: 'PEDIDOS'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people), label: 'CLIENTES'),
        BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), label: 'REPORTES'),
      ],
    );
  }
}