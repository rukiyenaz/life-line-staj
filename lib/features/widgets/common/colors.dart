import 'package:flutter/material.dart';

class AppColors {
  // ── Temel Arka Planlar ──────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);       // Ana sayfa arkaplan
  static const Color surface = Color(0xFFFFFFFF);          // Kart yüzeyi
  static const Color surfaceVariant = Color(0xFFF1F5F9);   // İkinci yüzey

  // ── Ana Renk Paleti ─────────────────────────────────────────
  static const Color primary = Color(0xFF1E293B);          // Lacivert - Ana renk
  static const Color primaryLight = Color(0xFF334155);     // Açık Lacivert
  static const Color primarySurface = Color(0xFFEFF6FF);   // Primary'nin çok açık tonu

  // ── Vurgu Renkleri ──────────────────────────────────────────
  static const Color accent = Color(0xFF3B82F6);           // Sağlık Mavisi
  static const Color accentGreen = Color(0xFF10B981);      // Nane Yeşili
  static const Color accentSurface = Color(0xFFECFDF5);    // Yeşilin çok açık tonu

  // ── Risk / Uyarı Renkleri ────────────────────────────────────
  static const Color error = Color(0xFFEF4444);            // Pastel Mercan Kırmızı
  static const Color warning = Color(0xFFF59E0B);          // Amber Sarı
  static const Color errorSurface = Color(0xFFFFF1F2);     // Kırmızının çok açık tonu
  static const Color warningSurface = Color(0xFFFFFBEB);   // Sarının çok açık tonu

  // ── Metin Renkleri ───────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);      // Ana başlık metni
  static const Color textSecondary = Color(0xFF64748B);    // Muted / alt başlık
  static const Color textDisabled = Color(0xFFCBD5E1);     // Disabled durum

  // ── Sınır / Bölme Renkleri ──────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);           // Hafif sınır
  static const Color borderLight = Color(0xFFF1F5F9);      // Çok hafif sınır

  // ── Cinsiyet Renkleri ────────────────────────────────────────
  static const Color femaleAccent = Color(0xFFF472B6);     // Pembe
  static const Color maleAccent = Color(0xFF60A5FA);       // Mavi

  // ── Legacy Aliases (geriye dönük uyumluluk) ──────────────────
  static const Color cardBackground = Color(0xFF1E293B);
  static const Color backgroundColor = Color(0xFFF1F5F9);
  static const Color buttonColor = Color(0xFF1E293B);
  static const Color textFieldBackground = Color(0xFF3B82F6);
  static const Color avatar = Color(0xFF3B82F6);
  static const Color femaleBackground = Color(0xFFF472B6);
  static const Color maleBackground = Color(0xFF1E293B);
  static const Color bottomBar = Color(0xFFFFFFFF);
  static const Color appBar = Colors.transparent;
  static const Color transparent = Colors.transparent;
  static const Color secondary = Color(0xFF3B82F6);
}