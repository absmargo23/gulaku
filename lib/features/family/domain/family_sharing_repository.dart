import 'family_member.dart';

abstract interface class FamilySharingRepository {
  Stream<List<FamilyMember>> watchFamilyMembers();

  Future<void> inviteFamilyMember(String contact);

  Future<void> setAlertNotifications(String memberId, bool enabled);

  Future<void> stopSharing();
}
