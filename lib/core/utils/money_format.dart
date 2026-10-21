/// Formats a SAR amount with thousands separators, e.g. 1500000 → '1,500,000'.
///
/// Fractions are rounded away: survey-sourced prices are estimates, so showing
/// halalas would suggest more precision than the data has.
String formatMoney(double value) {
  final whole = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return buffer.toString();
}
