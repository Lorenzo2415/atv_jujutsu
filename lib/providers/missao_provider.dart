import 'package:flutter/foundation.dart';
import '../models/missao.dart';
import '../services/missao_service.dart';

class MissaoProvider extends ChangeNotifier {
  MissaoProvider(this._service);

  final MissaoService _service;

  Stream<List<Missao>> missoesDoUsuario(String uid) =>
      _service.listarMissoesDoUsuario(uid);

  Future<void> cadastrar({
    required String titulo,
    required int grau,
    required String usuarioId,
  }) {
    final missao = Missao(
      titulo: titulo.trim(),
      grau: grau,
      concluida: false,
      usuarioId: usuarioId,
    );
    return _service.cadastrar(missao);
  }

  Future<void> marcarConcluida(Missao missao, bool concluida) =>
      _service.atualizarConclusao(missao, concluida);

  Future<void> excluir(Missao missao) => _service.excluir(missao);
}
