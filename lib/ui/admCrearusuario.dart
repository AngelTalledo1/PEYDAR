import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apppeydar/services/user_service.dart';

class RegistrarUsuarioScreen extends StatefulWidget {
  /// Si se pasa [clienteEditar], la pantalla entra en modo edición con los campos prellenados.
  /// Si es null, la pantalla entra en modo creación con campos vacíos.
  final Map<String, dynamic>? clienteEditar;
  const RegistrarUsuarioScreen({super.key, this.clienteEditar});

  @override
  State<RegistrarUsuarioScreen> createState() => _RegistrarUsuarioScreenState();
}

class _RegistrarUsuarioScreenState extends State<RegistrarUsuarioScreen> {
  bool _obscureText = true;
  bool _isSaving = false;

  // Modo edición si se pasó un cliente
  bool get _isEditing => widget.clienteEditar != null;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreCtrl    = TextEditingController();
  final TextEditingController _apellidoCtrl  = TextEditingController();
  final TextEditingController _telefonoCtrl  = TextEditingController();
  final TextEditingController _usuarioCtrl   = TextEditingController();
  final TextEditingController _passwordCtrl  = TextEditingController();
  final TextEditingController _gmailCtrl     = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();

  final Color primaryBlue   = const Color(0xFF003DA5);
  final Color backgroundGrey = const Color(0xFFF8FAFC);
  final Color inputGrey     = const Color(0xFFE9E9E9);
  final Color textNavy      = const Color(0xFF002855);

  @override
  void initState() {
    super.initState();
    // Si hay cliente, prellenar campos
    final edit = widget.clienteEditar;
    if (edit != null) {
      _nombreCtrl.text    = (edit['nombre']    ?? '').toString();
      _apellidoCtrl.text  = (edit['apellido']  ?? '').toString();
      _telefonoCtrl.text  = (edit['telefono']  ?? '').toString();
      _usuarioCtrl.text   = (edit['dni']       ?? edit['usuario'] ?? '').toString();
      _gmailCtrl.text     = (edit['gmail']     ?? '').toString();
      _direccionCtrl.text = (edit['direccion'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telefonoCtrl.dispose();
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    _gmailCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
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
        title: Text(
          _isEditing ? 'Editar Cliente' : 'Nuevo Cliente',
          style: TextStyle(
              color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02), blurRadius: 10)
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Editar Usuario' : 'Registrar Usuario',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textNavy),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEditing
                            ? 'Modifique los datos del cliente y guarde los cambios.'
                            : 'Ingrese los datos para habilitar el acceso al nuevo cliente.',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 24),

                      _buildFieldLabel('Nombres'),
                      _buildTextField(controller: _nombreCtrl, hint: 'Ej. Juan'),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Apellidos'),
                      _buildTextField(controller: _apellidoCtrl, hint: 'Ej. Pérez'),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Número de Celular'),
                          _buildTextField(
                            controller: _telefonoCtrl,
                            hint: '987654321',
                            keyboardType: TextInputType.number,
                            digitsOnly: true,
                            maxLength: 9),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Usuario (DNI)'),
                          _buildTextField(
                            controller: _usuarioCtrl,
                            hint: 'Número de identificación',
                            // En edición el DNI no se cambia
                            enabled: !_isEditing,
                            keyboardType: TextInputType.number,
                            digitsOnly: true,
                            maxLength: 8),
                      const SizedBox(height: 16),

                      _buildFieldLabel(
                          _isEditing ? 'Nueva Contraseña (dejar vacío para no cambiar)' : 'Contraseña'),
                      _buildPasswordField(),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Gmail (opcional)'),
                      _buildTextField(
                          controller: _gmailCtrl,
                          hint: 'correo@ejemplo.com',
                          required: false),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Dirección (opcional)'),
                      _buildTextField(
                          controller: _direccionCtrl,
                          hint: 'Dirección de entrega',
                          required: false),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleGuardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  _isEditing
                                      ? 'Guardar Cambios'
                                      : 'Crear Cuenta de Cliente',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // TIP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                      left: BorderSide(color: Color(0xFF009688), width: 5)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.01), blurRadius: 5)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.water_drop, color: Color(0xFF00796B), size: 18),
                        SizedBox(width: 8),
                        Text('TIP DE GESTIÓN',
                            style: TextStyle(
                                color: Color(0xFF00796B),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '"Asegúrese de que el número de celular sea correcto para garantizar la entrega de recordatorios de recarga."',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF455A64),
                          fontSize: 14,
                          height: 1.4),
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

  // ─── Widgets auxiliares ───────────────────────────────────────────────────

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: textNavy, fontSize: 14)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
    bool enabled = true,
    bool digitsOnly = false,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: enabled ? inputGrey : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: (digitsOnly || maxLength != null)
            ? <TextInputFormatter>[
                if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
                if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
              ]
            : null,
        enabled: enabled,
        validator: (v) {
          if (!required) return null;
          if (v == null || v.trim().isEmpty) return 'Campo requerido';
          return null;
        },
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
          color: inputGrey, borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
        controller: _passwordCtrl,
        obscureText: _obscureText,
        validator: (v) {
          // En edición la contraseña es opcional
          if (_isEditing) return null;
          if (v == null || v.trim().length < 4) {
            return 'La contraseña debe tener al menos 4 caracteres';
          }
          return null;
        },
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: '********',
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
                size: 20),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // ─── Lógica guardar ──────────────────────────────────────────────────────

  Future<void> _handleGuardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre    = _nombreCtrl.text.trim();
    final apellido  = _apellidoCtrl.text.trim();
    final telefono  = _telefonoCtrl.text.trim();
    final usuario   = _usuarioCtrl.text.trim();
    final password  = _passwordCtrl.text.trim();
    final gmail     = _gmailCtrl.text.trim().isEmpty ? null : _gmailCtrl.text.trim();
    final direccion = _direccionCtrl.text.trim().isEmpty ? null : _direccionCtrl.text.trim();

    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        // ── MODO EDICIÓN ──
        final usuarioId = widget.clienteEditar!['usuario_id'];
        final res = await UserService.editarCliente(
          usuarioId: usuarioId,
          nombre: nombre,
          apellido: apellido,
          telefono: telefono,
          gmail: gmail,
          direccion: direccion,
        );
        final success = res['status'] == 'success' || res['success'] == true;
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cliente actualizado correctamente')));
          Navigator.of(context).pop(true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res['message']?.toString() ?? 'No se pudo actualizar')));
        }
      } else {
        // ── MODO CREACIÓN ──
        final res = await UserService.crearCliente(
          usuario: usuario,
          nombre: nombre,
          apellido: apellido,
          telefono: telefono,
          password: password,
          gmail: gmail,
          direccion: direccion,
        );
        final success = res['status'] == 'success' || res['success'] == true;
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cliente creado con éxito')));
          Navigator.of(context).pop(true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res['message']?.toString() ?? 'No se pudo crear el cliente')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}