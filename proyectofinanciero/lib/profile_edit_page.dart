import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl.text = user?.displayName ?? '';
    _emailCtrl.text = user?.email ?? '';

    // Intentar traer nombre de Firestore si existe
    try {
      final uid = user?.uid;
      if (uid != null) {
        final snap = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .get();
        final data = snap.data();
        if (data != null) {
          final nombre = (data['nombre_usua'] ?? '') as String;
          if (nombre.isNotEmpty) {
            _nameCtrl.text = nombre;
          }
          final correo = (data['correo_usua'] ?? '') as String;
          if (correo.isNotEmpty) {
            _emailCtrl.text = correo;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('No se pudo cargar perfil Firestore: $e');
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 2) {
                    return 'Ingresa al menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa un correo';
                  final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!re.hasMatch(v.trim())) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              ElevatedButton(
                onPressed: _loading ? null : _onSave,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'No hay usuario autenticado';
      });
      return;
    }

    try {
      final newName = _nameCtrl.text.trim();
      final newEmail = _emailCtrl.text.trim();

      // 1) Actualizar displayName
      if (newName.isNotEmpty && newName != (user.displayName ?? '')) {
        await user.updateDisplayName(newName);
      }

      // 2) Actualizar email (en firebase_auth 6.x usar verifyBeforeUpdateEmail)
      if (newEmail.isNotEmpty && newEmail != (user.email ?? '')) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      // 3) Persistir en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({
            'nombre_usua': newName,
            'correo_usua': newEmail,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // 4) Recargar y volver. Si el correo cambió, puede requerir verificación.
      await user.reload();
      if (!mounted) return;
      if (newEmail != (user.email ?? '')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Revisa tu correo para confirmar el cambio de email.',
            ),
          ),
        );
      }
      Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode)
        debugPrint('Profile update error: ${e.code} ${e.message}');
      setState(() {
        _error = _mapAuthError(e);
      });
    } catch (e) {
      setState(() {
        _error = 'Error inesperado: $e';
      });
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'requires-recent-login':
        return 'Por seguridad, vuelve a iniciar sesión para cambiar tu correo.';
      case 'email-already-in-use':
        return 'Ese correo ya está en uso.';
      case 'invalid-email':
        return 'Correo inválido.';
      case 'network-request-failed':
        return 'Sin conexión. Intenta nuevamente.';
      default:
        return e.message ?? 'Error: ${e.code}';
    }
  }
}
