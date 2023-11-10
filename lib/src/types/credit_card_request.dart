class BraintreeCreditCardRequest {
  BraintreeCreditCardRequest({
    required this.cardNumber,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cvv,
    this.cardholderName,
  });

  /// Number shown on the credit card.
  String cardNumber;

  /// Two digit expiration month, e.g. `'05'`.
  String expirationMonth;

  /// Four digit expiration year, e.g. `'2021'`.
  String expirationYear;

  /// A 3 or 4 digit card verification value assigned to credit cards.
  String cvv;

  /// Cardholder name
  String? cardholderName;

  Map<String, dynamic> toJson() => {
    'cardNumber': cardNumber,
    'expirationMonth': expirationMonth,
    'expirationYear': expirationYear,
    'cvv': cvv,
    'cardholderName': cardholderName
  };
}