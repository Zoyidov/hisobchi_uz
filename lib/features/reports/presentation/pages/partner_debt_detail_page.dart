import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/partner_operation_models.dart';
import '../../data/reports_repository.dart';

class PartnerDebtDetailPage extends StatefulWidget {
  final String type;
  final int currencyTypeId;
  final String title;
  final int partnerId;

  const PartnerDebtDetailPage({
    super.key,
    required this.type,
    required this.currencyTypeId,
    required this.title,
    required this.partnerId,
  });

  @override
  State<PartnerDebtDetailPage> createState() => _PartnerDebtDetailPageState();
}

class _PartnerDebtDetailPageState extends State<PartnerDebtDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final List<PartnerOperation> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadPage(1);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadPage(_currentPage + 1);
    }
  }

  Future<void> _loadPage(int page) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    final result = await getIt<ReportsRepository>().getPartnerDebtOperations(
      partnerId: widget.partnerId,
      type: widget.type,
      currencyTypeId: widget.currencyTypeId,
      page: page,
    );

    if (!mounted) return;

    result.when(
      success: (paged) {
        setState(() {
          if (page == 1) {
            _items.clear();
          }
          _items.addAll(paged.items);
          _currentPage = page;
          _hasMore = paged.hasNext;
          _isLoading = false;
          _isLoadingMore = false;
        });
      },
      failure: (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
          _isLoadingMore = false;
        });
      },
    );
  }

  String _formatCurrency(String amount) {
    final value = double.tryParse(amount) ?? 0.0;
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        centerTitle: true,
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = context.colors;

    if (_isLoading) {
      return const AppSkeletonList();
    }

    if (_error != null && _items.isEmpty) {
      return AppErrorState(
        title: 'Yuklab bo\'lmadi',
        description: _error,
        onRetry: () => _loadPage(1),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: colors.textTertiary),
            const SizedBox(height: 12),
            Text(
              'Tranzaksiyalar mavjud emas',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final currencyLabel = widget.currencyTypeId == 2 ? 'USD' : 'UZS';

    return RefreshIndicator(
      onRefresh: () => _loadPage(1),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }

          final op = _items[index];
          final isIncoming = op.isIncoming;
          final amountColor = isIncoming ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

          return Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncoming ? Icons.south_west_rounded : Icons.north_east_rounded,
                      color: amountColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          op.partnerName,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (op.partnerPhone != null && op.partnerPhone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            PhoneFormatter.toDisplay(op.partnerPhone!),
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (op.dueDate != null && op.dueDate!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Muddat: ${op.dueDate}',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncoming ? '+' : '−'}${_formatCurrency(op.remainingAmount)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: amountColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currencyLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
