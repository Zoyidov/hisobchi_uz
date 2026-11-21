# Hisup (hisobchi_uz) — loyiha qoidalari

## Autentifikatsiya
- **Backend 401 qaytarsa — har doim kirish sahifasiga (`RoutePaths.phone`).**
  Hech qachon xato ekrani yoki "Qayta urinish" ko'rsatilmaydi.
  - `ErrorInterceptor` 401 → `AuthSessionController.notifyUnauthenticated()`.
  - `App._onAuthSessionEvent` → `AuthCubit.logout()` (bir nechta parallel 401
    bo'lsa faqat birinchisi ishlaydi) + "Sessiya tugadi" snackbar.
  - Router `redirect`: `unauthenticated` holatda faqat `RoutePaths.isPublicAuth`
    sahifalari (phone, otp, login, register, forgot/reset password) ochiq;
    boshqa har qanday sahifa (PIN-kod, hisob tanlash ham) → `phone`.
  - Splash o'zi yo'naltiradi: `loadMe` `AuthFailure` bilan tugasa → `phone`.
  - Yangi sahifa/oqim qo'shilganda shu qoida buzilmasligini tekshiring.

## UI qoidalari
- Ranglar faqat `context.colors.<token>` orqali; yangi rang kerak bo'lsa
  `tool/gen_colors.py`ga qo'shib, `python3 tool/gen_colors.py lib/core/theme/app_colors.dart`.
  Brend: primary `#0751CC`, brandAccent `#079FFF`.
- Radius — `AppRadius`, oraliq — `AppSpacing` (raqam yozilmaydi).
- Har bir UI matni `lib/l10n/app_uz.arb` + `app_ru.arb`da; kodda `context.l10n.x`.
  `context` yo'q joyda (cubit, model, validator) — `AppL10n.current`.
  So'zlarni yopishtirib gap yasalmaydi ("{nom} qo'shish") — to'liq gap kaliti.
  Ruscha sonlar uchun ICU plural. Generatsiya: `flutter gen-l10n`
  (yoki offline: `python3 tool/gen_l10n.py`).
- Testlar `locale: uz` bilan ishlaydi — Material matnlarini qattiq yozmang,
  `test/helpers/localized_finders.dart` dan foydalaning.
