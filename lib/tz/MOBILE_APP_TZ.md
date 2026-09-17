# E-HISOB — MOBIL ILOVA UCHUN TEXNIK TOPSHIRIQ (TZ)

**Mahsulot:** E-Hisob — kichik va o'rta biznes uchun moliyaviy hisobdorlik platformasi
**Hujjat turi:** Mobil ilova (iOS + Android) uchun to'liq texnik topshiriq
**Versiya:** 1.0
**Sana:** 2026-09-07
**Backend:** Laravel 11 + Sanctum (REST API)
**Manba:** `Hisobchi_Backend` repozitoriysi (routes, controllers, requests, resources, services, migrations tahlili asosida)

---

## MUNDARIJA

| № | Bo'lim |
|---|--------|
| 1 | [Kirish va hujjat haqida](#1-kirish-va-hujjat-haqida) |
| 2 | [Mahsulot umumiy ko'rinishi](#2-mahsulot-umumiy-korinishi) |
| 3 | [Texnik talablar va arxitektura](#3-texnik-talablar-va-arxitektura) |
| 4 | [API bilan ishlash qoidalari (Network layer)](#4-api-bilan-ishlash-qoidalari-network-layer) |
| 5 | [Modul 1 — Autentifikatsiya va onboarding](#5-modul-1--autentifikatsiya-va-onboarding) |
| 6 | [Modul 2 — Rollar, ruxsatlar va owner-kontekst](#6-modul-2--rollar-ruxsatlar-va-owner-kontekst) |
| 7 | [Modul 3 — Dashboard (Bosh sahifa)](#7-modul-3--dashboard-bosh-sahifa) |
| 8 | [Modul 4 — Hamkorlar (Mijozlar) va kirim/chiqim](#8-modul-4--hamkorlar-mijozlar-va-kirimchiqim) |
| 9 | [Modul 5 — Bo'lib to'lash (Installment)](#9-modul-5--bolib-tolash-installment) |
| 10 | [Modul 6 — Loyihalar](#10-modul-6--loyihalar) |
| 11 | [Modul 7 — Ma'lumotnomalar (Documents)](#11-modul-7--malumotnomalar-documents) |
| 12 | [Modul 8 — Hisobotlar](#12-modul-8--hisobotlar) |
| 13 | [Modul 9 — Obuna, tariflar va to'lov](#13-modul-9--obuna-tariflar-va-tolov) |
| 14 | [Modul 10 — Bildirishnomalar (Push)](#14-modul-10--bildirishnomalar-push) |
| 15 | [Modul 11 — Xodimlar boshqaruvi](#15-modul-11--xodimlar-boshqaruvi) |
| 16 | [Modul 12 — Faollik jurnali (Activity Log)](#16-modul-12--faollik-jurnali-activity-log) |
| 17 | [Modul 13 — Profil va sozlamalar](#17-modul-13--profil-va-sozlamalar) |
| 18 | [Modul 14 — Versiya nazorati va majburiy yangilash](#18-modul-14--versiya-nazorati-va-majburiy-yangilash) |
| 19 | [UI/UX, dizayn tizimi va lokalizatsiya](#19-uiux-dizayn-tizimi-va-lokalizatsiya) |
| 20 | [Xavfsizlik talablari](#20-xavfsizlik-talablari) |
| 21 | [Nofunksional talablar](#21-nofunksional-talablar) |
| 22 | [Analitika, loglash va monitoring](#22-analitika-loglash-va-monitoring) |
| 23 | [Testlash va qabul qilish mezonlari](#23-testlash-va-qabul-qilish-mezonlari) |
| 24 | [Yetkazib berish rejasi va Definition of Done](#24-yetkazib-berish-rejasi-va-definition-of-done) |
| 25 | [Ilovalar (Appendix)](#25-ilovalar-appendix) |

---

## 1. KIRISH VA HUJJAT HAQIDA

### 1.1 Hujjat maqsadi

Ushbu hujjat E-Hisob mobil ilovasini **noldan to'liq ishlab chiqish** uchun yagona texnik manba hisoblanadi. Hujjatda:

- barcha ekranlar va ularning xatti-harakati,
- har bir ekran uchun ishlatiladigan API endpointlar, so'rov/javob formatlari,
- biznes qoidalar va cheklovlar,
- validatsiya qoidalari va xatolik stsenariylari,
- qabul qilish mezonlari (Acceptance Criteria)

to'liq tavsiflangan. Dasturchi qo'shimcha savolsiz ishni boshlashi va yakunlashi kerak. Hujjatda ko'rsatilmagan har qanday xatti-harakat **qo'shimcha kelishuvsiz amalga oshirilmaydi**.

### 1.2 Auditoriya

- Mobil dasturchi (Flutter yoki Native)
- QA muhandisi
- Backend dasturchi (integratsiya nuqtalari bo'yicha)
- Loyiha menejeri

### 1.3 Terminologiya lug'ati

| Termin | Tavsif |
|--------|--------|
| **Owner (Egasi)** | `user` roliga ega asosiy foydalanuvchi. Barcha ma'lumotlar (hamkorlar, loyihalar, obuna) unga tegishli. |
| **Staff (Xodim)** | `staff` roliga ega foydalanuvchi. Owner nomidan, faqat berilgan ruxsatlar doirasida ishlaydi. |
| **Partner (Hamkor / Mijoz)** | Biznes hamkori: mijoz yoki yetkazib beruvchi. |
| **Wallet (Tranzaksiya)** | Hamkor bilan bitta moliyaviy operatsiya. Ikki turi bor: `credit` va `debt`. |
| **Chiqim (`credit`)** | Hamkorga pul/tovar qarzga berildi. Hamkor bizga qarzdor bo'ladi. Qaytarish sanasi (`return_date`) belgilanishi mumkin. |
| **Kirim (`debt`)** | Hamkordan to'lov qabul qilindi. FIFO orqali eski qarzlarni yopadi. |
| **Xaqdor** | Balans > 0 — hamkor bizga qarzdor (biz undan olishimiz kerak). |
| **Qarzdor** | Balans < 0 — biz hamkorga qarzdormiz. |
| **CreditSchedule** | Muddatli qarz grafigi. `credit` wallet + `return_date` bo'lganda avtomatik yaratiladi. |
| **FIFO** | To'lov (kirim) eng eski muddatli qarzdan boshlab avtomatik taqsimlanadi. |
| **Installment Plan (Bo'lib to'lash rejasi)** | Katta summani qismlarga bo'lib to'lash grafigi. |
| **Installment Item (Qism)** | Bo'lib to'lash rejasidagi bitta to'lov qismi. |
| **Advance (Avans)** | Bo'lib to'lash rejasining birinchi, reja yaratilishida allaqachon to'langan qismi. |
| **Subscription (Obuna)** | Foydalanuvchining tarif rejasi va limitlari. |
| **Effective User** | So'rov qaysi owner ma'lumotlari ustida bajarilayotgani (staff uchun — owner ID). |

### 1.4 Foydalaniladigan tashqi hujjatlar

Repozitoriyda mavjud va **ushbu TZ bilan birga o'qilishi shart** bo'lgan hujjatlar:

| Fayl | Mazmuni |
|------|---------|
| `docs/installment_api.md` | Bo'lib to'lash API — batafsil request/response namunalari |
| `docs/installment_reports_api.md` | Bo'lib to'lash hisobotlari API |
| `docs/installment_partner_report_mobile.md` | Hamkor bo'yicha bo'lib to'lash hisoboti — mobil ekran spetsifikatsiyasi |
| `docs/installment-sms-flow.md` | Bo'lib to'lash SMS oqimi (mobil UX uchun kontekst) |
| `docs/staff-system.md` | Xodimlar tizimi — arxitektura va oqimlar |
| `FEATURES.md` | Platformaning umumiy imkoniyatlari |

---

## 2. MAHSULOT UMUMIY KO'RINISHI

### 2.1 Biznes maqsad

E-Hisob — tadbirkorga daftar o'rniga:

1. **Kimga qancha berganini va kimdan qancha olishi kerakligini** yuritish,
2. Qarz muddatlarini kuzatish va **avtomatik SMS eslatma** yuborish,
3. Katta summalarni **bo'lib to'lash grafigi** bilan boshqarish,
4. **Qurilish/xizmat loyihalari** bo'yicha daromad-xarajat hisobini yuritish,
5. **Xodimlarga cheklangan ruxsat** berib, ular kiritgan operatsiyalarni nazorat qilish

imkonini beruvchi mobil-birinchi (mobile-first) platforma.

### 2.2 Foydalanuvchi rollari

| Rol | Backend nomi | Imkoniyatlari |
|-----|--------------|---------------|
| Egasi | `user` | To'liq huquq: barcha modullar, xodimlar boshqaruvi, obuna sotib olish |
| Xodim | `staff` | Faqat owner bergan permissionlar doirasida; `X-As-Owner` header bilan ishlaydi |
| Egasi + Xodim | `user` + `staff` | Ikkala rejim; ilovada hisob tanlash ekrani chiqadi |
| Admin | `admin` | Faqat admin panel (mobil ilovada **ishlatilmaydi**) |

### 2.3 Modul xaritasi (Information Architecture)

```
E-Hisob mobil ilova
│
├── Auth
│   ├── Splash / Version check
│   ├── Telefon kiritish → verify-number → (register | login)
│   ├── OTP tasdiqlash
│   ├── Ro'yxatdan o'tish
│   ├── Login (parol)
│   ├── Parolni tiklash (OTP)
│   ├── Pincode / Biometrika
│   └── Hisob tanlash (owner / staff)
│
├── Bottom Navigation (5 tab)
│   ├── [1] Bosh sahifa (Dashboard)
│   ├── [2] Hamkorlar
│   │     ├── Hamkorlar ro'yxati (balans, filtr, sort, qidiruv)
│   │     ├── Hamkor kartochkasi (kirim/chiqim, hisob, bo'lib to'lash, SMS)
│   │     ├── Kirim/Chiqim yaratish
│   │     ├── Bo'lib to'lash rejalari
│   │     └── SMS sozlamalari
│   ├── [3] Loyihalar
│   │     ├── Loyihalar ro'yxati
│   │     └── Loyiha kartochkasi (shartnoma, daromad, xarajat, ishchilar)
│   ├── [4] Hisobotlar
│   │     ├── Hamkorlar bo'yicha (umumiy / muddat / qarz muddatlari / xodimlar)
│   │     ├── Bo'lib to'lash hisobotlari
│   │     └── Loyihalar hisobotlari
│   └── [5] Profil
│         ├── Shaxsiy ma'lumotlar
│         ├── Obuna va tariflar
│         ├── SMS paketlari
│         ├── Xodimlar
│         ├── Ma'lumotnomalar
│         ├── Faollik jurnali
│         ├── Bildirishnomalar
│         ├── Valyuta kurslari
│         ├── Sozlamalar (til, mavzu, pincode)
│         └── Qo'llanmalar (video)
```

### 2.4 Asosiy foydalanuvchi stsenariylari (User Journeys)

**UJ-01. Yangi foydalanuvchi:** Telefon → OTP → Ism+parol → FREE tarif avtomatik → Dashboard (bo'sh holat) → Birinchi hamkor qo'shish → Birinchi chiqim.

**UJ-02. Kunlik ish:** Pincode/biometrika → Dashboard'da "muddati o'tgan 3 ta qarz" → Ro'yxat → Hamkorga qo'ng'iroq → Kirim kiritish → Hamkorga avtomatik SMS ketadi.

**UJ-03. Bo'lib to'lash:** Hamkor → "Bo'lib to'lash" → Reja yaratish (teng/erkin, avans) → Grafik ko'rinadi → Har oy to'lov qabul qilish → Reja yopiladi.

**UJ-04. Xodim:** Owner xodim qo'shadi (OTP orqali) → ruxsatlarni belgilaydi → xodim login qiladi → hisob tanlaydi → faqat ruxsat berilgan amallarni bajaradi → owner Activity Log'da ko'radi.

**UJ-05. Limit tugashi:** Hamkor qo'shishda "limit tugagan" xatosi → Tariflar ekrani → Tarif tanlash → Click/Payme → To'lov → Limit yangilanadi.

---

## 3. TEXNIK TALABLAR VA ARXITEKTURA

### 3.1 Platformalar

| Talab | Qiymat |
|-------|--------|
| Texnologiya | **Flutter (tavsiya etiladi, yagona kod bazasi)** yoki Native (Kotlin + Swift) |
| Android min SDK | 24 (Android 7.0) |
| Android target SDK | Joriy Play Store talabi (kamida 35) |
| iOS min versiya | 13.0 |
| Orientatsiya | Faqat **portret** |
| Ekran o'lchamlari | 320dp dan 1024dp gacha (telefon + planshet moslashuvi) |
| Til | uz (asosiy), ru, en |
| Mavzu | Light + Dark |

### 3.2 Tavsiya etiladigan arxitektura (Flutter)

```
lib/
├── core/
│   ├── network/          # Dio client, interceptorlar, error mapper
│   ├── storage/          # SecureStorage (token, pincode), SharedPrefs
│   ├── router/           # go_router, auth guard, permission guard
│   ├── theme/            # Design tokens, light/dark
│   ├── localization/     # uz/ru/en ARB
│   └── utils/            # formatters (money, date, phone), validators
├── data/
│   ├── models/           # freezed + json_serializable
│   ├── datasources/      # remote (API), local (cache)
│   └── repositories/
├── domain/
│   ├── entities/
│   └── usecases/
└── features/
    ├── auth/ dashboard/ partners/ installments/ projects/
    ├── reports/ subscription/ notifications/ staff/ profile/
    └── ... (har biri: presentation/ + bloc yoki riverpod)
```

**Majburiy talablar:**

- **State management:** BLoC/Cubit yoki Riverpod (loyiha davomida yagona yondashuv).
- **DI:** get_it + injectable yoki Riverpod providers.
- **Model generatsiya:** freezed + json_serializable. Qo'lda `Map<String, dynamic>` bilan ishlash **taqiqlanadi**.
- **Navigation:** go_router (deep link va push-notification navigatsiyasi uchun).
- **HTTP:** dio + interceptorlar (auth, owner-context, error, logging, retry).
- **Xavfsiz saqlash:** flutter_secure_storage (token, pincode).
- **Push:** firebase_messaging + flutter_local_notifications.
- **Lokal keshlash:** Hive yoki Isar (ro'yxatlar va ma'lumotnomalar uchun).

### 3.3 Kod sifati talablari

- `flutter analyze` — 0 error, 0 warning.
- Lint: `very_good_analysis` yoki `flutter_lints` (strict rejimda).
- Har bir feature uchun kamida repository darajasida unit test.
- Kritik oqimlar uchun widget/integration testlar (5.x, 8.x, 9.x bo'limlari).
- Barcha magic string/number — konstanta yoki enum'da.
- README'da: build qilish, muhitlarni almashtirish, release qilish yo'riqnomasi.

---

## 4. API BILAN ISHLASH QOIDALARI (NETWORK LAYER)

> **Bu bo'lim TZ ning eng muhim qismi.** Backend javob formati nostandart, shuning uchun barcha xatoliklarni qayta ishlash **markazlashgan interceptor**da amalga oshiriladi.

### 4.1 Muhitlar (Environments)

| Muhit | Base URL |
|-------|----------|
| Production | `https://{prod_domain}/api` |
| Staging / Dev | `https://{dev_domain}/api` |

Ilova **flavor**lar bilan quriladi: `dev`, `prod`. Base URL kompilyatsiya vaqtida (`--dart-define`) beriladi, kodga hardcode qilinmaydi.

### 4.2 Standart headerlar

| Header | Qiymat | Qachon |
|--------|--------|--------|
| `Accept` | `application/json` | Har doim (**majburiy** — aks holda Laravel HTML qaytarishi mumkin) |
| `Content-Type` | `application/json` (yoki `multipart/form-data` — fayl yuklashda) | Har doim |
| `Authorization` | `Bearer {token}` | Login qilingandan keyin barcha so'rovlarda |
| `X-As-Owner` | `{owner_id}` | Faqat xodim rejimida ishlayotganda (6-bo'limga qarang) |
| `Accept-Language` | `uz` / `ru` / `en` | Har doim (kelajakdagi backend lokalizatsiyasi uchun) |

### 4.3 Javob formatlari — 5 xil holat

Backend bir nechta formatda javob qaytaradi. Interceptor **hammasini** yagona `Result<T>` ga aylantirishi shart.

**A) Muvaffaqiyat (HTTP 200)**
```json
{ "status": true, "result": { } }
```

**B) Biznes-xatolik (HTTP 200!)** — eng ko'p uchraydigan holat
```json
{ "status": false, "error": { "message": "Bu telefon raqamli hamkor allaqachon mavjud" } }
```
> ⚠️ **Diqqat:** HTTP status kodi **200** bo'lsa ham, `status: false` bo'lsa — bu XATO. `error.message` foydalanuvchiga to'g'ridan-to'g'ri ko'rsatiladi (matnlar allaqachon o'zbek tilida).

**C) Validatsiya xatosi (HTTP 422)** — Laravel standart formati
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "phone": ["Telefon raqam 9 ta raqamdan iborat bo'lishi kerak."],
    "summa": ["Summa kiritilishi shart."]
  }
}
```
> Bu xatolar **maydonlar ostida** (inline) ko'rsatiladi, snackbar'da emas.

**D) Autentifikatsiya xatosi (HTTP 401)**
```json
{ "message": "Unauthenticated." }
```
> Token yaroqsiz/o'chirilgan. Ilova: barcha lokal ma'lumotlarni tozalab, **login ekraniga** qaytaradi va "Sessiya tugadi, qaytadan kiring" xabarini ko'rsatadi.

**E) Ruxsat xatosi (HTTP 403)**
```json
{ "status": false, "message": "Bu amalni bajarish uchun ruxsatingiz yo'q." }
```
> ⚠️ Bu formatda `error` obyekti **yo'q**, `message` to'g'ridan-to'g'ri ildizda.

### 4.4 Majburiy Error-Interceptor algoritmi

```
1. HTTP 401 → token tozalash → Login ekrani → "Sessiya tugadi"
2. HTTP 403 → body.message ni ko'rsatish (snackbar) → navigatsiya o'zgarmaydi
3. HTTP 422 → body.errors ni Map<String, String> ga aylantirib, formaga uzatish
4. HTTP 200 && body.status == false → body.error.message ni ko'rsatish
5. HTTP 200 && body.status == true → body.result ni parse qilish
6. HTTP 5xx → "Serverda xatolik. Keyinroq urinib ko'ring" + Retry tugmasi
7. Timeout / DNS / no internet → "Internet aloqasi yo'q" + Retry tugmasi
8. Boshqa holat → "Kutilmagan xatolik" + xatolikni Crashlytics'ga yuborish
```

**Timeout qiymatlari:** connect 15s, receive 30s, send 30s. Excel eksport uchun receive 120s.

### 4.5 Rate limiting (Throttle)

Ba'zi endpointlarda cheklov bor. Limit oshsa **HTTP 200** va quyidagi javob keladi:
```json
{ "status": false, "error": { "message": "Juda ko'p urinish. Biroz kutib qayta urining." } }
```

| Endpoint | Limit |
|----------|-------|
| `POST /auth/login` | 10 so'rov / 1 daqiqa |
| `POST /auth/verify-number` | 10 so'rov / 1 daqiqa |
| `POST /auth/register` | 5 so'rov / 1 daqiqa |
| `POST /auth/otp` | 5 so'rov / 1 daqiqa |
| `POST /auth/otp/verify` | 5 so'rov / 1 daqiqa |
| `POST /auth/reset-password` | 5 so'rov / 1 daqiqa |

Ilova OTP tugmasini **60 soniyalik countdown** bilan bloklaydi (backend'da OTP amal qilish muddati 1 daqiqa).

### 4.6 Obuna holati headeri

Autentifikatsiya talab qiluvchi deyarli barcha javoblarda header keladi:

```
X-Subscription-Status: ACTIVE | GRACE_PERIOD | READ_ONLY | ARCHIVED | none
```

**Ilova xatti-harakati:**

| Qiymat | UI reaksiyasi |
|--------|---------------|
| `ACTIVE` | Normal ish |
| `GRACE_PERIOD` | Yuqorida sariq banner: "Obuna muddati tugadi. Imtiyozli davr. Yangilang" + "Tariflar" tugmasi |
| `READ_ONLY` | Qizil banner: "Faqat ko'rish rejimi". Barcha yaratish/tahrirlash tugmalari **disabled** |
| `ARCHIVED` / `none` | To'liq bloklovchi ekran: "Obunani yangilang" → Tariflar |

> ⚠️ Bu header serverda **6 soat keshlanadi**, ya'ni to'lovdan keyin darhol yangilanmasligi mumkin. Shuning uchun to'lov muvaffaqiyatli bo'lgach ilova `GET /subscription/show` orqali haqiqiy holatni oladi va bannerni yashiradi.

### 4.7 Paginatsiya — 3 xil format

**A) `simplePaginate` (asosiy format)** — `total` va `last_page` **YO'Q**:
```json
{
  "status": true,
  "result": {
    "data": [ ... ],
    "links": { "first": "...", "last": null, "prev": null, "next": "...?page=2" },
    "meta": { "current_page": 1, "from": 1, "path": "...", "per_page": 15, "to": 15 }
  }
}
```
> Keyingi sahifa bor-yo'qligi **faqat `links.next != null`** orqali aniqlanadi. Progress bar "12 dan 3" ko'rinishida ko'rsatilmaydi.

**B) `paginate` (Activity Log)** — maxsus format:
```json
{
  "status": true,
  "result": {
    "data": [ ... ],
    "pagination": { "total": 150, "per_page": 20, "current_page": 1, "last_page": 8 }
  }
}
```

**C) Paginatsiyasiz massiv** — barcha yozuvlar bir marta keladi (masalan `GET /partners/partners`, `GET /documents/currencies`).

**Standart sahifa hajmlari:** 15 (hamkorlar, hisobotlar), 20 (bo'lib to'lash, bildirishnomalar), 10 (loyihalar).

**Infinite scroll talabi:** ro'yxatning oxiriga 3 element qolganda keyingi sahifa yuklanadi; pastda loader; xatolik bo'lsa "Qayta urinish" tugmasi.

### 4.8 Ma'lumot formatlari

| Tur | Format | Misol | Izoh |
|-----|--------|-------|------|
| Summa (javobda) | String yoki number | `"1500000.00"` | **Har doim `String`/`num` ni `Decimal`ga parse qiling. `double` bilan pul hisoblash TAQIQLANADI** |
| Summa (so'rovda) | Number (nuqta bilan) | `1500000.00` | Foydalanuvchi kiritgan bo'shliqlar/vergullar tozalanadi |
| Sana (javobda, qisqa) | `dd.mm.yyyy` | `"07.09.2026"` | `dateFormat()` helper |
| Sana+vaqt (javobda) | `dd.mm.yyyy HH:ii:ss` | `"07.09.2026 14:30:00"` | `dateTimeFormat()` helper |
| Sana (so'rovda, filtr) | `dd.mm.yyyy` | `date[0]=01.09.2026` | Wallet/Project/Report filtrlarida |
| Sana (so'rovda, yaratish) | `yyyy-mm-dd` | `"2026-10-01"` | `return_date`, `due_date`, `start_date` |
| Telefon | 9 raqam, prefikssiz | `"901234567"` | `+998` **yuborilmaydi**. UI da `+998 90 123 45 67` ko'rinishida ko'rsatiladi |
| Valyuta | `currency_type_id` | `1 = UZS`, `2 = USD` | Hisobotlarda bu ID lar **hardcode** qilingan |

**Summani ko'rsatish qoidasi:** `1 500 000 UZS` (uch xonali guruh, ajratgich — bo'shliq). Manfiy qiymat **qizil**, musbat **yashil**.

### 4.9 Fayllar bilan ishlash

1. Fayl **avval alohida** yuklanadi: `POST /files/upload` (multipart) → `{ id, url }`.
2. Olingan `id` obyekt yaratish/tahrirlashda `file_id[]` yoki `file_ids[]` massivida yuboriladi.
3. **Cheklovlar:** max **5 MB**, formatlar: `jpg, jpeg, png, webp, pdf, doc, docx, xls, xlsx, txt`.
4. Javobdagi fayl `url` — **vaqtinchalik (1 soat)** signed URL.

> ⚠️ **Muhim:** Fayl URL larini lokal bazaga saqlash **TAQIQLANADI** — ular 1 soatdan keyin ishlamaydi. Rasmlar `cached_network_image` bilan ko'rsatiladi, kesh kaliti sifatida `file.id` ishlatiladi, URL emas. Ekran ochilganda URL qayta olinadi.

5. Tahrirlashda `file_id` yuborilsa — eski fayllar **o'chiriladi va yangilari biriktiriladi** (replace). Fayllarni o'zgartirmaslik uchun `file_id` maydonini umuman yubormaslik kerak.
6. Faylni o'chirish: `DELETE /files/delete/{id}`.

### 4.10 Excel eksport

Ikki endpoint binar `.xlsx` fayl qaytaradi (JSON emas):

- `GET /partners/partners/export/excel` — barcha hamkorlar
- `GET /partners/partner/{partnerId}/wallets/export/excel` — hamkor tranzaksiyalari

**Ilova xatti-harakati:** `Authorization` header bilan yuklab olinadi → vaqtinchalik papkaga saqlanadi → OS ning "Ulashish/Ochish" oynasi (share sheet) ochiladi. Yuklab olish davomida progress dialog ko'rsatiladi. Bu funksiya faqat `export` xususiyati yoqilgan tariflarda ko'rinadi.

### 4.11 Keshlash va offline strategiyasi

| Ma'lumot | Strategiya |
|----------|-----------|
| Ma'lumotnomalar (valyutalar, ish turlari, xarajat turlari, lavozimlar) | Lokal bazada saqlanadi, ilova ochilganda 1 marta yangilanadi |
| `me()` — profil, rollar, permissionlar | Xotirada + lokal; har safar ilova foreground'ga chiqqanda yangilanadi |
| Ro'yxatlar (hamkorlar, tranzaksiyalar) | Oxirgi sahifa lokal keshlanadi — offline'da "oxirgi yuklangan ma'lumot" ko'rsatiladi + "Offline" bayrog'i |
| Hisobotlar | Keshlanmaydi (har doim tarmoqdan) |
| Yozish amallari (create/update/delete) | **Offline navbat YO'Q.** Internet bo'lmasa — "Internet aloqasi yo'q" xabari va amal bajarilmaydi |

> Offline rejimda ma'lumot yaratish **1.0 versiya qamroviga kirmaydi**.

---

## 5. MODUL 1 — AUTENTIFIKATSIYA VA ONBOARDING

### 5.1 Umumiy oqim (Flow diagram)

```
[Splash]
   │ mobile-check-version
   ├── update = true, hard  → [Majburiy yangilash ekrani] (chiqib bo'lmaydi)
   │
   ├── token bor + pincode yoqilgan → [Pincode/Biometrika] → [Hisob tanlash?] → [Dashboard]
   ├── token bor + pincode yo'q     → me() → [Hisob tanlash?] → [Dashboard]
   └── token yo'q                   → [Onboarding slaydlar] → [Telefon kiritish]

[Telefon kiritish] → POST /auth/verify-number
   ├── result.page = "login"    → [Parol kiritish]
   ├── result.page = "register" → POST /auth/otp → [OTP] → [Ro'yxatdan o'tish]
   └── status=false ("...kirish xuquqi cheklangan") → xatolik xabari

[Parol kiritish] → POST /auth/login → token → me() → [Dashboard]
       └── "Parolni unutdingizmi?" → POST /auth/otp → [OTP] → [Yangi parol]
```

### 5.2 Ekran: Splash

| Element | Talab |
|---------|-------|
| Ko'rinish | Logo + brend rangi, minimal animatsiya |
| Maksimal davomiylik | 3 soniya (API javob kelmasa ham ilova to'xtab qolmaydi) |
| Bajariladigan ishlar | 1) `POST /auth/mobile-check-version` 2) Token mavjudligini tekshirish 3) Ma'lumotnomalarni fon rejimida yangilash |

**Version check so'rovi:**
```http
POST /api/auth/mobile-check-version
{ "app_version": "1.4.2", "platform_type": "android" }   // yoki "ios"
```
**Javob:**
```json
{
  "status": true,
  "result": {
    "update": true,
    "current_version_play_market": "1.5.0",
    "current_version_mobile": "1.4.2",
    "update_status": "hard",
    "news": []
  }
}
```
`update = true` bo'lsa → 18-bo'limga qarang.

### 5.3 Ekran: Telefon raqam kiritish

| Element | Talab |
|---------|-------|
| Maydon | Telefon, maska `+998 (__) ___-__-__`, faqat raqam, **9 ta raqam** |
| Validatsiya | Bo'sh emas; aynan 9 raqam; aks holda tugma disabled |
| Tugma | "Davom etish" |
| Qo'shimcha | Ofertaga rozilik checkbox + "Foydalanish shartlari" havolasi (App Store talabi) |

**So'rov:** `POST /api/auth/verify-number` → `{ "phone": "901234567" }`

| Javob | Harakat |
|-------|---------|
| `result.page = "register"` | `POST /auth/otp` yuboriladi → OTP ekraniga o'tiladi |
| `result.page = "login"` | Parol ekraniga o'tiladi |
| `status=false`, message: "Sizda mobile ilovaga kirish xuquqi cheklangan!" | Bloklovchi dialog: sabab + "Qo'llab-quvvatlash" tugmasi |

### 5.4 Ekran: OTP tasdiqlash

| Element | Talab |
|---------|-------|
| Kod | **4 xonali** raqamli, avtomatik fokus, avtomatik yopishtirish (SMS autofill / SMS Retriever API) |
| Timer | 60 soniya countdown; tugagach "Qayta yuborish" faollashadi |
| Amal | 4 raqam kiritilishi bilan **avtomatik** tekshiriladi |

**So'rov:** `POST /api/auth/otp/verify` → `{ "phone": "901234567", "otp_code": "1234" }`

**Javob:**
```json
{ "status": true, "result": { "verify_token": "a3f9c2...", "expires_in": 120 } }
```

**Biznes qoidalar:**
- OTP amal qilish muddati — **1 daqiqa**. Muddat tugasa: "OTP muddati tugagan".
- OTP hali amal qilayotganda qayta so'ralsa: "OTP hali amal qiladi" → qayta yuborish tugmasi bloklanadi.
- `verify_token` — ro'yxatdan o'tish uchun **2 daqiqa** amal qiladi (backend `verified_at + 2 min` bo'yicha tekshiradi). Shu vaqt ichida ro'yxatdan o'tish yakunlanmasa: "Verify token eskirgan" → jarayon boshidan boshlanadi.
- Xato kod: "OTP noto'g'ri" — maydon ostida qizil matn, kod tozalanadi.

**Xatolik matnlari (backend'dan keladi, o'zgartirilmaydi):** `OTP topilmadi`, `OTP muddati tugagan`, `OTP noto'g'ri`, `SMS yuborilmadi`.

### 5.5 Ekran: Ro'yxatdan o'tish

| Maydon | Qoidalar |
|--------|----------|
| Ism | Majburiy, matn |
| Parol | Majburiy, **min 6 belgi**, ko'rsatish/yashirish tugmasi |
| Parolni takrorlash | Faqat client-side tekshiruv |

**So'rov:** `POST /api/auth/register`
```json
{
  "name": "Sarvar",
  "phone": "901234567",
  "password": "secret123",
  "verify_token": "a3f9c2...",
  "device_name": "iPhone 13",
  "device_token": "FCM_TOKEN",       // MAJBURIY
  "device_type": "ios",              // ios | android | web
  "device_model": "iPhone13,2",
  "platform": "iOS 17.2"
}
```
> ⚠️ `device_token` (FCM) — **majburiy maydon**. Ilova ro'yxatdan o'tishdan oldin FCM token olishi shart. Token olinmasa (push ruxsati rad etilgan holatda ham) — Firebase installation token ishlatiladi.

**Javob:** `{ "status": true, "result": { "message": "...", "token": "1|abc..." } }` → token saqlanadi → `me()` → Dashboard.

Backend avtomatik ravishda: FREE tarif obunasini yaratadi, `user` rolini beradi, standart app-settings yaratadi.

### 5.6 Ekran: Login (parol bilan)

**So'rov:** `POST /api/auth/login` — body `register` bilan bir xil (name/verify_token'siz; `device_token` bu yerda ixtiyoriy, lekin **har doim yuboriladi**).

**Javob:** `{ "status": true, "result": { "token": "..." } }`

**⚠️ KRITIK BIZNES QOIDA — bitta faol sessiya:**
- Har bir muvaffaqiyatli login **foydalanuvchining barcha eski tokenlarini o'chiradi**.
- Qurilmalar bo'yicha ham cheklov bor: **faqat 1 ta faol qurilma** saqlanadi (yangisi qo'shilganda eng eskisi deaktiv qilinadi).
- Natija: foydalanuvchi ikkinchi telefonda kirsa, birinchi telefonda keyingi so'rov **401** qaytaradi → ilova avtomatik logout qiladi va "Hisobingizga boshqa qurilmadan kirildi" xabarini ko'rsatadi.

**Yana bir muhim qoida:** login vaqtida backend `app_settings.pincode` ni **NULL** qiladi. Ya'ni **har bir yangi login'dan keyin foydalanuvchi pincode'ni qaytadan o'rnatishi kerak**. Ilova login'dan keyin "Pincode o'rnatasizmi?" ekranini ko'rsatadi (o'tkazib yuborish mumkin).

**Xatoliklar:** `Authorization failed!` (telefon/parol xato), `User is not active!` (hisob faol emas).

### 5.7 Ekran: Parolni tiklash

Oqim: Telefon → `POST /auth/otp` → OTP ekrani (kod kiritiladi, lekin **verify qilinmaydi**) → Yangi parol ekrani.

**So'rov:** `POST /api/auth/reset-password`
```json
{ "phone": "901234567", "otp_code": "1234", "password": "yangi_parol" }
```
**Javob:** `{ "status": true, "result": { "message": "Parol muvofaqiyatli yangilandi!", "token": "..." } }`

> Javobda token keladi — foydalanuvchi darhol tizimga kiritiladi, qayta login talab qilinmaydi.

### 5.8 Pincode va biometrika

| Talab | Tavsif |
|-------|--------|
| O'rnatish | Profil → Sozlamalar → "Pincode" yoki login'dan keyingi taklif ekrani |
| Uzunlik | 4 raqam |
| Saqlash | `POST /auth/app-settings-update-or-create/{userId}` orqali serverga + lokal `flutter_secure_storage` ga |
| Tekshirish | Offline: lokal secure storage bilan solishtiriladi (asosiy usul). Online tekshiruv: `POST /auth/login-pincode/{user_id}` → `{ "pincode": "1234" }` |
| Biometrika | Face ID / Touch ID / Fingerprint — pincode o'rnatilgan bo'lsa yoqiladi (`local_auth`) |
| Xato urinishlar | 5 marta xato → pincode ekrani bloklanadi → "Parol bilan kirish" ga majburiy o'tish (logout) |
| Qachon so'raladi | Ilova sovuq ishga tushganda va fondan qaytganda (background'da > 60 soniya bo'lsa) |

> ⚠️ Backend pincode'ni **ochiq matnda** saqlaydi va login'da NULL qiladi. Shuning uchun mobil tomonda pincode **faqat qulflash mexanizmi** sifatida ishlatiladi, autentifikatsiya vositasi sifatida emas — token har doim asosiy hisoblanadi.

### 5.9 Chiqish (Logout)

**So'rov:** `GET /api/auth/logout/{device_token}` — URL da FCM token uzatiladi.

**Ilova bajaradi:** qurilma tokenini serverdan o'chiradi → **barcha lokal ma'lumotlarni tozalaydi** (token, pincode, kesh, user profili) → Login ekraniga qaytadi.

> Backend bu chaqiruvda foydalanuvchining **barcha** tokenlarini o'chiradi.

### 5.10 Hisobni o'chirish (App Store/Play Store talabi)

Profil → Sozlamalar → "Hisobni o'chirish" → **ikki bosqichli tasdiq** (checkbox + "O'CHIRISH" so'zini yozish yoki parol kiritish) → `DELETE /api/auth/delete-account` → to'liq lokal tozalash → Login ekrani.

Ekranda ogohlantirish: "Barcha hamkorlar, tranzaksiyalar, loyihalar va hisobotlar o'chiriladi. Bu amalni qaytarib bo'lmaydi."

### 5.11 Qabul qilish mezonlari (AC) — Auth

- **AC-5.1** Yangi raqam kiritilganda ilova OTP → ro'yxatdan o'tish oqimiga o'tadi va Dashboard ochiladi.
- **AC-5.2** Mavjud raqam kiritilganda parol ekrani ochiladi; xato parolda "Authorization failed!" ko'rsatiladi.
- **AC-5.3** OTP ekranida timer 60 soniya sanaydi; tugagach qayta yuborish ishlaydi.
- **AC-5.4** `verify_token` 2 daqiqadan keyin ishlatilsa xatolik ko'rsatiladi va oqim boshidan boshlanadi.
- **AC-5.5** 401 kelganda ilova avtomatik logout qiladi va login ekraniga qaytadi.
- **AC-5.6** Login'dan keyin pincode NULL bo'lgani uchun ilova pincode qayta o'rnatishni taklif qiladi.
- **AC-5.7** Hisobni o'chirish oqimi ikki bosqichli tasdiq bilan ishlaydi.

---

## 6. MODUL 2 — ROLLAR, RUXSATLAR VA OWNER-KONTEKST

### 6.1 `me()` — profil va ruxsatlar manbai

**So'rov:** `GET /api/auth/me`

**Javob:**
```json
{
  "status": true,
  "result": {
    "user_id": 8,
    "name": "Abdulloh",
    "image": null,
    "phone": "901234567",
    "role": ["staff", "user"],
    "permissions": ["partners.view", "partners.create", "..."],
    "works_for": [
      {
        "owner_id": 5,
        "owner_name": "Sarvar",
        "owner_phone": "991234567",
        "permissions": ["partners.view", "wallets_debt.create"]
      }
    ],
    "app_settings": { "language": "uz", "mode": "light", "pincode": null },
    "x_ziffler": true
  }
}
```

**Maydonlar mantiqi:**

| Maydon | Ma'nosi |
|--------|---------|
| `role` | `user` = o'z hisobi bor; `staff` = kimningdir xodimi; ikkalasi ham bo'lishi mumkin |
| `permissions` | **O'z hisobida** ishlaganda amal qiluvchi ruxsatlar (owner uchun — barchasi) |
| `works_for` | Qaysi ownerlar uchun xodim ekanligi va **o'sha kontekstdagi** ruxsatlar |
| `app_settings` | Til, mavzu, pincode (serverdagi holat) |
| `x_ziffler` | To'lov bo'limini ko'rsatish/yashirish bayrog'i (`false` bo'lsa — to'lov UI si yashiriladi) |

> `me()` **har safar ilova ishga tushganda va foreground'ga qaytganda** chaqiriladi. Ruxsatlar o'zgargan bo'lishi mumkin (owner ularni istalgan vaqtda o'zgartiradi va bunda xodimning tokenlari o'chiriladi → 401).

### 6.2 Hisob tanlash ekrani

`me()` javobiga qarab:

| Holat | Ilova xatti-harakati |
|-------|---------------------|
| `works_for` bo'sh | To'g'ridan-to'g'ri Dashboard (o'z hisobi) |
| `role` faqat `["staff"]` | Avtomatik xodim rejimi: `X-As-Owner = works_for[0].owner_id` |
| `role` = `["user","staff"]` | **Hisob tanlash ekrani**: "O'z hisobim" + har bir owner uchun karta ("Sarvar — xodim") |
| `works_for` da bir nechta owner | Har biri alohida karta |

Tanlangan kontekst lokal saqlanadi va ilovaning yuqori qismida doimiy ko'rsatkich bo'ladi: **"Sarvar hisobida ishlayapsiz"** + "Almashish" tugmasi. Kontekst almashtirilganda barcha kesh tozalanadi va ekranlar qayta yuklanadi.

### 6.3 `X-As-Owner` header qoidalari

| Rejim | Header |
|-------|--------|
| O'z hisobi | Header **yuborilmaydi** (yoki o'z `user_id` si yuboriladi — backend ikkalasini ham qabul qiladi) |
| Xodim rejimi | `X-As-Owner: {owner_id}` — **barcha** so'rovlarda (auth endpointlaridan tashqari) |

**Xatolik:** header noto'g'ri owner bilan yuborilsa → **403** `{"success": false, "message": "Bu akkauntga kirish huquqi yo'q."}` → ilova kontekstni tozalab, hisob tanlash ekraniga qaytaradi.

> ⚠️ `X-As-Owner` header **`/api/auth/*` guruhida ishlamaydi** (u yerda `owner.context` middleware yo'q). Ya'ni xodim `POST /auth/staff` orqali xodim qo'sha olmaydi — bu amallar har doim **o'z** hisobida bajariladi. Xodimlar boshqaruvi bo'limi xodim rejimida **yashiriladi**.

### 6.4 Ruxsatlar (Permissions) — to'liq ro'yxat

| Kategoriya | Permission | UI dagi nomi |
|-----------|-----------|--------------|
| **Mijozlar** | `partners.view` | Ko'rish |
| | `partners.create` | Qo'shish |
| | `partners.edit` | Tahrirlash |
| | `partners.delete` | O'chirish |
| **Mijoz (kirim-chiqim)** | `wallets_debt.create` | Kirim qilish |
| | `wallets_debt.cancel` | Kirimni bekor qilish |
| | `wallets_credit.create` | Chiqim qilish |
| | `wallets_credit.cancel` | Chiqimni bekor qilish |
| **Loyihalar** | `projects.view` / `.create` / `.edit` / `.delete` | Ko'rish / Qo'shish / Tahrirlash / O'chirish |
| **Bo'lib to'lash** | `installments.view` / `.create` / `.edit` / `.delete` | Ko'rish / Qo'shish / Tahrirlash / Bekor qilish |
| | `installments.payment` | To'lov qabul qilish |
| | `installments.cancel_payment` | To'lovni bekor qilish |
| **Hisobotlar** | `report_partners.view` | Mijozlar hisoboti |
| | `report_partner.view` | Bitta mijoz hisoboti |
| | `report_project.view` | Loyiha hisoboti |
| | `report_installments.view` | Bo'lib to'lash hisoboti |
| **Profil** | `plan_about.view` | Tarif muddatini ko'rish |
| | `plan_limit.view` | Tarif limitlarini ko'rish |

> Ruxsatlar ro'yxatini serverdan olish: `GET /api/auth/staff/permissions` (kategoriyalar bo'yicha guruhlangan, xodim qo'shish formasi uchun).

### 6.5 UI da ruxsatlarni qo'llash qoidalari

1. **Ko'rish ruxsati yo'q** → menyu banddi/tab umuman **ko'rsatilmaydi**.
2. **Yaratish/tahrirlash ruxsati yo'q** → tugma **ko'rsatilmaydi** (disabled emas, yashiriladi).
3. Ruxsat bo'lmagan holda serverdan 403 kelsa — snackbar: "Bu amalni bajarish uchun ruxsatingiz yo'q."
4. Ruxsatlar manbai: xodim rejimida — `works_for[i].permissions`, o'z hisobida — `permissions`.
5. Ruxsatlar tekshiruvi UI qatlamida markazlashgan `PermissionGuard` widget/utility orqali amalga oshiriladi.

**Kirim/Chiqim uchun maxsus qoida:** Kirim va chiqim ruxsatlari **alohida**. Masalan, xodimda faqat `wallets_debt.create` bo'lsa — hamkor kartochkasida faqat "Kirim" tugmasi ko'rinadi, "Chiqim" ko'rinmaydi.

### 6.6 AC — Rollar

- **AC-6.1** `role` da `user` va `staff` bo'lsa hisob tanlash ekrani ko'rsatiladi.
- **AC-6.2** Xodim rejimida barcha so'rovlarda `X-As-Owner` yuboriladi va owner ma'lumotlari ko'rinadi.
- **AC-6.3** Ruxsati yo'q bo'lgan bo'lim/tugma UI da umuman ko'rinmaydi.
- **AC-6.4** Owner ruxsatlarni o'zgartirsa (xodim tokeni o'chadi) → xodim ilovasi 401 oladi → logout.
- **AC-6.5** Xodim rejimida "Xodimlar" bo'limi ko'rinmaydi.

---

## 7. MODUL 3 — DASHBOARD (BOSH SAHIFA)

### 7.1 Ekran tarkibi

**Endpoint:** `GET /api/reports/dashboard`

**Javob:**
```json
{
  "status": true,
  "result": {
    "partners": {
      "partners_count": 42,
      "details": {
        "qarz_expired":        { "count": 3, "type": "qarz_expired" },
        "qarz_today":          { "count": 1, "type": "qarz_today" },
        "qarz_3_days":         { "count": 5, "type": "qarz_3_days" },
        "installment_expired": { "count": 2, "type": "installment_expired" },
        "installment_today":   { "count": 0, "type": "installment_today" },
        "installment_3_days":  { "count": 4, "type": "installment_3_days" }
      }
    },
    "projects": { "projects_count": 7, "in_progress": 4, "frozen": 1, "completed": 2 }
  }
}
```

**Ekran bloklari:**

1. **Header:** Salomlashish + foydalanuvchi ismi + bildirishnoma ikonkasi (o'qilmaganlar soni badge bilan) + kontekst indikatori (xodim rejimida).
2. **Obuna banneri** (agar `X-Subscription-Status != ACTIVE`).
3. **"Hamkorlar" bloki:** umumiy soni + 3 ta karta:
   - 🔴 Muddati o'tgan qarzlar — `qarz_expired`
   - 🟡 Bugun muddati — `qarz_today`
   - 🟢 3 kun ichida — `qarz_3_days`
4. **"Bo'lib to'lash" bloki:** 3 ta karta (`installment_expired`, `installment_today`, `installment_3_days`).
5. **"Loyihalar" bloki:** umumiy soni + status bo'yicha (jarayonda / muzlatilgan / tugallangan).
6. **Tezkor amallar (FAB yoki gorizontal tugmalar):** "Kirim", "Chiqim", "Hamkor qo'shish" — ruxsatga qarab.
7. **Qo'llanmalar bloki:** `GET /api/reports/app/tutorials` → `[{title, url}]` → YouTube havolasini tashqi brauzerda ochish.

**Muhim:** Har bir kartadagi `count = 0` bo'lsa karta **kulrang** (bosilmaydigan) bo'ladi.

### 7.2 Detal ekranlar (kartani bosganda)

**A) Qarz muddatlari detali**
```http
GET /api/reports/dashboard/due-dates?type=qarz_expired   // qarz_today | qarz_3_days
```
Javob — `simplePaginate` (15 ta), har bir element:
```json
{
  "id": 12, "wallet_id": 45, "partner_id": 7,
  "partner_name": "Alibek", "partner_phone": "901234567",
  "files": [], "type": "credit",
  "scheduled_amount": "1000000.00", "remaining_amount": "600000.00", "paid_amount": "400000.00",
  "currency_type_id": 1, "currency_type_name": "UZS",
  "due_date": "01.09.2026",
  "days_overdue": 6, "days_left": null,
  "status": "Muddati o'tgan",
  "created_at": "01.08.2026",
  "activity": { "action": "created", "performed_by": {...}, "created_at": "..." }
}
```

**B) Bo'lib to'lash muddatlari detali**
```http
GET /api/reports/dashboard/installments/due-dates?type=installment_expired
// installment_today | installment_3_days
```
Element tarkibi: `item_number`, `is_advance`, `amount`, `paid_amount`, `remaining`, `due_date`, `status`, `status_label`, `days_overdue`, `days_left`, `plan_id`, `partner_*`, `plan_total`, `plan_paid`, `plan_remaining`, `plan_status`.

**UI:** Har bir qator — hamkor ismi, summa, muddat, kechikish kuni (qizil badge). Bosilganda hamkor kartochkasiga yoki bo'lib to'lash rejasiga o'tadi. Qatorda tezkor amallar: 📞 qo'ng'iroq, 💬 SMS/Telegram, 💵 "Kirim kiritish".

### 7.3 AC — Dashboard

- **AC-7.1** Ilova ochilganda dashboard 2 soniyadan kam vaqtda yuklanadi (yaxshi tarmoqda).
- **AC-7.2** Pull-to-refresh barcha bloklarni yangilaydi.
- **AC-7.3** Har bir karta to'g'ri `type` parametri bilan detal ekranini ochadi.
- **AC-7.4** `count = 0` kartalar bosilmaydi.
- **AC-7.5** Xodim rejimida owner ma'lumotlari ko'rsatiladi.

---

## 8. MODUL 4 — HAMKORLAR (MIJOZLAR) VA KIRIM/CHIQIM

> Bu ilovaning **asosiy moduli**. Barcha e'tibor va sifat shu yerga qaratiladi.

### 8.1 Biznes model va balans mantiqi

| Tur | Backend qiymati | Ma'nosi | Balansga ta'siri |
|-----|-----------------|---------|------------------|
| **Chiqim** | `credit` | Hamkorga qarzga berildi (pul/tovar) | Balansni **kamaytiradi** |
| **Kirim** | `debt` | Hamkordan to'lov qabul qilindi | Balansni **oshiradi** |

```
Balans = SUM(debt) − SUM(credit)      // bekor qilinganlar hisobga olinmaydi

Balans > 0  →  "Xaqdor"   (hamkor bizga qarzdor)
Balans < 0  →  "Qarzdor"  (biz hamkorga qarzdormiz)
Balans = 0  →  "Hisob-kitob yopiq"
```

**Muhim qoidalar:**
1. Balans **har bir valyuta uchun alohida** hisoblanadi (UZS va USD hech qachon qo'shilmaydi/konvertatsiya qilinmaydi).
2. `is_cancelled = true` tranzaksiyalar barcha hisob-kitoblardan **chiqariladi**.
3. `credit` + `return_date` bo'lsa → backend avtomatik `CreditSchedule` (muddatli qarz) yaratadi.
4. `debt` (kirim) kiritilganda → **FIFO** algoritmi eng eski muddatli qarzdan boshlab yopadi.

### 8.2 Ekran: Hamkorlar ro'yxati (asosiy ekran)

**Endpoint:** `GET /api/partners/partners/account`

**Query parametrlar:**

| Parametr | Tur | Tavsif |
|----------|-----|--------|
| `search` | string (max 255) | Ism / telefon / qo'shimcha telefon bo'yicha |
| `date[0]`, `date[1]` | date | Hamkor qo'shilgan sana oralig'i |
| `status_filter` | `xaqdor` \| `qarzdor` \| `muddati_otgan_qarzdor` | Holat filtri |
| `sort` | `qarzdor_uzs` \| `qarzdor_usd` \| `xaqdor_uzs` \| `xaqdor_usd` | Saralash |
| `page` | int | simplePaginate, 15 ta |

Standart saralash (sort berilmasa) — **oxirgi faollik bo'yicha** (`last_activity_at DESC`).

**Javob elementi:**
```json
{
  "id": 7,
  "name": "Alibek Toshmatov",
  "phone": "901234567",
  "additional_phone": null,
  "files": [{ "id": 3, "url": "https://...", "type": "..." }],
  "main_currency_type_id": 1,
  "main_currency_type_name": "UZS",
  "balance": { "UZS": 1500000, "USD": -200 },
  "installment_remaining": { "UZS": 400000, "USD": 0 },
  "send_on_kirim": true,
  "send_on_chiqim": true,
  "created_at": "01.08.2026",
  "deleted_at": null,
  "activity": { "action": "created", "performed_by": { "id": 8, "name": "Abdulloh" }, "created_at": "..." }
}
```

**UI talablari:**

- Har bir hamkor kartasi: avatar/bosh harf, ism, telefon, **balans** (UZS va USD alohida qatorlar; 0 bo'lgan valyuta ko'rsatilmaydi).
- Balans rangi: musbat — yashil ("Xaqdor"), manfiy — qizil ("Qarzdor"), 0 — kulrang.
- `installment_remaining` > 0 bo'lsa — "Bo'lib to'lash: 400 000 UZS" qo'shimcha qatori (ko'k).
- `deleted_at != null` → karta o'chirilgan deb belgilanadi (kulrang + "O'chirilgan" chipi) va faqat "Tiklash" amali mavjud.
- Yuqorida: qidiruv maydoni (debounce 400ms), filtr ikonkasi (bottom sheet), saralash ikonkasi.
- Bo'sh holat: illustratsiya + "Hamkor qo'shish" tugmasi.
- FAB: "Hamkor qo'shish" (`partners.create` ruxsati bo'lsa).
- Yuqori o'ng burchakda: "Excel'ga eksport" (`GET /api/partners/partners/export/excel`).

> ⚠️ **Backend cheklovi:** `GET /api/partners/partner/status-filter-options` endpointi route konflikti sababli **ishlamaydi** (`partner/{id}` bilan to'qnashadi). Filtr variantlari ilovada lokal ravishda hardcode qilinadi: `xaqdor` → "Xaqdorlar", `qarzdor` → "Qarzdorlar", `muddati_otgan_qarzdor` → "Muddati o'tgan qarzdorlar".

### 8.3 Ekran: Hamkor yaratish / tahrirlash

**Yaratish:** `POST /api/partners/partner`  |  **Tahrirlash:** `PUT /api/partners/partner/{id}`

```json
{
  "name": "Alibek Toshmatov",
  "phone": "901234567",
  "additional_phone": "935554433",
  "currency_type_id": 1,
  "file_id": [3, 4]
}
```

| Maydon | Validatsiya (backend) | UI |
|--------|----------------------|-----|
| `name` | required, unique (bir user ichida) | Matn maydoni |
| `phone` | required, **max 9 belgi**, unique (bir user ichida) | Telefon maskasi, 9 raqam |
| `additional_phone` | nullable, max 255 | Telefon maskasi |
| `currency_type_id` | required, mavjud bo'lishi kerak | Dropdown (asosiy valyuta) — `GET /documents/currencies` |
| `file_id[]` | nullable, massiv | Fayl/rasm biriktirish (avval `/files/upload`) |

**Xatoliklar:** `Bu nomli hamkor allaqachon mavjud.`, `Bu telefon raqamli hamkor allaqachon mavjud.`

**Limit xatosi (obuna):** HTTP 200 + `status: false`:
> "Yangi hamkor qo'shish uchun limitingiz tugagan. Yangi hamkor qo'shish uchun tarif rejangizni yangilang!"

→ Ilova dialog ko'rsatadi: xabar + **"Tariflarni ko'rish"** tugmasi (Obuna ekraniga o'tadi).

**Tahrirlash cheklovi:** o'chirilgan (soft-deleted) hamkorni tahrirlab bo'lmaydi — `"O'chirilgan hamkorni tahrirlash mumkin emas"`.

### 8.4 Boshqa hamkor amallari

| Amal | Endpoint | Izoh |
|------|----------|------|
| Ko'rish | `GET /api/partners/partner/{id}` | Bitta hamkor ma'lumoti |
| O'chirish (soft) | `DELETE /api/partners/partner/{id}` | Tasdiqlash dialogi majburiy |
| Tiklash | `POST /api/partners/partner/{id}/restore` | O'chirilganlar ro'yxatidan |
| Butunlay o'chirish | `DELETE /api/partners/partner/{id}/force-delete` | **Qaytarib bo'lmaydi** — ikki bosqichli tasdiq |
| Ro'yxat (soddalashtirilgan) | `GET /api/partners/partners?search=` | Dropdown/selectorlar uchun (balanssiz, paginatsiyasiz) |

### 8.5 Ekran: Hamkor kartochkasi (Partner Detail)

Ekran **3 ta tabdan** iborat: **Tranzaksiyalar** | **Bo'lib to'lash** | **SMS tarixi**

**Yuqori blok (hisob) — `GET /api/partners/partner/{partnerId}/account`:**
```json
{
  "status": true,
  "result": {
    "uzs_account": { "debt": 5000000, "credit": 3500000, "balance": 1500000, "balance_with_installment": 400000 },
    "usd_account": { "debt": 0, "credit": 200, "balance": -200, "balance_with_installment": 0 }
  }
}
```
- `debt` = jami kirim, `credit` = jami chiqim, `balance` = kirim − chiqim,
- `balance_with_installment` = faol bo'lib to'lash rejalari bo'yicha **qolgan qarz**.
- UZS va USD bloklari alohida kartalarda; qiymati 0 bo'lgan valyuta yashiriladi.

**Tezkor amallar paneli:** 📞 Qo'ng'iroq · ✉️ SMS · 📊 Hisobot · ⬇️ Excel · ⚙️ SMS sozlamalari · ✏️ Tahrirlash

### 8.6 Tab 1: Tranzaksiyalar ro'yxati

**Endpoint:** `GET /api/partners/wallets`

| Parametr | Majburiy | Tavsif |
|----------|----------|--------|
| `partner_id` | **ha** | Hamkor ID |
| `search` | yo'q | Summa yoki izoh bo'yicha |
| `date[0]`, `date[1]` | yo'q | Format **`dd.mm.yyyy`** |
| `type` | yo'q | `debt` \| `credit` \| `is_cancelled` |
| `currency_type_id` | yo'q | 1 yoki 2 |
| `is_cancelled` | yo'q | bool |

> Bu endpoint **paginatsiyasiz** — barcha tranzaksiyalar bir marta keladi. Ko'p yozuvli hamkorlarda ro'yxat uzun bo'lishi mumkin, shuning uchun ilovada **lazy rendering** (`ListView.builder`) va sana bo'yicha filtr sukut bo'yicha **oxirgi 3 oy** qilib qo'yiladi.

**Element (WalletResource):**
```json
{
  "id": 45, "partner_id": 7, "partner_name": "Alibek",
  "currency_type_id": 1, "currency_type_name": "UZS",
  "summa": "1000000.00", "description": "Tovar uchun",
  "files": [], "return_date": "2026-10-01",
  "type": "credit", "is_cancelled": false, "cancel_reason": null,
  "created_at": "01.09.2026 10:15:00", "deleted_at": null,
  "activity": { "action": "created", "performed_by": {...}, "created_at": "..." }
}
```

**UI:**
- Kunlar bo'yicha guruhlangan ro'yxat (sticky header: "Bugun", "Kecha", "12.09.2026").
- Kirim (`debt`) — ⬇️ yashil, "+1 000 000 UZS"; Chiqim (`credit`) — ⬆️ qizil, "−1 000 000 UZS".
- `return_date` bor bo'lsa: "Qaytarish: 01.10.2026" + muddat holati badge (muddati o'tgan — qizil, bugun — sariq, kelajak — kulrang).
- `is_cancelled = true` → yozuv **ustidan chizilgan**, "Bekor qilingan" chipi + sabab.
- `activity.performed_by.name` — "Abdulloh kiritdi" (xodim kiritgan bo'lsa) qatori.
- Fayl biriktirilgan bo'lsa — 📎 ikonka, bosilganda galereya/preview.

### 8.7 Kirim/Chiqim yaratish (eng muhim forma)

**Endpoint:** `POST /api/partners/wallet`

```json
{
  "partner_id": 7,
  "currency_type_id": 1,
  "summa": 1000000,
  "type": "credit",
  "description": "Tovar uchun",
  "return_date": "2026-10-01",
  "file_id": [3]
}
```

| Maydon | Validatsiya | UI |
|--------|-------------|-----|
| `partner_id` | required, integer | Oldindan to'ldirilgan (hamkor kartochkasidan) |
| `currency_type_id` | required, integer | Segment tugma: UZS / USD (default — hamkorning asosiy valyutasi) |
| `summa` | required, decimal | **Katta shrift**, raqamli klaviatura, avtomatik uch xonali ajratish, 0 dan katta bo'lishi client-side tekshiriladi |
| `type` | required | Segment: "Kirim" / "Chiqim" (yoki alohida tugmadan kirilganda qulflangan) |
| `description` | nullable | Ko'p qatorli izoh |
| `return_date` | nullable, date (`yyyy-mm-dd`) | **Faqat `type = credit` bo'lganda ko'rsatiladi.** Tez tanlash chiplari: "1 hafta", "2 hafta", "1 oy", "Sana tanlash" |
| `file_id[]` | nullable | Kamera/galereya/fayl |

**Ruxsat tekshiruvi (client + server):**
- `type = credit` → `wallets_credit.create`
- `type = debt` → `wallets_debt.create`
- Ruxsat yo'q bo'lsa server **403** qaytaradi: `{"status": false, "message": "Bu amalni bajarish uchun ruxsatingiz yo'q."}`

**Server tomonda avtomatik sodir bo'ladigan ishlar (foydalanuvchiga ko'rsatiladi):**
1. `credit` + `return_date` → muddatli qarz grafigi yaratiladi.
2. `debt` → FIFO bo'yicha eski qarzlar avtomatik yopiladi.
3. **Hamkorga SMS yuboriladi** — agar hamkorning SMS sozlamasi yoqilgan bo'lsa (`enabled` + `send_on_kirim`/`send_on_chiqim`) **va** obunada SMS limiti qolgan bo'lsa.

**UX talabi:** Saqlash tugmasi ostida kichik izoh: *"Hamkorga SMS xabar yuboriladi"* — agar shu hamkor uchun tegishli SMS sozlamasi yoqilgan bo'lsa. SMS limiti tugagan bo'lsa (obuna statistikasidan bilinadi): *"SMS limiti tugagan — xabar yuborilmaydi"*.

**Muvaffaqiyatdan keyin:** forma yopiladi, ro'yxat yangilanadi, hisob bloki qayta yuklanadi, snackbar: "Saqlandi".

### 8.8 Tranzaksiyani tahrirlash va bekor qilish

**Tahrirlash:** `PUT /api/partners/wallet/{id}` — body `store` bilan bir xil.

> ⚠️ **Kirim (`debt`) turini tahrirlab BO'LMAYDI.** Server xatolik qaytaradi: *"To'lovni tahrirlash mumkin emas. Iltimos, bekor qilib qaytadan kiriting."* — Ilova kirim yozuvlarida "Tahrirlash" tugmasini **umuman ko'rsatmaydi**, faqat "Bekor qilish" ni ko'rsatadi.

**Bekor qilish:** `PUT /api/partners/wallet/{id}/cancel`
```json
{ "cancel_reason": "Xato kiritildi" }
```
- Sabab — ixtiyoriy, lekin UI da **majburiy** qilinadi (kamida 3 belgi) — audit uchun.
- Ruxsat: `credit` → `wallets_credit.cancel`, `debt` → `wallets_debt.cancel`.
- Server: `credit` bekor qilinsa — muddat grafigi o'chiriladi; `debt` bekor qilinsa — FIFO taqsimoti qaytariladi.
- Bekor qilingan yozuv ro'yxatda qoladi (ustidan chizilgan holda) — **o'chirilmaydi**.

**O'chirish/tiklash:** `DELETE /api/partners/wallet/{id}`, `POST .../restore`, `DELETE .../force-delete` — faqat owner uchun ko'rsatiladi.

### 8.9 Tab 3: SMS tarixi

**Endpoint:** `GET /api/reports/partners/sended-sms/{partnerId}` (simplePaginate, 20)
```json
{ "id": 5, "message": "Hurmatli Alibek...", "status": "success", "sent_at": "01.09.2026 10:00:00" }
```
UI: xabar matni, yuborilgan vaqti, holat ikonkasi (✅ success / ❌ failed).

### 8.10 SMS sozlamalari (hamkor bo'yicha)

**Olish:** `GET /api/partners/partner/settings/{partnerId}`
```json
{
  "status": true,
  "result": {
    "body": {
      "send_on_kirim": true, "send_on_chiqim": true,
      "remind_before_days": 1, "send_on_due_date": true, "send_after_due_days": 1,
      "enabled": true, "send_date": "10:00"
    },
    "options": { "remind_before_days": [1, 3, 5], "send_after_due_days": [1, 3, 5] }
  }
}
```

**Saqlash:** `PUT /api/partners/partner/settings/{partnerId}` — **barcha maydonlar majburiy**:
```json
{
  "send_on_kirim": true, "send_on_chiqim": true,
  "remind_before_days": 3, "send_on_due_date": true,
  "send_after_due_days": 1, "enabled": true
}
```

| Maydon | Diapazon | UI |
|--------|----------|-----|
| `enabled` | bool | Asosiy toggle — o'chirilsa qolganlari disabled |
| `send_on_kirim` | bool | "Kirim qilinganda SMS" |
| `send_on_chiqim` | bool | "Chiqim qilinganda SMS" |
| `remind_before_days` | 0–30 | Chip tanlov: `options` dan (1, 3, 5) |
| `send_on_due_date` | bool | "Muddat kunida eslatish" |
| `send_after_due_days` | 0–30 | Chip tanlov: `options` dan (1, 3, 5) |
| `send_date` | read-only | "SMS yuborish vaqti: 10:00" — faqat ko'rsatiladi |

> SMS yuborish obuna limitiga bog'liq. Ekran pastida joriy SMS limiti ko'rsatiladi (`GET /subscription/get-statistics` dan): "Bu oy: 12/50 SMS ishlatildi" + "SMS paket sotib olish" havolasi.

### 8.11 AC — Hamkorlar

- **AC-8.1** Ro'yxat 15 talik sahifalar bilan yuklanadi, oxirigacha scroll qilinganda keyingisi qo'shiladi.
- **AC-8.2** Qidiruv 400ms debounce bilan ishlaydi, natija almashtiriladi (qo'shilmaydi).
- **AC-8.3** UZS va USD balanslar hech qachon qo'shilmaydi.
- **AC-8.4** Chiqim yaratishda `return_date` maydoni ko'rinadi, kirimda ko'rinmaydi.
- **AC-8.5** Kirim yozuvida "Tahrirlash" tugmasi yo'q.
- **AC-8.6** Bekor qilingan tranzaksiya ustidan chizilgan holda ko'rinadi va balansga ta'sir qilmaydi.
- **AC-8.7** Limit tugaganda "Tariflarni ko'rish" tugmali dialog chiqadi.
- **AC-8.8** Ruxsati yo'q bo'lgan kirim/chiqim tugmasi ko'rinmaydi.
- **AC-8.9** SMS sozlamalarida `enabled = false` bo'lsa boshqa switchlar disabled bo'ladi.

---

## 9. MODUL 5 — BO'LIB TO'LASH (INSTALLMENT)

> Batafsil API namunalari: `docs/installment_api.md`. Bu bo'limda mobil ekranlar va biznes qoidalar.

### 9.1 Biznes model

**Reja (Plan)** = jami summa + valyuta + grafik turi + qismlar (items).

**Grafik turlari:**

| Tur | `schedule_type` | Tavsif |
|-----|-----------------|--------|
| Teng | `equal` | Tizim qismlarni teng bo'lib, sanalarni avtomatik hisoblaydi (har oy) |
| Erkin | `custom` | Har bir qismning summasi va sanasi qo'lda kiritiladi |

**Avans (`has_advance`)** — ikkala turda ham mavjud. Yoqilsa:
- 1-qism = avans, **darhol to'langan** deb belgilanadi (`is_advance=true`, `status=paid`),
- `equal` da: avans sanasi = `start_date`, qolgan qismlar har oy (+1 oy, +2 oy...),
- reja `paid_amount` avans summasiga teng bo'lib boshlanadi.

**`installment_count` semantikasi (`equal` uchun) — muhim:**

| Holat | `installment_count` ma'nosi | Yaratiladigan qismlar soni | Minimum |
|-------|---------------------------|---------------------------|---------|
| `has_advance = false` | Jami qismlar soni | `installment_count` | **2** |
| `has_advance = true` | Avansdan **keyingi** oylar soni | `installment_count + 1` | **1** |

**Misol:** 500 000 UZS, avans 100 000, `installment_count = 4` → jami **5 ta qism**: avans 100 000 + 4 × 100 000.

**Yaxlitlash qoidasi:** oxirgi qism yaxlitlash farqini o'ziga oladi (qismlar yig'indisi har doim jami summaga teng).

### 9.2 Qism holatlari (Item status)

| Status | Label | Rang | Ma'nosi |
|--------|-------|------|---------|
| `pending` | Kutilmoqda | Kulrang | Muddat hali uzoq |
| `near` | Yaqinlashdi | Sariq | Muddatga ≤ 7 kun (scheduler kunlik o'rnatadi) |
| `overdue` | Muddati o'tdi | Qizil | Muddat o'tgan |
| `partial` | Qisman to'langan | Ko'k | Qisman to'lov qilingan |
| `paid` | To'langan | Yashil | To'liq to'langan |

**Reja holatlari:** `active` (Faol) · `completed` (To'liq to'langan) · `cancelled` (Bekor qilingan).

### 9.3 Ekran: Bo'lib to'lash rejalari ro'yxati

**Endpoint:** `GET /api/partners/installments`

| Parametr | Qiymatlar |
|----------|-----------|
| `partner_id` | int |
| `status` | `active` \| `completed` \| `cancelled` |
| `currency_type_id` | 1 \| 2 |
| `schedule_type` | `equal` \| `custom` |
| `search` | izoh (`note`) bo'yicha |
| `per_page` | 1–100 (default 20) |

**Element:** `id`, `partner_id`, `partner_name`, `currency_type_*`, `total_amount`, `paid_amount`, `remaining`, `schedule_type`, `has_advance`, `advance_amount`, `start_date`, `note`, `files`, `status`, `status_label`, `items_count`, `created_at`, `activity`.

**UI:** karta ko'rinishi — hamkor ismi, jami summa, **progress bar** (`paid_amount / total_amount`), qolgan summa, qismlar soni, holat chipi. Yuqorida filtr chiplari (Faol / Yopilgan / Bekor qilingan).

### 9.4 Ekran: Reja yaratish (Wizard — 3 qadam)

**Qadam 1 — Asosiy ma'lumot:** hamkor (majburiy), valyuta, jami summa, izoh, fayl.

**Qadam 2 — Grafik turi:**
- Segment: "Teng" / "Erkin"
- Toggle: "Avans bor" → avans summasi (jami summadan **kichik** bo'lishi shart)
- `equal` uchun: boshlanish sanasi (**bugundan kichik bo'lmasligi kerak**) + qismlar soni (stepper)
- `custom` uchun: qismlar ro'yxati (har biriga summa + sana + izoh), "+ Qism qo'shish" tugmasi

**Qadam 3 — Ko'rib chiqish:** hisoblangan grafikni jadval ko'rinishida ko'rsatish (raqam, summa, sana, avans belgisi) + jami tekshiruv.

> `equal` turida grafik **client-side** ham hisoblanadi (preview uchun) — server bilan bir xil algoritm: har oy +1 oy, oxirgi qism yaxlitlash farqini oladi.

**So'rov:** `POST /api/partners/installments`
```json
{
  "partner_id": 7,
  "currency_type_id": 1,
  "total_amount": 500000,
  "schedule_type": "equal",
  "has_advance": true,
  "advance_amount": 100000,
  "start_date": "2026-10-01",
  "installment_count": 4,
  "note": "Muzlatgich",
  "file_ids": [3]
}
```
`custom` uchun `start_date`/`installment_count` o'rniga:
```json
"items": [
  { "amount": 200000, "due_date": "2026-10-15", "note": "Birinchi" },
  { "amount": 300000, "due_date": "2026-11-15" }
]
```

**Validatsiya qoidalari (client-side ham tekshiriladi):**

| Qoida | Xato xabari |
|-------|-------------|
| `custom`: qismlar yig'indisi = jami summa (±0.01) | "Qismlar yig'indisi jami summaga teng bo'lishi kerak." |
| Avans < jami summa | "Avans summasi jami summadan kichik bo'lishi kerak." |
| `custom`: kamida **2 ta** qism | "Kamida 2 ta qism kiritilishi kerak." |
| `equal` + avanssiz: `installment_count` ≥ **2** | "Avans bilan kamida 1 ta qism, avansiz kamida 2 ta qism bo'lishi kerak." |
| Barcha sanalar ≥ bugun | "To'lov sanasi bugundan kichik bo'lishi mumkin emas." |
| `total_amount` ≥ 1 | "Jami summa 0 dan katta bo'lishi kerak." |

**Yaratilgandan keyin:** hamkorga avtomatik SMS ketadi (reja rasmiylashtirildi). Ilova buni forma pastida oldindan ma'lum qiladi.

### 9.5 Ekran: Reja tafsilotlari

**Endpoint:** `GET /api/partners/installments/{id}` (items bilan birga)

**Ekran tuzilishi:**
1. **Yuqori blok:** hamkor, jami / to'langan / qolgan, progress bar, holat chipi, izoh, fayllar.
2. **Grafik (items ro'yxati):** har bir qator — raqam, summa, `due_date`, holat chipi, `paid_amount`/`remaining`. Avans qismi "Avans" belgisi bilan. Muddati o'tganlar qizil chiziq bilan ajratiladi.
3. **Tugmalar:** "To'lov qabul qilish" (faol rejada, `installments.payment`), "To'lovlar tarixi", "Tahrirlash" (faqat izoh/fayl), "Bekor qilish" (faqat owner).

**Qismlarni alohida olish:** `GET /api/partners/installments/{id}/items`

### 9.6 To'lov qabul qilish

**Endpoint:** `POST /api/partners/installments/{id}/payment`
```json
{ "amount": 100000, "note": "Naqd", "paid_at": "2026-10-15" }
```

| Maydon | Talab |
|--------|-------|
| `amount` | **required**, decimal, min 1 |
| `note` | nullable |
| `paid_at` | **required**, date — ⚠️ backend validatsiyasi majburiy qiladi, shuning uchun **har doim yuboriladi** (odatda bugungi sana) |

**Biznes qoidalar:**
- To'lov **qolgan qarzdan oshib ketmasligi** kerak → *"To'lov summasi qolgan qarzdan oshib ketmasligi kerak."*
- Faqat `active` rejaga to'lov qabul qilinadi → *"Faqat faol rejalarga to'lov qabul qilinadi."*
- To'lov **FIFO** bo'yicha taqsimlanadi: eng eski `due_date` li qismdan boshlab. Qisman to'lov qo'llab-quvvatlanadi.
- Barcha qismlar yopilsa reja avtomatik `completed` bo'ladi.
- Hamkorga SMS ketadi (to'lov qabul qilindi / reja yopildi).

**UI:** Modal bottom sheet — katta summa maydoni + tez tanlash chiplari ("Keyingi qism summasi", "Barcha qolgan qarz") + izoh + sana (default bugun). Saqlashdan oldin **preview**: "Ushbu to'lov 2-qismni to'liq, 3-qismni qisman yopadi" (client-side FIFO hisobi).

**Javob:** yangilangan reja (items bilan) → ekran darhol yangilanadi.

### 9.7 To'lovlar tarixi va to'lovni bekor qilish

**Tarix:** `GET /api/partners/installments/{id}/payment-history`
```json
{
  "id": 3, "received_by": 8, "received_by_name": "Abdulloh",
  "amount": "100000.00", "plan_paid_before": "100000.00", "plan_paid_after": "200000.00",
  "note": "Naqd", "is_cancelled": false, "cancelled_by": null, "cancelled_by_name": null,
  "cancelled_at": null, "created_at": "15.10.2026 12:00:00"
}
```

**Bekor qilish:** `DELETE /api/partners/installments/{planId}/payments/{paymentId}`

> ⚠️ **Faqat oxirgi (bekor qilinmagan) to'lovni** bekor qilish mumkin: *"Faqat oxirgi to'lovni bekor qilish mumkin."* — Ilova faqat oxirgi to'lov kartasida "Bekor qilish" tugmasini ko'rsatadi.

### 9.8 Rejani tahrirlash va bekor qilish

- **Tahrirlash:** `PUT /api/partners/installments/{id}` — faqat `note` va `file_ids`. **Summa, grafik, sanalar o'zgartirilmaydi.** UI da faqat shu ikki maydon tahrirlanadi.
- Bekor qilingan rejani tahrirlab bo'lmaydi: *"Bekor qilingan rejani tahrirlash mumkin emas."*
- **Bekor qilish:** `DELETE /api/partners/installments/{id}` — reja `cancelled` holatiga o'tadi. Faqat **owner** bajaradi (xodimga tugma ko'rsatilmaydi). Tasdiqlash dialogi majburiy.

### 9.9 Hamkorning barcha rejalari

`GET /api/partners/partner/{partnerId}/installments` — hamkor kartochkasidagi "Bo'lib to'lash" tabi uchun (items bilan, paginatsiyasiz).

### 9.10 AC — Bo'lib to'lash

- **AC-9.1** `equal` turida client-side preview server yaratgan grafik bilan **to'liq mos** keladi (summalar va sanalar).
- **AC-9.2** Avansli rejada 1-qism "To'langan" holatida yaratiladi.
- **AC-9.3** `custom` da qismlar yig'indisi jami summaga teng bo'lmasa saqlash tugmasi bloklanadi.
- **AC-9.4** To'lov qolgan qarzdan katta bo'lsa forma xatolik ko'rsatadi (serverga so'rov ketmaydi).
- **AC-9.5** To'lovdan keyin progress bar va qismlar holati darhol yangilanadi.
- **AC-9.6** Faqat oxirgi to'lovda "Bekor qilish" tugmasi ko'rinadi.
- **AC-9.7** Rejani bekor qilish tugmasi xodimda ko'rinmaydi.

---

## 10. MODUL 6 — LOYIHALAR

### 10.1 Biznes model

Loyiha = obyekt (qurilish/xizmat). Har bir loyihada:
- **Shartnomalar** (`project_contracts`) — ish turi bo'yicha kelishilgan summa,
- **Daromadlar** (`project_incomes`) — loyihadan kelgan pul,
- **Xarajatlar** (`project_costs`) — xarajat turi bo'yicha; ishchiga bog'lanishi mumkin,
- **Ishchilar** (`projects_workers`) — loyihaga biriktirilgan ishchilar.

```
Loyiha balansi (valyuta bo'yicha) = SUM(daromad) − SUM(xarajat)
```

**Holatlar:** `in_progress` (Jarayonda) · `frozen` (Muzlatilgan) · `completed` (Tugallangan).

### 10.2 Ekran: Loyihalar ro'yxati

**Endpoint:** `GET /api/project/projects` (simplePaginate, 10)

| Parametr | Tavsif |
|----------|--------|
| `search` | Loyiha nomi bo'yicha |
| `status` | `in_progress` \| `frozen` \| `completed` |
| `date[0]`, `date[1]` | Format `dd.mm.yyyy` |

**Element:** `id`, `project_name`, `project_owner`, `phone`, `address`, `location`, `files`, `status` (label matn), `created_at`, `deleted_at`, `activity`.

**UI:** karta — loyiha nomi, buyurtmachi, telefon, holat chipi (rangli), manzil. Filtr chiplari yuqorida. FAB — "Loyiha qo'shish" (`projects.create`).

**Holatlar ro'yxati:** `GET /api/project/project-statuses` → `[{ "value": "in_progress", "label": "Jarayonda" }, ...]`

### 10.3 Loyiha CRUD

**Yaratish:** `POST /api/project/project`
```json
{
  "project_name": "Chilonzor 12-uy",
  "project_owner": "Aziz aka",
  "phone": "901112233",
  "address": "Toshkent, Chilonzor",
  "location": "41.3111,69.2401",
  "file_id": [5]
}
```
| Maydon | Validatsiya |
|--------|-------------|
| `project_name` | required, max 255, **unique** (bir user ichida) |
| `project_owner` | required, max 255 |
| `phone` | required, max 20 |
| `address`, `location` | nullable, max 255 |

> `location` — `"lat,lng"` matn. Ilova xaritadan tanlash imkonini beradi (ixtiyoriy) va karta ustida "Xaritada ochish" tugmasini ko'rsatadi.

**Boshqa amallar:** `PUT /project/project/{id}`, `DELETE /project/project/{id}`, `POST .../restore`, `DELETE .../force-delete`, `PUT /project/project/{id}/update-status` (`{"status": "completed"}`).

**Limit xatosi:** "Yangi loyiha qo'shish uchun limitingiz tugagan..." → Tariflar ekraniga havola.

### 10.4 Ekran: Loyiha kartochkasi

**Endpoint:** `GET /api/project/project/{id}` — javobda `accounts` bloki bor (daromad/xarajat/balans, UZS va USD bo'yicha).

**Tab lar:** Shartnomalar | Daromadlar | Xarajatlar | Ishchilar

**A) Shartnomalar**
- Ro'yxat: `GET /api/project/project-contracts?project_id={id}&search=`
- Yaratish: `POST /api/project/project-contract` → `{ work_type_id, description (required), summa, project_id, file_id[] }`
- Element: `work_type_id`, `work_type_name`, `description`, `summa`, `files`, `activity`.

**B) Daromadlar**
- Ro'yxat: `GET /api/project/project-incomes?project_id={id}&search=`
- Yaratish: `POST /api/project/project-income` → `{ currency_type_id, summa, description, project_id, file_id[] }`

**C) Xarajatlar**
- Ro'yxat: `GET /api/project/project-costs?project_id={id}&search=&cost_type_id=`
- Yaratish: `POST /api/project/project-cost` → `{ cost_type_id, currency_type_id, summa, description, project_id, worker_id?, file_id[] }`
- ⚠️ `worker_id` berilsa — ishchi **shu loyihaga biriktirilgan** bo'lishi shart (server tekshiradi). Shuning uchun ishchi tanlash dropdown'i faqat `GET /project/project/{projectId}/workers` dan keladigan ro'yxatdan to'ldiriladi.
- Xarajat turi `is_worker_join = true` bo'lsa — ishchi tanlash maydoni **ko'rsatiladi**, aks holda yashiriladi.

**D) Ishchilar**
- Ro'yxat: `GET /api/project/project/{projectId}/workers`
- Qo'shish: `POST /api/project/worker-add-to-project` → `{ "worker_ids": [1,2], "project_id": 5 }` (ko'p tanlovli)
- Olib tashlash: `POST /api/project/worker-remove-from-project` → `{ "worker_ids": [1], "project_id": 5 }`
- Tanlash oynasida hali biriktirilmagan ishchilarni olish: `GET /api/documents/workers?worker_not_in_project_id={projectId}`

Barcha yozuvlar uchun `update`, `destroy`, `restore`, `force-delete` endpointlari mavjud (12.x va Appendix A ga qarang).

### 10.5 AC — Loyihalar

- **AC-10.1** Loyiha nomi takrorlansa server xatosi ko'rsatiladi.
- **AC-10.2** Holat o'zgartirilganda ro'yxat va karta darhol yangilanadi.
- **AC-10.3** Xarajatda ishchi tanlash faqat loyihaga biriktirilgan ishchilardan mumkin.
- **AC-10.4** `is_worker_join = false` bo'lgan xarajat turida ishchi maydoni ko'rinmaydi.
- **AC-10.5** Loyiha kartasida UZS/USD balanslar alohida ko'rsatiladi.

---

## 11. MODUL 7 — MA'LUMOTNOMALAR (DOCUMENTS)

Profil → "Ma'lumotnomalar" bo'limi. Barcha ma'lumotnomalarda **bir xil** CRUD naqshi: `index`, `store`, `show`, `update`, `destroy`, `restore`, `force-delete`.

| Ma'lumotnoma | Endpoint prefiksi | Maydonlar | Izoh |
|--------------|-------------------|-----------|------|
| Valyutalar | `/documents/currency`, ro'yxat: `/documents/currencies` | `name` | Global; `id=1` UZS, `id=2` USD |
| Ish turlari | `/documents/work-type`, ro'yxat: `/documents/work-types` | `name`, `description` | Shartnomalarda ishlatiladi |
| Xarajat turlari | `/documents/cost-type`, ro'yxat: `/documents/cost-types` | `name`, `description`, `is_worker_join` | `is_update_and_delete=false` bo'lsa — tizim yozuvi, tahrirlanmaydi |
| Lavozimlar | `/documents/worker-position`, ro'yxat: `/documents/worker-positions` | `name`, `description` | Ishchilar uchun |
| Ishchilar | `/documents/worker`, ro'yxat: `/documents/workers` | `name`, `phone` (max 9, unique), `additional_phone`, `worker_position_id`, `description`, `file_id[]` | Loyihalarga biriktiriladi |

**Nomlar `user_id` bo'yicha unique** — takrorlanganda server xatosi ko'rsatiladi.

⚠️ **Backend nomuvofiqligi:** ish turini butunlay o'chirish endpointi `DELETE /api/documents/work/{id}/force-delete` (`work-type` emas). Ilova aynan shu manzilni ishlatadi.

**Valyuta kurslari (CBU):**
- Joriy kurslar: `GET /api/documents/currencys-exchange-rates` → `[{ Ccy, CcyNm_RU, CcyNm_UZ, Nominal, Rate, Diff, Date }]` (USD, EUR, RUB, KZT, KGS)
- Sana bo'yicha: `GET /api/currency-calc/cbu-rates/{date}` (`date` = `yyyy-MM-dd`)
- UI: kurslar ro'yxati + o'sish/pasayish ko'rsatkichi (`Diff`) + oddiy konvertor (kalkulyator).

**Keshlash:** ma'lumotnomalar lokal bazada saqlanadi va ilova ochilganda bir marta yangilanadi; CRUD amalidan keyin darhol qayta yuklanadi.

---

## 12. MODUL 8 — HISOBOTLAR

Hisobotlar 3 ta katta bo'limga bo'linadi. Kirish `report_*` ruxsatlariga bog'liq.

### 12.1 Hamkorlar hisoboti — V3 (asosiy)

**Hisobot turlari ro'yxati:** `GET /api/reports/partners-v3/summary-report-types`
→ `[{ "name": "Muddat hisoboti", "description": "..." }, ...]`

**A) Umumiy hisobot** — `GET /api/reports/partners-v3/summary`
```json
{
  "status": true,
  "result": {
    "UZS": {
      "debt": "15000000", "credit": "8000000", "balance": "7000000.00",
      "partners_count": 42,
      "operations":  { "count": 120, "type": "oparation" },
      "xaqdorlar":   { "count": 18,  "type": "xaqdor" },
      "qarzdorlar":  { "count": 7,   "type": "qarzdor" }
    },
    "USD": { ... }
  }
}
```
**UI:** valyuta tabi (UZS/USD) → 3 ta KPI karta (Kirim / Chiqim / Balans) + 3 ta bosiladigan karta (Operatsiyalar / Xaqdorlar / Qarzdorlar).

**Detal:** `GET /api/reports/partners-v3/summary-qarzdor-xaqdor-details?type=xaqdor&currency_type_id=1`
→ simplePaginate: hamkorlar ro'yxati balans bilan (kamayish tartibida).

**B) Muddat kesimida (davr bo'yicha)**
- Xulosalar: `GET /api/reports/partners-v3/periods?date[0]=01.09.2026&date[1]=30.09.2026` → UZS/USD bo'yicha `debt`/`credit`
- Operatsiyalar: `GET /api/reports/partners-v3/periods-operations?currency_type_id=1&type=debt&date[0]=..&date[1]=..` (simplePaginate)
- **UI:** yuqorida davr tanlash (Bugun / Hafta / Oy / Ixtiyoriy), ostida kirim/chiqim kartalari, ostida operatsiyalar ro'yxati (`debt`/`credit` filtri bilan).

**C) Qarz muddatlari bo'yicha**
- Xulosalar: `GET /api/reports/partners-v3/warranty-periods` → UZS/USD × (`qarz_expired`, `qarz_today`, `qarz_3_days`) sonlari
- Detal: `GET /api/reports/partners-v3/warranty-periods-details?type=qarz_expired&currency_type_id=1`

**D) Xodimlar kesimida**
- Umumiy: `GET /api/reports/partners-v3/workers?date[0]=..&date[1]=..`
- Xodimlar ro'yxati: `GET /api/reports/partners-v3/workers-lists?currency_type_id=1&date[0]=..&date[1]=..`
  → `[{ id, name, role, debt, credit, operations_count }]`
- Xodim xulosasi: `GET /api/reports/partners-v3/workers-details->summary?worker_id=8&date[..]`
- Xodim operatsiyalari: `GET /api/reports/partners-v3/workers-details->operations?worker_id=8&currency_type_id=1&type=debt&date[..]`

> ⚠️ **Diqqat:** oxirgi ikkita URL da `->` belgisi bor (`workers-details->summary`). Bu backenddagi manzilning aynan o'zi. HTTP klientda URL **encode qilinmasligi** kerak yoki `%3E` sifatida yuborilishi test qilinishi shart. Integratsiya bosqichida backend jamoasi bilan tekshiriladi.

### 12.2 Hamkor bo'yicha detal hisobot — V2

- **Asosiy:** `GET /api/reports/partners-v2/partner-details/{partnerId}`
  Javob (UZS va USD bo'yicha alohida): `balance`, `income`, `expense`, `operations_count`, `qarz_expired`, `qarz_today`, `qarz_3_days`, **`monthly_statistics`** (oxirgi 3 oy — bar chart uchun), **`balance_dynamics`** (oxirgi 7 kun — line chart uchun).
- **Detal:** `GET /api/reports/partners-v2/partner-details-section-one?partner_id=7&type=oparation&currency_type_id=1`
  (`type`: `oparation` | `qarz_expired` | `qarz_today` | `qarz_3_days`)

**UI:** grafiklar (`fl_chart`): 3 oylik ustunli diagramma (kirim/chiqim), 7 kunlik balans chizig'i. Grafiklar interaktiv (tap → qiymat tooltip).

> V2 ning `summary` endpointlari (`/partners-v2/summary*`) V3 bilan takrorlanadi. **1.0 versiyada faqat V3 ishlatiladi**, V2 dan faqat `partner-details*` olinadi.

### 12.3 Bo'lib to'lash hisobotlari

Batafsil: `docs/installment_reports_api.md`.

| Hisobot | Endpoint | Mazmuni |
|---------|----------|---------|
| Umumiy ko'rinish | `GET /api/reports/installments/summary` | Valyuta bo'yicha: faol/yopilgan/bekor rejalar, berilgan/to'langan/qolgan, muddati o'tgan summa |
| Hamkorlar bo'yicha | `GET /api/reports/installments/partners?currency_type_id=&sort=remaining\|overdue\|total_given` | Hamkorlar reytingi |
| Kutilayotgan to'lovlar | `GET /api/reports/installments/forecast?date_from=&date_to=&currency_type_id=` | Davr ichida kutilayotgan summa |
| Muammoli hamkorlar | `GET /api/reports/installments/risky-partners?currency_type_id=` | `risk_score`, `risk_level`, o'rtacha kechikish |
| Undirish samaradorligi | `GET /api/reports/installments/recovery` | `recovery_rate`, `overdue_rate`, `rating_label`, `by_items` |
| Oylik dinamika | `GET /api/reports/installments/monthly?year=2026&currency_type_id=` | 12 oylik to'lovlar |
| Status bo'yicha qismlar | `GET /api/reports/installments/items?status=paid\|partial\|overdue\|pending` | Recovery kartasi detali |
| Hamkor bo'yicha | `GET /api/reports/installments/partner/{partnerId}?year=&currency_type_id=&status=` | Mobil ekran spetsifikatsiyasi: `docs/installment_partner_report_mobile.md` |

**UI:** har bir hisobot alohida ekran; valyuta tabi; kartalar bosilganda tegishli detal ro'yxatiga o'tish; `risk_level` va `rating_label` rangli chiplar bilan.

### 12.4 Loyihalar hisoboti

| Hisobot | Endpoint | Parametrlar |
|---------|----------|-------------|
| Loyiha balansi | `GET /api/reports/projects/balance` | `project_id` (required) |
| Daromadlar detali | `GET /api/reports/projects/income-details` | `project_id`, `date[0]`, `date[1]` |
| Xarajatlar detali | `GET /api/reports/projects/cost-details` | `project_id`, `cost_type_id`, `date[..]` |
| Ishchilar xarajatlari | `GET /api/reports/projects/workers-costs` | `project_id` |
| Ishchi detali | `GET /api/reports/projects/workers-costs-details` | `project_id`, `worker_id`, `date[..]` |

Balans javobida: `income_uzs/usd`, `costs` (jami + `details[]` xarajat turlari bo'yicha), `balance_uzs/usd`.
**UI:** doiraviy diagramma (xarajat turlari bo'yicha ulushlar) + jadval.

### 12.5 Umumiy hisobot UX qoidalari

1. Har bir hisobot ekranida yuqorida **valyuta tabi** (UZS/USD) — barcha hisobotlar valyuta bo'yicha ajratilgan.
2. Davr tanlash komponenti yagona: **Bugun / Hafta / Oy / Ixtiyoriy davr**. Sana `dd.mm.yyyy` formatida yuboriladi (V3 va loyiha hisobotlarida — `date[0]`, `date[1]`).
3. Ma'lumot yo'q bo'lsa — bo'sh holat illustratsiyasi, "0" ko'rsatilmaydi.
4. Barcha KPI kartalar bosiladigan bo'lsa — detal ekranga o'tadi (`type` parametri bilan).
5. Hisobotlar keshlanmaydi; pull-to-refresh mavjud.
6. Katta raqamlar qisqartirilmaydi (`1 500 000`, `1.5M` emas).

### 12.6 AC — Hisobotlar

- **AC-12.1** Valyuta tabi almashtirilganda barcha ko'rsatkichlar tegishli valyutaga o'zgaradi.
- **AC-12.2** Davr filtri hisobotdan hisobotga o'tganda saqlanadi (sessiya davomida).
- **AC-12.3** Grafiklar (3 oy / 7 kun) to'g'ri masshtabda chiziladi va bo'sh ma'lumotda ham buzilmaydi.
- **AC-12.4** `report_*` ruxsati yo'q xodimda tegishli hisobot bo'limi ko'rinmaydi.

---

## 13. MODUL 9 — OBUNA, TARIFLAR VA TO'LOV

### 13.1 Obuna modeli

**Statuslar va o'tishlar:**

| Status | Ma'nosi | Ilova xatti-harakati |
|--------|---------|---------------------|
| `ACTIVE` | Faol | To'liq ish |
| `GRACE_PERIOD` | Imtiyozli davr (**7 kun**) | Sariq banner + yangilash taklifi; funksiyalar ishlaydi |
| `READ_ONLY` | Faqat ko'rish (**30 kun**) | Qizil banner; **yaratish/tahrirlash bloklangan** |
| `ARCHIVED` | Arxiv (**120 kundan keyin**) | Bloklovchi ekran |
| `DELETED` | O'chirilgan | Bloklovchi ekran |

**To'lov davrlari:** `MONTHLY`, `SEMI_ANNUAL` (6 oy), `ANNUAL` (12 oy).

**Standart tariflar (backend seed):**

| Tarif | Oylik | Hamkor | Loyiha | Xodim | SMS/oy |
|-------|-------|--------|--------|-------|--------|
| FREE (Bepul) | 0 | 10 | 1 | 0 | 5 |
| STANDARD | 27 000 | 100 | 5 | 1 | 50 |
| PROFESSIONAL | 54 000 | 300 | 15 | 3 | 200 |
| BUSINESS | 108 000 | ∞ (-1) | ∞ (-1) | 5 | 400 |

> `-1` = cheksiz. Ilova `-1` ni "Cheksiz" deb ko'rsatadi.

### 13.2 Ekran: Mening obunam

**Endpoint:** `GET /api/subscription/show`
```json
{
  "status": true,
  "result": {
    "has_subscription": true,
    "subscription": {
      "id": 12,
      "plan": { "id": 2, "name": "STANDARD", "display_name": "Standart" },
      "status": "ACTIVE", "status_label": "Faol",
      "billing_cycle": "MONTHLY",
      "current_period": { "start": "01.09.2026", "end": "01.10.2026" },
      "next_billing_date": "01.10.2026",
      "days_until_due": 24, "is_overdue": false, "days_past_due": 0,
      "usage": {
        "customers": { "current": 42, "max": 100, "percentage": 42, "can_add": true },
        "projects":  { "current": 3,  "max": 5,   "percentage": 60, "can_add": true },
        "users":     { "current": 1,  "max": 1,   "percentage": 100,"can_add": false },
        "sms":       { "current": 12, "max": 50, "remaining": 38, "percentage": 24, "can_send": true }
      },
      "last_payment": { "date": "01.09.2026", "amount": 27000, "method": "CLICK" }
    }
  }
}
```
**Faqat statistika:** `GET /api/subscription/get-statistics` → yuqoridagi `usage` blokining o'zi.

**UI:** joriy tarif kartasi (nomi, holat chipi, amal qilish muddati, "N kun qoldi" progress) + **4 ta limit progress bari** (hamkorlar, loyihalar, xodimlar, SMS). ≥80% da sariq, 100% da qizil + "Tarifni oshirish" tugmasi.

### 13.3 Ekran: Tariflar

**Ro'yxat:** `GET /api/pricing-plans` (FREE ko'rsatilmaydi)

Har bir tarifda 3 ta narx varianti (`monthly_price`, `semi_annual_price`, `annual_price`), har birida:
```json
{ "currently_subscribed": false, "amount": 113400, "formatted": "113 400 UZS",
  "discount": 30, "description": "48 600 so'm tejab qoling!", "description1": "" }
```
Shuningdek: `max_customers`, `max_projects`, `max_users`, `sms_per_month`, `features`, `currently_subscribed`, **`can_subscribe`**, **`downgrade_warnings`**.

**⚠️ Downgrade cheklovi:** `can_subscribe = false` bo'lsa tarif tanlanmaydi. `downgrade_warnings[]` dagi xabarlar ko'rsatiladi, masalan:
> "Hamkorlar soni 100 tadan oshib ketgan (hozir: 142)"

Tanlash tugmasi disabled + tushuntirish matni.

**Tafsilot:** `GET /api/pricing-plans/{id}` — narxlar + `payment_methods: ["PAYME","CLICK"]`.

**UI:** davr tanlash segmenti (Oylik / 6 oylik / Yillik) → tariflar kartalari (chegirma badgei bilan) → "Tanlash" tugmasi. Joriy tarif "Joriy tarifingiz" belgisi bilan.

### 13.4 To'lov oqimi

**1-qadam:** `POST /api/subscription/purchase`
```json
{ "plan_id": 2, "billing_cycle": "MONTHLY", "payment_provider": "click", "return_url": "ehisob://payment-result" }
```
**Javob:** `{ "order_id": 55, "order_number": "ORD-...", "amount": 27000, "payment_url": "https://..." }`

**2-qadam:** `payment_url` ni ochish:
- **Tavsiya:** `flutter_custom_tabs` / `SFSafariViewController` (tashqi brauzer) — bank ilovalariga deep-link o'tish uchun eng ishonchli usul.
- WebView ishlatilsa: `return_url` ga qaytishni ushlab qolish, JS va cookie yoqilgan bo'lishi kerak.

**3-qadam:** Foydalanuvchi qaytgach yoki 5 soniyalik interval bilan **polling**:
```http
GET /api/subscription/check-order-status/{order_number}
→ { "status": true, "result": { "order_number": "...", "status": "PAID" | "PENDING" | "FAILED" } }
```
- `PAID` → ✅ muvaffaqiyat ekrani → `GET /subscription/show` yangilanadi → banner yo'qoladi. Foydalanuvchiga push xabarnoma ham keladi.
- `PENDING` → pollingni davom ettirish (**maks. 2 daqiqa**), keyin "To'lov tekshirilmoqda, biroz kuting" holati + qo'lda "Tekshirish" tugmasi.
- `FAILED` → ❌ xatolik ekrani + "Qayta urinish".

### 13.5 SMS paketlari

- Ro'yxat: `GET /api/pricing-sms` → `[{ id, name, display_name, description, price, formatted_price, sms_count }]`
  (seed: SMS 10 — 2 500 so'm, SMS 50 — 12 500, SMS 100 — 25 000)
- Sotib olish: `POST /api/pricing-sms/purchase` → `{ "sms_package_id": 2, "payment_provider": "payme", "return_url": "..." }` → keyingi oqim tarif sotib olish bilan **bir xil**.

SMS paketlari joriy obunaga qo'shiladi (`extra_sms`).

### 13.6 Limit xatoliklari katalogi

| Holat | Server xabari (HTTP 200, `status:false`) | UI reaksiyasi |
|-------|------------------------------------------|---------------|
| Obuna yo'q | "Faol obuna topilmadi. Xizmatdan foydalanish uchun tarif rejasini tanlang!" | Tariflar ekraniga o'tkazuvchi dialog |
| READ_ONLY | "Tarif rejangiz muddati tugagan. Amallarni bajarish uchun tarif rejangizni yangilang!" | Xuddi shunday |
| Hamkor limiti | "Yangi hamkor qo'shish uchun limitingiz tugagan..." | Xuddi shunday |
| Loyiha limiti | "Yangi loyiha qo'shish uchun limitingiz tugagan..." | Xuddi shunday |
| Xodim limiti | "Yangi xodim qo'shish uchun limitingiz tugagan..." | Xuddi shunday |

### 13.7 To'lov UI ni yashirish bayrog'i

`me()` javobidagi `x_ziffler = false` bo'lsa — **to'lov bilan bog'liq barcha UI** (tariflar, sotib olish tugmalari, SMS paketlari) yashiriladi. Bu store-review va maxsus hisoblar uchun ishlatiladi.

### 13.8 AC — Obuna

- **AC-13.1** Limitlar progress barlarda to'g'ri foizda ko'rsatiladi; `-1` "Cheksiz" deb chiqadi.
- **AC-13.2** `can_subscribe = false` tarifni tanlab bo'lmaydi va sabab ko'rsatiladi.
- **AC-13.3** To'lovdan keyin polling ishlaydi va `PAID` da obuna ma'lumoti yangilanadi.
- **AC-13.4** `READ_ONLY` holatida yaratish tugmalari ishlamaydi va banner ko'rinadi.
- **AC-13.5** `x_ziffler = false` da to'lov bo'limlari umuman ko'rinmaydi.

---

## 14. MODUL 10 — BILDIRISHNOMALAR (PUSH)

### 14.1 Firebase Cloud Messaging

**Sozlash:** Android `google-services.json`, iOS `GoogleService-Info.plist` + APNs key. Ruxsat so'rash — birinchi ishga tushirishda emas, **login'dan keyin** kontekstli tushuntirish bilan (iOS talabi).

**Token boshqaruvi:**
- FCM token login/register so'rovida `device_token` sifatida yuboriladi.
- Token yangilansa (`onTokenRefresh`) — qayta login qilish shart emas, lekin ilova buni lokal saqlaydi va keyingi login'da yuboradi.
- Logout: `GET /api/auth/logout/{device_token}`.
- ⚠️ Backend **bir vaqtda 1 ta faol qurilma** saqlaydi (yangi qurilma qo'shilganda eski deaktiv qilinadi).

### 14.2 Bildirishnomalar ro'yxati

- Ro'yxat: `GET /api/notifications` (Laravel paginator, 20) — `notification` obyekti bilan (`type`, `title`, `body`, `data`, `image_url`, `created_at`) + `is_read`, `read_at`.
- O'qilmaganlar soni: `GET /api/notifications/unread-count` → `{ "unread_count": 3 }`
- O'qilgan deb belgilash: `POST /api/notifications/{id}/mark-as-read` (bu yerda `{id}` — **notification_id**).

> `POST /notifications/send*` endpointlari — admin uchun, mobil ilovada **ishlatilmaydi**.

### 14.3 Push turlari va navigatsiya (deep link)

| `type` | Sarlavha misoli | Bosilganda |
|--------|-----------------|-----------|
| `subscription` | "Yangi obuna sotib olindi" | Obuna ekrani |
| `sms_purchase` | "Yangi SMS paketi sotib olindi" | Obuna/SMS ekrani |
| `news`, `system`, `alert`, `promotion` | E'lonlar | Bildirishnoma tafsiloti |

`data` obyektida qo'shimcha maydonlar bo'lsa (masalan `partner_id`, `plan_id`) — tegishli ekranga navigatsiya qilinadi. Noma'lum `type` — bildirishnomalar ro'yxati ochiladi.

### 14.4 Xatti-harakat

- **Foreground:** local notification (banner) ko'rsatiladi + badge yangilanadi.
- **Background/terminated:** OS bildirishnomasi; bosilganda tegishli ekran (cold start'da ham `initialMessage` ishlanadi).
- Badge (bottom nav "Profil" yoki Dashboard'dagi qo'ng'iroq ikonkasi) — `unread-count` bo'yicha; ilova foreground'ga qaytganda va push kelganda yangilanadi.

### 14.5 AC — Push

- **AC-14.1** Login'dan keyin FCM token serverga yuboriladi.
- **AC-14.2** Push kelganda badge yangilanadi.
- **AC-14.3** Push bosilganda to'g'ri ekran ochiladi (ilova yopiq holatda ham).
- **AC-14.4** Bildirishnoma ochilganda `mark-as-read` chaqiriladi va ro'yxat yangilanadi.

---

## 15. MODUL 11 — XODIMLAR BOSHQARUVI

> Faqat **owner** uchun. Xodim rejimida bu bo'lim ko'rinmaydi.

### 15.1 Xodim qo'shish oqimi (3 qadam)

**1-qadam:** `POST /api/auth/staff/send-otp` → `{ "phone": "901234567" }` → xodim telefoniga OTP.
**2-qadam:** `POST /api/auth/staff/verify-otp` → `{ "phone": "...", "otp_code": "1234" }` → `{ "verify_token": "..." }` (**5 daqiqa** amal qiladi).
**3-qadam:** `POST /api/auth/staff`
```json
{
  "phone": "901234567",
  "verify_token": "a3f9c2...",
  "name": "Abdulloh",
  "password": "secret123",
  "permissions": ["partners.view", "wallets_debt.create"]
}
```
`permissions` — **kamida 1 ta** bo'lishi shart.

**Muhim biznes qoidalar (UI da ogohlantirish sifatida ko'rsatiladi):**
1. Agar telefon raqami tizimda mavjud bo'lsa — **uning ismi va paroli yangilanadi**.
2. Xodim boshqa ownerda ishlayotgan bo'lsa — **eski ownerdan avtomatik chiqariladi**.
3. Xodimning barcha tokenlari o'chiriladi (u qayta login qilishi kerak).
4. Owner o'zini xodim qilib qo'sha olmaydi: *"O'zingizni xodim sifatida qo'sha olmaysiz"*.

**Forma UI:** telefon → OTP → ism, parol → **ruxsatlar** (kategoriyalar bo'yicha guruhlangan checkbox ro'yxati, `GET /api/auth/staff/permissions` dan). Har bir kategoriyada "Barchasini tanlash" mavjud.

### 15.2 Xodimlar ro'yxati va tahrirlash

- Ro'yxat: `GET /api/auth/staff` → `[{ id, is_active, user_id, name, phone, permissions[], created_at }]`
- Yangilash: `PUT /api/auth/staff/{id}` → `{ "permissions": [...], "is_active": true }`
  > ⚠️ Yangilashda xodimning tokenlari o'chiriladi → u qayta login qilishi kerak. UI da ogohlantirish ko'rsatiladi.
- O'chirish: `DELETE /api/auth/staff/{id}` — tasdiqlash dialogi bilan.

**UI:** xodim kartasi — ism, telefon, faollik switchi, ruxsatlar soni ("8 ta ruxsat"), bosilganda ruxsatlarni tahrirlash ekrani.

**Limit:** xodim qo'shish tarif limitiga bog'liq (`max_users`). Limit tugasa tegishli xabar + Tariflar.

### 15.3 O'z hisobini faollashtirish (xodim uchun)

Agar foydalanuvchi faqat `staff` roliga ega bo'lsa, u o'z biznesini ham yuritishni xohlashi mumkin:

`POST /api/auth/activate-own-account` (body kerak emas) → `user` roli beriladi + FREE obuna yaratiladi.

**UI:** Profil → "O'z hisobimni ochish" tugmasi (faqat `role` da `user` yo'q bo'lganda ko'rinadi) → tushuntirish + tasdiqlash → muvaffaqiyatdan keyin `me()` qayta chaqiriladi va hisob tanlash ekrani paydo bo'ladi.

### 15.4 AC — Xodimlar

- **AC-15.1** Xodim qo'shish 3 qadamda ishlaydi, `verify_token` 5 daqiqa amal qiladi.
- **AC-15.2** Ruxsatlarsiz saqlash mumkin emas (kamida 1 ta).
- **AC-15.3** Ruxsat o'zgartirilganda ogohlantirish ko'rsatiladi.
- **AC-15.4** Bo'lim faqat ownerda ko'rinadi.
- **AC-15.5** "O'z hisobimni ochish" faqat `user` roli yo'q foydalanuvchida ko'rinadi.

---

## 16. MODUL 12 — FAOLLIK JURNALI (ACTIVITY LOG)

**Endpoint:** `GET /api/activity-logs`

| Filtr | Qiymatlar |
|-------|-----------|
| `action` | `created` \| `updated` \| `cancelled` \| `deleted` \| `restored` |
| `model_type` | `Wallet`, `Partner`, `Project`, `InstallmentPlan` ... (qisman moslik) |
| `performed_by` | user_id |
| `date_from`, `date_to` | `yyyy-mm-dd` |
| `per_page` | default 20 |

**Javob (maxsus paginatsiya formati):**
```json
{
  "status": true,
  "result": {
    "data": [{
      "id": 15, "action": "cancelled", "model_type": "Wallet", "model_id": 23,
      "performed_by": { "id": 8, "name": "Abdulloh", "phone": "901234567" },
      "description": { "cancel_reason": "Xato kiritildi" },
      "created_at": "2026-03-11T10:25:00.000000Z"
    }],
    "pagination": { "total": 150, "per_page": 20, "current_page": 1, "last_page": 8 }
  }
}
```

**UI:** vaqt bo'yicha timeline; har bir yozuv — amal ikonkasi (rangli), o'zbekcha matn ("Abdulloh tranzaksiyani bekor qildi"), obyekt turi, vaqt. Filtr bottom sheet orqali. Yozuv bosilganda — imkon bo'lsa tegishli obyektga o'tish.

**Amallar lug'ati (UI matnlari):**
| `action` | Matn |
|----------|------|
| `created` | yaratdi |
| `updated` | tahrirladi |
| `cancelled` | bekor qildi |
| `deleted` | o'chirdi |
| `restored` | tikladi |

> Har bir ro'yxat elementida (`WalletResource`, `PartnerAccountResource` va h.k.) `activity` maydoni bor — **oxirgi amal**. UI da "Abdulloh kiritdi · 12.09.2026" kabi kichik matn sifatida ko'rsatiladi.

---

## 17. MODUL 13 — PROFIL VA SOZLAMALAR

### 17.1 Profil ekrani tuzilishi

```
[Avatar + Ism + Telefon]
  ├── Shaxsiy ma'lumotlar
  ├── Obuna va tariflar          (x_ziffler = true bo'lsa)
  ├── SMS paketlari              (x_ziffler = true bo'lsa)
  ├── Xodimlar                   (faqat owner)
  ├── Ma'lumotnomalar
  ├── Faollik jurnali
  ├── Bildirishnomalar
  ├── Valyuta kurslari
  ├── Qo'llanmalar (video)
  ├── Sozlamalar
  │     ├── Til (uz / ru / en)
  │     ├── Mavzu (Light / Dark / Tizim)
  │     ├── Pincode va biometrika
  │     └── Bildirishnomalar (OS sozlamalariga o'tish)
  ├── Yordam va aloqa (Telegram / qo'ng'iroq)
  ├── Foydalanish shartlari va Maxfiylik siyosati
  ├── Ilova versiyasi
  ├── Chiqish
  └── Hisobni o'chirish
```

### 17.2 Shaxsiy ma'lumotlarni tahrirlash

| Amal | Endpoint | Body |
|------|----------|------|
| Ismni o'zgartirish | `PUT /api/auth/update-profile-info` | `{ "name": "Yangi ism" }` |
| Parolni o'zgartirish | `POST /api/auth/update-password` | `{ "old_password": "...", "new_password": "..." }` |

**Telefon raqamni o'zgartirish (3 qadam):**
1. `POST /api/auth/update-profile-phone-verify` → `{ "phone": "935554433" }`
   - `result.page = "otp_verify"` → yangi raqam bo'sh, davom etish mumkin
   - `status: false` → "Bu telefon raqam boshqa foydalanuvchi tomonidan ishlatilmoqda!"
2. `POST /api/auth/otp` → `{ "phone": "935554433" }` — yangi raqamga OTP
3. `POST /api/auth/update-profile-phone-check-otp` → `{ "phone": "935554433", "otp_code": "1234" }` → raqam yangilanadi

> Muvaffaqiyatdan keyin `me()` qayta chaqiriladi va profil yangilanadi.

**Xatoliklar:** `Eski parol noto'g'ri!`

### 17.3 Ilova sozlamalari

**Endpoint:** `POST /api/auth/app-settings-update-or-create/{userId}`
```json
{ "language": "uz", "mode": "dark", "pincode": "1234" }
```
| Maydon | Qiymatlar |
|--------|-----------|
| `language` | `uz` \| `ru` \| `en` |
| `mode` | `light` \| `dark` |
| `pincode` | 4 raqam yoki `null` |

> ⚠️ Backend `updateOrCreate` ishlatadi va **yuborilmagan maydonni `null` qiladi**. Shuning uchun ilova **har doim uchala maydonni ham** yuboradi (joriy qiymatlari bilan). Masalan faqat mavzu o'zgarsa ham `language` va `pincode` joriy qiymatlari bilan birga yuboriladi.

**Til va mavzu:** darhol lokal qo'llanadi (optimistic update), so'ng serverga yuboriladi. Server xatolik qaytarsa — lokal holat qaytariladi va xabar ko'rsatiladi.

### 17.4 Yordam va statik sahifalar

- **Qo'llanmalar:** `GET /api/reports/app/tutorials` → YouTube havolalari (tashqi brauzerda ochiladi).
- **Foydalanish shartlari / Maxfiylik siyosati:** veb-sahifa (URL loyiha boshlanishida beriladi) — WebView yoki tashqi brauzer.
- **Yordam:** Telegram bot/kanal havolasi va qo'llab-quvvatlash raqami (konfiguratsiyada).

---

## 18. MODUL 14 — VERSIYA NAZORATI VA MAJBURIY YANGILASH

**Endpoint:** `POST /api/auth/mobile-check-version`
```json
{ "app_version": "1.4.2", "platform_type": "android" }
```
```json
{
  "status": true,
  "result": {
    "update": true,
    "current_version_play_market": "1.5.0",
    "current_version_mobile": "1.4.2",
    "update_status": "hard",
    "news": []
  }
}
```

| Holat | Ilova xatti-harakati |
|-------|---------------------|
| `update = false` | Normal davom etadi |
| `update = true` + `update_status = "hard"` | **Bloklovchi ekran**: "Yangi versiya mavjud", "Yangilash" tugmasi → Play Store / App Store. Yopib bo'lmaydi (back tugmasi ishlamaydi) |
| `update = true` + `update_status = "soft"` (kelajakda) | Yopib bo'ladigan dialog: "Yangilash" / "Keyinroq" |
| So'rov muvaffaqiyatsiz | **Ilova bloklanmaydi** — normal davom etadi (backend nosozligi foydalanuvchini to'sib qo'ymasligi kerak) |

`news[]` bo'sh bo'lmasa — yangilash ekranida "Yangiliklar" ro'yxati ko'rsatiladi.

> Versiya solishtiruvi backend'da `version_compare` orqali amalga oshiriladi. Ilova `app_version` ni `pubspec.yaml` dagi versiyadan (build raqamisiz, masalan `1.4.2`) oladi.

---

## 19. UI/UX, DIZAYN TIZIMI VA LOKALIZATSIYA

### 19.1 Dizayn manbasi

Dizayn Figma'da beriladi. Dasturchi **piksel darajasida** moslikni ta'minlaydi. Figma'da mavjud bo'lmagan holat (bo'sh, xato, yuklanish) uchun quyidagi standart naqshlar ishlatiladi.

### 19.2 Har bir ekran uchun majburiy 4 holat

| Holat | Talab |
|-------|-------|
| **Loading** | Skeleton (shimmer) — spinner emas. Ro'yxatlarda 5–7 ta skeleton element |
| **Empty** | Illustratsiya + tushuntirish matni + asosiy amal tugmasi |
| **Error** | Ikonka + xabar + "Qayta urinish" tugmasi |
| **Success** | Ma'lumot + pull-to-refresh |

### 19.3 Formatlash qoidalari

| Ma'lumot | Format | Misol |
|----------|--------|-------|
| Summa | Uch xonali guruh, bo'shliq bilan | `1 500 000 UZS` |
| Manfiy summa | Qizil rang, minus bilan | `−200 USD` |
| Sana | `dd.MM.yyyy` | `07.09.2026` |
| Sana (yaqin) | Nisbiy | "Bugun", "Kecha", "3 kun oldin" |
| Sana + vaqt | `dd.MM.yyyy HH:mm` | `07.09.2026 14:30` |
| Telefon | `+998 (90) 123-45-67` | Ko'rsatishda |
| Foiz | Butun son | `42%` |

**Pul kiritish maydoni:** kiritilayotganda avtomatik guruhlanadi (`1 500 000`), serverga esa toza son yuboriladi (`1500000`).

### 19.4 Ranglar semantikasi

| Ma'no | Rang |
|-------|------|
| Kirim / Xaqdor / Musbat | Yashil |
| Chiqim / Qarzdor / Manfiy / Muddati o'tgan | Qizil |
| Ogohlantirish / Yaqinlashdi / Grace period | Sariq/Amber |
| Neytral / Kutilmoqda / Bekor qilingan | Kulrang |
| Bo'lib to'lash / Ma'lumot | Ko'k |

### 19.5 Lokalizatsiya

- 3 til: **uz** (asosiy), **ru**, **en**. ARB fayllar; hardcode matn **taqiqlanadi**.
- Til `me()` dagi `app_settings.language` dan olinadi; o'zgartirilganda serverga saqlanadi.
- ⚠️ **Backend xatolik matnlari faqat o'zbek tilida keladi.** 1.0 versiyada ular tarjima qilinmaydi va shundayligicha ko'rsatiladi. Ilovaning o'z matnlari (tugmalar, sarlavhalar, bo'sh holatlar) to'liq 3 tilda bo'ladi.
- Sana/son formatlari `intl` orqali tilga moslashtiriladi (lekin pul formati barcha tillarda bir xil — bo'shliq bilan).

### 19.6 Navigatsiya va UX qoidalari

1. Bottom navigation — 5 ta tab; tab holati (scroll pozitsiyasi) saqlanadi.
2. Har qanday **destruktiv amal** (o'chirish, bekor qilish, force-delete) — tasdiqlash dialogi bilan.
3. Butunlay o'chirish (`force-delete`) — **ikki bosqichli** tasdiq.
4. Formalarda saqlanmagan o'zgarish bo'lsa, orqaga qaytishda: "O'zgarishlarni bekor qilasizmi?"
5. Barcha ro'yxatlarda pull-to-refresh.
6. Uzoq operatsiyalarda tugma loading holatiga o'tadi va **takroriy bosish bloklanadi** (double-submit himoyasi — moliyaviy operatsiyalarda majburiy).
7. Snackbar 3 soniya; xatoliklarda "Qayta urinish" amali bilan.
8. Klaviatura ochiqligida forma scroll qilinadi, tugma ko'rinib turadi.

### 19.7 Accessibility

- Minimal teginish maydoni: 48×48 dp.
- Matn kontrasti WCAG AA (4.5:1).
- Tizim shrift o'lchamiga moslashish (maksimal 1.3× gacha layout buzilmaydi).
- Muhim ikonkalarda `semanticLabel`.

---

## 20. XAVFSIZLIK TALABLARI

| № | Talab |
|---|-------|
| 20.1 | Token **faqat** `flutter_secure_storage` (Keychain/Keystore) da saqlanadi. `SharedPreferences` da saqlash taqiqlanadi |
| 20.2 | Pincode lokal — **hash** (SHA-256 + salt) ko'rinishida saqlanadi |
| 20.3 | Barcha so'rovlar **faqat HTTPS** orqali. `http` ga fallback yo'q |
| 20.4 | Release build'da `certificate pinning` (agar backend sertifikat rotatsiyasi jarayoni kelishilsa) |
| 20.5 | Release build'da barcha loglar o'chirilgan; token/parol/OTP hech qachon loglanmaydi |
| 20.6 | Moliyaviy ekranlarda screenshot bloklash — **ixtiyoriy** (sozlamalarda yoqiladi) |
| 20.7 | Ilova fonga o'tganda ekran preview'i xiralashtiriladi (`FLAG_SECURE` yoki blur overlay) |
| 20.8 | Root/jailbreak aniqlansa — ogohlantirish (bloklash emas) |
| 20.9 | Deep linklar validatsiya qilinadi; tashqi manbadan kelgan parametrlar ishonchsiz deb qaraladi |
| 20.10 | `flutter_secure_storage` dagi ma'lumot logout va hisobni o'chirishda **to'liq tozalanadi** |
| 20.11 | Obfuscation: `--obfuscate --split-debug-info` release build'da yoqiladi |
| 20.12 | Uchinchi tomon SDK lari minimal; har biri kelishiladi |

---

## 21. NOFUNKSIONAL TALABLAR

| Ko'rsatkich | Talab |
|-------------|-------|
| Sovuq ishga tushish | ≤ 3 soniya (o'rta darajadagi qurilmada) |
| Ekranlar orasidagi o'tish | ≤ 300 ms |
| Ro'yxat scroll | 60 FPS, jank < 1% |
| Ilova hajmi (Android APK) | ≤ 40 MB |
| Xotira | Oddiy ishlashda ≤ 200 MB |
| Crash-free sessiyalar | ≥ 99.5% |
| ANR darajasi | < 0.5% |
| Tarmoq | Sekin 3G da ham ishlash: timeoutlar, skeletonlar, retry |
| Batareya | Fon rejimida faol jarayon yo'q (push'dan tashqari) |

**Ishonchlilik:**
- Har qanday API xatoligi ilovani "oq ekran"ga olib kelmaydi.
- Barcha `Future` lar `try/catch` bilan qoplangan; global `FlutterError.onError` va `PlatformDispatcher.onError` Crashlytics'ga ulanadi.
- JSON parse xatosi — element o'tkazib yuboriladi, ekran qulamaydi (`null-safe` parsing).

---

## 22. ANALITIKA, LOGLASH VA MONITORING

**Majburiy integratsiyalar:** Firebase Crashlytics, Firebase Analytics, Firebase Cloud Messaging.

**Minimal event to'plami:**

| Event | Parametrlar |
|-------|-------------|
| `sign_up`, `login`, `logout` | `method` |
| `partner_created` | — |
| `wallet_created` | `type` (debt/credit), `currency` |
| `installment_created` | `schedule_type`, `has_advance` |
| `installment_payment` | `currency` |
| `project_created` | — |
| `report_viewed` | `report_type` |
| `subscription_purchase_started` | `plan`, `cycle`, `provider` |
| `subscription_purchase_completed` | `plan`, `cycle`, `amount` |
| `limit_reached` | `limit_type` |
| `api_error` | `endpoint`, `status_code`, `message` |

> Shaxsiy ma'lumotlar (telefon, ism, summalar) analitikaga **yuborilmaydi**.

---

## 23. TESTLASH VA QABUL QILISH MEZONLARI

### 23.1 Test turlari

| Tur | Qamrov |
|-----|--------|
| Unit | Formatterlar, validatorlar, FIFO/grafik hisoblash mantiqi, repositorylar |
| Widget | Kritik formalar: kirim/chiqim, bo'lib to'lash yaratish, to'lov |
| Integration | Login → hamkor yaratish → chiqim → kirim → balans tekshiruvi |
| Manual (QA) | Barcha AC lar bo'yicha checklist |

### 23.2 Majburiy test stsenariylari

1. Ro'yxatdan o'tish (yangi raqam) → Dashboard.
2. Login → boshqa qurilmada login → birinchi qurilma avtomatik logout.
3. Hamkor yaratish → chiqim (muddat bilan) → kirim → balans va FIFO to'g'ri hisoblanadi.
4. Chiqimni bekor qilish → balans qayta hisoblanadi.
5. Bo'lib to'lash rejasi (teng + avans) → grafik server bilan mos.
6. Bo'lib to'lashga qisman to'lov → qism `partial` bo'ladi.
7. Oxirgi to'lovni bekor qilish → summalar qaytariladi.
8. Limit tugashi → Tariflar → to'lov → limit yangilanadi.
9. Xodim qo'shish → xodim login → faqat ruxsat berilgan amallar.
10. Xodim rejimida `X-As-Owner` bilan owner ma'lumotlari ko'rinadi.
11. Internet o'chirilgan holatda barcha ekranlar xatolik holatini to'g'ri ko'rsatadi.
12. Push kelganda navigatsiya to'g'ri ishlaydi (ilova yopiq holatda ham).
13. Til va mavzu almashtirish, ilovani qayta ochganda saqlanib qoladi.
14. Majburiy yangilash ekrani chiqadi va yopilmaydi.
15. Hisobni o'chirish oqimi to'liq ishlaydi.

### 23.3 Qurilmalar matritsasi

| Platforma | Qurilmalar |
|-----------|-----------|
| Android | Kichik ekran (5", 720p), o'rta (6.1", 1080p), katta/planshet; Android 8, 11, 14 |
| iOS | iPhone SE (kichik), iPhone 13/14 (o'rta), iPhone Pro Max (katta); iOS 14, 16, 17 |

### 23.4 Bug prioritetlari

| Prioritet | Ta'rif | SLA |
|-----------|--------|-----|
| P0 (Blocker) | Ilova ishga tushmaydi, ma'lumot yo'qoladi, noto'g'ri moliyaviy hisob | 24 soat |
| P1 (Critical) | Asosiy funksiya ishlamaydi | 3 kun |
| P2 (Major) | Funksiya qisman ishlamaydi, aylanma yo'l bor | 1 hafta |
| P3 (Minor) | UI/matn nomuvofiqliklari | Keyingi reliz |

---

## 24. YETKAZIB BERISH REJASI VA DEFINITION OF DONE

### 24.1 Bosqichlar (Milestones)

| № | Bosqich | Mazmuni | Natija |
|---|---------|---------|--------|
| M0 | Tayyorgarlik | Loyiha skeleti, network layer, DI, tema, lokalizatsiya, CI | Ishlaydigan skelet + `dev` build |
| M1 | Auth + Profil | 5, 6, 17, 18-bo'limlar | Login/register/pincode/profil |
| M2 | Hamkorlar | 8-bo'lim (asosiy modul) | Hamkorlar + kirim/chiqim to'liq |
| M3 | Bo'lib to'lash | 9-bo'lim | Rejalar + to'lovlar |
| M4 | Dashboard + Loyihalar | 7, 10, 11-bo'limlar | Dashboard + loyihalar + ma'lumotnomalar |
| M5 | Hisobotlar | 12-bo'lim | Barcha hisobotlar + grafiklar |
| M6 | Obuna + Push + Xodimlar | 13, 14, 15, 16-bo'limlar | To'lov oqimi, push, xodimlar |
| M7 | Sayqallash va reliz | 19–23-bo'limlar, testlar, store | Store'da chiqarilgan ilova |

Har bir bosqich oxirida: demo build (Firebase App Distribution / TestFlight) + QA raundi.

### 24.2 Definition of Done (har bir vazifa uchun)

- [ ] Funksiya TZ dagi AC larga to'liq mos.
- [ ] 4 ta holat (loading/empty/error/success) qo'llangan.
- [ ] Ruxsatlar (permissions) hisobga olingan.
- [ ] Xodim rejimida (`X-As-Owner`) tekshirilgan.
- [ ] `READ_ONLY` obuna holatida to'g'ri ishlaydi.
- [ ] Lokalizatsiya: uz/ru/en matnlari mavjud, hardcode yo'q.
- [ ] Light va Dark mavzuda tekshirilgan.
- [ ] Kichik va katta ekranda tekshirilgan.
- [ ] `flutter analyze` toza.
- [ ] Kod review o'tgan.

### 24.3 Yetkazib beriladigan materiallar (Deliverables)

1. To'liq manba kodi (Git repozitoriy, aniq commit tarixi bilan).
2. `dev` va `prod` flavor lar bilan build qilish yo'riqnomasi (README).
3. Android: signed AAB + keystore (xavfsiz uzatiladi).
4. iOS: App Store Connect'ga yuklangan build.
5. Store materiallari: ikonka, screenshotlar (6.7", 6.5", 5.5", iPad), tavsif (uz/ru/en), maxfiylik siyosati havolasi, "Data Safety" / "App Privacy" formalari to'ldirilgan.
6. Aniqlangan backend nosozliklari ro'yxati (Appendix D asosida yangilangan).
7. 1 oylik kafolat: P0/P1 buglar bepul tuzatiladi.

### 24.4 Reliz oldidan checklist

- [ ] Majburiy yangilash mexanizmi ishlayotgani tekshirilgan (`app_versions` jadvalida yozuv bor).
- [ ] Push notification production sertifikatlari (APNs) ishlaydi.
- [ ] `prod` base URL va Firebase konfiguratsiyasi to'g'ri.
- [ ] Crashlytics production'da ma'lumot qabul qilyapti.
- [ ] Hisobni o'chirish funksiyasi ishlaydi (store talabi).
- [ ] Maxfiylik siyosati URL ochiladi.
- [ ] To'lov oqimi real Click/Payme bilan test qilingan.
- [ ] Obfuscation va release logging o'chirilgani tekshirilgan.

---

## 25. ILOVALAR (APPENDIX)

### Appendix A — API endpointlarning to'liq ro'yxati

**Base:** `{{base_url}}/api`
**Auth:** `Bearer {token}` (aks holda "Ochiq" deb belgilangan)
**Xodim rejimida:** `X-As-Owner: {owner_id}` (🏢 belgisi qo'yilgan guruhlarda)

#### A.1 Auth

| Method | Endpoint | Auth | Tavsif |
|--------|----------|------|--------|
| POST | `/auth/verify-number` | Ochiq | Raqamni tekshirish → `page: login\|register` |
| POST | `/auth/otp` | Ochiq | OTP yuborish |
| POST | `/auth/otp/verify` | Ochiq | OTP tekshirish → `verify_token` |
| POST | `/auth/register` | Ochiq | Ro'yxatdan o'tish → token |
| POST | `/auth/login` | Ochiq | Kirish → token |
| POST | `/auth/reset-password` | Ochiq | Parolni tiklash → token |
| POST | `/auth/mobile-check-version` | Ochiq | Versiya tekshirish |
| GET | `/auth/me` | ✅ | Profil, rollar, ruxsatlar |
| GET | `/auth/logout/{device_token}` | ✅ | Chiqish |
| POST | `/auth/update-password` | ✅ | Parolni o'zgartirish |
| PUT | `/auth/update-profile-info` | ✅ | Ismni o'zgartirish |
| POST | `/auth/update-profile-phone-verify` | ✅ | Yangi raqam bo'shligini tekshirish |
| POST | `/auth/update-profile-phone-check-otp` | ✅ | Raqamni OTP bilan yangilash |
| POST | `/auth/login-pincode/{user_id}` | ✅ | Pincode tekshirish |
| POST | `/auth/app-settings-update-or-create/{userId}` | ✅ | Til/mavzu/pincode saqlash |
| POST | `/auth/activate-own-account` | ✅ | Xodim → o'z hisobini ochish |
| DELETE | `/auth/delete-account` | ✅ | Hisobni o'chirish |

#### A.2 Xodimlar

| Method | Endpoint | Tavsif |
|--------|----------|--------|
| POST | `/auth/staff/send-otp` | Xodim raqamiga OTP |
| POST | `/auth/staff/verify-otp` | OTP → `verify_token` (5 daq.) |
| GET | `/auth/staff/permissions` | Ruxsatlar ro'yxati (guruhlangan) |
| GET | `/auth/staff` | Xodimlar ro'yxati |
| POST | `/auth/staff` | Xodim qo'shish |
| PUT | `/auth/staff/{id}` | Ruxsat/faollikni yangilash |
| DELETE | `/auth/staff/{id}` | Xodimni o'chirish |

#### A.3 Hamkorlar 🏢

| Method | Endpoint | Ruxsat | Tavsif |
|--------|----------|--------|--------|
| GET | `/partners/partners` | `partners.view` | Soddalashtirilgan ro'yxat (selektorlar uchun) |
| GET | `/partners/partners/account` | `partners.view` | **Asosiy ro'yxat** (balans, filtr, sort) |
| GET | `/partners/partner/{id}` | `partners.view` | Bitta hamkor |
| POST | `/partners/partner` | `partners.create` + limit | Yaratish |
| PUT | `/partners/partner/{id}` | `partners.edit` | Tahrirlash |
| DELETE | `/partners/partner/{id}` | `partners.delete` | O'chirish (soft) |
| POST | `/partners/partner/{id}/restore` | `partners.delete` | Tiklash |
| DELETE | `/partners/partner/{id}/force-delete` | `partners.delete` | Butunlay o'chirish |
| GET | `/partners/partner/{partnerId}/account` | `partners.view` | Hisob (UZS/USD) |
| GET | `/partners/partners/export/excel` | `partners.view` | Excel — barcha hamkorlar |
| GET | `/partners/partner/{partnerId}/wallets/export/excel` | `partners.view` | Excel — tranzaksiyalar |
| GET | `/partners/partner/settings/{id}` | `partners.view` | SMS sozlamalari |
| PUT | `/partners/partner/settings/{id}` | `partners.edit` | SMS sozlamalarini saqlash |
| ⚠️ GET | `/partners/partner/status-filter-options` | — | **Ishlamaydi** (route konflikti) |

#### A.4 Tranzaksiyalar (Wallet) 🏢

| Method | Endpoint | Ruxsat | Tavsif |
|--------|----------|--------|--------|
| GET | `/partners/wallets` | `partners.view` | Ro'yxat (`partner_id` majburiy) |
| GET | `/partners/wallet/{id}` | `partners.view` | Bitta yozuv |
| POST | `/partners/wallet` | `wallets_credit.create` / `wallets_debt.create` | Yaratish |
| PUT | `/partners/wallet/{id}` | — | Tahrirlash (**`debt` uchun mumkin emas**) |
| PUT | `/partners/wallet/{id}/cancel` | `wallets_*.cancel` | Bekor qilish |
| DELETE | `/partners/wallet/{id}` | — | O'chirish (soft) |
| POST | `/partners/wallet/{id}/restore` | — | Tiklash |
| DELETE | `/partners/wallet/{id}/force-delete` | — | Butunlay o'chirish |

#### A.5 Bo'lib to'lash 🏢

| Method | Endpoint | Ruxsat |
|--------|----------|--------|
| GET | `/partners/installments` | `partners.view` |
| POST | `/partners/installments` | `partners.create` + obuna |
| GET | `/partners/installments/{id}` | `partners.view` |
| PUT | `/partners/installments/{id}` | `partners.edit` |
| DELETE | `/partners/installments/{id}` | Owner |
| GET | `/partners/installments/{id}/items` | `partners.view` |
| POST | `/partners/installments/{id}/payment` | `partners.create` |
| GET | `/partners/installments/{id}/payment-history` | `partners.view` |
| DELETE | `/partners/installments/{planId}/payments/{paymentId}` | Owner |
| GET | `/partners/partner/{partnerId}/installments` | `partners.view` |

#### A.6 Dashboard va hisobotlar 🏢

| Method | Endpoint | Ruxsat |
|--------|----------|--------|
| GET | `/reports/dashboard` | — |
| GET | `/reports/dashboard/due-dates?type=` | — |
| GET | `/reports/dashboard/installments/due-dates?type=` | — |
| GET | `/reports/app/tutorials` | — |
| GET | `/reports/partners-v3/summary` | `report_partners.view` |
| GET | `/reports/partners-v3/summary-qarzdor-xaqdor-details` | `report_partners.view` |
| GET | `/reports/partners-v3/summary-report-types` | `report_partners.view` |
| GET | `/reports/partners-v3/periods` | `report_partners.view` |
| GET | `/reports/partners-v3/periods-operations` | `report_partners.view` |
| GET | `/reports/partners-v3/warranty-periods` | `report_partners.view` |
| GET | `/reports/partners-v3/warranty-periods-details` | `report_partners.view` |
| GET | `/reports/partners-v3/workers` | `report_partners.view` |
| GET | `/reports/partners-v3/workers-lists` | `report_partners.view` |
| GET | `/reports/partners-v3/workers-details->summary` | `report_partners.view` |
| GET | `/reports/partners-v3/workers-details->operations` | `report_partners.view` |
| GET | `/reports/partners-v2/partner-details/{partnerId}` | `report_partner.view` |
| GET | `/reports/partners-v2/partner-details-section-one` | `report_partner.view` |
| GET | `/reports/partners/sended-sms/{partnerId}` | `report_partner.view` |
| GET | `/reports/installments/summary` | — |
| GET | `/reports/installments/partners` | — |
| GET | `/reports/installments/forecast` | — |
| GET | `/reports/installments/risky-partners` | — |
| GET | `/reports/installments/recovery` | — |
| GET | `/reports/installments/monthly` | — |
| GET | `/reports/installments/items` | — |
| GET | `/reports/installments/partner/{partnerId}` | `partners.view` |
| GET | `/reports/projects/balance` | `report_project.view` |
| GET | `/reports/projects/income-details` | `report_project.view` |
| GET | `/reports/projects/cost-details` | `report_project.view` |
| GET | `/reports/projects/workers-costs` | `report_project.view` |
| GET | `/reports/projects/workers-costs-details` | `report_project.view` |

#### A.7 Loyihalar 🏢

| Method | Endpoint | Ruxsat |
|--------|----------|--------|
| GET | `/project/projects` | `projects.view` |
| POST | `/project/project` | `projects.create` + limit |
| GET | `/project/project/{id}` | `projects.view` |
| PUT | `/project/project/{id}` | `projects.edit` |
| DELETE | `/project/project/{id}` | `projects.delete` |
| POST | `/project/project/{id}/restore` | `projects.delete` |
| DELETE | `/project/project/{id}/force-delete` | `projects.delete` |
| PUT | `/project/project/{id}/update-status` | `projects.edit` |
| GET | `/project/project-statuses` | `projects.view` |
| GET/POST/PUT/DELETE | `/project/project-contract[s]/...` | — |
| GET/POST/PUT/DELETE | `/project/project-income[s]/...` | — |
| GET/POST/PUT/DELETE | `/project/project-cost[s]/...` | — |
| GET | `/project/project/{projectId}/workers` | — |
| POST | `/project/worker-add-to-project` | — |
| POST | `/project/worker-remove-from-project` | — |

#### A.8 Ma'lumotnomalar 🏢

| Method | Endpoint |
|--------|----------|
| GET | `/documents/currencies` |
| GET/POST/PUT/DELETE | `/documents/currency[/{id}]` (+ `/restore`, `/force-delete`) |
| GET | `/documents/currencys-exchange-rates` |
| GET | `/documents/work-types` · `/documents/work-type[/{id}]` (+ `/restore`), ⚠️ force-delete: `/documents/work/{id}/force-delete` |
| GET | `/documents/cost-types` · `/documents/cost-type[/{id}]` (+ `/restore`, `/force-delete`) |
| GET | `/documents/worker-positions` · `/documents/worker-position[/{id}]` (+ `/restore`, `/force-delete`) |
| GET | `/documents/workers` · `/documents/worker[/{id}]` (+ `/restore`, `/force-delete`) |
| GET | `/currency-calc/cbu-rates/{date}` |

#### A.9 Obuna, to'lov, bildirishnoma, jurnal 🏢

| Method | Endpoint |
|--------|----------|
| GET | `/subscription/show` |
| GET | `/subscription/get-statistics` |
| POST | `/subscription/purchase` |
| GET | `/subscription/check-order-status/{order_number}` |
| GET | `/pricing-plans` · `/pricing-plans/{id}` |
| GET | `/pricing-sms` |
| POST | `/pricing-sms/purchase` |
| GET | `/notifications` |
| GET | `/notifications/unread-count` |
| POST | `/notifications/{id}/mark-as-read` |
| GET | `/activity-logs` |
| POST | `/files/upload` |
| DELETE | `/files/delete/{id}` |

> `/api/admin/*` — admin panel uchun, mobil ilovada ishlatilmaydi.
> `/api/click/*`, `/api/payme/*` — to'lov tizimlari uchun; mobil faqat `payment_url` ni ochadi.

---

### Appendix B — Enum va lug'atlar

**Wallet type:** `credit` = Chiqim · `debt` = Kirim
**Partner status filter:** `xaqdor` · `qarzdor` · `muddati_otgan_qarzdor`
**Partner sort:** `qarzdor_uzs` · `qarzdor_usd` · `xaqdor_uzs` · `xaqdor_usd`
**CreditSchedule status:** `pending` · `partial` · `paid` · `overdue`
**Installment plan status:** `active` (Faol) · `completed` (To'liq to'langan) · `cancelled` (Bekor qilingan)
**Installment item status:** `pending` (Kutilmoqda) · `near` (Yaqinlashdi) · `overdue` (Muddati o'tdi) · `partial` (Qisman to'langan) · `paid` (To'langan)
**Installment schedule type:** `equal` (Teng) · `custom` (Erkin)
**Project status:** `in_progress` (Jarayonda) · `frozen` (Muzlatilgan) · `completed` (Tugallangan)
**Subscription status:** `ACTIVE` · `GRACE_PERIOD` · `READ_ONLY` · `ARCHIVED` · `DELETED`
**Billing cycle:** `MONTHLY` · `SEMI_ANNUAL` · `ANNUAL`
**Payment provider:** `click` · `payme`
**Order status:** `PENDING` · `PAID` · `FAILED`
**Activity action:** `created` · `updated` · `cancelled` · `deleted` · `restored`
**Dashboard detail type:** `qarz_expired` · `qarz_today` · `qarz_3_days` · `installment_expired` · `installment_today` · `installment_3_days`
**Report detail type (V2/V3):** `oparation` (⚠️ imlo backendda shunday) · `qarz_expired` · `qarz_today` · `qarz_3_days` · `xaqdor` · `qarzdor`
**SMS log type:** `reminder` · `overdue` · `wallet` · `otp` · `due_today` · `installment_created` · `installment_payment` · `installment_completed`
**Currency ID:** `1 = UZS` · `2 = USD` (hisobotlarda hardcode)
**App settings:** `language`: `uz|ru|en` · `mode`: `light|dark`

---

### Appendix C — Xatolik xabarlari katalogi (backenddan keladi)

| Xabar | Kontekst | UI reaksiyasi |
|-------|----------|---------------|
| `Authorization failed!` | Login | Maydon ostida xato |
| `User is not active!` | Login | Bloklovchi dialog |
| `Sizda mobile ilovaga kirish xuquqi cheklangan!` | verify-number | Bloklovchi dialog + qo'llab-quvvatlash |
| `OTP topilmadi` / `OTP muddati tugagan` / `OTP noto'g'ri` | OTP | Maydon ostida xato |
| `OTP hali amal qiladi` | OTP qayta yuborish | Timer ko'rsatiladi |
| `SMS yuborilmadi` | OTP | "Qayta urinish" tugmasi |
| `Telefon tasdiqlanmagan` / `Verify token eskirgan` | Register / Staff | Oqim boshidan boshlanadi |
| `Eski parol noto'g'ri!` | Parol o'zgartirish | Maydon ostida xato |
| `Bu telefon raqam boshqa foydalanuvchi tomonidan ishlatilmoqda!` | Raqam o'zgartirish | Maydon ostida xato |
| `Bu nomli hamkor allaqachon mavjud.` | Hamkor | Maydon ostida xato |
| `Bu telefon raqamli hamkor allaqachon mavjud` | Hamkor | Maydon ostida xato |
| `O'chirilgan hamkorni tahrirlash mumkin emas` | Hamkor | Snackbar |
| `To'lovni tahrirlash mumkin emas. Iltimos, bekor qilib qaytadan kiriting.` | Wallet | Snackbar (tugma yashirilgan bo'lishi kerak) |
| `Bu amalni bajarish uchun ruxsatingiz yo'q.` | Har qanday (403) | Snackbar |
| `Bu akkauntga kirish huquqi yo'q.` | X-As-Owner (403) | Hisob tanlash ekraniga qaytish |
| `Qismlar yig'indisi jami summaga teng bo'lishi kerak.` | Installment | Forma xatosi |
| `Avans summasi jami summadan kichik bo'lishi kerak.` | Installment | Forma xatosi |
| `Faqat faol rejalarga to'lov qabul qilinadi.` | Installment payment | Snackbar |
| `To'lov summasi qolgan qarzdan oshib ketmasligi kerak.` | Installment payment | Forma xatosi |
| `Faqat oxirgi to'lovni bekor qilish mumkin.` | Payment cancel | Snackbar |
| `Bekor qilingan rejani tahrirlash mumkin emas.` | Installment | Snackbar |
| `Faol obuna topilmadi...` / `Tarif rejangiz muddati tugagan...` | Limitlar | Tariflar dialogi |
| `Yangi hamkor/loyiha/xodim qo'shish uchun limitingiz tugagan...` | Limitlar | Tariflar dialogi |
| `Bu xodim allaqachon qo'shilgan` / `O'zingizni xodim sifatida qo'sha olmaysiz` | Staff | Snackbar |
| `Xodim topilmadi` | Staff | Snackbar + ro'yxatni yangilash |
| `Juda ko'p urinish. Biroz kutib qayta urining.` | Throttle | Snackbar + timer |
| `Loyiha topilmadi` / `Bunday loyiha topilmadi!` | Project | Snackbar + orqaga |

---

### Appendix D — Ma'lum backend cheklovlari va risklari

> Bu ro'yxat mobil dasturchi uchun **ogohlantirish**, backend jamoasi uchun **tuzatish ro'yxati**. Mobil tomon ko'rsatilgan aylanma yechimlarni qo'llaydi.

| № | Muammo | Ta'siri | Mobil tomon yechimi |
|---|--------|---------|---------------------|
| D-1 | Biznes xatoliklar HTTP **200** bilan qaytadi (`status:false`) | Standart HTTP error handling ishlamaydi | Markazlashgan interceptor `status` maydonini tekshiradi (4.4) |
| D-2 | `GET /partners/partner/status-filter-options` — `partner/{id}` bilan route konflikti | Endpoint ishlamaydi | Filtr variantlari ilovada hardcode |
| D-3 | `/reports/partners-v3/workers-details->summary` URL da `->` belgisi | URL encoding muammosi bo'lishi mumkin | Integratsiyada tekshirish; kerak bo'lsa backendda manzilni o'zgartirish so'raladi |
| D-4 | Ish turini force-delete: `/documents/work/{id}/force-delete` (`work-type` emas) | Noto'g'ri manzilda 404 | To'g'ri manzil ishlatiladi |
| D-5 | Login barcha tokenlarni o'chiradi; faol qurilma 1 ta | Ikkinchi qurilmada kirilganda birinchi qurilma "tushadi" | 401 da avtomatik logout + tushuntiruvchi xabar |
| D-6 | Login `app_settings.pincode` ni NULL qiladi | Pincode har login'dan keyin yo'qoladi | Login'dan keyin pincode qayta o'rnatish taklif qilinadi |
| D-7 | Pincode serverda **ochiq matnda** saqlanadi | Xavfsizlik | Lokal hash + serverga faqat sinxronizatsiya uchun yuboriladi; autentifikatsiya token orqali |
| D-8 | `app-settings-update-or-create` yuborilmagan maydonni NULL qiladi | Til o'zgartirilsa pincode yo'qoladi | Har doim uchala maydon birga yuboriladi |
| D-9 | `X-Subscription-Status` header 6 soat keshlanadi | To'lovdan keyin darhol yangilanmaydi | To'lovdan keyin `GET /subscription/show` chaqiriladi |
| D-10 | `GET /partners/wallets` paginatsiyasiz | Ko'p yozuvda sekinlashish | Default sana filtri (oxirgi 3 oy) + lazy list |
| D-11 | Fayl URL lari 1 soatda eskiradi | Rasm ko'rinmay qoladi | URL saqlanmaydi; `file.id` bo'yicha kesh; ekran ochilganda qayta olinadi |
| D-12 | `verify_token` amal qilish muddati kodda 2 daqiqa, xabarda 5 daqiqa deb yozilgan (register uchun) | Foydalanuvchi chalg'ishi mumkin | Ilova 2 daqiqalik timer ko'rsatadi |
| D-13 | Installment `payment` da `paid_at` majburiy, lekin serverda ishlatilmaydi | Yuborilmasa 422 | Har doim bugungi sana yuboriladi |
| D-14 | `subscription.limit:installments` middleware'da `installments` turi ishlanmagan | Reja soni bo'yicha limit yo'q, lekin **faol obuna** talab qilinadi | Obuna yo'q/READ_ONLY bo'lsa tegishli xabar ko'rsatiladi |
| D-15 | Hisobotlarda valyuta ID lari (1=UZS, 2=USD) hardcode | Yangi valyuta qo'shilsa hisobotlarga tushmaydi | Ilova ham hozircha shu ikki valyuta bilan ishlaydi |
| D-16 | Xatolik matnlari faqat o'zbek tilida | ru/en da aralash til | 1.0 da shundayligicha ko'rsatiladi; keyingi versiyada backend lokalizatsiyasi so'raladi |
| D-17 | `/auth/*` guruhida `X-As-Owner` ishlamaydi | Xodim owner nomidan xodim boshqara olmaydi | Xodim rejimida "Xodimlar" bo'limi yashiriladi |
| D-18 | `PUT /partners/wallet/{id}` `credit` uchun `CreditSchedule` ni to'liq yangilamaydi (`firstOrNew` ishlatilgan, saqlanmaydi) | Chiqim tahrirlanganda muddat grafigi eskicha qolishi mumkin | UI da chiqimni tahrirlash o'rniga "bekor qilib qayta kiritish" tavsiya qilinadi; backendga tuzatish so'raladi |

---

### Appendix E — Ekranlar ro'yxati (Screen inventory)

| № | Ekran | Modul | Prioritet |
|---|-------|-------|-----------|
| 1 | Splash | Auth | P0 |
| 2 | Onboarding (3 slayd) | Auth | P2 |
| 3 | Telefon kiritish | Auth | P0 |
| 4 | OTP | Auth | P0 |
| 5 | Ro'yxatdan o'tish | Auth | P0 |
| 6 | Login (parol) | Auth | P0 |
| 7 | Parolni tiklash | Auth | P0 |
| 8 | Pincode o'rnatish / kiritish | Auth | P1 |
| 9 | Hisob tanlash (owner/staff) | Auth | P1 |
| 10 | Majburiy yangilash | System | P0 |
| 11 | Dashboard | Dashboard | P0 |
| 12 | Qarz muddatlari detali | Dashboard | P0 |
| 13 | Bo'lib to'lash muddatlari detali | Dashboard | P1 |
| 14 | Hamkorlar ro'yxati | Partners | P0 |
| 15 | Hamkor filtri (bottom sheet) | Partners | P1 |
| 16 | Hamkor yaratish/tahrirlash | Partners | P0 |
| 17 | Hamkor kartochkasi (3 tab) | Partners | P0 |
| 18 | Kirim/Chiqim yaratish | Partners | P0 |
| 19 | Tranzaksiyani bekor qilish | Partners | P0 |
| 20 | SMS sozlamalari | Partners | P1 |
| 21 | SMS tarixi | Partners | P2 |
| 22 | Bo'lib to'lash rejalari ro'yxati | Installment | P1 |
| 23 | Reja yaratish (3 qadamli wizard) | Installment | P1 |
| 24 | Reja tafsilotlari + grafik | Installment | P1 |
| 25 | To'lov qabul qilish | Installment | P1 |
| 26 | To'lovlar tarixi | Installment | P1 |
| 27 | Loyihalar ro'yxati | Projects | P1 |
| 28 | Loyiha yaratish/tahrirlash | Projects | P1 |
| 29 | Loyiha kartochkasi (4 tab) | Projects | P1 |
| 30 | Shartnoma/daromad/xarajat formalari | Projects | P1 |
| 31 | Loyihaga ishchi biriktirish | Projects | P2 |
| 32 | Hisobotlar bosh sahifasi | Reports | P1 |
| 33 | Hamkorlar umumiy hisoboti | Reports | P1 |
| 34 | Muddat kesimida hisobot | Reports | P1 |
| 35 | Qarz muddatlari hisoboti | Reports | P1 |
| 36 | Xodimlar kesimida hisobot | Reports | P2 |
| 37 | Hamkor detal hisoboti (grafiklar) | Reports | P1 |
| 38 | Bo'lib to'lash hisobotlari (8 ta ekran) | Reports | P2 |
| 39 | Loyiha hisobotlari | Reports | P2 |
| 40 | Obuna (mening tarifim) | Subscription | P1 |
| 41 | Tariflar ro'yxati | Subscription | P1 |
| 42 | To'lov (WebView/Custom Tab) | Subscription | P1 |
| 43 | To'lov natijasi | Subscription | P1 |
| 44 | SMS paketlari | Subscription | P2 |
| 45 | Bildirishnomalar ro'yxati | Notifications | P1 |
| 46 | Xodimlar ro'yxati | Staff | P1 |
| 47 | Xodim qo'shish (3 qadam) | Staff | P1 |
| 48 | Xodim ruxsatlarini tahrirlash | Staff | P1 |
| 49 | Faollik jurnali | Activity | P2 |
| 50 | Ma'lumotnomalar (5 ta ro'yxat + formalar) | Documents | P2 |
| 51 | Valyuta kurslari + konvertor | Documents | P2 |
| 52 | Profil | Profile | P0 |
| 53 | Shaxsiy ma'lumotlarni tahrirlash | Profile | P1 |
| 54 | Telefon raqamni o'zgartirish | Profile | P2 |
| 55 | Sozlamalar (til, mavzu, pincode) | Profile | P1 |
| 56 | Qo'llanmalar | Profile | P2 |
| 57 | Hisobni o'chirish | Profile | P0 (store talabi) |

**Jami: 57 ta ekran** (dialoglar va bottom sheet lar alohida hisoblanmagan).

---

## Hujjat versiyalari

| Versiya | Sana | O'zgarish | Muallif |
|---------|------|-----------|---------|
| 1.0 | 2026-09-07 | Backend kod bazasi to'liq tahlili asosida birinchi to'liq versiya | — |

---

**TZ tasdiqlandi:**

| Rol | F.I.Sh. | Sana | Imzo |
|-----|---------|------|------|
| Buyurtmachi | | | |
| Loyiha menejeri | | | |
| Backend dasturchi | | | |
| Mobil dasturchi | | | |
