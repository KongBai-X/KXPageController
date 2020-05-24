//
//  KXPageController.swift
//  KXPageController
//
//  Created by KongBai.X on 2020/5/17.
//  Copyright © 2020 KongBai.X. All rights reserved.
//

import UIKit

// MARK: KXPageDelegate 协议
public protocol KXPageDelegate: class {
    /// 获取当前页面显示的控制器视图左边(上边)的视图控制器
    func pageControllerDidLoadLeftController(_ currentController: UIViewController) -> UIViewController?
    /// 获取当前页面显示的控制器视图右边(下边)的视图控制器
    func pageControllerDidLoadRightController(_ currentController: UIViewController) -> UIViewController?
    /// 滑动监听
    func pageControllerDidScroll(_ currentController: UIViewController, _ offset: CGFloat)
    /// 用户即将drag时的事件回调
    func pageControllerWillDrag(_ currentController: UIViewController)
    /// 用户结束drag的事件回调
    func pageControllerDidEndDrag(_ currentController: UIViewController)
}
public extension KXPageDelegate {
    /// 滑动监听
    func pageControllerDidScroll(_ currentController: UIViewController, _ offset: CGFloat) {}
    /// 用户即将drag时的事件回调
    func pageControllerWillDrag(_ currentController: UIViewController) {}
    /// 用户结束drag的事件回调
    func pageControllerDidEndDrag(_ currentController: UIViewController) {}
}

/// 分页控制器
@available(iOS 9.0, *)
public class KXPageController: UIViewController {
    /// 滑动方向
    public enum Direction {
        /// 水平方向
        case horizontal
        /// 竖直方向
        case vertical
    }
    /// 滑动出现位置
    public enum Position: CGFloat {
        /// 从左边开始出现
        case left = 0.0
        /// 中间出现
        case center = 1.0
        /// 从右边开始出现
        case right = 2.0
    }
    /// 最大显示数量，3个
    private let pageCount: CGFloat = 3.0
    /// 自定义分页内容
    private class Content {
        /// 被显示的控制器
        public var controller: UIViewController
        /// 控制器视图布局集合
        public var layoutConstraints: [NSLayoutConstraint] = []
        /// 分页处理布局
        public var pageConstraint: NSLayoutConstraint!
        /// 初始化
        public init(_ controller: UIViewController) {
            self.controller = controller
            controller.view.translatesAutoresizingMaskIntoConstraints = false
        }
        /// 添加到视图上
        public func addTo(_ superview: UIView, _ direction: KXPageController.Direction) {
            superview.addSubview(controller.view)
            layoutConstraints = [
                controller.view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                controller.view.topAnchor.constraint(equalTo: superview.topAnchor),
                controller.view.widthAnchor.constraint(equalTo: superview.widthAnchor),
                controller.view.heightAnchor.constraint(equalTo: superview.heightAnchor)
            ]
            pageConstraint = layoutConstraints.first(where: { direction == .horizontal ? $0.firstAttribute == .leading : $0.firstAttribute == .top })
        }
        /// 激活约束
        public func activate() {
            NSLayoutConstraint.activate(layoutConstraints)
            guard let superview = controller.view.superview else { return }
            superview.layoutIfNeeded()
        }
        /// 销毁
        deinit {
            NSLayoutConstraint.deactivate(layoutConstraints)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }
    }

    /// 展示分页视图的滑动视图
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = true
        if #available(iOS 13.0, *) {
            scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        return scrollView
    }()
    /// 是否有回弹效果，默认有
    public var bounces: Bool {
        set { scrollView.bounces = newValue }
        get { scrollView.bounces }
    }
    /// 滑动方向
    public var direction: Direction = .horizontal
    /// 当前内容
    private var current: Content? {
        didSet { scrollView.isScrollEnabled = current != nil }
    }
    /// 缓存内容
    private var cachedContens: [Position : Content] = [:]
    
    /// 创建控制器视图
    public override func loadView() {
        view = UIView()
    }
    /// 内容设置
    public override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    /// 内存警告处理
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    /// 布局处理
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 设置容器大小
        let size = scrollSize
        scrollView.contentSize = CGSize(width: size.width * pageCount, height: size.height * pageCount)
        if let current = current {
            current.pageConstraint.constant = scrollWidth
        }
        // 修复旋转导致错位问题
        scrollTo(.center)
    }
    
    /// 偏移量
    private var contentOffset: CGFloat {
        direction == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
    }
    /// 滑动大小
    private var scrollWidth: CGFloat {
        direction == .horizontal ? scrollView.bounds.width : scrollView.bounds.height
    }
    /// 滑动大小
    private var scrollSize: CGSize {
        direction == .horizontal ? CGSize(width: scrollView.bounds.width, height: .zero) : CGSize(width: .zero, height: scrollView.bounds.height)
    }
    /// 滑动到指定位置
    private func scrollTo(_ position: Position,
                          offset: CGFloat = .zero,
                          animated: Bool = false) {
        let finalOffset: CGFloat = scrollWidth * position.rawValue + offset
        if direction == .horizontal {
            scrollView.setContentOffset(CGPoint(x: finalOffset, y: .zero), animated: animated)
        } else {
            scrollView.setContentOffset(CGPoint(x: .zero, y: finalOffset), animated: animated)
        }
    }
    /// 移除缓存的视图控制器
    private func removeCache(_ position: Position? = nil) {
        guard let position = position else { cachedContens.removeAll(); return }
        cachedContens.removeValue(forKey: position)
    }
    
    /// 代理
    public weak var delegate: KXPageDelegate?
    /// 当前显示的内容控制器
    public var currentController: UIViewController? { current?.controller }
    /// 设置当前显示的视图控制器
    /// position: 滑动出现位置
    /// animated: 是否通过动画方式展示
    public func setController(_ controller: UIViewController,
                              position: Position = .center,
                              animated: Bool = false) {
        // 避免重复显示
        if let current = current {
            guard current.controller != controller else { return }
        }
        removeCache()
        loadController(controller, position)
        scrollTo(position, animated: animated)
    }
    
    ///加载指定位置的视图控制器
    /// - controller:  将要加载的视图控制器
    /// - position:  控制器位置
    private func loadController(_ controller: UIViewController, _ position: Position) {
        addChild(controller)
        let content = Content(controller)
        content.addTo(scrollView, direction)
        content.pageConstraint.constant = scrollWidth * position.rawValue
        content.activate()
        if position == .center {
            current = content
        } else {
            cachedContens[position] = content
        }
    }
    /// 更新当前内容布局
    /// - 参数: position 位置
    /// - 参数: constant 偏移常量
    private func updateCurrentContentLayout(_ position: Position) {
        guard let current = current else { return }
        current.pageConstraint.constant = scrollWidth * position.rawValue
        scrollView.layoutIfNeeded()
    }
    /// 请求新内容
    /// - position: 新内容位置，left | right
    private func requsetNewContentIfNeeded(_ position: Position) {
        guard let current = current,
              let delegate = delegate,
              position != .center,
              cachedContens[position] == nil else { return }
        guard let controller = { () -> UIViewController? in
            if position == .left { return delegate.pageControllerDidLoadLeftController(current.controller) }
            return delegate.pageControllerDidLoadRightController(current.controller)
        }() else {
            if bounces {
                guard Position(rawValue: current.pageConstraint.constant / scrollWidth) == .center else { return }
                updateCurrentContentLayout(position)
                scrollTo(position)
            } else {
                scrollTo(.center)
            }
            return
        }
        loadController(controller, position)
    }
    /// 更新当前内容
    /// - offset: 相对中心内容偏移量
    private func replaceCurrent(_ offset: CGFloat = .zero) {
        let position: Position = {
            if contentOffset >= scrollWidth * Position.right.rawValue { return .right }
            if contentOffset <= scrollWidth * Position.left.rawValue { return .left }
            return .center
        }()
        if position == .center {
            removeCache()
            return
        }
        guard let cachedContent = cachedContens[position] else { return }
        current = cachedContent
        updateCurrentContentLayout(.center)
        scrollTo(.center, offset: offset)
        removeCache()
    }
}
//MARK: UIScrollViewDelegate 协议
extension KXPageController: UIScrollViewDelegate {
    /// 滑动处理
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentSize != .zero,
            let current = current,
            let delegate = delegate else { return }
        let newContentPosition: Position = {
            if contentOffset > scrollWidth { return .right }
            if contentOffset < scrollWidth { return .left }
            return .center
        }()
        // 请求新内容
        if newContentPosition != .center {
            requsetNewContentIfNeeded(newContentPosition)
        }
        // 替换当前内容
        if contentOffset >= scrollWidth * Position.right.rawValue {
            replaceCurrent(contentOffset - scrollWidth * Position.right.rawValue)
        } else if contentOffset <= scrollWidth * Position.left.rawValue {
            replaceCurrent(contentOffset)
        } else if contentOffset == scrollWidth * Position.center.rawValue {
            replaceCurrent()
        }
        delegate.pageControllerDidScroll(current.controller, contentOffset - scrollWidth)
    }
    /// 结束滑动动画
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
    /// 结束滑动加速
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !scrollView.isDragging && !scrollView.isDecelerating else { return }
        scrollViewDidScroll(scrollView)
        guard let current = current,
              Position(rawValue: current.pageConstraint.constant / scrollWidth) != .center else { return }
        updateCurrentContentLayout(.center)
        scrollTo(.center)
    }
    /// 用户开始Drag
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let current = current, let delegate = delegate else { return }
        delegate.pageControllerWillDrag(current.controller)
    }
    /// 用户结束Drag
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let current = current, let delegate = delegate else { return }
        delegate.pageControllerDidEndDrag(current.controller)
    }
}
