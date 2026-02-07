import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/car_enums.dart';

enum DisplayCurrency { gbp, try_ }

class UIHelpers {
  static const String _currencyPrefKey = 'displayCurrency';

  static Future<void> setDisplayCurrency(DisplayCurrency currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyPrefKey, currency.toString());
  }

  static Future<DisplayCurrency> getDisplayCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyString = prefs.getString(_currencyPrefKey);
    if (currencyString == DisplayCurrency.try_.toString()) {
      return DisplayCurrency.try_;
    }
    return DisplayCurrency.gbp;
  }

  static String formatPrice(double price, Currency currency) {
    String symbol;
    switch (currency) {
      case Currency.try_: symbol = '₺'; break;
      case Currency.gbp: symbol = '£'; break;
      case Currency.eur: symbol = '€'; break;
      case Currency.usd: symbol = '\$'; break;
    }

    final format = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: symbol,
      decimalDigits: 0,
    );

    return format.format(price);
  }

  static String formatPriceWithConversion(
    double price, {
    required Currency originalCurrency,
    required DisplayCurrency displayCurrency,
    double? gbpToTryRate,
  }) {
    final targetCurrency = displayCurrency == DisplayCurrency.gbp ? Currency.gbp : Currency.try_;

    // Kur oranı yoksa, 0 ise veya para birimleri zaten aynıysa çevirme yapma
    if (gbpToTryRate == null || gbpToTryRate <= 0 || originalCurrency == targetCurrency) {
      return formatPrice(price, originalCurrency);
    }

    // GBP → TRY
    if (originalCurrency == Currency.gbp && targetCurrency == Currency.try_) {
      return formatPrice(price * gbpToTryRate, Currency.try_);
    }

    // TRY → GBP
    if (originalCurrency == Currency.try_ && targetCurrency == Currency.gbp) {
      return formatPrice(price / gbpToTryRate, Currency.gbp);
    }

    return formatPrice(price, originalCurrency);
  }

  static String translateTransmission(TransmissionType transmission) {
    switch (transmission) {
      case TransmissionType.manual: return 'Manuel';
      case TransmissionType.automatic: return 'Otomatik';
      case TransmissionType.semiAutomatic: return 'Yarı Otomatik';
    }
  }

  static String translateSteering(SteeringType steering) {
    switch (steering) {
      case SteeringType.left: return 'Soldan';
      case SteeringType.right: return 'Sağdan';
    }
  }

  static String formatMileage(int mileage) {
    if (mileage >= 1000) {
      final formatter = NumberFormat('#,###', 'tr_TR');
      return formatter.format(mileage);
    }
    return mileage.toString();
  }

  static String translateFuelType(String? fuelType) {
    if (fuelType == null || fuelType.isEmpty) return 'Bilinmiyor';
    switch (fuelType.toLowerCase()) {
      case 'gasoline': return 'Benzin';
      case 'diesel': return 'Dizel';
      case 'electric': return 'Elektrik';
      case 'hybrid': return 'Hibrit';
      case 'lpg': return 'LPG';
      default: return fuelType;
    }
  }
}