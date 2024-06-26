//
//  ZoomableView.swift
//  ZoomableView
//
//  Created by kevin.ngh54 on 01/01/2023.
//

import UIKit

class Weak<T: AnyObject> {
  weak var value : T?
  init (value: T) {
    self.value = value
  }
}

public class ZoomableView: UIView {
    public weak var delegate: ZoomableViewDelegate?
    /// Enable/Disable zoom ability
    public var isEnableZoom = true

    /// View's zoom status
    public var isZooming = false
    private var beginSourceViewFrame: CGRect?
    private var parentScrollView: [Weak<UIScrollView>] = []

    var onPanDoubleTap: (() -> Void)? = nil
    var onPanTap: (() -> Void)? = nil

    var _onPinchStart: (() -> Void)? = nil
    var _onPinchEnd: (() -> Void)? = nil

    /// Add/remove gesture if the view is/isn't zoomable
    public var isZoomable: Bool = false {
        didSet {
            pinchGesture.map { removeGestureRecognizer($0) }
            panGesture.map { removeGestureRecognizer($0) }
            if isZoomable {
                inititialize()
                pinchGesture.map { addGestureRecognizer($0) }
                panGesture.map { addGestureRecognizer($0) }
            }
        }
    }

    /// View's pinch gesture
    public var pinchGesture: UIPinchGestureRecognizer?
    public var doubleTapGesture: UITapGestureRecognizer?
    public var tapGesture: UITapGestureRecognizer?

    /// View's pan gesture
    public var panGesture: UIPanGestureRecognizer?

    /// View's background when zooming
    public var backgroundView: UIView?

    /// ZoomableView is the superview of sourceView which will be zoomed when the gestures recognize
    /// sourceView is needed to set reference so as to be zoomed
    public var sourceView: UIView?

    /// The rate between UIPinchGestureRecognizer and Zoomable scale
    public var scaleRate: CGFloat = 1.0

    /// View's scale
    private var scale: CGFloat = 1.0

    func findScrollViewParent() {
        if !parentScrollView.isEmpty { return }
        var parent = superview
        while parent != nil {
            parent = parent?.superview
            if (parent is UIScrollView) {
                parentScrollView.append(.init(value: parent as! UIScrollView))
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(oneTapped))
        tapGesture?.require(toFail: doubleTapGesture!)
        doubleTapGesture?.numberOfTapsRequired = 2
        doubleTapGesture.map { addGestureRecognizer($0) }
        tapGesture.map { addGestureRecognizer($0) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Background view when the view is zooming
    private func getBackgroundView() -> UIView {
        // default background view
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        if let pinchSourceView = sourceView {
            let rect = pinchSourceView.convert(pinchSourceView.bounds, to: UIApplication.shared.getKeyWindow())
            backgroundView.addSubview(pinchSourceView)
            pinchSourceView.frame = rect
        }
        self.backgroundView = backgroundView
        return backgroundView
    }

    /// Initialize pinch & pan gestures
    private func inititialize() {
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imagePinched(_:)))
        pinchGesture?.delegate = self
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePanned(_:)))
        panGesture?.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reset),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    private func shouldSkip(_ gesture: UITapGestureRecognizer) -> Bool {
        let view = gesture.view
        let loc = gesture.location(in: view)
        let subview = view?.hitTest(loc, with: nil) // note: it is a `UIView?`
        return subview?.nativeID == "pinchZoomTapSkippable"
    }
    @objc
    private func doubleTapped(_ gesture: UITapGestureRecognizer) {
        if shouldSkip(gesture) { return }
        onPanDoubleTap?()
    }

    @objc
    private func oneTapped(_ gesture: UITapGestureRecognizer) {
        if shouldSkip(gesture) { return }
        onPanTap?()
    }

    /// Perform the pinch to zoom if needed.
    ///
    /// - Parameter sender: UIPinchGestureRecognizer
    @objc
    private func imagePinched(_ pinch: UIPinchGestureRecognizer) {
        if !isEnableZoom { return }
        if pinch.state == .began {
            _onPinchStart?()
            parentScrollView.forEach { $0.value?.isScrollEnabled = false }
            beginSourceViewFrame = sourceView!.frame
            isZooming = true
            UIApplication.shared.getKeyWindow()?.addSubview(getBackgroundView())
            delegate?.zoomableViewDidZoom(self)
        }
        if pinch.state == .changed, pinch.scale >= 1.0 {
            scale = min(pinch.scale * scaleRate, 3)
            transform(withTranslation: .zero)
        }
        if pinch.state == .ended || pinch.state == .cancelled {
            reset()
        }
    }

    /// Perform the panning if needed
    @objc private func imagePanned(_ pan: UIPanGestureRecognizer) {
        if !isEnableZoom { return }
        if scale > 1.0 {
            transform(withTranslation: pan.translation(in: self))
        }
    }

    /// Set the image back to it's initial state.
    @objc func reset() {
        scale = 1.0
        parentScrollView.forEach { $0.value?.isScrollEnabled = true }
        self.backgroundView?.backgroundColor = .clear
        UIView.animate(
            withDuration: 0.35,
            animations: {
                self.sourceView?.transform = .identity
            },
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.backgroundView?.removeFromSuperview()
                self.backgroundView = nil
                if let zoomableSourceView = self.sourceView {
                    self.addSubview(zoomableSourceView)
                    if let frame = self.beginSourceViewFrame {
                        zoomableSourceView.frame = frame
                    }
                    self.beginSourceViewFrame = nil
                }
                self.isZooming = false
                _onPinchEnd?()
                self.delegate?.zoomableViewEndZoom(self)
            })
    }

    /// Will transform the image with the appropriate
    private func transform(withTranslation translation: CGPoint) {
        var transform = CATransform3DIdentity
        transform = CATransform3DScale(transform, scale, scale, 1.0)
        transform = CATransform3DTranslate(transform, translation.x * 0.8, translation.y * 0.8, 0)
        sourceView?.layer.transform = transform
    }

    deinit {
        parentScrollView.removeAll()
    }
}

extension ZoomableView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UIApplication {
    func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.keyWindow
    }
}
