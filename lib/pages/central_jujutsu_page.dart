import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/missao.dart';
import '../providers/auth_provider.dart';
import '../providers/missao_provider.dart';
import '../services/missao_service.dart';

class CentralJujutsuPage extends StatelessWidget {
  const CentralJujutsuPage({super.key});

  Future<void> _mostrarCadastro(BuildContext context, String uid) async {
    final tituloController = TextEditingController();
    int grau = 1;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Nova missão'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tituloController,
                  autofocus: true,
                  decoration:
                      const InputDecoration(labelText: 'Título da missão'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Digite um título'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: grau,
                  decoration: const InputDecoration(labelText: 'Grau'),
                  items: List.generate(4, (i) => i + 1)
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text('Grau $value'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => grau = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await context.read<MissaoProvider>().cadastrar(
                        titulo: tituloController.text,
                        grau: grau,
                        usuarioId: uid,
                      );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Não foi possível cadastrar: $e')),
                    );
                  }
                }
              },
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
    tituloController.dispose();
  }

  Future<bool> _confirmarExclusao(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Excluir missão?'),
            content: const Text('Essa ação não pode ser desfeita.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    return ChangeNotifierProvider(
      create: (_) => MissaoProvider(MissaoService()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Central Jujutsu',
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                tooltip: 'Sair da conta',
                onPressed: () => context.read<AuthProvider>().signOut(),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _mostrarCadastro(context, user.uid),
            icon: const Icon(Icons.add),
            label: const Text('Nova missão'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                _PerfilCard(user: user),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('MISSÕES REGISTRADAS',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFFA78BFA))),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Missao>>(
                    stream: context
                        .read<MissaoProvider>()
                        .missoesDoUsuario(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text(
                                'Erro ao carregar missões. Verifique o Firebase.'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final missoes = snapshot.data!;
                      if (missoes.isEmpty) {
                        return const _EstadoVazio();
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: missoes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final missao = missoes[index];
                          return _MissaoCard(
                            missao: missao,
                            onConcluir: (value) => context
                                .read<MissaoProvider>()
                                .marcarConcluida(missao, value),
                            onExcluir: () async {
                              if (await _confirmarExclusao(context) &&
                                  context.mounted) {
                                await context
                                    .read<MissaoProvider>()
                                    .excluir(missao);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PerfilCard extends StatelessWidget {
  const _PerfilCard({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF33205D), Color(0xFF1E1E30)],
        ),
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: const Color(0xFF6D4BC3).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bem-vindo,',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 3),
                Text(user.displayName ?? 'Feiticeiro',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user.email ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissaoCard extends StatelessWidget {
  const _MissaoCard({
    required this.missao,
    required this.onConcluir,
    required this.onExcluir,
  });

  final Missao missao;
  final ValueChanged<bool> onConcluir;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1B1B28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: missao.concluida,
              onChanged: (value) => onConcluir(value ?? false),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    missao.titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: missao.concluida
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: missao.concluida ? Colors.white54 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                      'Grau ${missao.grau} • ${missao.concluida ? 'Concluída' : 'Pendente'}',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Excluir missão',
              onPressed: onExcluir,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome,
                size: 54,
                color: const Color(0xFFA78BFA).withValues(alpha: 0.8)),
            const SizedBox(height: 16),
            const Text('Nenhuma missão por enquanto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Cadastre sua primeira missão e comece a investigação.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}
