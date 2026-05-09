import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

/// Handles all Firestore + Firebase Storage sync.
/// Strategy: every local write pushes to Firestore.
/// On login, pull Firestore data and merge into local DB.
class CloudService {
  static final _db = FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static DocumentReference? get _userDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection("users").doc(uid);
  }

  // ── PROFILE ───────────────────────────────────────────────

  static Future<void> saveProfile(UserProfile profile) async {
    try {
      final doc = _userDoc;
      if (doc == null) return;
      await doc
          .set(profile.toMap(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  static Future<UserProfile?> fetchProfile() async {
    try {
      final uid = _uid;
      if (uid == null) return null;
      final doc = await _userDoc!.get().timeout(const Duration(seconds: 5));
      if (!doc.exists || doc.data() == null) return null;
      return UserProfile.fromMap(
          {...(doc.data() as Map<String, dynamic>), 'uid': uid});
    } catch (_) {
      return null;
    }
  }

  // ── PROFILE PHOTO ─────────────────────────────────────────
  // Firebase Storage requires Blaze plan — photo sync not available on Spark.
  // Photos are stored locally only. Cross-device photo sync is a future feature.

  static Future<String?> uploadProfilePhoto(String localPath) async => null;
  static Future<String?> downloadProfilePhoto(String url) async => null;

  // ── SETTINGS SYNC ─────────────────────────────────────────

  /// Push key settings to Firestore user document
  static Future<void> pushSettings(Map<String, String> settings) async {
    try {
      final doc = _userDoc;
      if (doc == null) return;
      await doc.set({'settings': settings}, SetOptions(merge: true)).timeout(
          const Duration(seconds: 5));
    } catch (_) {}
  }

  /// Pull settings from Firestore user document
  static Future<Map<String, String>> fetchSettings() async {
    try {
      final uid = _uid;
      if (uid == null) return {};
      final doc = await _userDoc!.get().timeout(const Duration(seconds: 5));
      if (!doc.exists || doc.data() == null) return {};
      final data = doc.data() as Map<String, dynamic>;
      final settings = data['settings'] as Map<String, dynamic>?;
      if (settings == null) return {};
      return settings.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  // ── GENERIC COLLECTION SYNC ───────────────────────────────

  static CollectionReference? _col(String name) {
    final doc = _userDoc;
    if (doc == null) return null;
    return doc.collection(name);
  }

  /// Push a single document to a Firestore collection.
  /// Uses the local SQLite id as the Firestore document ID for deduplication.
  static Future<void> pushDoc(
      String collection, Map<String, dynamic> data) async {
    try {
      final col = _col(collection);
      if (col == null) return;
      final id = data['id']?.toString();
      if (id != null) {
        await col
            .doc(id)
            .set(data, SetOptions(merge: true))
            .timeout(const Duration(seconds: 5));
      } else {
        await col.add(data).timeout(const Duration(seconds: 5));
      }
    } catch (_) {}
  }

  /// Delete a document from a Firestore collection by local id.
  static Future<void> deleteDoc(String collection, int id) async {
    try {
      final col = _col(collection);
      if (col == null) return;
      await col.doc(id.toString()).delete().timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  /// Fetch all documents from a Firestore collection.
  static Future<List<Map<String, dynamic>>> fetchCollection(
      String collection) async {
    try {
      final col = _col(collection);
      if (col == null) return [];
      final snap = await col.get().timeout(const Duration(seconds: 15));
      return snap.docs
          .map((d) =>
              {'firestore_doc_id': d.id, ...d.data() as Map<String, dynamic>})
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── FULL SYNC ON LOGIN ────────────────────────────────────

  /// Pull all data from Firestore and return it for merging into local DB.
  /// Called once after login on a new device.
  static Future<SyncData> pullAll() async {
    try {
      final uid = _uid;
      if (uid == null) return SyncData.empty();

      final results = await Future.wait([
        fetchCollection('expenses'),
        fetchCollection('budgets'),
        fetchCollection('goals'),
        fetchCollection('income'),
        fetchCollection('recurring'),
        fetchCollection('debts'),
        fetchCollection('custom_categories'),
        fetchCollection('installments'),
        fetchCollection('installment_plans'),
        fetchProfile(),
      ]);

      return SyncData(
        expenses: results[0] as List<Map<String, dynamic>>,
        budgets: results[1] as List<Map<String, dynamic>>,
        goals: results[2] as List<Map<String, dynamic>>,
        income: results[3] as List<Map<String, dynamic>>,
        recurring: results[4] as List<Map<String, dynamic>>,
        debts: results[5] as List<Map<String, dynamic>>,
        customCategories: results[6] as List<Map<String, dynamic>>,
        installments: results[7] as List<Map<String, dynamic>>,
        installmentPlans: results[8] as List<Map<String, dynamic>>,
        profile: results[9] as UserProfile?,
      );
    } catch (_) {
      return SyncData.empty();
    }
  }

  /// Push all local data to Firestore (called after login to ensure cloud is up to date).
  static Future<void> pushAll({
    required List<Map<String, dynamic>> expenses,
    required List<Map<String, dynamic>> budgets,
    required List<Map<String, dynamic>> goals,
    required List<Map<String, dynamic>> income,
    required List<Map<String, dynamic>> recurring,
    required List<Map<String, dynamic>> debts,
    List<Map<String, dynamic>> customCategories = const [],
    List<Map<String, dynamic>> installments = const [],
    List<Map<String, dynamic>> installmentPlans = const [],
  }) async {
    try {
      final uid = _uid;
      if (uid == null) return;

      // For budgets: delete all existing Firestore budget docs first,
      // then push current set. This prevents deleted budgets from resurrecting.
      // Budgets are small (max 8) so this is safe and fast.
      try {
        final budgetDocs = await _db
            .collection("users")
            .doc(uid)
            .collection("budgets")
            .get()
            .timeout(const Duration(seconds: 5));
        final deleteBatch = _db.batch();
        for (final doc in budgetDocs.docs) {
          deleteBatch.delete(doc.reference);
        }
        if (budgetDocs.docs.isNotEmpty) {
          await deleteBatch.commit().timeout(const Duration(seconds: 5));
        }
      } catch (_) {}

      // Use batched writes for efficiency
      final batches = <WriteBatch>[];
      WriteBatch current = _db.batch();
      int count = 0;

      void addToBatch(String collection, Map<String, dynamic> data) {
        final id = data['id']?.toString();
        if (id == null) return;
        final ref =
            _db.collection("users").doc(uid).collection(collection).doc(id);
        current.set(ref, data, SetOptions(merge: true));
        count++;
        if (count >= 490) {
          // Firestore batch limit is 500
          batches.add(current);
          current = _db.batch();
          count = 0;
        }
      }

      for (final e in expenses) addToBatch('expenses', e);
      for (final b in budgets) addToBatch('budgets', b);
      for (final g in goals) addToBatch('goals', g);
      for (final i in income) addToBatch('income', i);
      for (final r in recurring) addToBatch('recurring', r);
      for (final d in debts) addToBatch('debts', d);
      for (final c in customCategories) addToBatch('custom_categories', c);
      for (final inst in installments) addToBatch('installments', inst);
      for (final plan in installmentPlans)
        addToBatch('installment_plans', plan);

      batches.add(current);

      for (final batch in batches) {
        await batch.commit().timeout(const Duration(seconds: 20));
      }
    } catch (_) {}
  }

  // ── LEGACY COMPAT ─────────────────────────────────────────

  /// Keep old method name working (called from DBService.insertExpense)
  static Future<void> saveExpense(Map<String, dynamic> data) async {
    await pushDoc('expenses', data);
  }
}

class SyncData {
  final List<Map<String, dynamic>> expenses;
  final List<Map<String, dynamic>> budgets;
  final List<Map<String, dynamic>> goals;
  final List<Map<String, dynamic>> income;
  final List<Map<String, dynamic>> recurring;
  final List<Map<String, dynamic>> debts;
  final List<Map<String, dynamic>> customCategories;
  final List<Map<String, dynamic>> installments;
  final List<Map<String, dynamic>> installmentPlans;
  final UserProfile? profile;

  SyncData({
    required this.expenses,
    required this.budgets,
    required this.goals,
    required this.income,
    required this.recurring,
    required this.debts,
    this.customCategories = const [],
    this.installments = const [],
    this.installmentPlans = const [],
    required this.profile,
  });

  factory SyncData.empty() => SyncData(
        expenses: [],
        budgets: [],
        goals: [],
        income: [],
        recurring: [],
        debts: [],
        customCategories: [],
        installments: [],
        installmentPlans: [],
        profile: null,
      );

  bool get isEmpty =>
      expenses.isEmpty &&
      budgets.isEmpty &&
      goals.isEmpty &&
      income.isEmpty &&
      recurring.isEmpty &&
      debts.isEmpty &&
      customCategories.isEmpty &&
      installments.isEmpty &&
      installmentPlans.isEmpty &&
      profile == null;
}
