package dev.jonmlk.braintree_paypal

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** BraintreePaypalPlugin */
class BraintreePaypalPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private val CUSTOM_ACTIVITY_REQUEST_CODE = 0x420

    private var activity: Activity? = null
    private val activeResult: Result? = null

    //
    // Platform Channel
    //

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "braintree_paypal")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "tokenizeCreditCard") {
            tokenizeCreditCard(call, result)
        } else if (call.method == "requestPaypalNonce") {
            requestPaypalNonce(call, result)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        // Now you have the Activity reference
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    //
    // Actions
    //

    private fun tokenizeCreditCard(call: MethodCall, result: Result) {
        val intent = Intent(activity, BraintreePaypalActivity::class.java)
        intent.putExtra("type", "tokenizeCreditCard")

        if (call.hasArgument("authorization")) {
            val authorization = call.argument("authorization") as? String
            if (authorization is String) {
                intent.putExtra("authorization", authorization as String)
            }
        }
        val request = call.argument("request") as? Map<*, *>
        assert(request is Map<*, *>)

        intent.putExtra("cardNumber", request?.get("cardNumber") as String?)
        intent.putExtra("expirationMonth", request?.get("expirationMonth") as String?)
        intent.putExtra("expirationYear", request?.get("expirationYear") as String?)
        intent.putExtra("cvv", request?.get("cvv") as String?)
        intent.putExtra("cardholderName", request?.get("cardholderName") as String?)
        activity?.startActivityForResult(intent, CUSTOM_ACTIVITY_REQUEST_CODE)
    }

    private fun requestPaypalNonce(call: MethodCall, result: Result) {
        val intent = Intent(activity, BraintreePaypalActivity::class.java)
        intent.putExtra("type", "requestPaypalNonce")

        if (call.hasArgument("authorization")) {
            val authorization = call.argument("authorization") as? String
            if (authorization is String) {
                intent.putExtra("authorization", authorization as String)
            }
        }
        val request = call.argument("request") as? Map<*, *>
        assert(request is Map<*, *>)

        intent.putExtra("amount", request?.get("amount") as String?)
        intent.putExtra("currencyCode", request?.get("currencyCode") as String?)
        intent.putExtra("displayName", request?.get("displayName") as String?)
        intent.putExtra("payPalPaymentIntent", request?.get("payPalPaymentIntent") as String?)
        intent.putExtra(
            "payPalPaymentUserAction",
            request?.get("payPalPaymentUserAction") as String?
        )
        intent.putExtra(
            "billingAgreementDescription",
            request?.get("billingAgreementDescription") as String?
        )
        activity?.startActivityForResult(intent, CUSTOM_ACTIVITY_REQUEST_CODE)
    }
}

