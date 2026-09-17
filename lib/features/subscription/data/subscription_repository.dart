import '../../../core/constants/app_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import 'subscription_models.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._client);

  final ApiClient _client;

  Future<ApiResult<SubscriptionInfo>> getSubscription() {
    return _client.get(ApiEndpoints.subscriptionShow, parse: (r) => SubscriptionInfo.fromJson(r as Map<String, dynamic>));
  }

  Future<ApiResult<SubscriptionUsage>> getStatistics() {
    return _client.get(ApiEndpoints.subscriptionStatistics, parse: (r) => SubscriptionUsage.fromJson(r as Map<String, dynamic>));
  }

  Future<ApiResult<List<PricingPlan>>> getPricingPlans() =>
      _client.getList(ApiEndpoints.pricingPlans, fromJson: PricingPlan.fromJson);

  Future<ApiResult<PurchaseOrder>> purchase({
    required int planId,
    required BillingCycle billingCycle,
    required String paymentProvider,
    required String returnUrl,
  }) {
    return _client.post(
      ApiEndpoints.subscriptionPurchase,
      data: {
        'plan_id': planId,
        'billing_cycle': billingCycle.apiValue,
        'payment_provider': paymentProvider,
        'return_url': returnUrl,
      },
      parse: (r) => PurchaseOrder.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<OrderStatus>> checkOrderStatus(String orderNumber) {
    return _client.get(
      ApiEndpoints.checkOrderStatus(orderNumber),
      parse: (r) => OrderStatusX.fromApi((r as Map<String, dynamic>)['status'] as String?),
    );
  }

  Future<ApiResult<List<SmsPackage>>> getSmsPackages() =>
      _client.getList(ApiEndpoints.pricingSms, fromJson: SmsPackage.fromJson);

  Future<ApiResult<PurchaseOrder>> purchaseSms({
    required int packageId,
    required String paymentProvider,
    required String returnUrl,
  }) {
    return _client.post(
      ApiEndpoints.pricingSmsPurchase,
      data: {'sms_package_id': packageId, 'payment_provider': paymentProvider, 'return_url': returnUrl},
      parse: (r) => PurchaseOrder.fromJson(r as Map<String, dynamic>),
    );
  }
}
