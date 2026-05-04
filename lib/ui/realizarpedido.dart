import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 
import 'package:apppeydar/ui/resumenPedido.dart';

class RealizarPedidoPage extends StatefulWidget {
  const RealizarPedidoPage({super.key});

  @override
  State<RealizarPedidoPage> createState() => _RealizarPedidoPageState();
}

class _RealizarPedidoPageState extends State<RealizarPedidoPage> {
  late String clienteName;
  int? usuarioId;

  // 1. VARIABLES DE ESTADO PARA CONTADORES
  int recargaAzul = 0;
  int recargaCeleste = 0;
  int compraAzul = 0;
  int compraCeleste = 0;

  // 2. CONTROLADORES PARA CAPTURAR TEXTO
  final TextEditingController _dirController = TextEditingController();
  final TextEditingController _telController = TextEditingController();

  @override
  void initState() {
    super.initState();
    clienteName = 'Cliente';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    clienteName = args?['nombre'] ?? 'Cliente';
    usuarioId = args?['id'] ?? args?['usuario_id']; // Obtenemos el ID del usuario para la DB
  }

  // 3. NAVEGACIÓN AL RESUMEN DEL PEDIDO
  void _abrirResumenPedido() {
    if (_dirController.text.isEmpty || _telController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa la dirección y el teléfono")),
      );
      return;
    }

    final List<Map<String, dynamic>> productos = [];
    if (recargaAzul > 0) productos.add({'tipo': 'Recarga', 'color': 'Azul', 'cantidad': recargaAzul});
    if (recargaCeleste > 0) productos.add({'tipo': 'Recarga', 'color': 'Celeste', 'cantidad': recargaCeleste});
    if (compraAzul > 0) productos.add({'tipo': 'Compra', 'color': 'Azul', 'cantidad': compraAzul});
    if (compraCeleste > 0) productos.add({'tipo': 'Compra', 'color': 'Celeste', 'cantidad': compraCeleste});

    if (productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona al menos un bidón")),
      );
      return;
    }

    if (usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se ha podido identificar al usuario. Vuelve a iniciar sesión.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResumenPedidoScreen(
          usuarioId: usuarioId!,
          clienteName: clienteName,
          direccion: _dirController.text,
          telefono: _telController.text,
          detalles: productos,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Realizar pedido para $clienteName', 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF002855))),
            const Text('Hidratación directo a tu puerta.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            
            // Sección de Recargas
            _buildSectionCard(
              title: 'Recarga de Bidones',
              tag: 'ECONÓMICO',
              icon: Icons.refresh,
              isHighlight: true,
              subtitle: 'Intercambia tus envases vacíos de 20L.',
              children: [
                _buildCounterItem('Bidón Azul', recargaAzul, (val) => setState(() => recargaAzul = val)),
                _buildCounterItem('Bidón Celeste', recargaCeleste, (val) => setState(() => recargaCeleste = val)),
              ],
            ),
            const SizedBox(height: 20),
            
            // Sección de Compras
            _buildSectionCard(
              title: 'Compra de Bidones',
              tag: 'NUEVO',
              icon: Icons.verified_user_outlined,
              isHighlight: true,
              subtitle: 'Incluye el envase de 20L nuevo + agua.',
              children: [
                _buildCounterItem('Bidón Azul', compraAzul, (val) => setState(() => compraAzul = val)),
                _buildCounterItem('Bidón Celeste', compraCeleste, (val) => setState(() => compraCeleste = val)),
              ],
            ),
            const SizedBox(height: 25),
            
            _buildDeliveryInfo(),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _abrirResumenPedido,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003DA5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Ver resumen', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES DE UI ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const CircleAvatar(
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(Icons.arrow_back, color: Color(0xFF003DA5), size: 18),
          ),
        ),
      ),
      title: const Text('PEYDAR', style: TextStyle(color: Color(0xFF003DA5), fontWeight: FontWeight.bold)),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Color(0xFF002855)))],
    );
  }

  Widget _buildSectionCard({required String title, required String tag, required IconData icon, required String subtitle, required List<Widget> children, bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isHighlight ? Border.all(color: Colors.blue.shade200, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(icon, color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCounterItem(String name, int cantidad, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Container(width: 4, height: 20, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
              onPressed: () { if (cantidad > 0) onChanged(cantidad - 1); },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('$cantidad', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF002855)),
              onPressed: () => onChanged(cantidad + 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping, color: Color(0xFF002855)),
              SizedBox(width: 10),
              Text('Información de Entrega', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 15),
          _buildSmallField('DIRECCIÓN DE ENTREGA', 'Calle, número, departamento', Icons.location_on, _dirController),
          const SizedBox(height: 8),
          const SizedBox(height: 15),
          _buildSmallField('NÚMERO DE TELÉFONO', '+51', Icons.phone, _telController, digitsOnly: true, maxLength: 9),
        ],
      ),
    );
  }

  Widget _buildSmallField(String label, String hint, IconData icon, TextEditingController controller, {bool digitsOnly = false, int? maxLength}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: digitsOnly ? TextInputType.number : TextInputType.text,
          inputFormatters: (digitsOnly || maxLength != null)
              ? <TextInputFormatter>[
                  if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
                  if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
                ]
              : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            hintText: hint,
            filled: true,
            fillColor: Colors.white70,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
      ],
    );
  }
}