import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/missao.dart';

class MissaoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _missoes =>
      _firestore.collection('missoes');

  Stream<List<Missao>> listarMissoesDoUsuario(String usuarioId) {
    return _missoes
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((document) => Missao.fromDocument(document))
            .toList());
  }

  Future<void> cadastrar(Missao missao) async {
    await _missoes.add(missao.toMap());
  }

  Future<void> atualizarConclusao(Missao missao, bool concluida) async {
    if (missao.id == null) return;
    await _missoes.doc(missao.id).update({'concluida': concluida});
  }

  Future<void> excluir(Missao missao) async {
    if (missao.id == null) return;
    await _missoes.doc(missao.id).delete();
  }
}
