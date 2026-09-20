import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_line/features/home/presenatation/search_cubits/search_state.dart';

class HastaSearchCubit extends Cubit<HastaSearchState> {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  HastaSearchCubit({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const HastaSearchState());

  List<Map<String, dynamic>> _all = [];
  bool _loaded = false;
  Future<void>? _loadFuture;
  Timer? _debounce;

  Future<void> onQueryChanged(String q) async {
    emit(state.copyWith(query: q, error: null));

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      await _ensureLoaded();
      final norm = _normalize(state.query); 
      final list = norm.isEmpty
          ? List<Map<String, dynamic>>.from(_all)
          : _filter(_all, norm);

      emit(state.copyWith(hastalar: list, isLoading: false, error: null));
    });
  }

  Future<void> loadOnce() async {
    await onQueryChanged('');
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    if (_loadFuture == null) {
      emit(state.copyWith(isLoading: true, error: null));
      _loadFuture = _fetchAll();
    }
    await _loadFuture;
  }

  Future<void> _fetchAll() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Oturum bulunamadı');
    final snap = await _db
        .collection('doctorUsers')
        .doc(uid)
        .collection('hastalari')
        .get();

    _all = snap.docs.map((d) => {...d.data(), '_id': d.id}).toList(growable: false);
    _loaded = true;
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> src, String q) {
    return src.where((h) {
      final ad    = _normalize(h['name']?.toString() ?? '');
      final soyad = _normalize(h['surName']?.toString() ?? '');
      return ad.startsWith(q) || soyad.startsWith(q) || ad.contains(q) || soyad.contains(q);
    }).toList(growable: false);
  }

  static String _normalize(String s) {
    if (s.isEmpty) return '';
    const map = {'I':'ı','İ':'i','Ş':'ş','Ğ':'ğ','Ü':'ü','Ö':'ö','Ç':'ç'};
    var out = s.trim();
    map.forEach((k, v) => out = out.replaceAll(k, v));
    return out.toLowerCase();
  }
}
