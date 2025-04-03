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
            // print("PinchZoomView | onDoubleTap.didSet | is present: \(onDoubleTap != nil)")
            guard let onDoubleTap else {
                onPanDoubleTap = nil
                // print("PinchZoomView | removing DoubleTap Gesture")
                doubleTapGesture.map { removeGestureRecognizer($0) }
                doubleTapGesture = nil
                return
            }
            onPanDoubleTap = { onDoubleTap([:]) }

            // print("PinchZoomView | adding DoubleTap Gesture")
            doubleTapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(doubleTapped)
            )
            doubleTapGesture?.numberOfTapsRequired = 2
            doubleTapGesture.map { addGestureRecognizer($0) }
        }
    }
    @objc
    var onTap: RCTDirectEventBlock? = nil {
        didSet {
            // print("PinchZoomView | onTap.didSet | is present: \(onTap != nil)")
            guard let onTap else {
                onPanTap = nil

                // print("PinchZoomView | removing Tap Gesture")
                tapGesture.map { removeGestureRecognizer($0) }
                tapGesture = nil

                return
            }
            onPanTap = { onTap([:]) }

            // print("PinchZoomView | adding Tap Gesture")
            tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(oneTapped)
            )
            if let doubleTapGesture = doubleTapGesture {
                tapGesture?.require(toFail: doubleTapGesture)
            }
            tapGesture.map { addGestureRecognizer($0) }
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
