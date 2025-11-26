import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyectofinanciero/blocs/theme/theme_bloc.dart';
import 'profile_edit_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 18),

          // Header
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20),
          //   child: Row(
          //     children: [
          //       InkWell(
          //         borderRadius: BorderRadius.circular(23),
          //         onTap: () async {
          //           final changed = await Navigator.of(context).push(
          //             MaterialPageRoute(
          //               builder: (_) => const ProfileEditPage(),
          //             ),
          //           );
          //           if (changed == true && mounted) setState(() {});
          //         },
          //         child: Container(
          //           width: 46,
          //           height: 46,
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             gradient: const LinearGradient(
          //               colors: [Color(0xFF00B2E7), Color(0xFFE064F7)],
          //               begin: Alignment.topLeft,
          //               end: Alignment.bottomRight,
          //             ),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black.withOpacity(0.06),
          //                 blurRadius: 6,
          //               ),
          //             ],
          //           ),
          //           child: const Center(
          //             child: CircleAvatar(
          //               backgroundColor: Colors.white,
          //               radius: 18,
          //               child: Icon(Icons.person, color: Color(0xFF00B2E7)),
          //             ),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 12),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           const Text(
          //             'Menú',
          //             style: TextStyle(fontSize: 12, color: Colors.black54),
          //           ),
          //           const SizedBox(height: 2),
          //           Text(
          //             user?.displayName ?? user?.email ?? 'Usuario',
          //             style: const TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ],
          //       ),
          //       const Spacer(),
          //       InkWell(
          //         borderRadius: BorderRadius.circular(10),
          //         onTap: () async {
          //           final changed = await Navigator.of(context).push(
          //             MaterialPageRoute(
          //               builder: (_) => const ProfileEditPage(),
          //             ),
          //           );
          //           if (changed == true && mounted) setState(() {});
          //         },
          //         child: Container(
          //           width: 36,
          //           height: 36,
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(10),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black.withOpacity(0.04),
          //                 blurRadius: 6,
          //               ),
          //             ],
          //           ),
          //           child: const Icon(
          //             Icons.settings,
          //             size: 18,
          //             color: Colors.black54,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 32),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Profile section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00B2E7), Color(0xFFE064F7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.displayName ?? 'Usuario',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Menu options
                  _buildMenuOption(
                    icon: Icons.person_outline,
                    title: 'Editar Perfil',
                    subtitle: 'Actualiza tu información personal',
                    onTap: () async {
                      final changed = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileEditPage(),
                        ),
                      );
                      if (changed == true && mounted) setState(() {});
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildMenuOption(
                    icon: Icons.notifications_none,
                    title: 'Notificaciones',
                    subtitle: 'Configura tus alertas',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función próximamente disponible'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildMenuOption(
                    icon: Icons.security_outlined,
                    title: 'Seguridad',
                    subtitle: 'Gestiona tu cuenta y privacidad',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función próximamente disponible'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Theme toggle option
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      return _buildMenuOption(
                        icon: state.themeMode == ThemeMode.dark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        title: state.themeMode == ThemeMode.dark
                            ? 'Modo Claro'
                            : 'Modo Oscuro',
                        subtitle: 'Cambia la apariencia de la app',
                        onTap: () {
                          context.read<ThemeBloc>().add(ToggleTheme());
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildMenuOption(
                    icon: Icons.help_outline,
                    title: 'Ayuda y Soporte',
                    subtitle: 'Obtén asistencia',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función próximamente disponible'),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // Logout button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF00B2E7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF00B2E7), size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.of(ctx).pop(); // Cerrar el diálogo
                  // Navegar al splash screen y limpiar toda la pila de navegación
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al cerrar sesión: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
