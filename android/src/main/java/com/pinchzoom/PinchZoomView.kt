package com.pinchzoom

import android.content.Context
import com.facebook.react.views.view.ReactViewGroup

class PinchZoomView(context: Context?) : ReactViewGroup(context) {
  var disabledPinchZoom = false
  var shouldAdjustSystemUi = true
}
