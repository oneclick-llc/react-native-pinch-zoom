import React

@objc(PinchZoomViewManager)
class PinchZoomViewManager: RCTViewManager {

  override func view() -> (PinchZoomView) {
      return PinchZoomView(frame: .zero)
  }

  @objc override static func requiresMainQueueSetup() -> Bool {
    return false
  }
}

@objc
class PinchZoomView : ZoomableView {
    @objc
    var disableScrollViewOnPinch: Bool = false
    @objc
    var onDoubleTap: RCTDirectEventBlock? = nil
    @objc
    var doubleTapEnabled: Bool = false {
        didSet {
            if !doubleTapEnabled { onPanDoubleTap = nil }
            else {
                onPanDoubleTap = { [weak self] in
                    self?.onDoubleTap?([:])
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isZoomable = true
        isEnableZoom = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !subviews.isEmpty {
            sourceView = subviews[0]
            if disableScrollViewOnPinch {
                findScrollViewParent()
            }
        }
    }
}
