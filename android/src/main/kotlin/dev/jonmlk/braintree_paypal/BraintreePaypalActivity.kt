package dev.jonmlk.braintree_paypal

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.braintreepayments.api.BraintreeClient
import com.braintreepayments.api.Card
import com.braintreepayments.api.CardClient
import com.braintreepayments.api.CardNonce
import com.braintreepayments.api.CardTokenizeCallback
import com.braintreepayments.api.PayPalAccountNonce
import com.braintreepayments.api.PayPalCheckoutRequest
import com.braintreepayments.api.PayPalClient
import com.braintreepayments.api.PayPalListener
import com.braintreepayments.api.PayPalVaultRequest
import com.braintreepayments.api.PaymentMethodNonce
import com.braintreepayments.api.UserCanceledException


public open class BraintreePaypalActivity: AppCompatActivity(), PayPalListener {

    private var braintreeClient: BraintreeClient? = null

    //
    // Lifecycle
    //

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            val intent = intent
            braintreeClient = BraintreeClient(this, intent.getStringExtra("authorization")!!)
            val type = intent.getStringExtra("type")
            if (type == "tokenizeCreditCard") {
                tokenizeCreditCard()
            } else if (type == "requestPaypalNonce") {
                requestPaypalNonce()
            } else {
                throw Exception("Invalid request type: $type")
            }
        } catch (e: Exception) {
            val result = Intent()
            result.putExtra("error", e)
            setResult(2, result)
            finish()
            return
        }
    }

    override fun onNewIntent(newIntent: Intent?) {
        super.onNewIntent(newIntent)
        intent = newIntent
    }

    override fun onStart() {
        super.onStart()
    }

    override fun onResume() {
        super.onResume()
    }

    //
    // Actions
    //

    protected fun tokenizeCreditCard() {
        val intent = intent
        val card = Card()
        card.expirationMonth = intent.getStringExtra("expirationMonth")
        card.expirationYear = intent.getStringExtra("expirationYear")
        card.cvv = intent.getStringExtra("cvv")
        card.cardholderName = intent.getStringExtra("cardholderName")
        card.number = intent.getStringExtra("cardNumber")
        val cardClient = CardClient(braintreeClient!!)
        val callback = CardTokenizeCallback { cardNonce: CardNonce?, error: java.lang.Exception? ->
            cardNonce?.let { onPaymentMethodNonceCreated(it) }
            error?.let { onError(it) }
        }
        cardClient.tokenize(card, callback)
    }

    protected fun requestPaypalNonce() {
        val payPalClient = PayPalClient(this, braintreeClient!!)
        payPalClient.setListener(this)

        val intent = intent
        if (intent.getStringExtra("amount") == null) {
            // Vault flow
            val vaultRequest = PayPalVaultRequest()
            vaultRequest.displayName = intent.getStringExtra("displayName")
            vaultRequest.billingAgreementDescription =
                intent.getStringExtra("billingAgreementDescription")
            payPalClient.tokenizePayPalAccount(this, vaultRequest)
        } else {
            // Checkout flow
            val checkOutRequest = PayPalCheckoutRequest(intent.getStringExtra("amount")!!)
            checkOutRequest.currencyCode = intent.getStringExtra("currencyCode")
            payPalClient.tokenizePayPalAccount(this, checkOutRequest)
        }
    }

    //
    // Callbacks
    //

    private fun onPaymentMethodNonceCreated(paymentMethodNonce: PaymentMethodNonce) {
        val nonceMap = HashMap<String, Any?>()
        nonceMap["nonce"] = paymentMethodNonce.string
        nonceMap["isDefault"] = paymentMethodNonce.isDefault
        if (paymentMethodNonce is PayPalAccountNonce) {
            val paypalAccountNonce = paymentMethodNonce
            nonceMap["paypalPayerId"] = paypalAccountNonce.payerId
            nonceMap["typeLabel"] = "PayPal"
            nonceMap["description"] = paypalAccountNonce.email
        } else if (paymentMethodNonce is CardNonce) {
            val cardNonce = paymentMethodNonce
            nonceMap["typeLabel"] = cardNonce.cardType
            nonceMap["description"] = "ending in ••" + cardNonce.lastTwo
        }
        val result = Intent()
        result.putExtra("type", "paymentMethodNonce")
        result.putExtra("paymentMethodNonce", nonceMap)
        setResult(RESULT_OK, result)
        finish()
    }

    private fun onCancel() {
        setResult(RESULT_CANCELED)
        finish()
    }

    private fun onError(error: java.lang.Exception?) {
        val result = Intent()
        result.putExtra("error", error)
        setResult(2, result)
        finish()
    }

    //
    // PayPal Listener
    //

    override fun onPayPalSuccess(payPalAccountNonce: PayPalAccountNonce) {
        onPaymentMethodNonceCreated(payPalAccountNonce)
    }

    override fun onPayPalFailure(error: java.lang.Exception) {
        if (error is UserCanceledException) {
            if (error.isExplicitCancelation) {
                onCancel()
            }
        } else {
            onError(error)
        }
    }
}