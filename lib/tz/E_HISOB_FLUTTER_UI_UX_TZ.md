# E-HISOB — FLUTTER MOBIL ILOVA UI/UX TEXNIK TOPSHIRIQ

**Hujjat turi:** Flutter Mobile UI/UX + Frontend Architecture TZ  
**Platforma:** iOS + Android  
**Asosiy tillar:** O‘zbek (uz), Rus (ru)  
**Mavzular:** Light / Dark / System  
**Navigation:** GoRouter  
**State management:** flutter_bloc (Bloc/Cubit)  
**Network:** Dio  
**Responsive:** flutter_screenutil  
**Backend:** Laravel REST API  
**Backend manbasi:** `MOBILE_APP_TZ (3).md`

---

# 1. MAQSAD

Ushbu hujjat backend tomonidan berilgan E-Hisob mobil ilova TZ asosida **Flutter frontend/UI qismini** ishlab chiqish uchun yozilgan.

Backend TZ da biznes qoidalari, endpointlar, permissionlar va API oqimlari belgilangan. Ushbu hujjat esa ularga qo‘shimcha ravishda:

- Flutter loyiha arxitekturasi;
- UI/UX qoidalari;
- ekranlar;
- navigation;
- BLoC/Cubit state management;
- Dio network layer;
- local storage;
- responsive;
- Light/Dark theme;
- uz/ru localization;
- bottom sheet patternlari;
- form validation;
- loading/empty/error/success holatlari;
- money/phone/date formatterlar;
- permission va subscription guardlar;
- native-like interaction;
- accessibility;
- animation;
- testing;
- Definition of Done

talablarini belgilaydi.

Backend TZ da Flutter uchun BLoC/Riverpod, Dio, go_router, secure storage, Firebase Messaging va lokal cache kabi texnologiyalar tavsiya qilingan. Ushbu frontend TZ da **BLoC + Dio + GoRouter + flutter_screenutil** yagona standart sifatida qabul qilinadi. Backend arxitekturasi ham feature/core/data/domain qatlamlariga ajratilgan. [Backend TZ: architecture va majburiy texnologiyalar] 

---

# 2. MUHIM UI QOIDALARI

## 2.1 Dropdown ishlatilmaydi

**Ilovada klassik `DropdownButton`, `DropdownButtonFormField` va native dropdown UI ishlatilmaydi.**

Backend TZ da ayrim joylarda dropdown deb ko‘rsatilgan bo‘lsa ham, mobil UX uchun quyidagi pattern ishlatiladi:

### Single selection
- `ModalBottomSheet`
- searchable selection sheet
- radio/check indicator
- tanlangan element yuqorida ko‘rsatiladi

### Multiple selection
- `ModalBottomSheet`
- checkbox list
- sticky bottom action bar:
  - `Bekor qilish`
  - `Tanlash`

### Date selection
- native `showDatePicker` yoki custom bottom sheet calendar

### Currency
- UZS / USD uchun segmented control yoki bottom sheet

### Status
- filter bottom sheet

### Worker
- searchable bottom sheet

### Work type
- searchable bottom sheet

### Cost type
- searchable bottom sheet

### Payment provider
- bottom sheet

### Billing cycle
- segmented control

Bu yondashuv barcha tanlovlar uchun yagona UX beradi.

---

# 3. NATIVE-LIKE UX

Ilova oddiy CRUD web-app ko‘rinishida emas, **iOS/Android native application** kabi ishlashi kerak.

## Majburiy prinsiplar

- smooth push/pop navigation;
- native back gesture;
- iOS swipe-back;
- Android back handling;
- haptic feedback;
- keyboard-aware forms;
- safe area;
- edge-to-edge;
- pull-to-refresh;
- swipe actions;
- bottom sheets;
- confirmation dialogs;
- skeleton loading;
- optimistic UI;
- inline validation;
- snackbar;
- toast faqat juda qisqa feedback uchun;
- animated state transitions;
- content preserving;
- scroll position preserving;
- keyboard ochilganda formaning avtomatik siljishi.

## Interaction

Bosiladigan element:
- minimum touch area: **44x44 dp**;
- primary CTA: 48–52 dp;
- icon button: 44–48 dp;
- destructive action: alohida confirmation.

---

# 4. FLUTTER PACKAGE STANDARDI

## Core

```yaml
flutter_bloc:
go_router:
dio:
flutter_screenutil:
get_it:
injectable:
freezed_annotation:
json_annotation:
flutter_secure_storage:
shared_preferences:
isar:
equatable:
```

## Code generation

```yaml
freezed:
build_runner:
json_serializable:
injectable_generator:
```

Qo‘lda `Map<String, dynamic>` bilan biznes/model qatlamida ishlash taqiqlanadi.

API response → DTO → domain model → UI.

## UI

```yaml
cached_network_image:
shimmer:
flutter_svg:
fl_chart:
image_picker:
file_picker:
url_launcher:
share_plus:
intl:
mask_text_input_formatter:
```

## Native integrations

```yaml
firebase_core:
firebase_messaging:
flutter_local_notifications:
local_auth:
flutter_custom_tabs:
```

## Quality

```yaml
very_good_analysis:
mocktail:
bloc_test:
flutter_test:
integration_test:
```

Package versiyalari loyiha boshlanishida stable/latest compatible holatda lock qilinadi.

---

# 5. LOYIHA ARXITEKTURASI

```text
lib/
│
├── app/
│   ├── app.dart
│   ├── bootstrap.dart
│   └── app_bloc_observer.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── formatters/
│   ├── localization/
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── interceptors/
│   │   └── api_result.dart
│   ├── router/
│   ├── storage/
│   ├── theme/
│   ├── widgets/
│   └── utils/
│
├── data/
│   ├── datasources/
│   │   ├── remote/
│   │   └── local/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── features/
    ├── auth/
    ├── dashboard/
    ├── partners/
    ├── installments/
    ├── projects/
    ├── reports/
    ├── subscription/
    ├── notifications/
    ├── staff/
    ├── activity_log/
    ├── documents/
    └── profile/
```

Har bir feature:

```text
feature/
├── data/
├── domain/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

---

# 6. BLOC / CUBIT STANDARTI

Global state uchun Bloc/Cubit ishlatiladi.

## Global Cubitlar

```text
AppCubit
AuthCubit
UserCubit
ThemeCubit
LocaleCubit
OwnerContextCubit
SubscriptionCubit
NotificationCubit
ConnectivityCubit
```

## Feature Cubit/Bloclar

```text
DashboardCubit

PartnersBloc
PartnerDetailBloc
WalletBloc
PartnerFormCubit
PartnerSmsSettingsCubit

InstallmentsBloc
InstallmentCreateCubit
InstallmentDetailBloc
InstallmentPaymentCubit

ProjectsBloc
ProjectDetailBloc
ProjectFormCubit

ReportsBloc
PartnerReportCubit
InstallmentReportCubit
ProjectReportCubit

StaffBloc
StaffFormCubit

DocumentsBloc
WorkersBloc
CurrencyCubit
```

## State naming

```text
initial
loading
success
empty
failure
submitting
submitted
```

Form uchun:

```text
FormState
- initial
- editing
- validating
- submitting
- success
- failure
```

Har bir state immutable bo‘lishi kerak.

---

# 7. ROUTING — GO_ROUTER

## Root navigation

Bottom Navigation 5 tab:

```text
/dashboard
/partners
/projects
/reports
/profile
```

## Auth routes

```text
/splash
/onboarding
/auth/phone
/auth/otp
/auth/login
/auth/register
/auth/forgot-password
/auth/reset-password
/auth/pincode
/auth/account-selection
/system/force-update
```

## Partner routes

```text
/partners
/partners/create
/partners/:id
/partners/:id/edit
/partners/:id/wallet/create
/partners/:id/wallet/:walletId
/partners/:id/sms-settings
/partners/:id/sms-history
/partners/:id/report
```

## Installment

```text
/installments
/installments/create
/installments/:id
/installments/:id/payments
```

## Projects

```text
/projects
/projects/create
/projects/:id
/projects/:id/edit
/projects/:id/contracts
/projects/:id/incomes
/projects/:id/costs
/projects/:id/workers
```

## Reports

```text
/reports
/reports/partners
/reports/partners/period
/reports/partners/due-dates
/reports/partners/workers
/reports/partner/:id
/reports/installments
/reports/installments/:type
/reports/projects
```

## Profile

```text
/profile
/profile/edit
/profile/password
/profile/phone
/profile/subscription
/profile/plans
/profile/sms
/profile/staff
/profile/documents
/profile/activity
/profile/notifications
/profile/currency
/profile/settings
/profile/help
```

---

# 8. ROUTE GUARDS

## AuthGuard

Token yo‘q:

```text
→ /auth/phone
```

Token bor:

```text
→ me()
```

Pincode yoqilgan:

```text
→ /auth/pincode
```

## PermissionGuard

Permission yo‘q bo‘lsa:

- route ko‘rsatilmaydi;
- action tugmasi ko‘rsatilmaydi;
- deep link orqali kirilsa access denied screen/snackbar.

Backend TZ bo‘yicha view permission bo‘lmasa menyu/tab yashiriladi, create/edit permission bo‘lmasa action tugmasi yashiriladi. 

## SubscriptionGuard

```text
ACTIVE
→ normal

GRACE_PERIOD
→ normal + warning banner

READ_ONLY
→ read only

ARCHIVED
→ subscription required screen
```

Backend subscription statuslari aynan shu UI oqimini talab qiladi. 

---

# 9. DESIGN SYSTEM

## 9.1 Spacing

8pt grid:

```text
4
8
12
16
20
24
32
40
48
64
```

Asosiy horizontal padding:

```text
16.dp
```

Tablet:

```text
24–32.dp
```

## 9.2 Radius

```text
XS: 8
SM: 12
MD: 16
LG: 20
XL: 28
FULL: 999
```

## 9.3 Typography

Material 3 typography asosida custom type scale.

```text
Display
Headline
Title
Body
Label
Caption
```

Money value uchun:

```text
28–36 px
fontWeight: 700
```

## 9.4 Cards

Card:
- radius 16;
- content padding 16;
- border 1 px;
- dark mode'da subtle border;
- shadow minimal.

---

# 10. COLOR SEMANTICS

Ranglar semantik bo‘lishi kerak.

```text
Success:
Kirim
Xaqdor
Musbat
To‘langan

Error:
Chiqim
Qarzdor
Manfiy
Muddati o‘tgan
Delete

Warning:
Grace Period
Yaqinlashdi
Bugun
80%+ limit

Info:
Bo‘lib to‘lash
Informatsiya

Neutral:
Pending
Bekor qilingan
Disabled
```

Backend TZ ham kirim/musbatni yashil, chiqim/manfiyni qizil, warningni amber, installment/info ni ko‘k bilan ajratishni belgilaydi. 

---

# 11. LIGHT / DARK THEME

## Light

```text
background: #F7F8FA
surface: #FFFFFF
surfaceSecondary: #F1F3F5

textPrimary: #15171A
textSecondary: #6B7280
textTertiary: #9CA3AF

border: #E5E7EB

success: #16A34A
error: #DC2626
warning: #D97706
info: #2563EB

overlay: rgba(0,0,0,0.45)
```

## Dark

```text
background: #0B0D0F
surface: #15181C
surfaceSecondary: #1C2025

textPrimary: #F5F7FA
textSecondary: #A7AFBA
textTertiary: #737B87

border: #2A3038

success: #22C55E
error: #EF4444
warning: #F59E0B
info: #3B82F6

overlay: rgba(0,0,0,0.65)
```

> Ranglar Figma bilan final bosqichda token sifatida birlashtiriladi. Yuqoridagi qiymatlar frontend baseline.

---

# 12. SCREEN STATES

Har bir ekran kamida 4 state bilan ishlab chiqiladi.

## Loading

Spinner asosiy loading sifatida ishlatilmaydi.

```text
Skeleton + shimmer
```

List:

```text
5–7 skeleton item
```

## Empty

```text
Illustration
Title
Description
Primary CTA
```

## Error

```text
Icon
Title/message
Retry button
```

## Success

```text
Content
Pull-to-refresh
```

Bu backend TZ dagi majburiy UX talabi. 

---

# 13. MONEY FORMATTER

## Ko‘rsatish

```text
100000
→ 100 000 UZS

1500000
→ 1 500 000 UZS

-200
→ −200 USD
```

**1.5M kabi qisqartirish taqiqlanadi.**

## Input

User yozayotganda:

```text
1
10
100
1 000
10 000
100 000
1 000 000
```

Backendga:

```text
1000000
```

yuboriladi.

Pul hisoblashda `double` ishlatilmaydi.

---

# 14. TELEFON FORMATTER

UI:

```text
+998 (93) 737-33-22
```

Backend:

```text
937373322
```

Input:

```text
+998 (__) ___-__-__
```

Faqat 9 digit saqlanadi/yuboriladi.

Backend TZ UI formatini `+998 90 123 45 67` ko‘rsatishni belgilaydi; ushbu frontend TZ barcha mobil ekranlarda yagona **`+998 (90) 123-45-67`** formatini qabul qiladi. 

---

# 15. DATE FORMAT

UI:

```text
07.09.2026
```

DateTime:

```text
07.09.2026 14:30
```

Relative:

```text
Bugun
Kecha
3 kun oldin
```

API create:

```text
yyyy-MM-dd
```

API filter:

```text
dd.MM.yyyy
```

---

# 16. BOTTOM SHEET SYSTEM

Ilovada bottom sheet asosiy interaction pattern bo‘ladi.

## Standart

```text
showModalBottomSheet
isScrollControlled: true
useSafeArea: true
```

## Sheet anatomy

```text
Drag handle
Title
Optional search
Content
Sticky action area
```

## Types

```text
SelectionSheet
MultiSelectionSheet
FilterSheet
SortSheet
DateRangeSheet
CurrencySheet
ActionSheet
ConfirmationSheet
FormSheet
PaymentSheet
```

## Height

Contentga qarab:

```text
35%
50%
70%
90%
```

Full screen form kerak bo‘lsa:

```text
DraggableScrollableSheet
```

---

# 17. AUTH MODULE

## 17.1 Splash

### UI

```text
Logo
Brand animation
```

### Background work

- version check;
- token check;
- local cache initialization;
- FCM initialization;
- me().

Maximum UX timeout: 3 sec.

---

## 17.2 Onboarding

3 slayd:

1. Hamkorlar va qarzlar
2. Bo‘lib to‘lash
3. Hisobotlar

Skip:

```text
O‘tkazib yuborish
```

P2.

---

## 17.3 Phone

### UI

```text
Logo

Telefon raqamingiz
[ +998 (93) 737-33-22 ]

☐ Foydalanish shartlariga roziman

[ Davom etish ]
```

Button faqat valid bo‘lganda enabled.

Backend verify-number dan keyin:
- login → password;
- register → OTP;
- blocked → blocking dialog.

---

## 17.4 OTP

```text
+998 (93) 737-33-22

SMS orqali yuborilgan 4 xonali kodni kiriting

[ • • • • ]

Qayta yuborish 00:43
```

4 digit bo‘lishi bilan auto-submit.

Error:

```text
OTP noto‘g‘ri
```

OTP oqimi backendda 60 sekund va verify token 2 daqiqa amal qiladi. 

---

## 17.5 Login

```text
Telefon
Parol

[ Ko‘rsatish ]

[ Kirish ]

Parolni unutdingizmi?
```

---

## 17.6 Register

```text
Ism
Parol
Parolni takrorlash

[ Ro‘yxatdan o‘tish ]
```

Password:
- min 6;
- show/hide;
- strength optional.

---

## 17.7 Pincode

```text
Ilovani himoyalang

4 xonali PIN yarating

● ● ● ●
```

Biometrika:

```text
Face ID
Touch ID
Fingerprint
```

5 ta xato → logout/password flow.

---

## 17.8 Account Selection

Agar user + staff:

```text
Qaysi hisobda ishlaysiz?

[ O‘z hisobim ]

[ Sarvar ]
  Xodim sifatida
```

Tanlangandan keyin context header:

```text
Sarvar hisobida ishlayapsiz
[Almashtirish]
```

---

# 18. BOTTOM NAVIGATION

5 tab:

```text
Bosh sahifa
Hamkorlar
Loyihalar
Hisobotlar
Profil
```

Permission bo‘yicha ayrim tablar yashirilishi mumkin.

Icon:
- outlined inactive;
- filled active.

Notification badge Profil yoki Dashboard bell orqali ko‘rsatiladi.

---

# 19. DASHBOARD

## Header

```text
Assalomu alaykum, Sarvar 👋

[notification]
```

Staff:

```text
Sarvar hisobida ishlayapsiz
```

## Subscription banner

GRACE:

```text
Obunangiz muddati tugash arafasida
[Yangilash]
```

READ_ONLY:

```text
Faqat ko‘rish rejimi
[Tariflar]
```

## Partners

```text
Hamkorlar
42 ta

[Muddati o‘tgan]
3

[Bugun]
1

[3 kun ichida]
5
```

## Installments

```text
Bo‘lib to‘lash

[Muddati o‘tgan]
2

[Bugun]
0

[3 kun ichida]
4
```

0 count card:
- disabled;
- grey;
- no navigation.

## Projects

```text
Loyihalar
7

Jarayonda 4
Muzlatilgan 1
Tugallangan 2
```

## Quick Actions

Floating / horizontal:

```text
+ Kirim
+ Chiqim
+ Hamkor
```

Permission bilan.

Dashboard backend endpointi `/reports/dashboard` bo‘lib, hamkor qarz muddatlari, installment muddatlari va loyiha statuslarini qaytaradi. 

---

# 20. PARTNERS LIST

## Header

```text
Hamkorlar

[ Search... ] [Filter] [Sort]
```

Search debounce:

```text
400ms
```

## Partner Card

```text
[AT]  Alibek Toshmatov
      +998 (90) 123-45-67

      Xaqdor
      1 500 000 UZS

      Bo‘lib to‘lash:
      400 000 UZS
```

USD mavjud bo‘lsa alohida qator.

0 bo‘lgan valyuta ko‘rsatilmaydi.

## Swipe actions

Owner permission bo‘lsa:

```text
Edit
Delete
```

Soft deleted:

```text
O‘chirilgan
[Restore]
```

## FAB

```text
+
Hamkor qo‘shish
```

---

# 21. PARTNER FILTER BOTTOM SHEET

```text
Filtr

Holat
○ Barchasi
○ Xaqdorlar
○ Qarzdorlar
○ Muddati o‘tgan qarzdorlar

Qo‘shilgan sana
[ Boshlanish ] [ Tugash ]

[ Filtrni tozalash ]
[ Natijalarni ko‘rsatish ]
```

Status backend endpointidan olinmaydi, lokal enum orqali beriladi, chunki backend TZ da status-filter-options route conflict sabab ishlamasligi ko‘rsatilgan. 

---

# 22. PARTNER SORT BOTTOM SHEET

```text
Saralash

○ Oxirgi faollik
○ Qarzdor UZS
○ Qarzdor USD
○ Xaqdor UZS
○ Xaqdor USD
```

---

# 23. CREATE / EDIT PARTNER

Full-screen form.

```text
Hamkor qo‘shish

Avatar
[Rasm qo‘shish]

Ism
[________________]

Telefon
[+998 (__) ___-__-__]

Qo‘shimcha telefon
[+998 (__) ___-__-__]

Asosiy valyuta
[ UZS > ]
```

Currency classic dropdown emas.

Bosilganda:

```text
BottomSheet
UZS ✓
USD
```

Files:
```text
[ Kamera ]
[ Galereya ]
[ Fayl ]
```

Bottom sticky CTA:

```text
[ Saqlash ]
```

---

# 24. PARTNER DETAIL

Top:

```text
← Alibek Toshmatov
   +998 (90) 123-45-67
```

Account cards:

```text
UZS
Kirim       5 000 000
Chiqim      3 500 000
Balans      +1 500 000
Bo‘lib      400 000
```

USD alohida.

Quick action row:

```text
Call
SMS
Report
Excel
SMS settings
Edit
```

## Tabs

```text
Tranzaksiyalar
Bo‘lib to‘lash
SMS tarixi
```

---

# 25. TRANSACTIONS

Date-grouped:

```text
BUGUN
```

Transaction:

```text
↓ Kirim
+1 000 000 UZS
Tovar uchun

Bugun 10:15
Abdulloh kiritdi
```

Credit:

```text
↑ Chiqim
−1 000 000 UZS
```

Return date:

```text
Qaytarish: 01.10.2026
```

Cancelled:

```text
╳ −1 000 000 UZS
Bekor qilingan
Sabab: Xato kiritildi
```

Text strikethrough.

---

# 26. CREATE WALLET — KIRIM / CHIQIM

Bu ilovadagi eng muhim form.

## Header

```text
Kirim
```

yoki

```text
Chiqim
```

## Type

Agar Dashboard'dan Kirim bosilsa:

```text
Kirim
```

locked.

Partner detaildan kiritilsa:

```text
Kirim | Chiqim
```

Segment control.

## Currency

```text
UZS | USD
```

## Amount

Huge typography:

```text
1 500 000
UZS
```

Numeric keyboard.

## Description

Multiline.

## Return date

Faqat Chiqim:

```text
Qaytarish sanasi

[1 hafta]
[2 hafta]
[1 oy]
[Sana tanlash]
```

Date selection bottom sheet/calendar.

## Attachment

```text
+ Fayl biriktirish
```

## SMS hint

Agar SMS yuborilsa:

```text
ⓘ Hamkorga SMS xabar yuboriladi
```

Limit tugagan:

```text
SMS limiti tugagan — xabar yuborilmaydi
```

## Submit

```text
[ Chiqimni saqlash ]
```

Success:
- sheet/form close;
- transaction refresh;
- account refresh;
- snackbar `Saqlandi`.

---

# 27. TRANSACTION ACTION SHEET

Transaction card bosilganda:

```text
Kirim

1 000 000 UZS

Tahrirlash
Bekor qilish
Fayllarni ko‘rish
```

Kirim uchun edit **ko‘rsatilmaydi**.

Owner-only:
```text
O‘chirish
```

---

# 28. CANCEL TRANSACTION

Bottom sheet:

```text
Tranzaksiyani bekor qilish

Bekor qilish sababi
[________________]

Kamida 3 belgi

[ Bekor qilish ]
```

Confirmation destructive.

---

# 29. SMS SETTINGS

Full screen yoki large bottom sheet.

```text
SMS sozlamalari

SMS xizmati                         ON

Kirim qilinganda SMS                ON
Chiqim qilinganda SMS               ON

Muddatdan oldin eslatish
[ 1 kun ]

Muddat kunida eslatish               ON

Muddatdan keyin
[ 1 kun ]

SMS yuborish vaqti
10:00
```

`enabled=false` bo‘lsa qolgan switchlar disabled.

Selection values bottom sheet orqali.

Bottom:

```text
Bu oy: 12 / 50 SMS ishlatildi

[ SMS paket sotib olish ]
```

Backend SMS settings uchun options 1/3/5 kun kabi qiymatlarni beradi. 

---

# 30. SMS HISTORY

```text
SMS tarixi
```

Card:

```text
01.09.2026 10:00

Hurmatli Alibek...
...

✓ Yuborildi
```

Failed:

```text
✕ Yuborilmadi
```

---

# 31. INSTALLMENTS LIST

Card:

```text
Alibek Toshmatov

500 000 UZS

████████░░ 80%

To‘langan: 400 000
Qolgan: 100 000

5 ta qism

Faol
```

Filter chips:

```text
Faol
Yopilgan
Bekor qilingan
```

Additional filters bottom sheet.

---

# 32. CREATE INSTALLMENT WIZARD

3 step.

## Step 1

```text
1 / 3

Hamkor
[ Alibek > ]

Valyuta
[ UZS ]

Jami summa
[ 500 000 ]

Izoh
[ Muzlatgich ]

Fayl
[ + ]
```

## Step 2

```text
2 / 3

Grafik turi

[Teng] [Erkin]

Avans bor
          ON

Avans:
[100 000]

Boshlanish sanasi
[01.10.2026]

Qismlar soni
[-] 4 [+]
```

`custom`:

```text
Qism 1
Summa
Sana
Izoh

Qism 2
...

[ + Qism qo‘shish ]
```

## Step 3

```text
3 / 3

To‘lov grafigi

1   100 000   01.10.2026   Avans
2   100 000   01.11.2026
3   100 000   01.12.2026
...

Jami: 500 000 UZS
```

Validation:
- custom sum = total;
- advance < total;
- dates >= today;
- equal without advance >= 2;
- total > 0.

Backend TZ installment qoidalari va preview algoritmini client-side ham bir xil qilishni talab qiladi. 

---

# 33. INSTALLMENT DETAIL

Header:

```text
Alibek Toshmatov
500 000 UZS

400 000 to‘langan
100 000 qolgan

████████░░

Faol
```

Schedule:

```text
01
100 000
01.10.2026
✓ To‘langan

02
100 000
01.11.2026
Yaqinlashdi

03
100 000
01.12.2026
Kutilmoqda
```

Overdue:

```text
Muddati o‘tgan
```

Buttons:

```text
[ To‘lov qabul qilish ]
[ To‘lovlar tarixi ]
```

More action sheet:

```text
Tahrirlash
Bekor qilish
```

---

# 34. INSTALLMENT PAYMENT BOTTOM SHEET

```text
To‘lov qabul qilish

Qolgan:
100 000 UZS

Summa
[100 000]

Tez tanlash:
[Keyingi qism]
[Barcha qolgan qarz]

Izoh
[ Naqd ]

Sana
[ Bugun ]
```

Preview:

```text
Ushbu to‘lov:
2-qismni to‘liq
3-qismni qisman yopadi
```

CTA:

```text
[ To‘lovni qabul qilish ]
```

Backend FIFO algoritmi sabab preview ham FIFO bo‘yicha hisoblanadi. 

---

# 35. PAYMENT HISTORY

```text
15.10.2026 12:00
+100 000 UZS

Abdulloh qabul qildi

Reja:
100 000 → 200 000

Naqd
```

Faqat oxirgi bekor qilinmagan payment:

```text
[ Bekor qilish ]
```

---

# 36. PROJECTS LIST

Header:

```text
Loyihalar
[Search] [Filter]
```

Card:

```text
Chilonzor 12-uy

Buyurtmachi:
Aziz aka

+998 (90) 111-22-33

Toshkent, Chilonzor

[ Jarayonda ]
```

Status chips:

```text
Jarayonda
Muzlatilgan
Tugallangan
```

FAB:

```text
+ Loyiha
```

---

# 37. CREATE PROJECT

```text
Loyiha nomi
Buyurtmachi
Telefon
Manzil
Lokatsiya
Fayllar
```

Location:

```text
[ Xaritadan tanlash ]
```

Map screen/bottom sheet.

---

# 38. PROJECT DETAIL

Header:

```text
Chilonzor 12-uy
[Jarayonda]
```

Balance:

```text
UZS
Daromad
Xarajat
Balans

USD
Daromad
Xarajat
Balans
```

Tabs:

```text
Shartnomalar
Daromadlar
Xarajatlar
Ishchilar
```

---

# 39. PROJECT CONTRACT

Bottom sheet form:

```text
Ish turi
[ Beton ishlari > ]

Tavsif
[________________]

Summa
[1 500 000]

Fayl
```

Work type bottom sheet searchable.

---

# 40. PROJECT INCOME

```text
Valyuta
UZS | USD

Summa
[ ]

Izoh
[ ]

Fayl
```

---

# 41. PROJECT COST

```text
Xarajat turi
[ Transport > ]

Valyuta
UZS | USD

Summa
[ ]

Izoh
[ ]
```

Agar cost type `is_worker_join=true`:

```text
Ishchi
[ Ishchini tanlang > ]
```

Worker selection bottom sheet.

---

# 42. PROJECT WORKERS

```text
Ishchilar

[ + Ishchi biriktirish ]
```

Multi-selection bottom sheet:

```text
☐ Abdulloh
☑ Akmal
☐ Jamshid

[ Bekor qilish ]
[ Biriktirish ]
```

---

# 43. DOCUMENTS

Profile → Ma’lumotnomalar.

Sections:

```text
Valyutalar
Ish turlari
Xarajat turlari
Lavozimlar
Ishchilar
Valyuta kurslari
```

CRUD list universal pattern.

Item:

```text
Nomi
Description
[...]
```

Action sheet:

```text
Tahrirlash
O‘chirish
```

Deleted item:

```text
O‘chirilgan
Tiklash
Butunlay o‘chirish
```

---

# 44. CURRENCY RATES

```text
Valyuta kurslari

USD
12 450.00
+15.20

EUR
14 100.00
−22.10
```

Increase/decrease visual.

Converter:

```text
USD
[100]

UZS
[1 245 000]
```

Currency selection bottom sheet.

---

# 45. REPORTS HOME

Reports faqat permission mavjud bo‘lsa ko‘rsatiladi.

```text
Hisobotlar

Hamkorlar
Bo‘lib to‘lash
Loyihalar
```

Each as large navigation card.

---

# 46. REPORT GLOBAL FILTER

Barcha reportlarda yagona filter:

```text
Valyuta:
[ UZS | USD ]

Davr:
[ Bugun ]
[ Hafta ]
[ Oy ]
[ Ixtiyoriy ]
```

Custom:

```text
Boshlanish
Tugash
```

Date range bottom sheet.

Sessiya davomida tanlangan period saqlanadi.

---

# 47. PARTNER SUMMARY REPORT

```text
UZS

Kirim
15 000 000

Chiqim
8 000 000

Balans
7 000 000
```

Clickable:

```text
Operatsiyalar
120

Xaqdorlar
18

Qarzdorlar
7
```

Tap → detail list.

---

# 48. PERIOD REPORT

```text
Sentabr 2026

Kirim
...

Chiqim
...
```

Type filter:

```text
[Kirim] [Chiqim]
```

Operations list.

---

# 49. DUE DATE REPORT

Cards:

```text
Muddati o‘tgan
3

Bugun
1

3 kun ichida
5
```

Detail:

```text
Alibek
600 000 UZS

01.09.2026

6 kun kechikdi
```

Quick actions:
- call;
- SMS;
- Kirim.

---

# 50. WORKER REPORT

```text
Abdulloh
Kirim: ...
Chiqim: ...
Operatsiyalar: 24
```

Tap:

```text
Worker Summary
Worker Operations
```

---

# 51. PARTNER DETAIL REPORT

KPI:

```text
Balans
Kirim
Chiqim
Operatsiyalar
```

Charts:

```text
3 oy — Bar Chart
7 kun — Line Chart
```

Chart tap → tooltip.

`fl_chart` ishlatiladi.

---

# 52. INSTALLMENT REPORTS

Screens:

```text
Umumiy
Hamkorlar
Kutilayotgan to‘lovlar
Muammoli hamkorlar
Undirish samaradorligi
Oylik dinamika
Status bo‘yicha qismlar
Hamkor bo‘yicha
```

KPI cards clickable.

Risk/rating:

```text
Risk: Yuqori
```

Color semantic.

---

# 53. PROJECT REPORTS

Project selector:

```text
Loyihani tanlang
```

Dropdown emas.

Bottom sheet:

```text
Search
Project list
```

Balance:

```text
Daromad
Xarajat
Balans
```

Pie chart:

```text
Xarajat turlari
```

Details table/list.

---

# 54. SUBSCRIPTION

Agar:

```text
x_ziffler == false
```

bo‘lsa:

- subscription tab;
- plans;
- purchase;
- SMS package purchase

umuman UI'dan yashiriladi.

Bu backend TZ bilan mos. 

## My Subscription

```text
STANDARD
Faol

01.09.2026 — 01.10.2026

24 kun qoldi
████████░░
```

Limits:

```text
Hamkorlar
42 / 100

Loyihalar
3 / 5

Xodimlar
1 / 1

SMS
12 / 50
```

80%+ → warning.
100% → error.

---

# 55. PLANS

Billing segment:

```text
Oylik
6 oy
Yillik
```

Tarif cards:

```text
STANDARD

27 000 UZS / oy

100 Hamkor
5 Loyiha
1 Xodim
50 SMS

[ Tanlash ]
```

Discount:

```text
−30%
```

Current:

```text
Joriy tarifingiz
```

`can_subscribe=false`:

```text
[ Tanlash ] disabled

Sabab:
Hamkorlar soni limitdan oshib ketgan
```

---

# 56. PAYMENT FLOW

1. Plan select.
2. Payment provider bottom sheet:

```text
Payme
Click
```

3. External payment page.
4. Deep-link return.
5. Polling every 5 sec, max 2 min.
6. Result:

```text
PAID
→ success screen

PENDING
→ checking screen

FAILED
→ error + retry
```

Backend payment flow aynan external `payment_url`, deep link va status polling orqali ishlaydi. 

---

# 57. SMS PACKAGES

Cards:

```text
SMS 10
2 500 UZS

[ Sotib olish ]
```

```text
SMS 50
12 500 UZS
```

```text
SMS 100
25 000 UZS
```

Purchase flow subscription payment flow bilan bir xil.

---

# 58. NOTIFICATIONS

Header:

```text
Bildirishnomalar
```

List:

```text
● Yangi obuna sotib olindi
  Bugun 12:30

  Batafsil...
```

Unread:
- bold;
- dot;
- subtle background.

Push deep links:

```text
subscription → subscription
sms_purchase → SMS/subscription
partner_id → partner detail
plan_id → installment detail
unknown → notifications
```

Backend push flow foreground/background/terminated holatlarini ham belgilaydi. 

---

# 59. STAFF

Faqat owner.

## Staff list

```text
Abdulloh
+998 (90) 123-45-67

8 ta ruxsat

Faol        ON
```

## Add staff wizard

Step 1:

```text
Telefon
[+998 ...]
```

Step 2:

```text
OTP
```

Step 3:

```text
Ism
Parol

Ruxsatlar
```

Permissions grouped:

```text
Mijozlar
☐ Ko‘rish
☐ Qo‘shish
☐ Tahrirlash
☐ O‘chirish

[Barchasini tanlash]
```

Permission selection checkbox UI, dropdown emas.

Kamida 1 permission.

---

# 60. ACTIVITY LOG

Timeline:

```text
●
Abdulloh tranzaksiyani bekor qildi
Wallet
12.09.2026 14:30

│

●
Sarvar hamkor qo‘shdi
Partner
12.09.2026 13:10
```

Filter bottom sheet:

```text
Amal
Model
Xodim
Sana
```

Action colors semantic.

---

# 61. PROFILE

Header:

```text
[Avatar]

Sarvar
+998 (90) 123-45-67
```

Menu:

```text
Shaxsiy ma’lumotlar
Obuna va tariflar
SMS paketlari
Xodimlar
Ma’lumotnomalar
Faollik jurnali
Bildirishnomalar
Valyuta kurslari
Qo‘llanmalar
Sozlamalar
Yordam va aloqa
Foydalanish shartlari
Maxfiylik siyosati
Ilova versiyasi
```

Bottom:

```text
Chiqish
```

Danger:

```text
Hisobni o‘chirish
```

---

# 62. PROFILE EDIT

```text
Ism
Telefon
```

Phone change 3-step:
1. new phone;
2. OTP;
3. verification.

Password:

```text
Eski parol
Yangi parol
```

---

# 63. SETTINGS

## Language

Bottom sheet:

```text
O‘zbek
Русский
```

Tanlangan:

```text
Русский ✓
```

## Theme

```text
Light
Dark
Tizim
```

Backend mode `light/dark`; local `system` preference ThemeCubit orqali boshqariladi.

## Pincode

```text
Pincode
Biometrika
```

OS notification:

```text
Bildirishnomalarni sozlash
```

→ system settings.

---

# 64. LOCALIZATION

Faqat:

```text
uz
ru
```

UI hardcode qilinmaydi.

Structure:

```text
assets/l10n/
├── app_uz.arb
└── app_ru.arb
```

Keyinchalik en qo‘shishga tayyor arxitektura saqlanadi.

Backend `Accept-Language` headeri:
- `uz`
- `ru`

UI tarjimalari frontend localization fayllarida bo‘ladi.

Dynamic backend error message serverdan kelgan holatda tarjima qilinmaydi, agar backend xabarining o‘zi lokalizatsiya qilinmagan bo‘lsa.

---

# 65. RESPONSIVE — SCREENUTIL

`flutter_screenutil`.

Base design:

```text
360 x 800
```

Usage:

```dart
16.w
12.h
16.sp
```

Tablet:

```text
max content width:
600–720
```

Landscape:
- portrait only.

Backend TZ 320dp–1024dp diapazonini va portrait orientationni belgilaydi. 

---

# 66. KEYBOARD / FORM UX

Form ochilganda:
- keyboard auto scroll;
- focused field always visible;
- bottom CTA keyboard ustida chiqishi mumkin;
- `resizeToAvoidBottomInset` tekshiriladi.

Input:
- correct keyboard type;
- numeric input uchun decimal keyboard;
- phone uchun phone keyboard;
- password uchun obscured keyboard.

---

# 67. FILE UPLOAD UX

Flow:

```text
+ Fayl biriktirish
        ↓
BottomSheet
 ├── Kamera
 ├── Galereya
 └── Fayl
```

Upload:

```text
Uploading...
████████░░
```

Success:

```text
✓ file.pdf
```

Error:

```text
Yuklash muvaffaqiyatsiz
[Qayta urinish]
```

Limit:
- max 5 MB;
- jpg/jpeg/png/webp/pdf/doc/docx/xls/xlsx/txt.

Backend signed URL 1 soat amal qiladi; URL cache key sifatida ishlatilmaydi, file ID asosida cache qilinadi. 

---

# 68. NETWORK LAYER

Dio client:

```text
Base URL
Headers
Auth interceptor
Owner interceptor
Error interceptor
Logging interceptor
Retry
```

Timeout:

```text
connect: 15 sec
send: 30 sec
receive: 30 sec
Excel: 120 sec
```

## Headers

```text
Accept: application/json
Content-Type: application/json
Authorization: Bearer ...
Accept-Language: uz/ru
X-As-Owner: owner_id
```

`X-As-Owner` faqat staff contextda.

---

# 69. ERROR MAPPER

## 401

```text
clear token
clear local auth state
logout
→ login
```

Message:

```text
Sessiya tugadi, qaytadan kiring
```

Agar second device:

```text
Hisobingizga boshqa qurilmadan kirildi
```

## 403

Snackbar:

```text
Bu amalni bajarish uchun ruxsatingiz yo‘q.
```

## 422

Inline field error.

## 200 status=false

Server error message.

## 5xx

```text
Serverda xatolik.
Keyinroq urinib ko‘ring.

[Qayta urinish]
```

## No internet

```text
Internet aloqasi yo‘q

[Qayta urinish]
```

Backend TZ ushbu markazlashgan error interceptor algoritmini majburiy deb belgilaydi. 

---

# 70. PAGINATION

Infinite scroll.

Trigger:
- list oxiriga 3 item qolganda.

Footer:

```text
Loading skeleton
```

Error:

```text
Keyingi ma’lumotlarni yuklab bo‘lmadi
[Qayta urinish]
```

Primary pagination `links.next != null`.

Activity Log maxsus pagination:

```text
total
per_page
current_page
last_page
```

---

# 71. OFFLINE

Read-only cache:

```text
Partners
Transactions
Documents
Profile
```

Offline banner:

```text
Offline — oxirgi ma’lumotlar ko‘rsatilmoqda
```

Create/update/delete:
**offline queue yo‘q**.

Offline write:

```text
Internet aloqasi yo‘q
```

Reports cache qilinmaydi.

Backend TZ ham aynan shu strategiyani belgilaydi. 

---

# 72. PULL TO REFRESH

Barcha asosiy list/detail/reportlarda.

```text
RefreshIndicator
```

Dashboard:
- barcha bloklar refresh.

Partner detail:
- account + transactions + installments.

Subscription:
- subscription + statistics.

---

# 73. ANIMATION

Animation minimal va professional.

## Page

```text
300ms
easeOutCubic
```

## Bottom sheet

Native platform animation.

## List insertion

```text
150–220ms
```

## Number change

KPI uchun subtle animated number.

## Theme

Light ↔ Dark:
- global theme transition;
- hard cut taqiqlanadi.

---

# 74. HAPTIC

Use cases:

```text
Successful save
Destructive confirmation
Toggle
Selection
Payment success
Pull refresh completion
```

Excessive haptic taqiqlanadi.

---

# 75. ACCESSIBILITY

- semantic labels;
- icon-only buttonlarda tooltip/semantic label;
- minimum touch 44x44;
- text scaling support;
- contrast;
- no color-only meaning;
- charts uchun textual summary;
- screen reader compatible.

---

# 76. SECURITY

Token:

```text
flutter_secure_storage
```

Pincode:

```text
flutter_secure_storage
```

Sensitive data:
- logsga chiqarilmaydi;
- Dio logger production'da body/tokenni ko‘rsatmaydi.

Logout:
- token;
- pincode;
- cache;
- current user;
- owner context

tozalanadi.

---

# 77. PERMISSION UI ARCHITECTURE

```dart
PermissionGuard(
  permission: Permissions.partnersCreate,
  child: ...
)
```

## Rules

```text
view missing
→ menu/tab hidden

create missing
→ create CTA hidden

edit missing
→ edit CTA hidden

delete missing
→ delete action hidden
```

Disabled qilish faqat biznes sababiga ko‘ra kerak bo‘lsa ishlatiladi, permission uchun emas.

---

# 78. SUBSCRIPTION UI GUARD

Global:

```text
SubscriptionStatusBanner
SubscriptionActionGuard
```

READ_ONLY:

```text
Create
Edit
Delete
Payment mutation
```

blocked.

Read:
- available.

ARCHIVED:

```text
SubscriptionRequiredScreen
```

---

# 79. GLOBAL WIDGETS

```text
AppScaffold
AppBar
AppBottomNavigation
AppCard
AppButton
AppIconButton
AppTextField
AppMoneyField
AppPhoneField
AppSearchField
AppSegmentedControl
AppChip
AppStatusChip
AppSkeleton
AppEmptyState
AppErrorState
AppBottomSheet
AppSelectionSheet
AppMultiSelectionSheet
AppDateRangeSheet
AppConfirmationDialog
AppSnackbar
AppFilePicker
AppAvatar
AppBalanceCard
AppKpiCard
AppProgressBar
AppTimeline
AppPermissionGuard
AppSubscriptionGuard
```

---

# 80. DATA MODELS

Freezed.

Example:

```dart
@freezed
class Partner with _$Partner {
  const factory Partner({
    required int id,
    required String name,
    required String phone,
    String? additionalPhone,
    required Balance balance,
    ...
  }) = _Partner;

  factory Partner.fromJson(Map<String, dynamic> json) =>
      _$PartnerFromJson(json);
}
```

Domain layer UI'dan mustaqil.

---

# 81. REPOSITORY

```text
RemoteDataSource
       ↓
Repository
       ↓
UseCase
       ↓
Bloc/Cubit
       ↓
Page
```

UI to‘g‘ridan-to‘g‘ri Dio chaqirmaydi.

---

# 82. CACHE

Isar yoki Hive.

Cache:
- documents;
- last partners page;
- last transaction page;
- me/profile.

Cache invalidation:
- create/update/delete success → ilgili cache invalidate;
- owner context switch → all business cache clear.

---

# 83. ANALYTICS

Events:

```text
app_open
login_success
login_failed
register_success
partner_created
partner_deleted
wallet_created
wallet_cancelled
installment_created
installment_payment
project_created
report_opened
subscription_purchase_started
subscription_purchase_success
subscription_purchase_failed
```

PII event parameterlarga yuborilmaydi.

---

# 84. CRASHLYTICS

Unexpected:
- API parse errors;
- routing errors;
- fatal UI exceptions;
- unexpected state errors

Crashlyticsga yuboriladi.

Token/password yuborilmaydi.

---

# 85. TESTING

## Unit

- formatters;
- money;
- phone;
- date;
- installment equal algorithm;
- FIFO preview;
- permission;
- subscription guard.

## Bloc tests

Har bir critical Bloc.

## Widget

Critical screens:
- auth;
- partners;
- wallet;
- installment;
- payment;
- projects;
- reports.

## Integration

```text
Register
Login
Create partner
Create wallet
Create installment
Payment
Project
Logout
```

---

# 86. ACCEPTANCE CRITERIA

## Global

- [ ] Light mode.
- [ ] Dark mode.
- [ ] Uzbek.
- [ ] Russian.
- [ ] No dropdown.
- [ ] Selection bottom sheet.
- [ ] Native-like navigation.
- [ ] GoRouter.
- [ ] flutter_bloc.
- [ ] Dio.
- [ ] ScreenUtil.
- [ ] Secure storage.
- [ ] Infinite scroll.
- [ ] Skeleton.
- [ ] Empty.
- [ ] Error.
- [ ] Pull refresh.

## Money

- [ ] `100 000` format.
- [ ] UZS/USD separate.
- [ ] No double calculations.
- [ ] Negative red.
- [ ] Positive green.

## Phone

- [ ] `+998 (93) 737-33-22`.
- [ ] Backend receives 9 digits.

## Permission

- [ ] Hidden if no permission.
- [ ] Owner/staff context.
- [ ] X-As-Owner.

## Subscription

- [ ] ACTIVE.
- [ ] GRACE_PERIOD.
- [ ] READ_ONLY.
- [ ] ARCHIVED.
- [ ] x_ziffler.

---

# 87. SCREEN INVENTORY

## P0

```text
Splash
Phone
OTP
Register
Login
Dashboard
Partners
Partner Detail
Wallet Create
Wallet Cancel
```

## P1

```text
Pincode
Account Selection
Dashboard Due Dates
Installments
Installment Create
Installment Detail
Payment
Projects
Project Detail
Reports
Subscription
Notifications
Staff
Activity Log
Profile
Settings
Documents
```

## P2

```text
Onboarding
SMS History
Worker assignment
Tutorials
Advanced reports
```

Backend TZ appendixida jami ekranlar inventorysi ham berilgan; frontend TZ shu inventoryni UI implementation nuqtayi nazaridan kengaytiradi. 

---

# 88. DEVELOPMENT MILESTONES

## M0 — Foundation

```text
Flutter project
Theme
Localization
Dio
GoRouter
BLoC
DI
Storage
Common widgets
CI
```

## M1 — Auth + Profile

```text
Splash
Phone
OTP
Login
Register
Pincode
Profile
Settings
```

## M2 — Partners

```text
Partner list
Filter
Sort
Create
Edit
Detail
Wallet
SMS
```

## M3 — Installments

```text
List
Wizard
Schedule
Payment
History
```

## M4 — Dashboard + Projects + Documents

## M5 — Reports

## M6 — Subscription + Push + Staff + Activity

## M7 — QA + Polish + Store

Backend TZ ham developmentni M0–M7 tarzida bosqichlarga ajratadi. 

---

# 89. DEFINITION OF DONE

Har bir ekran uchun:

- [ ] Figma bilan pixel-level mos.
- [ ] Light mode.
- [ ] Dark mode.
- [ ] Uzbek.
- [ ] Russian.
- [ ] Loading.
- [ ] Empty.
- [ ] Error.
- [ ] Success.
- [ ] Responsive.
- [ ] Keyboard safe.
- [ ] Permission checked.
- [ ] Subscription checked.
- [ ] Owner context checked.
- [ ] Offline state checked.
- [ ] Accessibility checked.
- [ ] Haptic kerakli joylarda.
- [ ] Animation.
- [ ] API integration.
- [ ] Unit test.
- [ ] Widget test.
- [ ] No hardcoded UI strings.
- [ ] No dropdown.
- [ ] Money formatter.
- [ ] Phone formatter.
- [ ] Date formatter.
- [ ] `flutter analyze` = 0 error / 0 warning.

---

# 90. CODE QUALITY

Majburiy:

```text
flutter analyze
0 errors
0 warnings
```

Lint:
```text
very_good_analysis
```

Rules:
- magic string yo‘q;
- magic number yo‘q;
- business logic UI'da yo‘q;
- API call widgetda yo‘q;
- duplicated formatter yo‘q;
- duplicated permission logic yo‘q;
- duplicated theme values yo‘q.

---

# 91. NATIVE-LIKE FINAL QUALITY BAR

Developer quyidagi holatda “tayyor” deb hisoblamaydi:

```text
API ishlayapti
```

yetarli emas.

Quyidagilar ham ishlashi kerak:

```text
Loading
→ skeleton

Slow network
→ stable UI

No internet
→ offline state

API error
→ retry

401
→ automatic logout

403
→ permission feedback

Form error
→ inline

Keyboard
→ no overflow

Dark mode
→ correct contrast

Russian
→ no overflow

Long name
→ correct ellipsis/wrap

Large amount
→ no overflow

Small phone
→ no overflow

Tablet
→ centered responsive layout

Back gesture
→ native

Bottom sheet
→ native-like

Theme change
→ smooth

Push
→ deep link

Payment
→ return from external app
```

---

# 92. FINAL FRONTEND PRINCIPLES

1. **Mobile-first.**
2. **Native-like UX.**
3. **Dropdown yo‘q.**
4. **Selection → Bottom Sheet.**
5. **BLoC/Cubit → yagona state management.**
6. **Dio → yagona HTTP client.**
7. **GoRouter → yagona navigation.**
8. **ScreenUtil → responsive.**
9. **Freezed → models.**
10. **SecureStorage → token/pincode.**
11. **Money → Decimal-safe.**
12. **Phone → `+998 (XX) XXX-XX-XX`.**
13. **Light/Dark → birinchi darajali requirement.**
14. **UZ/RU → birinchi darajali requirement.**
15. **Permission → UI renderdan oldin tekshiriladi.**
16. **Subscription → global guard.**
17. **Skeleton → spinner emas.**
18. **Empty/Error state → har bir screen uchun majburiy.**
19. **No offline writes.**
20. **UI backend biznes qoidalarini buzmasligi kerak.**
21. **Figma mavjud bo‘lsa pixel-level implementation.**
22. **Kichik ekran, katta ekran va uzun matnlar albatta test qilinadi.**
23. **Production'da debug/logging orqali sensitive data chiqmasligi kerak.**
24. **Har bir critical flow test bilan yopiladi.**
25. **Frontend “CRUD ekranlar to‘plami” emas, yagona design systemga ega native-quality mobil mahsulot sifatida ishlab chiqiladi.**

---

## SOURCE NOTES

Ushbu frontend TZ quyidagi backend TZ talablari asosida ishlab chiqildi:

- Flutter arxitekturasi, BLoC, Dio, GoRouter, secure storage va cache talablari;
- API error/pagination/format qoidalari;
- Auth;
- Owner/staff permissions;
- Dashboard;
- Partners/wallet;
- Installments;
- Projects;
- Documents;
- Reports;
- Subscription;
- Push;
- Staff;
- Activity Log;
- Profile/settings;
- Localization/theme;
- Acceptance criteria.

Backend TZ da ushbu talablar mos ravishda architecture, UI/UX va screen inventory bo‘limlarida berilgan. 
