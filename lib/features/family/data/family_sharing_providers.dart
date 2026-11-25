import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/family_member.dart';
import '../domain/family_sharing_repository.dart';

final familySharingRepositoryProvider = Provider<FamilySharingRepository>(
  (ref) => _UnavailableFamilySharingRepository(),
);

final familyMembersProvider =
    StreamProvider.autoDispose<List<FamilyMember>>((ref) {
  return ref.watch(familySharingRepositoryProvider).watchFamilyMembers();
});

class _UnavailableFamilySharingRepository implements FamilySharingRepository {
  @override
  Stream<List<FamilyMember>> watchFamilyMembers() => Stream.value([]);

  @override
  Future<void> inviteFamilyMember(String contact) async {
    throw UnsupportedError('Undangan keluarga belum tersedia.');
  }

  @override
  Future<void> setAlertNotifications(String memberId, bool enabled) async {
    throw UnsupportedError('Pengaturan berbagi belum tersedia.');
  }

  @override
  Future<void> stopSharing() async {
    throw UnsupportedError('Berbagi data belum tersedia.');
  }
}
