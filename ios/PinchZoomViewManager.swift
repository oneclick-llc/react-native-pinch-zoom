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
    var disabledPinchZoom: Bool = false {
        didSet {
            isZoomable = !disabledPinchZoom
            isEnableZoom = !disabledPinchZoom
        }
    }
    @objc
    var disableScrollViewOnPinch: Bool = false
    @objc
    var onDoubleTap: RCTDirectEventBlock? = nil {
        didSet {
            onPanDoubleTap = { [weak self] in
                self?.onDoubleTap?([:])
            }
        }
    }
    @objc
    var onTap: RCTDirectEventBlock? = nil {
        didSet {
            onPanTap = { [weak self] in
                self?.onTap?([:])
            }
        }
    }
    
    @objc
    var onPinchStart: RCTDirectEventBlock? = nil {
        didSet {
          _onPinchStart = { [weak self] in
                self?.onPinchStart?([:])
            }
        }
    }
    @objc
    var onPinchEnd: RCTDirectEventBlock? = nil {
        didSet {
            _onPinchEnd = { [weak self] in
                self?.onPinchEnd?([:])
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
