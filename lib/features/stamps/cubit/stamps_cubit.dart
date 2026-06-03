import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/loyalty_repository.dart';
import 'stamps_state.dart';

class StampsCubit extends Cubit<StampsState> {
  final LoyaltyRepository _repo;
  final String            _userId;

  StampsCubit({
    required LoyaltyRepository repository,
    required String userId,
  })  : _repo   = repository,
        _userId = userId,
        super(StampsInitial());

  Future<void> load() async {
    emit(StampsLoading());
    try {
      final cards = await _repo.getMyCards(_userId);
      emit(StampsLoaded(cards: cards));
    } catch (_) {
      emit(const StampsError('No se pudieron cargar tus tarjetas de sellos.'));
    }
  }

  Future<void> refresh() => load();
}
