import 'package:flutter/material.dart';

void main() {
  runApp(const PeydarApp());
}

class PeydarApp extends StatelessWidget {
  const PeydarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'sans-serif'),
      home: const RegistrarUsuarioScreen(),
    );
  }
}

class RegistrarUsuarioScreen extends StatefulWidget {
  const RegistrarUsuarioScreen({super.key});

  @override
  State<RegistrarUsuarioScreen> createState() => _RegistrarUsuarioScreenState();
}

class _RegistrarUsuarioScreenState extends State<RegistrarUsuarioScreen> {
  bool _obscureText = true;

  // Colores de marca PEYDAR
  final Color primaryBlue = const Color(0xFF003DA5);
  final Color backgroundGrey = const Color(0xFFF8FAFC);
  final Color inputGrey = const Color(0xFFE9E9E9);
  final Color textNavy = const Color(0xFF002855);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () {},
        ),
        title: Text(
          'Crear Cliente',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFD6E4FF),
              child: Text('AU', style: TextStyle(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // FORMULARIO DE REGISTRO
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registrar Usuario', 
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textNavy)),
                    const SizedBox(height: 8),
                    const Text('Ingrese los datos para habilitar el acceso al nuevo cliente.', 
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 24),
                    
                    _buildFieldLabel('Nombres y Apellidos'),
                    _buildTextField(hint: 'Ej. Juan Pérez'),
                    const SizedBox(height: 16),
                    
                    _buildFieldLabel('Número de Celular'),
                    _buildTextField(hint: '+51 987 654 321', keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    
                    _buildFieldLabel('Usuario (DNI)'),
                    _buildTextField(hint: 'Número de identificación'),
                    const SizedBox(height: 16),
                    
                    _buildFieldLabel('Contraseña'),
                    _buildPasswordField(),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: const Text('Crear Cuenta de Cliente', 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SECCIÓN: TIP DE GESTIÓN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  // Borde lateral turquesa característico
                  border: const Border(left: BorderSide(color: Color(0xFF009688), width: 5)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Color(0xFF00796B), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'TIP DE GESTIÓN', 
                          style: TextStyle(
                            color: const Color(0xFF00796B), 
                            fontWeight: FontWeight.bold, 
                            fontSize: 12,
                            letterSpacing: 0.5,
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '"Asegúrese de que el número de celular sea correcto para garantizar la entrega de recordatorios de recarga."',
                      style: TextStyle(
                        fontStyle: FontStyle.italic, 
                        color: Color(0xFF455A64),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widgets auxiliares para mantener el código limpio
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: textNavy, fontSize: 14)),
    );
  }

  Widget _buildTextField({required String hint, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: inputGrey, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(color: inputGrey, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        obscureText: _obscureText,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: '********',
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 20),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}