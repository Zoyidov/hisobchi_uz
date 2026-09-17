# E-HISOB — FLUTTER UI COMPONENT SYSTEM / DESIGN SYSTEM TZ

**Hujjat turi:** UI Component Library + Flutter implementation specification  
**Platforma:** iOS + Android  
**Frontend:** Flutter  
**State:** flutter_bloc / Cubit  
**Navigation:** GoRouter  
**Network:** Dio  
**Responsive:** flutter_screenutil  
**Localization:** Uzbek / Russian  
**Theme:** Light / Dark / System  
**Design source:** Figma  
**Quality target:** Senior / Production / Native-like

---

# 1. HUJJAT MAQSADI

Ushbu hujjat E-HISOB mobil ilovasi uchun barcha qayta ishlatiladigan UI komponentalarini yagona standartga keltirish uchun yozilgan.

Backend TZ da Figma dizayniga **piksel darajasida moslik** talabi mavjud. Figma'da loading, empty va error holatlari berilmagan bo‘lsa, standart UI patternlardan foydalanish kerak. Shuningdek, mobil ilova 320dp–1024dp kenglik oralig‘ida responsive bo‘lishi va portrait orientationni qo‘llashi kerak.

Ushbu hujjat esa shu talabni konkret Flutter komponentalariga ajratadi:

```text
Foundation
↓
Theme
↓
Typography
↓
Iconography
↓
Buttons
↓
Inputs
↓
Cards
↓
Lists
↓
Tabs
↓
Navigation
↓
Bottom Sheets
↓
Dialogs
↓
Feedback
↓
Loading
↓
Empty / Error
↓
Charts
↓
Forms
↓
Business Components
```

**Asosiy prinsip:**

> Feature screenlar alohida dizayn qilinmaydi; ular Design System komponentalaridan yig‘iladi.

---

# 2. COMPONENT NOMLASH STANDARTI

Flutter class nomlari:

```text
AppButton
AppIconButton
AppTextField
AppMoneyField
AppPhoneField
AppCard
AppListTile
AppSection
AppTabBar
AppSegmentedControl
AppBottomSheet
AppSelectionSheet
AppFilterSheet
AppDateRangeSheet
AppStatusChip
AppBadge
AppAvatar
AppKpiCard
AppBalanceCard
AppProgressBar
AppSkeleton
AppEmptyState
AppErrorState
AppSnackbar
AppDialog
AppConfirmationDialog
```

Business-specific:

```text
PartnerCard
TransactionCard
InstallmentCard
InstallmentScheduleItem
ProjectCard
WorkerCard
SubscriptionCard
PlanCard
NotificationCard
ActivityTimelineItem
```

Generic component ichiga biznes logic joylashtirilmaydi.

---

# 3. DESIGN TOKENS

Barcha UI qiymatlari token orqali olinadi.

```text
AppSpacing
AppRadius
AppColors
AppTypography
AppElevation
AppDuration
AppBreakpoints
AppIconSize
```

Widget ichida:

```dart
EdgeInsets.all(16)
```

kabi takroriy qiymatlar ko‘paytirilmasin.

Preferred:

```dart
EdgeInsets.all(AppSpacing.md)
```

---

# 4. SPACING SYSTEM

8pt grid.

```text
xxs = 4
xs  = 8
sm  = 12
md  = 16
lg  = 20
xl  = 24
xxl = 32
xxxl = 40
huge = 48
```

## Qoidalar

Screen horizontal padding:

```text
16dp
```

Tablet:

```text
24–32dp
```

Card internal padding:

```text
16dp
```

Section gap:

```text
24dp
```

List item gap:

```text
8–12dp
```

Input vertical gap:

```text
12–16dp
```

---

# 5. BORDER RADIUS

```text
small      = 8
medium     = 12
card       = 16
large      = 20
sheet      = 28
pill       = 999
```

## Qoidalar

Input:

```text
12–16
```

Card:

```text
16
```

BottomSheet:

```text
28 top corners
```

Chip:

```text
999
```

Button:

```text
12–16
```

Radiuslar feature bo‘yicha o‘zgarmasligi kerak.

---

# 6. HEIGHT SYSTEM

## Buttons

```text
Small: 40
Medium: 48
Large: 52
```

Primary CTA:

```text
48–52
```

## Inputs

```text
48–56
```

## Icon buttons

```text
44
48
```

## List items

Compact:

```text
56
```

Regular:

```text
72
```

Large:

```text
88+
```

Touch target hech qachon:

```text
< 44dp
```

bo‘lmasin.

---

# 7. COLORS

## Light

```text
Background       #F7F8FA
Surface          #FFFFFF
SurfaceSecondary #F1F3F5

TextPrimary      #15171A
TextSecondary    #6B7280
TextTertiary     #9CA3AF

Border           #E5E7EB
Divider          #ECEEF1

Primary          #2563EB
Success          #16A34A
Error            #DC2626
Warning          #D97706
Info             #2563EB

Disabled         #D1D5DB
Overlay          rgba(0,0,0,0.45)
```

## Dark

```text
Background       #0B0D0F
Surface          #15181C
SurfaceSecondary #1C2025

TextPrimary      #F5F7FA
TextSecondary    #A7AFBA
TextTertiary     #737B87

Border           #2A3038
Divider          #242A31

Primary          #3B82F6
Success          #22C55E
Error            #EF4444
Warning          #F59E0B
Info             #3B82F6

Disabled         #3B414A
Overlay          rgba(0,0,0,0.65)
```

---

# 8. SEMANTIC COLOR RULES

Rang faqat dekoratsiya emas, ma’no beradi.

```text
Green:
positive
income
paid
credit
success

Red:
negative
expense
debt
overdue
delete
failed

Amber:
warning
grace period
due soon
80%+ usage

Blue:
info
installment
neutral action
navigation

Grey:
disabled
inactive
cancelled
secondary
```

**Faqat rang orqali status bildirish mumkin emas.**

Status har doim:

```text
icon + label + color
```

kombinatsiyasida beriladi.

---

# 9. TYPOGRAPHY

Material 3 asosida custom typography.

## Display

```text
DisplayLarge
DisplayMedium
DisplaySmall
```

KPI/money.

## Headline

```text
HeadlineLarge
HeadlineMedium
HeadlineSmall
```

Page title.

## Title

```text
TitleLarge
TitleMedium
TitleSmall
```

Card va section title.

## Body

```text
BodyLarge
BodyMedium
BodySmall
```

Asosiy content.

## Label

```text
LabelLarge
LabelMedium
LabelSmall
```

Button, chip, metadata.

---

# 10. MONEY TYPOGRAPHY

Pul qiymatlari:

```text
fontWeight: 700
```

Dashboard:

```text
28–36sp
```

Card:

```text
20–24sp
```

List:

```text
16–18sp
```

Currency:

```text
12–14sp
```

Example:

```text
1 500 000 UZS
```

`1.5M` taqiqlanadi.

---

# 11. ICON SYSTEM

Iconlar:

```text
SVG / Icon font / Material Symbols
```

Bitta screen ichida turli icon style aralashtirilmaydi.

Sizes:

```text
16 — inline
20 — list
24 — standard
28 — prominent
32 — feature
40 — empty state
48 — hero
```

Icon-only action:

```text
minimum 44x44 touch area
```

Icon semantic labelga ega bo‘lishi kerak.

---

# 12. APP SCAFFOLD

`AppScaffold`

Mas’uliyati:

- SafeArea;
- background;
- keyboard behavior;
- page body;
- optional app bar;
- optional bottom navigation;
- optional FAB;
- optional bottom CTA.

API:

```text
title
body
actions
bottomNavigation
floatingActionButton
bottomBar
background
resizeToAvoidBottomInset
```

Feature widget `Scaffold`ni qayta yaratmasligi kerak.

---

# 13. APP BAR

## Standard

```text
←   Hamkorlar                 🔍
```

Height:

```text
56–64dp
```

## Large title

iOS-like:

```text
←

Hamkorlar
42 ta
```

Scroll bilan compact app barga transition.

## Rules

- 1 ta primary title;
- maximum 2–3 actions;
- icon-only actions semantic label bilan;
- destructive action AppBar ichida faqat zarur bo‘lsa.

---

# 14. BACK BUTTON

GoRouter bilan ishlaydi.

Behavior:

```text
pop()
```

Agar unsaved form:

```text
O‘zgarishlarni saqlamadingiz.

Chiqishni xohlaysizmi?
```

BottomSheet ichida esa:

```text
sheet dismiss
```

---

# 15. BOTTOM NAVIGATION BAR

5 tagacha item.

E-HISOB:

```text
Bosh sahifa
Hamkorlar
Loyihalar
Hisobotlar
Profil
```

## Active

- filled icon;
- label;
- primary color.

## Inactive

- outlined/neutral icon;
- secondary text.

## Badge

Notification:

```text
●
```

yoki:

```text
9+
```

## Rules

- 5 tadan ko‘p item yo‘q;
- permission bilan yashiriladi;
- hidden item o‘rniga disabled tab qoldirilmaydi;
- tab switch state preserving bo‘lishi kerak.

---

# 16. TAB BAR

TabBar faqat section ichidagi peer navigation uchun.

Misol:

```text
Tranzaksiyalar | Bo‘lib to‘lash | SMS
```

## Style

Default:

```text
Underline / indicator
```

Indicator:

```text
2–3dp
```

## Height

```text
48–52dp
```

## Rules

- 2–4 tab ideal;
- 5+ tab bo‘lsa horizontal scroll yoki segment/filter pattern;
- tab label qisqa;
- Russian translation overflow qilmasligi kerak;
- tab content lazy load qilinadi.

---

# 17. SEGMENTED CONTROL

Variantlar soni:

```text
2–4
```

Misollar:

```text
UZS | USD
```

```text
Kirim | Chiqim
```

```text
Oylik | 6 oy | Yillik
```

Segment:

```text
height: 44–48
radius: 12
```

Active segment:
- elevated/surface;
- primary text.

Segmented control dropdown o‘rnini bosadi.

---

# 18. CHIP

`AppChip`

Types:

```text
StatusChip
FilterChip
ChoiceChip
InfoChip
```

Height:

```text
32–36
```

Examples:

```text
Faol
Muddati o‘tgan
Bugun
Yopilgan
```

## Status

```text
✓ Faol
! Muddati o‘tgan
× Bekor qilingan
```

---

# 19. BADGE

Badge:
- notification;
- count;
- status;
- small indicator.

Examples:

```text
9+
Yangi
```

Count > 99:

```text
99+
```

---

# 20. CARD

`AppCard`

Default:

```text
background: surface
radius: 16
padding: 16
border: 1px
```

Shadow minimal.

## Card states

```text
default
pressed
selected
disabled
loading
error
```

Pressed:
- subtle surface transition;
- optional haptic.

---

# 21. CARD TYPES

```text
AppCard
KpiCard
BalanceCard
PartnerCard
TransactionCard
InstallmentCard
ProjectCard
WorkerCard
SubscriptionCard
PlanCard
NotificationCard
InfoCard
ActionCard
```

---

# 22. KPI CARD

Structure:

```text
Icon

Kirim
1 500 000 UZS

120 operatsiya
```

Clickable KPI:

```text
→ detail
```

## Rules

- number dominant;
- label secondary;
- optional trend;
- semantic color.

0 bo‘lsa report UX qoidalariga ko‘ra kerakli holatda empty state ishlatiladi, oddiy “0” bilan ekran to‘ldirilmaydi.

---

# 23. BALANCE CARD

```text
UZS

+1 500 000

Kirim       5 000 000
Chiqim      3 500 000
```

Balance:

```text
positive → green
negative → red
zero → neutral
```

USD alohida card yoki section.

---

# 24. PARTNER CARD

```text
┌────────────────────────────┐
│ [AT] Alibek Toshmatov   › │
│      +998 (90) 123-45-67   │
│                            │
│ Qarzdor                   │
│ −1 500 000 UZS            │
│                            │
│ Bo‘lib to‘lash  400 000   │
└────────────────────────────┘
```

Tap:

```text
Partner Detail
```

Long press / swipe:

```text
Edit
Delete
```

faqat permission bo‘lsa.

---

# 25. TRANSACTION CARD

```text
↓  Kirim
   Tovar uchun

+1 000 000 UZS
Bugun 10:15

Abdulloh
```

Expense:

```text
↑ Chiqim
−1 000 000 UZS
```

Cancelled:

```text
−1 000 000 UZS
Bekor qilingan
```

Strikethrough.

---

# 26. INSTALLMENT CARD

```text
Alibek Toshmatov

500 000 UZS

████████░░ 80%

To‘langan     400 000
Qolgan        100 000

Faol
```

Card:
- tap → detail;
- progress animated;
- status chip.

---

# 27. PROJECT CARD

```text
Chilonzor 12-uy

Aziz aka
+998 (90) 111-22-33

Toshkent, Chilonzor

[ Jarayonda ]
```

Optional footer:

```text
Balans: 12 500 000 UZS
```

---

# 28. SUBSCRIPTION CARD

```text
STANDARD

Faol

01.09.2026 — 01.10.2026

24 kun qoldi
████████░░

[ Tarifni boshqarish ]
```

Statusga qarab:

```text
ACTIVE → neutral/success
GRACE → warning
READ_ONLY → error
```

---

# 29. PLAN CARD

```text
PROFESSIONAL

54 000 UZS / oy

300 Hamkor
15 Loyiha
3 Xodim
200 SMS

−30%

[ Tanlash ]
```

Current:

```text
Joriy tarifingiz
```

Cannot subscribe:

```text
[ Tanlash ] disabled

Sabab:
...
```

---

# 30. LIST

Barcha listlar:

```text
ListView.builder
```

yoki:

```text
CustomScrollView
SliverList
```

Large screensda `ListView.separated`.

List item orasida:

```text
8–12dp
```

---

# 31. SECTION

`AppSection`

```text
Hamkorlar                         Barchasi ›

[content]
```

Header:
- title;
- optional subtitle;
- optional action.

Section spacing:

```text
24dp
```

---

# 32. LIST TILE

Structure:

```text
leading
title
subtitle
trailing
```

Minimum:

```text
56dp
```

Examples:

```text
👤  Alibek Toshmatov
    +998...

              ›
```

---

# 33. AVATAR

Sizes:

```text
32
40
48
56
72
```

Partner:

```text
48
```

Profile:

```text
72
```

Fallback:

```text
initials
```

Example:

```text
AT
```

Image loading:

```text
skeleton
```

Error:

```text
initials
```

---

# 34. DIVIDER

Faqat grouping uchun.

```text
height: 1
```

Card ichida divider bilan haddan tashqari bo‘linish qilinmasin.

---

# 35. TEXT FIELD

`AppTextField`

States:

```text
default
focused
filled
error
disabled
readOnly
```

Structure:

```text
Label
[ Input                         ]
helper/error
```

Label field ichida placeholderga almashtirilmaydi, agar Figma boshqacha ko‘rsatmasa.

---

# 36. TEXT FIELD RULES

- autofocus faqat birinchi logical field;
- error inline;
- password show/hide;
- clear icon faqat kerak bo‘lsa;
- keyboard type to‘g‘ri;
- text capitalization domainga mos;
- maxLength;
- counter faqat kerak bo‘lsa.

---

# 37. MONEY FIELD

`AppMoneyField`

Input:

```text
1 500 000
```

Suffix:

```text
UZS
```

Rules:

- thousands separator;
- cursor position smart;
- paste handling;
- minus faqat ruxsat etilgan fieldda;
- decimal faqat valyuta talabi bo‘lsa;
- backendga raw numeric value.

---

# 38. PHONE FIELD

Mask:

```text
+998 (__) ___-__-__
```

Example:

```text
+998 (93) 737-33-22
```

Backend:

```text
937373322
```

Country code locked.

---

# 39. SEARCH FIELD

`AppSearchField`

```text
⌕  Qidirish...
```

Debounce:

```text
400ms
```

Clear:

```text
×
```

Focus:
- keyboard opens;
- list updates;
- no unnecessary API request.

---

# 40. PASSWORD FIELD

Features:

```text
obscured
show/hide
```

Strength optional.

Rules:
- password never logged;
- paste allowed unless security requirement says otherwise;
- error below field.

---

# 41. MULTILINE FIELD

For:

```text
description
comment
reason
note
```

Minimum:

```text
96dp
```

Max height feature-specific.

---

# 42. FORM SECTION

Long form:

```text
Shaxsiy ma’lumotlar

[Ism]
[Telefon]

Moliyaviy ma’lumotlar

[Valyuta]
[Summa]
```

Section title:

```text
TitleMedium
```

Gap:

```text
24dp
```

---

# 43. FORM VALIDATION

Validation 3 bosqich:

```text
typing
focus lost
submit
```

Heavy validation:
- submitda.

Inline error:

```text
Telefon raqami noto‘g‘ri
```

Backend 422:
- exact fieldga map qilinadi.

---

# 44. PRIMARY BUTTON

`AppButton.primary`

```text
[ Saqlash ]
```

Height:

```text
52
```

States:

```text
enabled
pressed
loading
disabled
```

Loading:

```text
spinner + label yoki spinner
```

Double submit bloklanadi.

---

# 45. SECONDARY BUTTON

```text
[ Bekor qilish ]
```

Surface/border.

---

# 46. TEXT BUTTON

```text
Barchasi
```

Faqat secondary action.

Touch area 44dp.

---

# 47. DESTRUCTIVE BUTTON

```text
[ O‘chirish ]
```

Faqat destructive operation.

Confirmation talab qilinadi.

---

# 48. ICON BUTTON

Examples:

```text
search
filter
sort
more
edit
delete
share
download
refresh
```

Touch:

```text
44x44
```

Tooltip/semantic label.

---

# 49. FAB

Asosiy create action uchun.

```text
+
```

yoki:

```text
+ Hamkor
```

Faqat screen primary actioni aniq bo‘lsa.

Bottom Navigation bilan overlap bo‘lmasin.

---

# 50. STICKY BOTTOM CTA

Forms uchun asosiy pattern.

```text
────────────────────────
[ Saqlash ]
```

SafeArea bilan.

Keyboard ochilganda:
- CTA ko‘rinishi;
- input ustini yopmasligi.

---

# 51. BOTTOM SHEET SYSTEM

E-HISOBda dropdown ishlatilmaydi.

Barcha selection:

```text
BottomSheet
```

## Sheet types

```text
AppBottomSheet
SelectionSheet
SearchSelectionSheet
MultiSelectionSheet
FilterSheet
SortSheet
DateSheet
DateRangeSheet
ActionSheet
FormSheet
PaymentSheet
ConfirmationSheet
```

---

# 52. BOTTOM SHEET ANATOMY

```text
Drag Handle

Title
Optional subtitle

Search

Content

────────────────
Secondary CTA
Primary CTA
```

Top radius:

```text
28
```

Background:

```text
surface
```

SafeArea:

```text
true
```

---

# 53. SELECTION SHEET

Misol:

```text
Valyutani tanlang

🔍 Qidirish...

○ UZS
● USD
```

Selected:

```text
USD ✓
```

Tap item:
- immediate close for single select;
- multi-select uchun Apply.

---

# 54. SEARCH SELECTION SHEET

Worker / Partner / Project / Work Type.

```text
Ishchini tanlang

[ 🔍 Ishchini qidiring ]

Abdulloh
Akmal
Jamshid
```

API search:
- debounce 400ms;
- pagination.

---

# 55. MULTI-SELECTION SHEET

```text
Ishchilar

☐ Abdulloh
☑ Akmal
☐ Jamshid
```

Bottom sticky:

```text
2 ta tanlandi

[ Bekor qilish ] [ Tanlash ]
```

---

# 56. FILTER SHEET

Universal:

```text
Filtr

Holat
○ Barchasi
○ Faol
○ Muddati o‘tgan

Sana
[01.09.2026]
[17.09.2026]

Valyuta
[UZS | USD]

[Tozalash]
[Natijalarni ko‘rsatish]
```

Filter state Cubit/Blocda.

---

# 57. SORT SHEET

```text
Saralash

○ Oxirgi faollik
○ Qarzdor summa
○ Xaqdor summa
○ Sana
```

Single selection.

---

# 58. DATE SHEET

Presets:

```text
Bugun
Kecha
Hafta
Oy
```

Custom:

```text
Sana tanlash
```

---

# 59. DATE RANGE SHEET

```text
Davr

Boshlanish
07.09.2026

Tugash
17.09.2026

[Qo‘llash]
```

Calendar native-like.

---

# 60. ACTION SHEET

Item bosilganda:

```text
Amallar

Tahrirlash
Ulashish
Faylni ko‘rish
Bekor qilish
```

Destructive oxirida.

---

# 61. CONFIRMATION SHEET

Destructive action uchun.

```text
Tranzaksiyani bekor qilmoqchimisiz?

Bu amalni keyin qaytarib bo‘lmaydi.

[ Bekor qilish ]
[ Ha, bekor qilish ]
```

---

# 62. DIALOG

Dialog:
- destructive;
- critical;
- blocking;
- short confirmation.

Oddiy selection uchun dialog ishlatilmaydi.

Selection:

```text
BottomSheet
```

---

# 63. SNACKBAR

Success:

```text
✓ Saqlandi
```

Error:

```text
Amal bajarilmadi
[Qayta urinish]
```

Warning:

```text
Internet aloqasi yo‘q
```

Duration:

```text
2–4 sec
```

Action bo‘lsa duration biroz uzunroq.

---

# 64. TOAST

Toast faqat juda qisqa non-critical feedback.

Masalan:

```text
Nusxalandi
```

Critical/error uchun Snackbar.

---

# 65. BANNER

Subscription / offline / system state.

Example:

```text
⚠ Obunangiz 3 kundan keyin tugaydi
                         Yangilash
```

Types:

```text
InfoBanner
WarningBanner
ErrorBanner
SuccessBanner
OfflineBanner
SubscriptionBanner
```

---

# 66. SKELETON

Loading paytida:

```text
Card skeleton
Text skeleton
Avatar skeleton
Chart skeleton
```

Spinner butun screen uchun default loading sifatida ishlatilmaydi.

List:

```text
5–7 skeleton
```

---

# 67. PROGRESS BAR

Types:

```text
Linear
Circular
```

Subscription:

```text
42 / 100
██████░░░░
```

Colors:

```text
<80% → primary
80–99% → warning
100% → error
```

---

# 68. CIRCULAR PROGRESS

KPI/limit:

```text
72%
```

Label markazda.

Animation:
- 500–700ms;
- easeOut.

---

# 69. EMPTY STATE

Har bir list/report uchun.

Structure:

```text
[Illustration]

Ma’lumot topilmadi

Hozircha bu bo‘limda ma’lumot yo‘q.

[ Hamkor qo‘shish ]
```

Figma'da empty state bo‘lmasa shu standard.

0 sonini shunchaki ko‘rsatish o‘rniga meaningful empty state ishlatiladi.

---

# 70. ERROR STATE

```text
[Icon]

Ma’lumotni yuklab bo‘lmadi

Internetni tekshiring yoki qayta urinib ko‘ring.

[ Qayta urinish ]
```

5xx uchun generic message.

422 field error.

403 permission message.

---

# 71. FULL SCREEN BLOCKING STATE

ARCHIVED / force update / authentication blocking.

```text
[Illustration]

Ilovani davom ettirish uchun
yangilash talab qilinadi.

[ Yangilash ]
```

---

# 72. PULL TO REFRESH

Asosiy list va detail screenlarda.

```text
Pull
↓
Refresh
```

Refresh state:
- native indicator;
- content saqlanadi;
- full skeleton qayta ko‘rsatilmaydi.

---

# 73. INFINITE SCROLL

List oxiriga yaqin:

```text
3 item remaining
→ fetch next page
```

Footer skeleton.

Pagination error:

```text
Keyingi ma’lumotlarni yuklab bo‘lmadi
[Qayta urinish]
```

---

# 74. SWIPE ACTION

Partner / transaction kabi listlarda.

Example:

```text
← Tahrirlash
← O‘chirish
```

Delete:
- destructive;
- haptic;
- confirmation.

Swipe faqat secondary actions uchun.

---

# 75. REFRESH / RETRY

Retry component:

```text
[ Qayta urinish ]
```

Tap:
- current Bloc event qayta yuboriladi;
- duplicate request bloklanadi.

---

# 76. TOOLTIP

Faqat icon ma’nosi aniq bo‘lmaganda.

Desktop/tablet:
- hover.

Mobile:
- long press.

---

# 77. CONTEXT MENU

`More`:

```text
⋮
```

Mobileda:

```text
BottomSheet ActionSheet
```

Native PopupMenu faqat Figma aynan talab qilsa.

---

# 78. SWITCH

Boolean setting:

```text
SMS xizmati              ON
Bildirishnoma             OFF
```

States:
- on;
- off;
- disabled.

Switch o‘zgarganda optimistic UI mumkin.

---

# 79. CHECKBOX

Multi-selection:

```text
☑ Ishchi
```

Permission:

```text
☑ Ko‘rish
☐ Qo‘shish
```

Checkbox + label touch area birga.

---

# 80. RADIO

Single choice:

```text
● Teng
○ Erkin
```

BottomSheet ichida ko‘p ishlatiladi.

---

# 81. SLIDER

Faqat numeric range kerak bo‘lgan joylarda.

Masalan:

```text
SMS reminder:
1 ─────●──── 7 kun
```

Aniq sana uchun date picker ishlatiladi.

---

# 82. DATE PICKER

Native calendar style.

Requirements:
- locale-aware;
- uz/ru;
- minimum date;
- maximum date;
- disabled dates;
- current date highlight.

---

# 83. TIME PICKER

SMS yuborish vaqti:

```text
10:00
```

Native-like time picker.

---

# 84. FILE PICKER

BottomSheet:

```text
Fayl qo‘shish

📷 Kamera
🖼 Galereya
📄 Fayl
```

Preview:

```text
file.pdf
1.2 MB
✓
```

Upload:

```text
██████░░░░ 60%
```

---

# 85. IMAGE PREVIEW

Tap image:

```text
Full screen viewer
```

Actions:

```text
Share
Delete
```

---

# 86. LINK / URL

External URL:
- launch confirmation only zarur bo‘lsa;
- browser/custom tab;
- app state saqlanadi.

Payment URL external app/browserga chiqishi mumkin.

---

# 87. AVATAR PICKER

```text
[Avatar]
```

Tap:

```text
Rasmni o‘zgartirish

Kamera
Galereya
O‘chirish
```

---

# 88. PROGRESS STEPPER

Installment wizard:

```text
1   2   3
●───○───○
```

Labels:

```text
Asosiy
Grafik
Tasdiqlash
```

Completed:

```text
✓
```

Back allowed.

---

# 89. WIZARD FOOTER

```text
[Orqaga]                 [Davom etish]
```

Step 3:

```text
[Orqaga]                 [Yaratish]
```

Validation current stepdan o‘tmasdan keyingi stepga ruxsat bermaydi.

---

# 90. TIMELINE

Activity log:

```text
●  Abdulloh tranzaksiyani bekor qildi
│  12.09.2026 14:30
│
●  Sarvar hamkor qo‘shdi
   12.09.2026 13:10
```

Node:
- icon;
- semantic color.

---

# 91. TRANSACTION GROUP

Date grouping:

```text
BUGUN

transaction
transaction

KECHA

transaction
```

Header sticky bo‘lishi mumkin.

---

# 92. STATUS TIMELINE

Installment:

```text
✓ To‘langan
│
● Kutilmoqda
│
○ Kutilmoqda
```

Overdue:

```text
! Muddati o‘tgan
```

---

# 93. TABLE / DATA LIST

Mobileda klassik desktop table default emas.

Preferred:

```text
Card/List
```

Agar column comparison zarur bo‘lsa:

```text
horizontal scroll
```

Column header sticky.

Reports uchun table faqat data density talab qilsa.

---

# 94. CHART CONTAINER

Chart har doim:

```text
AppCard
```

ichida.

Structure:

```text
Kirim / Chiqim
Oxirgi 3 oy

[ chart ]

Legend
```

---

# 95. BAR CHART

Partner report:

```text
3 oy
Kirim / Chiqim
```

Interaction:
- tap bar;
- tooltip;
- accessibility summary.

No-data:
- empty chart state;
- axes break qilinmaydi.

---

# 96. LINE CHART

Balance dynamics:

```text
7 kun
```

Tap point:

```text
12.09
1 500 000 UZS
```

---

# 97. PIE / DONUT CHART

Project costs:

```text
Xarajatlar

Transport 30%
Material 50%
Ishchi 20%
```

Legend:
- icon/color;
- label;
- amount;
- percentage.

Color-only meaning emas.

---

# 98. CHART TOOLTIP

Tooltip:

```text
12 sentabr

Kirim
1 200 000 UZS

Chiqim
500 000 UZS
```

Touch friendly.

---

# 99. CHART EMPTY

```text
Bu davr uchun grafik ma’lumoti mavjud emas.
```

Chart container balandligi saqlanadi.

---

# 100. CURRENCY SWITCHER

Universal:

```text
UZS | USD
```

Reports:
- session davomida state saqlanadi;
- barcha KPI va chartlar currencyga mos yangilanadi.

---

# 101. PERIOD SWITCHER

Universal:

```text
Bugun | Hafta | Oy | Ixtiyoriy
```

Custom tanlansa:

```text
07.09.2026 — 17.09.2026
```

---

# 102. SEARCH + FILTER HEADER

```text
[ 🔍 Qidirish... ]

[ Filtr ] [ Saralash ]
```

Filter active:

```text
Filtr • 3
```

---

# 103. FILTER COUNT BADGE

```text
Filtr ③
```

Clear:

```text
Barchasini tozalash
```

---

# 104. LOADING BUTTON

Submit:

```text
[ ⟳ Saqlanmoqda... ]
```

Button disabled.

Double tap:
- second request yuborilmaydi.

---

# 105. SUCCESS OVERLAY

Critical create operationdan keyin:

```text
✓

Muvaffaqiyatli saqlandi
```

Auto dismiss yoki CTA.

Oddiy CRUD uchun full-screen success shart emas; Snackbar yetarli.

---

# 106. CONFIRMATION PATTERNS

## Minor

Snackbar.

## Important

BottomSheet.

## Destructive

ConfirmationSheet.

## Blocking

Dialog/full screen.

---

# 107. OFFLINE BANNER

```text
Offline

Oxirgi saqlangan ma’lumotlar ko‘rsatilmoqda.
```

Write action:

```text
Internet aloqasi yo‘q
```

Offline queue qilinmaydi.

---

# 108. NETWORK ERROR COMPONENT

```text
Internet aloqasi yo‘q

[ Qayta urinish ]
```

Backend 5xx:

```text
Serverda xatolik yuz berdi.

[ Qayta urinish ]
```

---

# 109. PERMISSION-BASED COMPONENT

Generic:

```text
PermissionBuilder
```

Rules:

```text
view yo‘q → component hidden
create yo‘q → CTA hidden
edit yo‘q → edit action hidden
delete yo‘q → delete action hidden
```

Permission uchun disabled button default qilinmaydi.

---

# 110. SUBSCRIPTION-BASED COMPONENT

```text
SubscriptionGuard
```

READ_ONLY:

```text
Mutation buttons hidden/blocked
```

GRACE:

```text
WarningBanner
```

ARCHIVED:

```text
BlockingScreen
```

---

# 111. ROLE CONTEXT HEADER

Staff:

```text
Sarvar hisobida ishlayapsiz

[Almashtirish]
```

Tap:

```text
AccountSelectionSheet
```

---

# 112. ACCOUNT SWITCH SHEET

```text
Hisobni tanlang

● O‘z hisobim
○ Sarvar
○ Abdulloh
```

Switch:
- current feature state clear;
- business cache invalidate;
- dashboard reload.

---

# 113. NOTIFICATION BADGE

Header:

```text
🔔 3
```

Unread:
- badge;
- bold card.

Tap:
```text
Notifications
```

---

# 114. DATE GROUP HEADER

```text
BUGUN
```

Russian:

```text
СЕГОДНЯ
```

Localization orqali.

---

# 115. MONEY DISPLAY COMPONENT

```text
MoneyText(
  amount: 1500000,
  currency: UZS
)
```

Output:

```text
1 500 000 UZS
```

Sign:

```text
+1 500 000 UZS
−1 500 000 UZS
```

Negative sign uchun Unicode minus:

```text
−
```

---

# 116. PHONE DISPLAY COMPONENT

```text
PhoneText(...)
```

Output:

```text
+998 (93) 737-33-22
```

---

# 117. DATE DISPLAY COMPONENT

```text
DateText(...)
```

Output:

```text
17.09.2026
```

DateTime:

```text
17.09.2026 14:30
```

---

# 118. NUMBER FIELD

Integer:

```text
10
```

Quantity:

```text
[-] 4 [+]
```

Increment:
- haptic;
- max/min;
- disabled boundary.

---

# 119. QUANTITY STEPPER

Installment parts:

```text
−    4    +
```

Minimum:

```text
2
```

Maximum backend/business rulega bog‘liq.

---

# 120. INLINE ACTION

Card ichida:

```text
Barchasi ›
```

yoki:

```text
Tafsilotlar ›
```

Touch area 44dp.

---

# 121. DIVIDERLESS CARD

Native-like UI uchun card ichida har bir row orasiga divider qo‘yish shart emas.

Preferred:

```text
vertical spacing
```

Divider faqat semantic separation kerak bo‘lsa.

---

# 122. PRESS FEEDBACK

Har bir tappable component:

```text
pressed state
```

Duration:

```text
100–150ms
```

Optional:

```text
HapticFeedback.selectionClick()
```

---

# 123. RIPPLE

Material interaction:

- subtle;
- dark/light themega mos;
- radius cardga mos.

Custom animation Figma talab qilmasa haddan tashqari kuchli bo‘lmasin.

---

# 124. ANIMATION TOKENS

```text
instant     0ms
fast        150ms
normal      250ms
medium      300ms
slow        500ms
```

Page transition:

```text
250–300ms
```

Theme transition:

```text
300–400ms
```

Progress:

```text
500–700ms
```

---

# 125. PAGE TRANSITION

GoRouter.

Default:
- platform-aware transition;
- iOS → Cupertino-like;
- Android → Material-like.

Modal:
- bottom sheet.

Full-screen:
- route push.

---

# 126. KEYBOARD SAFE COMPONENTS

Form components:

```text
KeyboardAwareScrollView
```

Rules:
- focused field visible;
- bottom CTA keyboard bilan collision qilmasligi;
- safe area;
- no overflow.

---

# 127. RESPONSIVE COMPONENT RULES

Backend TZ 320dp–1024dp oralig‘ini talab qiladi.

## 320–359

- 16 padding;
- compact typography;
- horizontal content overflow yo‘q.

## 360–599

- standard mobile.

## 600–1024

- centered content;
- max width;
- optional 2-column layout;
- larger spacing.

---

# 128. SCREENUTIL

Design base:

```text
360 x 800
```

Use:

```dart
16.w
12.h
16.sp
```

Fixed semantic values:

```text
touch target
border
1px
```

uchun ScreenUtilni majburan ishlatish shart emas.

---

# 129. DARK MODE COMPONENT RULES

Dark mode:
- pure black default emas;
- surface hierarchy saqlanadi;
- borders subtle;
- success/error text contrastli;
- shadows kamayadi;
- image/icon contrast tekshiriladi.

---

# 130. THEME COMPONENT API

Components colorni hardcode qilmaydi.

Wrong:

```dart
color: Colors.green
```

Preferred:

```dart
color: context.colorScheme.success
```

yoki:

```dart
AppColors.success(context)
```

---

# 131. LOCALIZATION COMPONENT RULES

Component ichida:

```text
"Saqlash"
```

hardcode qilinmaydi.

Preferred:

```text
context.l10n.save
```

Long Russian text:
- overflow;
- button width;
- chip width;
- tab width

test qilinadi.

---

# 132. ACCESSIBILITY COMPONENT RULES

Har bir interactive component:

```text
semantic label
```

Icon-only:

```text
Tooltip
Semantics
```

Charts:
- visual;
- textual summary.

Touch target:

```text
≥44dp
```

---

# 133. SKELETON COMPONENTS

```text
SkeletonBox
SkeletonText
SkeletonAvatar
SkeletonCard
SkeletonListTile
SkeletonKpi
SkeletonChart
```

Shimmer:
- subtle;
- dark/light compatible.

---

# 134. EMPTY COMPONENTS

```text
EmptyState
EmptyPartners
EmptyTransactions
EmptyInstallments
EmptyProjects
EmptyReports
EmptyNotifications
```

Generic `EmptyState` configurable bo‘ladi.

---

# 135. ERROR COMPONENTS

```text
ErrorState
NetworkErrorState
ServerErrorState
PermissionDeniedState
SubscriptionBlockedState
```

---

# 136. FORM BOTTOM ACTION COMPONENT

```text
AppFormBottomBar
```

Variants:

```text
single CTA
secondary + primary
destructive + cancel
```

---

# 137. MODAL COMPONENTS

```text
AppDialog
AppConfirmationDialog
AppBottomSheet
AppActionSheet
```

Selection:
- BottomSheet.

Critical:
- Dialog.

---

# 138. MODAL DISMISS RULES

Normal sheet:
- drag down;
- outside tap.

Form sheet:
- outside tap confirmation if dirty.

Payment sheet:
- outside tap may be disabled while processing.

Blocking:
- cannot dismiss.

---

# 139. FORM DIRTY STATE

Cubit:

```text
isDirty
```

Back:

```text
if isDirty:
  show confirmation
else:
  pop
```

---

# 140. ERROR INLINE

API:

```json
{
  "phone": [
    "Telefon raqami noto‘g‘ri"
  ]
}
```

UI:

```text
Telefon
[+998 ...]
Telefon raqami noto‘g‘ri
```

---

# 141. SUCCESS FEEDBACK MATRIX

| Action | Feedback |
|---|---|
| Save form | Snackbar |
| Create partner | Snackbar + navigate/detail |
| Wallet create | Snackbar + refresh |
| Installment create | Success + detail |
| Payment | Success screen/Snackbar |
| Copy | Toast/Snackbar |
| Delete | Snackbar |
| Theme change | immediate animated |
| Language | immediate reload |

---

# 142. ERROR FEEDBACK MATRIX

| Error | UI |
|---|---|
| 401 | Logout |
| 403 | Snackbar/denied |
| 422 | Inline |
| 429 | Snackbar |
| 5xx | Error state |
| No internet | Offline state |
| Timeout | Retry |
| Payment failed | Payment error |
| File upload failed | File row error |

---

# 143. LIST COMPONENT ARCHITECTURE

```text
AppPagedList<T>
 ├── Loading
 ├── Success
 │    ├── items
 │    └── pagination
 ├── Empty
 └── Error
```

Feature:
- Bloc event;
- repository;
- UI renders state.

---

# 144. CARD INTERACTION CONTRACT

Card:
```text
onTap
```

Optional:
```text
onLongPress
```

Optional:
```text
swipe actions
```

Business action Card ichida to‘g‘ridan-to‘g‘ri API chaqirmaydi.

---

# 145. COMPONENT STATE CONTRACT

Har bir interactive component:

```text
enabled
disabled
loading
error
selected
pressed
focused
```

Figma'da barcha state ko‘rsatilmasa ham implementation uchun shu state matrix saqlanadi.

---

# 146. COMPONENT DOCUMENTATION

Har bir reusable component uchun:

```text
Purpose
Anatomy
Variants
States
Sizes
Colors
Spacing
Interaction
Accessibility
Localization
Usage
Do / Don't
```

---

# 147. COMPONENT STORY / CATALOG

Development davomida barcha komponentalar uchun internal component gallery yaratiladi:

```text
/components_gallery
```

Sections:

```text
Buttons
Inputs
Cards
Navigation
Sheets
Dialogs
Feedback
Loading
Charts
Business
```

Har bir component:
- light;
- dark;
- uz;
- ru;
- disabled;
- error;
- loading

holatda ko‘rsatiladi.

---

# 148. DO / DON'T — BUTTON

DO:

```text
[ Saqlash ]
```

DON'T:

```text
[       ]
```

label yo‘q.

DON'T:
- bir screen'da 4 ta primary CTA;
- tiny button;
- permission yo‘q bo‘lsa disabled primary.

---

# 149. DO / DON'T — CARD

DO:

```text
clear hierarchy
title
value
metadata
action
```

DON'T:

```text
card ichida card ichida card
```

3+ nestingdan qochish.

---

# 150. DO / DON'T — TAB

DO:

```text
Tranzaksiyalar | Bo‘lib to‘lash | SMS
```

DON'T:
- 7–8 tabni bitta qatorda tiqish;
- long sentence label;
- tabni action menu sifatida ishlatish.

---

# 151. DO / DON'T — BOTTOM SHEET

DO:
- selection;
- filters;
- quick forms;
- actions.

DON'T:
- katta murakkab nested modal;
- sheet ichida sheetni haddan tashqari ko‘paytirish;
- dropdownni BottomSheet nomi bilan yashirib, desktop UXni ko‘chirish.

---

# 152. DO / DON'T — INPUT

DO:
```text
Label
Input
Error/helper
```

DON'T:
- faqat placeholder bilan labelni almashtirish;
- errorni Snackbar'da yashirish;
- backend errorni ko‘rsatmaslik.

---

# 153. DO / DON'T — COLOR

DO:

```text
negative → semantic error
positive → semantic success
```

DON'T:
- random green/red;
- dark mode uchun alohida random palette;
- statusni faqat rang bilan ko‘rsatish.

---

# 154. DO / DON'T — LOADING

DO:

```text
Skeleton
```

DON'T:

```text
white screen
center spinner
```

butun contentni yo‘qotish.

---

# 155. DO / DON'T — EMPTY

DO:

```text
Illustration
Meaningful message
CTA
```

DON'T:

```text
0
```

deb bo‘sh screen qoldirish.

---

# 156. DO / DON'T — ERROR

DO:

```text
what happened
what to do
retry
```

DON'T:

```text
Exception: DioException...
```

userga chiqarish.

---

# 157. BUSINESS COMPONENT — PARTNER HEADER

```text
[Avatar]

Alibek Toshmatov
+998 (90) 123-45-67

[Call] [SMS]
```

Call:
- `tel:`.

SMS:
- app SMS feature yoki system depending business flow.

---

# 158. BUSINESS COMPONENT — BALANCE SUMMARY

```text
UZS

+1 500 000
Balans

Kirim  5 000 000
Chiqim 3 500 000
```

USD alohida.

---

# 159. BUSINESS COMPONENT — DUE DATE CARD

```text
Muddati o‘tgan

Alibek
600 000 UZS

01.09.2026
6 kun kechikdi

[ Kirim ]
```

---

# 160. BUSINESS COMPONENT — INSTALLMENT PROGRESS

```text
500 000 UZS

████████░░

80%

400 000 to‘langan
100 000 qolgan
```

---

# 161. BUSINESS COMPONENT — PAYMENT ITEM

```text
+100 000 UZS

15.10.2026 12:00
Naqd

Abdulloh qabul qildi
```

Cancelled:

```text
Bekor qilingan
```

---

# 162. BUSINESS COMPONENT — PROJECT STATUS

```text
● Jarayonda
● Muzlatilgan
● Tugallangan
```

Status chip.

---

# 163. BUSINESS COMPONENT — SUBSCRIPTION USAGE

```text
Hamkorlar
42 / 100

████░░░░░░
```

Variants:

```text
normal
warning
critical
unlimited
```

Unlimited:

```text
Cheksiz
```

Backend `-1` qiymatini UI'da “Cheksiz” deb ko‘rsatadi.

---

# 164. BUSINESS COMPONENT — PERMISSION GROUP

```text
Hamkorlar

☑ Ko‘rish
☑ Qo‘shish
☐ Tahrirlash
☐ O‘chirish

[Barchasini tanlash]
```

---

# 165. BUSINESS COMPONENT — NOTIFICATION ITEM

```text
● Yangi obuna sotib olindi

Batafsil ma’lumot...
Bugun 12:30
```

Unread:
- bold;
- dot.

---

# 166. BUSINESS COMPONENT — ACTIVITY ITEM

```text
● Abdulloh tranzaksiyani bekor qildi

Wallet
12.09.2026 14:30
```

---

# 167. BUSINESS COMPONENT — FILE ITEM

```text
📄 contract.pdf

1.2 MB
✓ Yuklandi

⋮
```

ActionSheet:
- open;
- share;
- delete.

---

# 168. BUSINESS COMPONENT — SEARCHABLE ENTITY SELECTOR

Generic:

```text
EntitySelectionSheet<T>
```

Supports:

```text
Partner
Project
Worker
Currency
WorkType
CostType
```

No dropdown.

---

# 169. BUSINESS COMPONENT — CURRENCY SELECTOR

```text
UZS
USD
```

2 option bo‘lsa:

```text
SegmentedControl
```

Agar context ko‘proq bo‘lsa:

```text
SelectionSheet
```

---

# 170. BUSINESS COMPONENT — PERIOD SELECTOR

```text
Bugun
Hafta
Oy
Ixtiyoriy
```

Segmented control yoki horizontal chips.

---

# 171. BUSINESS COMPONENT — REPORT KPI

```text
Kirim
15 000 000 UZS
```

Tap:
```text
→ details
```

---

# 172. BUSINESS COMPONENT — REPORT CHART CARD

```text
Kirim / Chiqim

[Bar Chart]

Yan  Fev  Mar
```

Chart container fixed minimum height.

---

# 173. BUSINESS COMPONENT — RISK CHIP

Installment reports:

```text
Risk: Yuqori
```

Color + icon + text.

Risk level qiymati backenddan keladi.

Frontend o‘zi risk score hisoblab, yangi label yaratmaydi.

---

# 174. BUSINESS COMPONENT — RECOVERY CARD

```text
Undirish samaradorligi

82%

Qaytarilgan
1 200 000

Muddati o‘tgan
250 000
```

Rating label backenddan.

---

# 175. BUSINESS COMPONENT — SUBSCRIPTION STATUS BANNER

ACTIVE:
- hidden yoki subtle.

GRACE:

```text
⚠ 7 kunlik imtiyozli davr
Obunani yangilang
```

READ_ONLY:

```text
🔒 Faqat ko‘rish rejimi
```

ARCHIVED:

```text
🔒 Obuna talab qilinadi
```

---

# 176. COMPONENT COMPOSITION RULE

Complex screen:

```text
Screen
 ├── AppScaffold
 ├── AppBar
 ├── FilterHeader
 ├── AppSection
 │    └── BusinessCard
 ├── AppSection
 │    └── AppList
 └── StickyCTA
```

Monolithic widget:

```text
1000+ line Widget
```

qilmaslik.

---

# 177. WIDGET SIZE RULE

Ideal:

```text
50–200 lines
```

Complex component:
- split into subcomponents.

Screen:
- composition only;
- business logic Blocda.

---

# 178. BLOC INTEGRATION

UI:

```text
BlocBuilder
BlocListener
BlocConsumer
```

Event:

```text
context.read<PartnersBloc>().add(
  PartnersRequested()
);
```

Widget:
- repositoryga to‘g‘ridan-to‘g‘ri murojaat qilmaydi.

---

# 179. COMPONENT TESTING

Har bir reusable component uchun:

```text
default
disabled
loading
error
dark
light
uz
ru
long text
small width
```

test qilinadi.

Critical business components:

```text
Money
Phone
PartnerCard
TransactionCard
InstallmentCard
PaymentSheet
SubscriptionCard
```

widget testga ega bo‘lishi kerak.

---

# 180. GOLDEN TEST

Design System uchun golden test:

```text
AppButton
AppCard
AppTextField
AppBottomSheet
AppTabBar
AppStatusChip
AppKpiCard
```

Light/Dark uchun.

Golden test Figma bilan visual regressionni ushlash uchun ishlatiladi.

---

# 181. PERFORMANCE

Avoid:
- unnecessary rebuild;
- huge images;
- nested ListView;
- expensive chart rebuild;
- animation everywhere.

Use:

```text
const widgets
BlocSelector
buildWhen
select
cached images
lazy lists
```

---

# 182. REBUILD RULE

State o‘zgarganda butun screen emas, faqat kerakli component rebuild qilinadi.

Example:

```text
Subscription usage update
→ UsageProgressCard rebuild
```

butun Profile rebuild qilinmaydi.

---

# 183. IMAGE RULES

Network images:

```text
cached
placeholder
error fallback
```

Max display size:
- server image dimensionsga mos;
- unnecessary full-resolution image decode qilinmaydi.

---

# 184. SCROLL RULES

Nested scroll faqat zarur bo‘lsa.

Preferred:

```text
CustomScrollView
SliverAppBar
SliverList
```

Tab screenlarda:

```text
NestedScrollView
```

faqat sticky TabBar kerak bo‘lsa.

---

# 185. TAB + SCROLL

Partner detail:

```text
SliverAppBar

TabBar
────────────
Tranzaksiyalar
```

Tab content:
- independent scroll;
- preserve state;
- preserve scroll position.

---

# 186. BOTTOM SHEET + KEYBOARD

Form Sheet:
- `isScrollControlled: true`;
- max 90%;
- keyboard inset;
- draggable only when content allows;
- CTA sticky.

---

# 187. MODAL Z-INDEX

Priority:

```text
Snackbar
↓
BottomSheet
↓
Dialog
↓
Blocking Dialog
```

Multiple modal stackingdan qochish.

---

# 188. HAPTIC RULES

Haptic:

```text
selection
success
destructive
toggle
```

Har bir tapga haptic qo‘yish taqiqlanadi.

---

# 189. NATIVE PLATFORM DIFFERENCES

## iOS

- swipe back;
- Cupertino-feel where appropriate;
- keyboard;
- Face ID;
- date/time picker.

## Android

- system back;
- Material;
- fingerprint;
- notification behavior.

Design system umumiy bo‘lsa ham interaction platformga moslashadi.

---

# 190. COMPONENT ACCEPTANCE CHECKLIST

## Visual

- [ ] Figma bilan mos.
- [ ] Light.
- [ ] Dark.
- [ ] 320dp.
- [ ] 360dp.
- [ ] 600dp.
- [ ] 1024dp.
- [ ] Uzbek.
- [ ] Russian.

## Interaction

- [ ] Tap.
- [ ] Pressed.
- [ ] Disabled.
- [ ] Loading.
- [ ] Error.
- [ ] Keyboard.
- [ ] Accessibility.
- [ ] Haptic where needed.

## Engineering

- [ ] Reusable.
- [ ] Theme tokens.
- [ ] Localization.
- [ ] No hardcoded color.
- [ ] No hardcoded text.
- [ ] No direct API call.
- [ ] Unit/widget test where applicable.

---

# 191. SCREEN-LEVEL COMPONENT COMPOSITION EXAMPLE

## Dashboard

```text
AppScaffold
 ├── AppBar
 │    ├── Greeting
 │    └── NotificationButton
 │
 ├── SubscriptionBanner
 │
 ├── Section
 │    └── BalanceCard
 │
 ├── Section
 │    └── KPI Cards
 │
 ├── Section
 │    └── DueDateCard
 │
 ├── Section
 │    └── InstallmentCard
 │
 └── QuickActionBar
```

---

# 192. PARTNER LIST COMPOSITION

```text
AppScaffold
 ├── AppBar
 ├── SearchField
 ├── Filter/Sort Header
 └── AppPagedList
      └── PartnerCard
```

---

# 193. PARTNER DETAIL COMPOSITION

```text
AppScaffold
 ├── Large AppBar
 ├── PartnerHeader
 ├── BalanceCard
 ├── QuickActions
 ├── AppTabBar
 │    ├── Transactions
 │    ├── Installments
 │    └── SMS
 └── Tab Content
```

---

# 194. CREATE WALLET COMPOSITION

```text
AppScaffold
 ├── AppBar
 ├── SegmentedControl
 │    ├── Kirim
 │    └── Chiqim
 ├── CurrencySelector
 ├── MoneyField
 ├── DescriptionField
 ├── DateSelector
 ├── FileAttachment
 └── FormBottomBar
```

---

# 195. INSTALLMENT WIZARD COMPOSITION

```text
AppScaffold
 ├── AppBar
 ├── Stepper
 ├── StepContent
 └── WizardFooter
```

---

# 196. REPORT COMPOSITION

```text
AppScaffold
 ├── AppBar
 ├── CurrencySwitcher
 ├── PeriodSelector
 ├── KPI Cards
 ├── ChartCard
 └── AppPagedList
```

---

# 197. PROFILE COMPOSITION

```text
AppScaffold
 ├── ProfileHeader
 ├── SubscriptionCard
 ├── SettingsSection
 │    └── ListTile
 ├── ManagementSection
 │    └── ListTile
 └── DangerSection
      ├── Logout
      └── Delete account
```

---

# 198. COMPONENT FOLDER STRUCTURE

```text
lib/core/widgets/
│
├── app_bar/
├── buttons/
├── cards/
├── charts/
├── chips/
├── dialogs/
├── feedback/
├── forms/
├── inputs/
├── lists/
├── loading/
├── navigation/
├── sheets/
├── selectors/
├── states/
├── typography/
└── media/
```

Business:

```text
lib/features/*/presentation/widgets/
```

---

# 199. DESIGN TOKEN FILE STRUCTURE

```text
core/theme/
├── app_theme.dart
├── app_colors.dart
├── app_typography.dart
├── app_spacing.dart
├── app_radius.dart
├── app_elevation.dart
├── app_duration.dart
├── app_breakpoints.dart
└── app_component_theme.dart
```

---

# 200. FINAL COMPONENT RULES

1. Dropdown ishlatilmaydi.
2. Selection uchun BottomSheet.
3. 2–4 variant uchun SegmentedControl.
4. TabBar peer content navigation uchun.
5. BottomNavigation global module navigation uchun.
6. Cardlar yagona design tokenlardan foydalanadi.
7. Buttonlar yagona variantlarga ega.
8. Inputlar yagona validation patterniga ega.
9. Money va Phone formatterlar central bo‘ladi.
10. Theme values hardcode qilinmaydi.
11. Textlar localizationdan olinadi.
12. Light va Dark har bir componentda test qilinadi.
13. Loadingda skeleton ishlatiladi.
14. Empty state har bir list/reportda mavjud.
15. Error state retry bilan bo‘ladi.
16. Permission bo‘lmasa action yashiriladi.
17. Subscription status UI behaviorni o‘zgartiradi.
18. Touch target minimum 44dp.
19. Native platform navigation saqlanadi.
20. Haptic faqat meaningful interactionda.
21. Animation subtle va consistent.
22. Responsive 320–1024dp.
23. Russian uzun textlari alohida test qilinadi.
24. Complex widgetlar kichik reusable widgetlarga bo‘linadi.
25. API/business logic UI componentga joylashtirilmaydi.
26. Critical componentlar widget/golden test bilan himoyalanadi.
27. Figma source of truth; ushbu TZ Figma'da mavjud bo‘lmagan component states uchun implementation standardidir.
28. Har bir feature screen Design System komponentalaridan compose qilinadi.
29. Web-style UI emas, native-quality mobile UX asosiy sifat mezonidir.
30. Component library production kod bilan birga rivojlantiriladi.

---

# 201. DEFINITION OF DONE — UI COMPONENT

Component “Done” bo‘lishi uchun:

```text
[ ] Figma implementation
[ ] Light
[ ] Dark
[ ] UZ
[ ] RU
[ ] Responsive
[ ] Default
[ ] Pressed
[ ] Disabled
[ ] Loading
[ ] Error
[ ] Empty where applicable
[ ] Accessibility
[ ] Haptic where applicable
[ ] Keyboard safe where applicable
[ ] Theme tokens
[ ] Localization
[ ] Reusable API
[ ] Widget test
[ ] Golden test for critical visual components
[ ] No hardcoded business logic
[ ] No direct network access
[ ] flutter analyze clean
```

---

# 202. FINAL QUALITY BAR

Developer quyidagi holatda komponentni “tayyor” deb hisoblamaydi:

```text
Desktop web componentni Flutterga ko‘chirdim
```

emas.

Balki:

```text
Figma
  ↓
Design Token
  ↓
Reusable Component
  ↓
Theme
  ↓
Localization
  ↓
Responsive
  ↓
Interaction
  ↓
Loading/Error/Empty
  ↓
Accessibility
  ↓
Tests
  ↓
Production
```

bo‘lishi kerak.

E-HISOB UI tizimining maqsadi — **bir xil ko‘rinadigan ekranlar emas, bir xil qoidalar asosida ishlaydigan native-quality component ecosystem** yaratish.
