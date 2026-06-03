class AdminEstablishmentEntry {
  final String  id;
  final String  name;
  final String? photoUrl;
  final String  ownerName;
  final double  creditBalance;

  const AdminEstablishmentEntry({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.ownerName,
    required this.creditBalance,
  });

  factory AdminEstablishmentEntry.fromJson(Map<String, dynamic> json) {
    final ownerMap = json['profiles'] as Map<String, dynamic>?;
    final creditMap = json['ad_credits'];
    double balance = 0.0;
    if (creditMap is Map<String, dynamic>) {
      balance = (creditMap['balance_mxn'] as num?)?.toDouble() ?? 0.0;
    } else if (creditMap is List && (creditMap as List).isNotEmpty) {
      balance = ((creditMap.first as Map<String, dynamic>)['balance_mxn'] as num?)?.toDouble() ?? 0.0;
    }
    return AdminEstablishmentEntry(
      id:            json['id']        as String,
      name:          json['name']      as String,
      photoUrl:      json['photo_url'] as String?,
      ownerName:     (ownerMap?['full_name'] as String?) ?? 'Sin nombre',
      creditBalance: balance,
    );
  }
}
