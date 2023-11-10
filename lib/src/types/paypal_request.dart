class BraintreePayPalRequest {
  BraintreePayPalRequest({
    required this.amount,
    this.currencyCode,
    this.displayName,
    this.billingAgreementDescription,
    this.payPalPaymentIntent = PayPalPaymentIntent.authorize,
    this.payPalPaymentUserAction = PayPalPaymentUserAction.default_,
  });

  /// Amount of the transaction. If [amount] is `null`, PayPal will use the billing agreement (Vault) flow.
  /// If [amount] is set, PayPal will follow the one time payment (Checkout) flow.
  String? amount;

  /// Currency code. If set to `null`, PayPal will choose it based on the active merchant account in the client token.
  String? currencyCode;

  /// The merchant name displayed in the PayPal flow. If set to `null`, PayPal will use the company name in your Braintree account.
  String? displayName;

  /// Description for the billing agreement for the Vault flow.
  String? billingAgreementDescription;

  /// The payment intent in the PayPal Checkout flow.
  PayPalPaymentIntent payPalPaymentIntent;

  /// The user action in the PayPal Checkout flow. See [PayPalPaymentUserAction]
  /// for additional documentation.
  PayPalPaymentUserAction payPalPaymentUserAction;

  /// Converts this request object into a JSON-encodable format.
  Map<String, dynamic> toJson() => {
    if (amount != null) 'amount': amount,
    if (currencyCode != null) 'currencyCode': currencyCode,
    if (displayName != null) 'displayName': displayName,
    if (billingAgreementDescription != null)
      'billingAgreementDescription': billingAgreementDescription,
    'payPalPaymentIntent': payPalPaymentIntent.name,
    'payPalPaymentUserAction': payPalPaymentUserAction.name,
  };
}

enum PayPalPaymentUserAction {
  /// Shows the default call-to-action text on the PayPal Express Checkout page.
  /// This option indicates that a final confirmation will be shown on the
  /// merchant checkout site before the user's payment method is charged.
  default_,

  /// Shows a deterministic call-to-action. This option indicates to the user
  /// that their payment method will be charged when they click the
  /// call-to-action button on the PayPal Checkout page, and that no final
  /// confirmation page will be shown on the merchant's checkout page. This
  /// option works for both checkout and vault flows.
  commit
}

enum PayPalPaymentIntent {
  /// Payment intent to create an order.
  order,

  /// Payment intent for immediate payment.
  sale,

  /// Payment intent to authorize a payment for capture later.
  authorize,
}