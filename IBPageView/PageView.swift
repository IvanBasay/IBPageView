//
//  PageView.swift
//  IBPageView
//
//  Created by Иван Викторович on 14.03.2020.
//  Copyright © 2020 BosaIT. All rights reserved.
//

import UIKit

public class PageView: UIView, ViewControllerInView {
    
    // MARK: - Private Properties
    
    /// List of avilable view controllers
    private var viewControllers: [UIViewController]! {
        didSet {
            // On set new list on default sets first
            guard let firstController = viewControllers.first else {return}
            currentContainerView = createContainerWith(viewController: firstController, state: .current)
        }
    }
    
    /// ContainerView who contains current view controller
    private var currentContainerView: ContainerView?
    
    /// Parent of PageView
    private var initialViewController: UIViewController?
    
    /// Index of current controller in viewControllers list
    private var currentControllerIndex = 0
    
    // MARK: - Public propeties
    
    open weak var delegate: PageViewDelegate?
    
    /// Default its 30
    open var cornerRadius: CGFloat = 30
    /// Default value 0.7, working range (0.3...1)
    open var zoomSize: CGFloat = 0.7 {
        didSet {
            if zoomSize > 1 {
                zoomSize = 1
            } else if zoomSize < 0.3 {
                zoomSize = 0.3
            }
        }
    }
    /// Default 0.5
    open var zoomDuration: CGFloat = 0.5
    /// Default 0.5
    open var scrollDuration: CGFloat = 0.5
    
    // MARK: - Ovverides
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initialViewController = parentViewController
    }
    
    // MARK: - Public functions
    
    /// - Description: Set list of view controllers
    open func setViewControllers(_ viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
    
    /// - Description: Switch current view controller to view controller from 'viewControllers' array by index
    /// - Parameter index: The index of the controller for which you want to change the current
    open func goToViewController(index: Int) {
        if currentControllerIndex > index {
            if index >= 0 {
                DispatchQueue.main.async {
                    let container = self.createContainerWith(viewController: self.viewControllers[index], state: .previus)
                    self.delegate?.currentPageWillChangeOn?(index: index)
                    self.currentContainerView?.zoom(value: self.zoomSize, duration: self.zoomDuration, completion: {
                        self.currentContainerView?.moveOnValue(valueX: self.frame.width, duration: self.scrollDuration) {
                            self.currentContainerView?.removeZoom(animated: false, duration: nil)
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                                self.remove(viewController: self.viewControllers[self.currentControllerIndex])
                                self.currentContainerView?.removeFromSuperview()
                                self.currentContainerView = container
                                self.currentControllerIndex = index
                                self.delegate?.currentPageDidChangeOn?(index: index)
                            }
                        }
                    })
                    container.zoom(value: self.zoomSize, duration: self.zoomDuration) {
                        container.moveOnValue(valueX: self.frame.width, duration: self.scrollDuration) {
                            container.removeZoom(animated: true, duration: self.zoomDuration)
                        }
                    }
                }
            }
        } else if currentControllerIndex < index {
            if index <= viewControllers.count-1 {
                DispatchQueue.main.async {
                    let container = self.createContainerWith(viewController: self.viewControllers[index], state: .next)
                    self.delegate?.currentPageWillChangeOn?(index: index)
                    self.currentContainerView?.zoom(value: self.zoomSize, duration: self.zoomDuration, completion: {
                        self.currentContainerView?.moveOnValue(valueX: -self.frame.width, duration: self.scrollDuration, completion: {
                            self.currentContainerView?.removeZoom(animated: false, duration: nil)
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                                self.remove(viewController: self.viewControllers[self.currentControllerIndex])
                                self.currentContainerView?.removeFromSuperview()
                                self.currentContainerView = container
                                self.currentControllerIndex = index
                                self.delegate?.currentPageDidChangeOn?(index: index)
                            }
                        })
                    })
                    
                    container.zoom(value: self.zoomSize, duration: self.zoomDuration) {
                        container.moveOnValue(valueX: -self.frame.width, duration: self.scrollDuration) {
                            container.removeZoom(animated: true, duration: self.zoomDuration)
                        }
                    }
                }
            }
        } else {return}
    }

    // MARK: - Private functions
    
    /// - Description: Create a ContainerView who contains view controller
    /// - Parameters:
    ///     - viewController: The controller that must be placed in the container&
    ///     - state: It has 3 stages: Next, previous and current. The initial location of the container on the screen depends on it.
    /// - Returns: ContainerView with view controller on it.
    fileprivate func createContainerWith(viewController: UIViewController, state: CreateContainerState) -> ContainerView {
        let view = ContainerView(frame: CGRect(origin: CGPoint.zero, size: self.frame.size))
        
        switch state {
        case .current:
            break
        case .next:
            view.frame.origin.x = self.frame.size.width
        case .previus:
            view.frame.origin.x = -self.frame.size.width
        }
        view.cornerRadius = cornerRadius
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.sizeToFit()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        self.addSubview(view)
        set(viewController: viewController, in: view)
        return view
    }
    
    /// - Description: Add view controller as view on containerView&
    /// - Parameters:
    ///     - viewController: view controller to add on container.
    ///     - view: container view for contains view controller.
    fileprivate func set(viewController: UIViewController, in view: ContainerView) {
        initialViewController?.addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParent: initialViewController)
    }
    
    fileprivate enum CreateContainerState {
        case current
        case next
        case previus
    }
    
    /// - Description: Use for remove view controller from container.
    fileprivate func remove(viewController: UIViewController?) {
        if viewController != nil {
            viewController!.willMove(toParent: nil)
            viewController!.view.removeFromSuperview()
            viewController!.removeFromParent()
        }
    }
}

fileprivate extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// Protocol for manipulate child view controllers
fileprivate protocol ViewControllerInView {
    func set(viewController: UIViewController, in view: ContainerView)
    func remove(viewController: UIViewController?)
}

@objc public protocol PageViewDelegate: class {
    @objc optional func currentPageWillChangeOn(index: Int)
    @objc optional func currentPageDidChangeOn(index: Int)
}
