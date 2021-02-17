//
//  TableSectionIndexView.swift
//  TableSectionIndexDemo
//
//  Created by superyang on 2021/2/16.
//

#if canImport(UIKit)
import UIKit
#endif


//MARK: - TableSectionIndexViewDataSource
 public protocol TableSectionIndexViewDataSource: NSObjectProtocol {
     func numberOfScetions(in sectionIndexView: TableSectionIndexView) -> Int
     func sectionIndexView(_ sectionIndexView: TableSectionIndexView, itemAt section: Int) -> TableSectionIndexViewItem
}

//MARK: - TableSectionIndexViewDelegate
 public protocol TableSectionIndexViewDelegate: NSObjectProtocol {
     func sectionIndexView(_ sectionIndexView: TableSectionIndexView, didSelect section: Int)
     func sectionIndexViewToucheEnded(_ sectionIndexView: TableSectionIndexView)
}


//MARK: - TableSectionIndexView
public class TableSectionIndexView: UIView {

     public weak var dataSource: TableSectionIndexViewDataSource? { didSet { reloadData() } }
     public weak var delegate: TableSectionIndexViewDelegate?
    
     public var isItemIndicatorAlwaysInCenterY = false
     public var itemIndicatorHorizontalOffset: CGFloat = -20
    
     public private(set) var selectedItem: TableSectionIndexViewItem?
     public private(set) var isTouching = false
    
    @available(iOS 10.0, *)
    private lazy var generator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator.init(style: .light)
    }()
        
    private var items = [TableSectionIndexViewItem]()
            
    // MARK: - Func
    
    @objc public func reloadData() {
        for item in items {
            item.removeFromSuperview()
            item.indicator?.removeFromSuperview()
        }
        items.removeAll()
        loadView()
    }
    
    @objc public func item(at section: Int) -> TableSectionIndexViewItem? {
        guard section >= 0, section < items.count else { return nil }
        return items[section]
    }
    
    @objc public func impact() {
        guard #available(iOS 10.0, *) else { return }
        generator.prepare()
        generator.impactOccurred()
    }
    
    @objc public func selectItem(at section: Int) {
        guard let item = item(at: section) else { return }
        item.isSelected = true
        selectedItem = item
    }
    
    @objc public func deselectCurrentItem() {
        selectedItem?.isSelected = false
        selectedItem = nil
    }
    
    @objc public func showCurrentItemIndicator() {
        guard let selectedItem = selectedItem, let indicator = selectedItem.indicator else { return }
        guard indicator.superview != nil else {
            let x = -(indicator.bounds.width * 0.5) + itemIndicatorHorizontalOffset
            let y = isItemIndicatorAlwaysInCenterY ? (bounds.height - selectedItem.bounds.height) * 0.5 : selectedItem.center.y
            indicator.center = CGPoint.init(x: x, y: y)
            addSubview(indicator)
            return
        }
        indicator.alpha = 1
    }
    
    @objc public func hideCurrentItemIndicator() {
        guard let indicator = self.selectedItem?.indicator else { return }
        indicator.alpha = 0
    }
    
    private func loadView() {
        guard let dataSource = self.dataSource  else { return }
        let numberOfItems = dataSource.numberOfScetions(in: self)
        items = Array(0..<numberOfItems).compactMap { dataSource.sectionIndexView(self, itemAt: $0)}
        setItemsLayoutConstraint()
    }
     
    private func setItemsLayoutConstraint() {
        guard !items.isEmpty else { return }
        let heightMultiplier = CGFloat(1) / CGFloat(items.count)
        for (i, item) in items.enumerated() {
            item.translatesAutoresizingMaskIntoConstraints = false
            addSubview(item)
            let constraints = [
                item.leadingAnchor.constraint(equalTo: leadingAnchor),
                item.trailingAnchor.constraint(equalTo: trailingAnchor),
                item.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightMultiplier),
                item.topAnchor.constraint(equalTo: i == 0 ? topAnchor : items[i - 1].bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    
    // MARK: -  Touches handle
    private func point(_ point: CGPoint, isIn view: UIView) -> Bool {
        return point.y <= (view.frame.origin.y + view.frame.size.height) && point.y >= view.frame.origin.y
    }
    
    private func getSectionBy(_ touches: Set<UITouch>) -> Int? {
        guard let touch = touches.first else { return nil }
        let p = touch.location(in: self)
        return items.enumerated().filter { point(p, isIn: $0.element) }.compactMap { $0.offset }.first
    }
    
    private func touchesOccurred(_ touches: Set<UITouch>) {
        isTouching = true
        guard let section = getSectionBy(touches) else { return }
        guard let item = item(at: section), !(self.selectedItem?.isEqual(item) ?? false) else { return }
        delegate?.sectionIndexView(self, didSelect: section)
        NotificationCenter.default.post(name: TableSectionIndexView.touchesEndedNotification, object: self, userInfo: ["section": section])
    }
    
    private func touchesEnded() {
        delegate?.sectionIndexViewToucheEnded(self)
        NotificationCenter.default.post(name: TableSectionIndexView.touchesEndedNotification, object: self)
        isTouching = false
    }
    
    
    // MARK: - UIView TouchesEvent
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesOccurred(touches)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesOccurred(touches)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded()
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded()
    }
}

extension TableSectionIndexView {
    public static let touchesOccurredNotification = Notification.Name.init("SectionIndexViewTouchesOccurredNotification")
    public static let touchesEndedNotification = Notification.Name.init("SectionIndexViewTouchesEndedNotification")
}
