package dev.jonmlk.braintree_paypal

import android.app.Activity
import android.content.Intent
import com.braintreepayments.api.BraintreeClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener


/** BraintreePaypalPlugin */
class BraintreePaypalPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private val CUSTOM_ACTIVITY_REQUEST_CODE = 0x420

    private var activity: Activity? = null
    private var activeResult: Result? = null

    //
    // Platform Channel
    //

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "braintree_paypal")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (activeResult != null) {
            result.error(
                "already_running",
                "Cannot launch another custom activity while one is already running.",
                null
            )
            return
        }
        activeResult = result

        if (call.method == "tokenizeCreditCard") {
            tokenizeCreditCard(call)
        } else if (call.method == "requestPaypalNonce") {
            requestPaypalNonce(call)
        } else if (call.method == "getDeviceData") {
            getDeviceData(call)
        } else {
            activeResult = null
            result.notImplemented()
        }
    }

    //
    // Activity Aware
    //

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        // Now you have the Activity reference
        binding.addActivityResultListener(this);
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this);
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    //
    // Activity Result Listener
    //

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (activeResult == null || requestCode != CUSTOM_ACTIVITY_REQUEST_CODE) {
            activeResult = null
            return false
        }

        if (resultCode == Activity.RESULT_OK) {
            val type: String? = data?.getStringExtra("type")
            if (type == "paymentMethodNonce") {
                activeResult!!.success(data.getSerializableExtra("paymentMethodNonce"))
            } else if (type == "deviceData") {
                activeResult!!.success(data.getSerializableExtra("deviceData"))
            } else {
                val error = Exception("Invalid activity result type.")
                activeResult!!.error("error", error.message, null)
            }
        } else if (resultCode == Activity.RESULT_CANCELED) {
            activeResult!!.success(null)
        } else {
            val error = data?.getSerializableExtra("error") as Exception?
            activeResult!!.error("error", error?.message ?: "error but no exception raised", null)
        }
        activeResult = null
        return true
    }

    //
    // Actions
    //

    private fun getDeviceData(call: MethodCall) {
        val intent = Intent(activity, BraintreePaypalActivity::class.java)
        intent.putExtra("type", "getDeviceData")
        if (call.hasArgument("authorization")) {
            val authorization = call.argument("authorization") as? String
            if (authorization is String) {
                intent.putExtra("authorization", authorization)
            }
        }
        activity?.startActivityForResult(intent, CUSTOM_ACTIVITY_REQUEST_CODE)
    }

    private fun tokenizeCreditCard(call: MethodCall) {
        val intent = Intent(activity, BraintreePaypalActivity::class.java)
        intent.putExtra("type", "tokenizeCreditCard")

        if (call.hasArgument("authorization")) {
            val authorization = call.argument("authorization") as? String
            if (authorization is String) {
                intent.putExtra("authorization", authorization)
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

    private fun requestPaypalNonce(call: MethodCall) {
        val intent = Intent(activity, BraintreePaypalActivity::class.java)
        intent.putExtra("type", "requestPaypalNonce")

        if (call.hasArgument("authorization")) {
            val authorization = call.argument("authorization") as? String
            if (authorization is String) {
                intent.putExtra("authorization", authorization)
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

