import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_line/features/home/presenatation/today_meds_cubits/today_meds_state.dart';

class TodayMedsCubit extends Cubit<TodayMedsState> {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  Timer? _midnightTimer;

  TodayMedsCubit({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const TodayMedsState());

  Future<void> loadToday() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Oturum bulunamadı');

      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day);
      final nextDayStart = dayStart.add(const Duration(days: 1));

      final startTs = Timestamp.fromDate(dayStart);
      final endTs = Timestamp.fromDate(nextDayStart);

      final list = await _fetchTodayAnySchema(uid, startTs, endTs);

      if (kDebugMode) {
        debugPrint('[today] ${dayStart.toIso8601String()} -> ${list.length} kayıt');
      }

      emit(state.copyWith(hastalar: list, isLoading: false, error: null));
      _scheduleMidnightRefresh();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, error: "$e"));
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTodayAnySchema(
      String uid, Timestamp startTs, Timestamp endTs) async {
    
    final query = _db.collection('patients').where('doctorId', isEqualTo: uid);

    try {
      var snap = await query
          .where('cihazTakmaGunu', isGreaterThanOrEqualTo: startTs)
          .where('cihazTakmaGunu', isLessThan: endTs)
          .get();
      
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) => {...d.data(), '_id': d.id}).toList(growable: false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[today] Range query failed (index gerekebilir): $e');
    }

    final all = await query.limit(500).get();
    final allList = all.docs.map((d) => {...d.data(), '_id': d.id}).toList();

    final startDateTime = startTs.toDate();
    final endDateTime = endTs.toDate();

    final todayList = allList.where((h) {
      final v = h['cihazTakmaGunu'];
      if (v is Timestamp) {
        final d = v.toDate();
        return d.isAfter(startDateTime.subtract(const Duration(seconds: 1))) && d.isBefore(endDateTime);
      } else if (v is String) {
        final parsed = DateTime.tryParse(v);
        if (parsed != null) {
          return parsed.isAfter(startDateTime.subtract(const Duration(seconds: 1))) && parsed.isBefore(endDateTime);
        }
      }
      return false;
    }).toList(growable: false);

    return todayList;
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final until = nextMidnight.difference(now);
    _midnightTimer = Timer(until, () => loadToday());
  }

  @override
  Future<void> close() {
    _midnightTimer?.cancel();
    return super.close();
  }

  static String _isoDayStart(DateTime d) {
    String two(int v) => v < 10 ? '0$v' : '$v';
    return '${d.year}-${two(d.month)}-${two(d.day)}T00:00:00.000';
  }
}
