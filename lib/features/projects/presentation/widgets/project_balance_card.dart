import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../data/project_models.dart';

class ProjectBalanceCard extends StatefulWidget {
  const ProjectBalanceCard({super.key, required this.account});

  final ProjectAccounts account;

  @override
  State<ProjectBalanceCard> createState() => _ProjectBalanceCardState();
}

class _ProjectBalanceCardState extends State<ProjectBalanceCard> {
  late String _selectedCurrency;
  int _slideDirection = 1;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = 'UZS';
  }

  bool get _hasUsd {
    final usd = widget.account.usd;
    return usd.income != Decimal.zero ||
        usd.cost != Decimal.zero ||
        usd.balance != Decimal.zero;
  }

  void _selectCurrency(String currency) {
    if (_selectedCurrency == currency) return;
    HapticFeedback.selectionClick();
    setState(() {
      _slideDirection = currency == 'USD' ? 1 : -1;
      _selectedCurrency = currency;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasUsd = _hasUsd;
    final activeCurrency = hasUsd ? _selectedCurrency : 'UZS';
    final activeAccount = activeCurrency == 'UZS'
        ? widget.account.uzs
        : widget.account.usd;
    final tint = activeCurrency == 'UZS' ? colors.primary : colors.accentViolet;

    return GestureDetector(
      onHorizontalDragEnd: hasUsd
          ? (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -150 && _selectedCurrency == 'UZS') {
                _selectCurrency('USD');
              } else if (velocity > 150 && _selectedCurrency == 'USD') {
                _selectCurrency('UZS');
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: tint.withValues(alpha: 0.22), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: tint.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ikkala valyuta ham mavjud bo'lsa, ixcham zamonaviy sliding segmented tab
            if (hasUsd) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final tabWidth = (constraints.maxWidth - 6) / 2;
                  final isUzs = _selectedCurrency == 'UZS';

                  return Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.4),
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Stack(
                      children: [
                        // Silliq siljuvchi oq pill (Sliding selection indicator)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.fastOutSlowIn,
                          left: isUzs ? 0 : tabWidth,
                          top: 0,
                          bottom: 0,
                          width: tabWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? colors.surface : Colors.white,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.25 : 0.08,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tab tugmalari
                        Row(
                          children: [
                            _buildSegmentTab(
                              context: context,
                              label: 'UZS',
                              balance: widget.account.uzs.balance,
                              isSelected: isUzs,
                              tint: colors.primary,
                              onTap: () => _selectCurrency('UZS'),
                            ),
                            _buildSegmentTab(
                              context: context,
                              label: 'USD',
                              balance: widget.account.usd.balance,
                              isSelected: !isUzs,
                              tint: colors.accentViolet,
                              onTap: () => _selectCurrency('USD'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],

            // Aktiv valyutadagi ma'lumotlar (yo'naltirilgan silliq slide va fade animatsiya bilan)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.fastOutSlowIn,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder:
                      (Widget? currentChild, List<Widget> previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                  transitionBuilder: (child, animation) {
                    final isIncoming =
                        child.key == ValueKey<String>(activeCurrency);
                    final inOffset = Tween<Offset>(
                      begin: Offset(_slideDirection * 0.25, 0),
                      end: Offset.zero,
                    ).animate(animation);

                    final outOffset = Tween<Offset>(
                      begin: Offset(-_slideDirection * 0.25, 0),
                      end: Offset.zero,
                    ).animate(animation);

                    return SlideTransition(
                      position: isIncoming ? inOffset : outOffset,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _buildAccountDetails(
                    key: ValueKey<String>(activeCurrency),
                    context: context,
                    account: activeAccount,
                    currency: activeCurrency,
                    tint: tint,
                    showSingleBadge: !hasUsd,
                  ),
                ),
              ),
            ),

            // Silliq nuqta indikatori (faqat ikkala valyuta mavjud bo'lganda)
            if (hasUsd) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(
                    isSelected: _selectedCurrency == 'UZS',
                    color: colors.primary,
                  ),
                  const SizedBox(width: 5),
                  _buildDot(
                    isSelected: _selectedCurrency == 'USD',
                    color: colors.accentViolet,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab({
    required BuildContext context,
    required String label,
    required Decimal balance,
    required bool isSelected,
    required Color tint,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: isSelected ? 0.16 : 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: tint,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: amountColor(context, balance.toDouble()),
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.fontFamily,
                  ),
                  child: Text(
                    MoneyFormatter.formatSigned(balance, currencyLabel: ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required bool isSelected, required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.fastOutSlowIn,
      width: isSelected ? 16 : 5,
      height: 4,
      decoration: BoxDecoration(
        color: isSelected ? color : color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildAccountDetails({
    required Key key,
    required BuildContext context,
    required ProjectCurrencyAccount account,
    required String currency,
    required Color tint,
    required bool showSingleBadge,
  }) {
    final colors = context.colors;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSingleBadge) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currency,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: tint,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sof balans',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currency == 'UZS'
                        ? 'O‘zbek so‘mi hisobi'
                        : 'AQSH dollari hisobi',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Text(
                MoneyFormatter.formatSigned(
                  account.balance,
                  currencyLabel: currency,
                ),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: amountColor(context, account.balance.toDouble()),
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary.withValues(alpha: .6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _flow(
                  context,
                  'Kirim',
                  account.income,
                  colors.success,
                  Icons.south_west_rounded,
                  currency,
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: colors.border.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _flow(
                  context,
                  'Chiqim',
                  account.cost,
                  colors.error,
                  Icons.north_east_rounded,
                  currency,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _flow(
    BuildContext context,
    String label,
    Decimal amount,
    Color color,
    IconData icon,
    String currency,
  ) => Row(
    children: [
      Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              MoneyFormatter.format(amount, currencyLabel: currency),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
