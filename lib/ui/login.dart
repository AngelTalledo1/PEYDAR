import 'package:flutter/material.dart';
import 'package:apppeydar/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Lógica de estado funcional
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Función de Login vinculada a tu backend en cPanel
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.login(username, password);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      final String rol = result['rol'];
      final String nombre = result['nombre'];
      final int id = result['id'];

      // Navegación automática según el rol de la base de datos
      if (rol == 'administrador') {
        Navigator.pushReplacementNamed(
          context,
          '/admin',
          arguments: {'nombre': nombre, 'id': id},
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/cliente',
          arguments: {'nombre': nombre, 'id': id},
        );
      }
    } else {
      _showError(result['message'] ?? 'Usuario o contraseña incorrectos');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fondo degradado que cubre toda la pantalla
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCEE2EF), Color(0xFFC4D0E1)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildBrand(),
                  const SizedBox(height: 28),
                  _buildLoginPanel(),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 42,
          backgroundColor: Color(0xFF003A93),
          child: Icon(Icons.water_drop_rounded, color: Colors.white, size: 44),
        ),
        SizedBox(height: 20),
        Text(
          'PEYDAR',
          style: TextStyle(
            fontSize: 30, // 45 * 0.66 aprox
            fontWeight: FontWeight.w700,
            color: Color(0xFF003A93),
            letterSpacing: -0.6,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'AGUA PURIFICADA',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3342),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A1C2737),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Bienvenido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF10141C),
              ),
            ),
          ),
          const SizedBox(height: 35),
          const Text(
            'USUARIO',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF394053),
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 12),
          _InputContainer(
            child: Row(
              children: [
                const Icon(Icons.person_rounded, color: Color(0xFF6E7483), size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Ingrese su usuario',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Color(0xFF727989),
                        fontSize: 15,
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'PASSWORD',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF394053),
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 12),
          _InputContainer(
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, color: Color(0xFF6E7483), size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: const InputDecoration(
                      hintText: '••••••••',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Color(0xFF727989),
                        fontSize: 15,
                        letterSpacing: 2,
                      ),
                    ),
                    onSubmitted: (_) => _handleLogin(),
                  ),
                ),
                IconButton(
                  splashRadius: 22,
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: const Color(0xFF727989),
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Botón con lógica de carga (Loading)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                backgroundColor: const Color(0xFF073F9E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ingresar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 14),
                        Icon(Icons.arrow_forward, size: 24),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 26),
          Container(height: 1.6, color: const Color(0xFFD2D7DF)),
        ],
      ),
    );
  }
}

class _InputContainer extends StatelessWidget {
  const _InputContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFD8DBE0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}