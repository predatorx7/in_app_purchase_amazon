package com.magnificsoftware.in_app_purchase_amazon

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel

// MethodChannel.Result wrapper that responds on the platform thread.
class MethodResultWrapper internal constructor(
  private val safeResult: MethodChannel.Result,
  private val safeChannel: MethodChannel
) :
  MethodChannel.Result {
  private val handler: Handler = Handler(Looper.getMainLooper())
  override fun success(result: Any?) {
    handler.post { safeResult.success(result) }
  }

  override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
    handler.post { safeResult.error(errorCode, errorMessage, errorDetails) }
  }

  override fun notImplemented() {
    handler.post { safeResult.notImplemented() }
  }

  fun invokeMethod(method: String, arguments: Any?) {
    handler.post { safeChannel.invokeMethod(method, arguments, null) }
  }
}
