package com.magnificsoftware.in_app_purchase_amazon

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.VisibleForTesting
import com.amazon.device.drm.LicensingService
import com.amazon.device.iap.PurchasingListener
import com.amazon.device.iap.PurchasingService
import com.amazon.device.iap.model.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap
import java.util.Locale


/** InAppPurchaseAmazonPlugin */
class InAppPurchaseAmazonPlugin : FlutterPlugin, MethodCallHandler {
    private val tag = "InAppPurchasePlugin"

    @VisibleForTesting
    internal object MethodNames {
        const val UPDATE_PACKAGE_INSTALLER = "Additional#updatePackageInstaller()"
        const val INITIALIZE = "AmazonIAPClient#initialize()"
        const val SDK_MODE = "AmazonIAPClient#getSDKMode()"
        const val PLATFORM_VERSION = "AmazonIAPClient#getPlatformVersion()"
        const val CLIENT_INFORMATION = "AmazonIAPClient#getClientInformation()"
        const val CLIENT_INFORMATION_CALLBACK =
                "AmazonIAPClient#onClientInformation(AmazonUserData)"
        const val LICENSE_VERIFICATION_RESPONSE_CALLBACK =
                "AmazonIAPClient#onLicenseVerificationResponse()"
        const val SKUS = "AmazonIAPClient#SKU(sku_names)"
        const val SKUS_CALLBACK = "AmazonIAPClient#onSKU(AmazonUserData)"
        const val PURCHASE_UPDATES = "AmazonIAPClient#getPurchaseUpdateData(boolean)"
        const val PURCHASE_UPDATES_CALLBACK = "AmazonIAPClient#onPurchaseUpdateData(PurchaseDetails)"
        const val PURCHASE = "AmazonIAPClient#doPurchase()"
        const val PURCHASE_CALLBACK = "AmazonIAPClient#onPurchaseData(receipt)"
        const val ERROR_CALLBACK =
                "AmazonIAPClient#onError(ErrorDescription)"
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

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == MethodNames.UPDATE_PACKAGE_INSTALLER) {
            val pm = applicationContext?.packageManager
            val packageName = applicationContext?.packageName

            if (pm != null && packageName != null) {
                try {
                    pm.setInstallerPackageName(packageName, call.arguments as String)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("PM_FAILED", "PM failed: ${e.message}", null)
                }
            } else {
                result.error("PM_FAILED", "PM failed", null)
            }
            return
        }

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
        try {
            when (call.method) {
                MethodNames.INITIALIZE -> {
                    LicensingService.verifyLicense(
                            applicationContext
                    ) {
                        Log.w(tag, "License verification response ${it.requestStatus}")
                        channel.invokeMethod(
                                MethodNames.LICENSE_VERIFICATION_RESPONSE_CALLBACK,
                                it.requestStatus.name
                        )
                    }
                    result.success(true)
                    return
                }
                MethodNames.PLATFORM_VERSION -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                    return
                }
                MethodNames.CLIENT_INFORMATION -> {
                    val data = PurchasingService.getUserData()
                    Log.w(tag, "Requesting user data from purchasing service: ${data.toJSON()}")
                    Log.w(tag, "Appstore SDK Mode: " + LicensingService.getAppstoreSDKMode())
                    result.success(true)
                    return
                }
                MethodNames.SDK_MODE -> {
                    result.success(LicensingService.getAppstoreSDKMode())
                    return
                }
                MethodNames.SKUS -> {
                    val skus = call.argument<List<String>>("skus")
                    if (skus == null || skus.isEmpty()) {
                        result.success(false)
                        return
                    }
                    PurchasingService.getProductData(skus.toSet())
                    result.success(true)
                    return
                }
                MethodNames.PURCHASE_UPDATES -> {
                    val activate = call.argument<Boolean>("activate") ?: true
                    PurchasingService.getPurchaseUpdates(activate)
                    result.success(true)
                    return
                }
                MethodNames.PURCHASE -> {
                    val sku = call.argument<String>("sku")
                    if (sku == null) {
                        result.success(false)
                        return
                    }
                    PurchasingService.purchase(sku)
                    result.success(true)
                    return
                }
                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            result.error("METHOD_ERROR", "Unexpected error occurred", e.message)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = null
        channel.setMethodCallHandler(null)
    }

    private val purchasesUpdatedListener: PurchasingListener = object : PurchasingListener {
        override fun onUserDataResponse(response: UserDataResponse) {
            Log.w(tag, "Received user data response: $response")
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

                Log.w(tag, "Putting data: $item")
                channel.invokeMethod(MethodNames.CLIENT_INFORMATION_CALLBACK, item)
            } catch (e: Exception) {

                Log.e(tag, "ON_USER_DATA_RESPONSE_JSON_PARSE_ERROR: ${e.message}")
                e.printStackTrace();
                channel.invokeMethod(MethodNames.ERROR_CALLBACK, arrayOf("ON_USER_DATA_RESPONSE_JSON_PARSE_ERROR", e.message))
            }
        }

        override fun onProductDataResponse(response: ProductDataResponse?) {
            Log.w(tag, "on Product Data Response: $response")
            try {
                val status = response?.requestStatus
                var productData: Map<String, Map<String, Any>>? = response?.productData?.entries?.associate {
                    it.key to toMap(it.value.toJSON())
                }
                val statusValue: String

                when (status) {
                    ProductDataResponse.RequestStatus.SUCCESSFUL -> {
                        Log.i(
                                tag,
                                "onProductDataResponse: successful.  The item data map in this response includes the valid SKUs"
                        )
                        productData = response.productData.entries.associate {
                            it.key to toMap(it.value.toJSON())
                        }
                        statusValue = "SUCCESSFUL"
                    }
                    ProductDataResponse.RequestStatus.FAILED, null -> statusValue = "FAILED"
                    // Fail gracefully.
                    ProductDataResponse.RequestStatus.NOT_SUPPORTED ->
                        statusValue = "NOT_SUPPORTED"
                }

                val item: HashMap<String, Any?> = HashMap()
                item["data"] = productData
                item["status"] = statusValue
                channel.invokeMethod(MethodNames.SKUS_CALLBACK, item)
            } catch (e: Exception) {
                Log.e(tag, "ON_PRODUCT_DATA_RESPONSE_JSON_PARSE_ERROR: ${e.message}")
                e.printStackTrace();
                channel.invokeMethod(MethodNames.ERROR_CALLBACK, arrayOf("ON_PRODUCT_DATA_RESPONSE_JSON_PARSE_ERROR", e.message))
            }
        }

        override fun onPurchaseResponse(response: PurchaseResponse?) {
            Log.w(tag, "onPurchaseResponse =$response")
            try {
                val status = response?.requestStatus
                var receipt: Receipt? = null
                when (status) {
                    PurchaseResponse.RequestStatus.SUCCESSFUL -> {
                        receipt = response.receipt
                        PurchasingService.notifyFulfillment(
                                receipt.receiptId,
                                FulfillmentResult.FULFILLED
                        )
                    }
                    else -> {
                        // do nothing
                    }
                }
                val item: HashMap<String, Any?> = HashMap()
                if (receipt != null) {
                    item["data"] = toMap(receipt.toJSON())
                }
                item["status"] = status?.name ?: "UNKNOWN"
                channel.invokeMethod(MethodNames.PURCHASE_CALLBACK, item)
            } catch (e: Exception) {
                Log.e(tag, "ON_PURCHASE_DATA_RESPONSE_JSON_PARSE_ERROR: ${e.message}")
                e.printStackTrace();
                channel.invokeMethod(MethodNames.ERROR_CALLBACK, arrayOf("ON_PURCHASE_DATA_RESPONSE_JSON_PARSE_ERROR", e.message))
            }
        }

        override fun onPurchaseUpdatesResponse(response: PurchaseUpdatesResponse?) {
            Log.w(tag, "onPurchaseUpdatesResponse: $response")
            try {
                val items = JSONArray()
                val receipts = response?.receipts
                if (receipts != null) {
                    for (receipt in receipts) {
                        val item = receipt.toJSON()
                        Log.w(tag, "onPurchase update Putting $item")
                        items.put(item)
                    }
                }
                val argument: HashMap<String, Any?> = HashMap()
                argument["data"] = toList(items)
                argument["status"] = response?.requestStatus?.name ?: "UNKNOWN"
                channel.invokeMethod(MethodNames.PURCHASE_UPDATES_CALLBACK, argument)
            } catch (e: Exception) {
                Log.e(tag, "ON_PURCHASE_UPDATE_DATA_RESPONSE_JSON_PARSE_ERROR: ${e.message}")
                e.printStackTrace();
                channel.invokeMethod(MethodNames.ERROR_CALLBACK, arrayOf("ON_PURCHASE_UPDATE_DATA_RESPONSE_JSON_PARSE_ERROR", e.message))
            }
        }
    }

    companion object {
        private fun toMap(jsonobj: JSONObject): Map<String, Any> {
            val map: MutableMap<String, Any> = HashMap()
            val keys: Iterator<String> = jsonobj.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                var value: Any = jsonobj.get(key)
                if (value is JSONArray) {
                    value = toList(value)
                } else if (value is JSONObject) {
                    value = toMap(value)
                } else if (value is ProductType) {
                    value = value.name
                } else if (value is Date) {
                    value = toISO8601String(value)
                }
                Log.w("toMap", value.javaClass.name)
                map[key] = value
            }
            return map
        }

        @SuppressLint("SimpleDateFormat")
        private fun toISO8601String(date: Date) : String {
            // This is a jugaadu implementation
            val tz: TimeZone = TimeZone.getTimeZone("UTC")
            val df: DateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'")
            df.timeZone = tz
            return df.format(date)
        }

        private fun toList(array: JSONArray): List<Any> {
            val list: MutableList<Any> = ArrayList()
            for (i in 0 until array.length()) {
                var value: Any = array.get(i)
                if (value is JSONArray) {
                    value = toList(value)
                } else if (value is JSONObject) {
                    value = toMap(value)
                } else if (value is ProductType) {
                    value = value.name
                } else if (value is Date) {
                    value = toISO8601String(value)
                }
                Log.w("toMap", value.javaClass.name)
                list.add(value)
            }
            return list
        }
    }
}
