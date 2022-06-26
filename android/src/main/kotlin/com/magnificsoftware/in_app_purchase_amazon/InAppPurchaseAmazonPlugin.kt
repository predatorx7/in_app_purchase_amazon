package com.magnificsoftware.in_app_purchase_amazon

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.VisibleForTesting
import com.amazon.device.drm.LicensingService
import com.amazon.device.iap.PurchasingListener
import com.amazon.device.iap.PurchasingService
import com.amazon.device.iap.model.ProductDataResponse
import com.amazon.device.iap.model.PurchaseResponse
import com.amazon.device.iap.model.PurchaseUpdatesResponse
import com.amazon.device.iap.model.UserDataResponse
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** InAppPurchaseAmazonPlugin */
class InAppPurchaseAmazonPlugin : FlutterPlugin, MethodCallHandler {
    private val tag = "InAppPurchasePlugin"

    @VisibleForTesting
    internal object MethodNames {
        const val INITIALIZE = "AmazonIAPClient#initialize()"
        const val PLATFORM_VERSION = "AmazonIAPClient#getPlatformVersion()"
        const val CLIENT_INFORMATION = "AmazonIAPClient#getClientInformation()"
        const val CLIENT_INFORMATION_CALLBACK =
            "AmazonIAPClient#onClientInformation(AmazonUserData)"
        const val SDK_MODE = "AmazonIAPClient#getSDKMode()"
        const val LICENSE_VERIFICATION_RESPONSE_CALLBACK = "AmazonIAPClient#onLicenseVerificationResponse()"
    }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "plugins.magnificsoftware.com/in_app_purchase_amazon"
        )
        channel.setMethodCallHandler(this)
        this.applicationContext = flutterPluginBinding.applicationContext
    }

    private var methodResult: MethodResultWrapper? = null

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        methodResult = MethodResultWrapper(result, channel);

        try {
            if (applicationContext != null) {
                PurchasingService.registerListener(applicationContext, purchasesUpdatedListener)
            } else {
                Log.w(
                    tag,
                    "Cannot register listener on purchasing service because applicationContext is null."
                )
            }
        } catch (e: Exception) {
            Log.e(
                tag,
                "For call '${call.method}', plugin failed to add purchase listener with error: ${e.message}"
            )
        }

        when (call.method) {
            MethodNames.INITIALIZE -> {
                LicensingService.verifyLicense(applicationContext
                ) {
                    Log.d(tag, "License verification response ${it.requestStatus}")
                    methodResult?.invokeMethod(MethodNames.LICENSE_VERIFICATION_RESPONSE_CALLBACK, it.requestStatus.name)
                };
                result.success(true);
            }
            MethodNames.PLATFORM_VERSION -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            MethodNames.CLIENT_INFORMATION -> {
                val data = PurchasingService.getUserData();
                Log.d(tag, "Requesting user data from purchasing service: ${data.toJSON()}");
                Log.d(tag, "Appstore SDK Mode: " + LicensingService.getAppstoreSDKMode());
            }
            MethodNames.SDK_MODE -> {
                result.success(LicensingService.getAppstoreSDKMode())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = null;
        channel.setMethodCallHandler(null)
    }

    private val purchasesUpdatedListener: PurchasingListener = object : PurchasingListener {
        override fun onUserDataResponse(response: UserDataResponse) {
            Log.d(tag, "Received user data response: $response")
            try {
                val status = response.requestStatus
                var currentUserId: String? = null
                var currentMarketplace: String? = null
                val statusValue: String

                when (status) {
                    UserDataResponse.RequestStatus.SUCCESSFUL -> {
                        currentUserId = response.userData.userId
                        currentMarketplace = response.userData.marketplace
                        statusValue = "SUCCESSFUL"
                    }
                    UserDataResponse.RequestStatus.FAILED, null -> statusValue = "FAILED"
                    // Fail gracefully.
                    UserDataResponse.RequestStatus.NOT_SUPPORTED ->
                        statusValue = "NOT_SUPPORTED"
                }

                val item: HashMap<String, Any?> = HashMap()

                item["userId"] = currentUserId
                item["marketplace"] = currentMarketplace
                item["status"] = statusValue

                Log.d(tag, "Putting data: $item")
                val result = methodResult
                if (result == null) {
                    Log.d(tag, "Method result is null")
                } else {
                    result.success(item)
                    result.invokeMethod(MethodNames.CLIENT_INFORMATION_CALLBACK, item)
                }
            } catch (e: Exception) {
                Log.e(tag, "ON_USER_DATA_RESPONSE_JSON_PARSE_ERROR: ${e.message}")
                methodResult?.error("ON_USER_DATA_RESPONSE_JSON_PARSE_ERROR", e.message, null);
            }
        }

        override fun onProductDataResponse(productDataResponse: ProductDataResponse?) {
            Log.w(tag, "'onProductDataResponse' has not been implemented")
        }

        override fun onPurchaseResponse(purchaseResponse: PurchaseResponse?) {
            Log.w(tag, "'onPurchaseResponse' has not been implemented")
        }

        override fun onPurchaseUpdatesResponse(purchaseUpdatesResponse: PurchaseUpdatesResponse?) {
            Log.w(tag, "'onPurchaseUpdatesResponse' has not been implemented")
        }
    };
}
