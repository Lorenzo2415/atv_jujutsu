import 'package:cloud_firestore/cloud_firestore.dart';

class Missao {
  const Missao({
    this.id,
    required this.titulo,
    required this.grau,
    required this.concluida,
    required this.usuarioId,
  });

  final String? id;
  final String titulo;
  final int grau;
  final bool concluida;
  final String usuarioId;

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'grau': grau,
        'concluida': concluida,
        'usuarioId': usuarioId,
      };

  factory Missao.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    return Missao(
      id: document.id,
      titulo: data['titulo'] as String? ?? '',
      grau: (data['grau'] as num?)?.toInt() ?? 1,
      concluida: data['concluida'] as bool? ?? false,
      usuarioId: data['usuarioId'] as String? ?? '',
    );
  }
}
