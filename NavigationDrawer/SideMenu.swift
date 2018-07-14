//
//  NavigationDrawerMenu.swift
//  NavigationDrawer
//
//  Created by siva prasad on 14/07/18.
//  Copyright © 2018 SIVA PRASAD. All rights reserved.
//


import UIKit

open class NavigationDrawerController: UIViewController, UIGestureRecognizerDelegate {
    
    private var menuLeftConst: NSLayoutConstraint!
    private var containerLeftConst: NSLayoutConstraint!
    private var sideMenu = UIView()
    private var NavigationDrawerMenuShadowView = UIView()
    private var containerView = UIView()
    private var myView = UIView()
    
    private var isMenuOpened: Bool = false
    
    private var screenEdgeRecognizer : UIScreenEdgePanGestureRecognizer!
    private var swipeRecognizer: UIPanGestureRecognizer!
    private var firstLocationX: CGFloat!
    
    private var isStatusBarHidden = false
    
    public var animationDuration: Double = 0.3
    public var roundCorners: Bool = true
    public var roundCornersValue: Double = 8
    public var shadowVisible: Bool = true
    public var rootViewAnimation: RootViewAnimationType = .scale
    public var menuPosition: NavigationDrawerPosition = .front
    public var openSwipeEnabled: Bool = true
    public var closeSwipeEnabled: Bool = true
    
    public var animateStatusBar: Bool = true {
        didSet {
            if animateStatusBar {
                overlapStatusBar = false
            }
        }
    }
    public var overlapStatusBar: Bool = false {
        didSet {
            if animateStatusBar {
                overlapStatusBar = false
            }
        }
    }
    
    public var rootViewBackgroundColor: UIColor = .white {
        didSet {
            myView.backgroundColor = rootViewBackgroundColor
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Change RootView
        myView = UIView()
        myView.frame = view.frame
        containerView = self.view
        self.view = myView
        self.view.clipsToBounds = true
        self.view.addSubview(containerView)
    }
    
    public func setNavigationDrawer(ViewController vc: UIViewController) {
        self.addChildViewController(vc)
        sideMenu = vc.view
        sideMenu.clipsToBounds = true
        
        NavigationDrawerMenuShadowView.backgroundColor = .black
        NavigationDrawerMenuShadowView.alpha = 0
        NavigationDrawerMenuShadowView.isHidden = true
        
        sideMenu.translatesAutoresizingMaskIntoConstraints = false
        NavigationDrawerMenuShadowView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(NavigationDrawerMenuShadowView)
        self.view.addSubview(sideMenu)
        
        if menuPosition == .front {
            self.view.bringSubview(toFront: sideMenu)
        } else {
            self.view.bringSubview(toFront: containerView)
            self.view.bringSubview(toFront: NavigationDrawerMenuShadowView)
        }
        
        NavigationDrawerControllerConstraints()
        NavigationDrawerOptions()
        
        //setup recognizers
        let tap = UITapGestureRecognizer(target: self, action:#selector(handleBlurTap))
        NavigationDrawerMenuShadowView.addGestureRecognizer(tap)
        
        if openSwipeEnabled {
            screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.openMenuFromSwipe))
            screenEdgeRecognizer.edges = .left
            screenEdgeRecognizer.delegate = self
            self.view.addGestureRecognizer(screenEdgeRecognizer)
        }
        
        if closeSwipeEnabled {
            swipeRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.closeMenuFromSwipe))
            swipeRecognizer.delegate = self
            self.view.addGestureRecognizer(swipeRecognizer)
        }
    }
    
    public func openMenu() {
        showMenu(canShow: true, duration: animationDuration)
    }
    
    public func closeMenu() {
        showMenu(canShow: false, duration: animationDuration)
    }
    
    func NavigationDrawerOptions() {
        if shadowVisible {
            if menuPosition == .front {
                NavigationDrawerShadowGenericSetting(layerObj: sideMenu.layer, opacity: 0.5)
            } else {
                NavigationDrawerShadowGenericSetting(layerObj: containerView.layer, opacity: 0.5)
            }
        }
        
        if roundCorners {
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: sideMenu.bounds, byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: roundCornersValue, height: roundCornersValue)).cgPath
            sideMenu.layer.mask = maskLayer
        }
    }
    
    //MARK: Constraints
    func NavigationDrawerControllerConstraints() {
        //Shadow constraints
        self.view.addConstraint(NSLayoutConstraint(item: NavigationDrawerMenuShadowView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: NavigationDrawerMenuShadowView, attribute: .centerX, relatedBy: .equal, toItem: ((menuPosition == .front) ? self.view : self.containerView), attribute: .centerX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: NavigationDrawerMenuShadowView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .top, multiplier: 1.0, constant: (overlapStatusBar) ? -20 : 0))
        self.view.addConstraint(NSLayoutConstraint(item: NavigationDrawerMenuShadowView, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        //Menu constraints
        self.view.addConstraint(NSLayoutConstraint(item: sideMenu, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.width*0.8))
        self.view.addConstraint(NSLayoutConstraint(item: sideMenu, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .top, multiplier: 1.0, constant: (overlapStatusBar) ? -20 : 0))
        self.view.addConstraint(NSLayoutConstraint(item: sideMenu, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        menuLeftConst = NSLayoutConstraint(item: sideMenu, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: (menuPosition == .front) ? -self.view.frame.width*0.8 : 0)
        self.view.addConstraint(menuLeftConst)
        
        //Container constraints
        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        containerLeftConst = NSLayoutConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0)
        self.view.addConstraint(containerLeftConst)
        
        self.view.layoutIfNeeded()
    }
    
    
    //MARK: Menu Interaction Swift
    func showMenu(canShow: Bool, duration: Double) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.showStatusBar(canShow: !canShow)
        
        if menuPosition == .front {
            menuLeftConst.constant = (canShow) ? 0 : -sideMenu.frame.width
        }else {
            containerLeftConst.constant = (canShow) ? sideMenu.frame.width : 0
        }
        
        let alpha : CGFloat = (canShow) ? 0.6 : 0
        self.NavigationDrawerMenuShadowView.isHidden = false
        
        UIView.animate(withDuration: duration, animations: {
            self.NavigationDrawerMenuShadowView.alpha = alpha
            self.animateRootView(percentage: (canShow) ? 1 : 0, all: false)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.sideMenu.isHidden = false
            self.NavigationDrawerMenuShadowView.isHidden = !canShow
            self.isMenuOpened = canShow
            UIApplication.shared.endIgnoringInteractionEvents()
        })
        
        animateRootViewFrom(canShow: canShow)
    }
    
    @objc func handleBlurTap() {
        showMenu(canShow: false, duration: animationDuration)
    }
    
    //Open Menu
    @objc func openMenuFromSwipe() {
        if isMenuOpened {
            return
        }
        
        switch screenEdgeRecognizer.state.rawValue {
        case 1:
            firstLocationX = screenEdgeRecognizer.location(in: self.view).x
            NavigationDrawerMenuShadowView.isHidden = false
            showStatusBar(canShow: false)
            break
        case 2:
            let offsetX = screenEdgeRecognizer.location(in: self.view).x - firstLocationX
            checkOpenMenuOrContainer(offsetX: offsetX)
            break
        case 3,4:
            if menuPosition == .front {
                showMenu(canShow: (menuLeftConst.constant > -sideMenu.frame.width+80) ? true : false, duration: animationDuration - Double((sideMenu.frame.width+menuLeftConst.constant)/sideMenu.frame.width) * animationDuration)
            } else {
                showMenu(canShow: (containerLeftConst.constant > 80) ? true : false, duration: Double((sideMenu.frame.width-containerLeftConst.constant)/sideMenu.frame.width) * animationDuration)
            }
            break
        default:
            print("default")
        }
    }
    
    func checkOpenMenuOrContainer(offsetX: CGFloat) {
        if offsetX > sideMenu.frame.width {
            if menuPosition == .front {
                menuLeftConst.constant = 0
                self.NavigationDrawerMenuShadowView.alpha = 0.6
            } else {
                containerLeftConst.constant = sideMenu.frame.width
            }
        } else {
            let percentage = offsetX/sideMenu.frame.width
            self.NavigationDrawerMenuShadowView.alpha = percentage*0.6
            
            if menuPosition == .front {
                menuLeftConst.constant = -sideMenu.frame.width+offsetX
                animateRootView(percentage: percentage, all: true)
            } else {
                containerLeftConst.constant = offsetX
                if containerLeftConst.constant < 0 {
                    containerLeftConst.constant = 0
                }
                self.view.setNeedsLayout()
            }
        }
        self.view.layoutIfNeeded()
    }
    
    //Close Menu
    @objc func closeMenuFromSwipe() {
        if !isMenuOpened {
            return
        }
        
        switch swipeRecognizer.state.rawValue {
        case 1:
            firstLocationX = swipeRecognizer.location(in: self.view).x
            NavigationDrawerMenuShadowView.isHidden = false
            break
        case 2:
            if firstLocationX < sideMenu.frame.width - 80 {
                return
            }
            let offsetX = swipeRecognizer.location(in: self.view).x - firstLocationX
            checkCloseMenuOrContainer(offsetX: offsetX)
            break
        case 3,4:
            if menuPosition == .front {
                showMenu(canShow: (menuLeftConst.constant > -80) ? true : false, duration: Double((sideMenu.frame.width+menuLeftConst.constant)/sideMenu.frame.width) * animationDuration)
            } else {
                showMenu(canShow: (containerLeftConst.constant > sideMenu.frame.width-80) ? true : false, duration: Double(containerLeftConst.constant/sideMenu.frame.width) * animationDuration)
            }
            break
        default:
            print("default")
        }
    }
    
    func checkCloseMenuOrContainer(offsetX: CGFloat) {
        if offsetX > 0 {
            if menuPosition == .front {
                menuLeftConst.constant = 0
                self.NavigationDrawerMenuShadowView.alpha = 0.6
            } else {
                containerLeftConst.constant = self.sideMenu.frame.width
            }
        } else {
            let percentage = -offsetX/sideMenu.frame.width
            self.NavigationDrawerMenuShadowView.alpha = 0.6 - percentage*0.6
            
            if menuPosition == .front {
                menuLeftConst.constant = offsetX
                animateRootView(percentage: 1-percentage, all: true)
            } else {
                containerLeftConst.constant = self.sideMenu.frame.width + offsetX
                if containerLeftConst.constant < 0 {
                    containerLeftConst.constant = 0
                }
                self.view.setNeedsLayout()
            }
        }
        self.view.layoutIfNeeded()
    }
    
    //MARK: Animate Root View
    func animateRootView(percentage: CGFloat, all: Bool) {
        switch rootViewAnimation {
        case .scale:
            let scale = 0.02*percentage
            self.containerView.transform = CGAffineTransform(scaleX: 1-scale, y: 1-scale)
            self.containerView.frame.origin = CGPoint(x: -2*percentage, y: self.containerView.frame.origin.y)
            if all {
                self.containerView.layer.cornerRadius = 8*percentage
            }
        case .none: break
        }
    }
    
    func animateRootViewFrom(canShow: Bool) {
        if rootViewAnimation == .scale {
            let animation = CABasicAnimation(keyPath: "cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.fromValue = self.containerView.layer.cornerRadius
            animation.toValue = (canShow) ? 8 : 0
            animation.duration = 0.3
            self.containerView.layer.add(animation, forKey: "cornerRadius")
            self.containerView.layer.cornerRadius = (canShow) ? 8 : 0
        }
    }
    
    
    //MARK: Gesture Delegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if screenEdgeRecognizer != nil && screenEdgeRecognizer.state.rawValue >= 0 && screenEdgeRecognizer.state.rawValue <= 3 && gestureRecognizer != screenEdgeRecognizer {
            return false
        }
        if !isMenuOpened && gestureRecognizer == swipeRecognizer {
            return false
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == screenEdgeRecognizer {
            return true
        }
        return false
    }
    
    
    //MARK: Shadow
    func NavigationDrawerShadowGenericSetting(layerObj: CALayer , opacity :Float) {
        layerObj.masksToBounds = false
        layerObj.shouldRasterize = false
        layerObj.shadowOpacity = opacity
        layerObj.shadowRadius = 1.5
        layerObj.shadowColor = UIColor.black.cgColor
        layerObj.shadowOffset = CGSize(width: 0.0, height: 1.5)
    }
    
    
    //MARK: StatusBar Appearance
    func showStatusBar(canShow: Bool) {
        guard animateStatusBar else {
            return
        }
        isStatusBarHidden = !canShow
        UIView.animate(withDuration: animationDuration, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    override open var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    
    //MARK: Detect Rotation
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if !isMenuOpened {
            sideMenu.isHidden = true
        }
        self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.containerView.frame = myView.frame
        
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.showMenu(canShow: false, duration: self.animationDuration)
        })
    }
    
}

public enum RootViewAnimationType {
    case none
    case scale
}

public enum NavigationDrawerPosition {
    case front
    case behind
}
