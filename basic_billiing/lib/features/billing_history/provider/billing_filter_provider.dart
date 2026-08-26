import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/billing_filter_model.dart';

final billingFilterProvider =
    NotifierProvider<BillingFilterNotifier, BillingFilterModel>(() {
  return BillingFilterNotifier();
});

class BillingFilterNotifier extends Notifier<BillingFilterModel> {
  @override
  BillingFilterModel build() {
    return const BillingFilterModel(type: DateFilterType.today);
  }

  void setFilterType(DateFilterType type) {
    state = state.copyWith(type: type);
  }

  void setSelectedDate(DateTime date) {
    state = BillingFilterModel(
      type: DateFilterType.singleDate,
      selectedDate: date,
    );
  }
}
