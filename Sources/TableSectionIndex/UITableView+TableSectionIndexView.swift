//
//  UITableView+TableSectionIndexView.swift
//  TableSectionIndexDemo
//
//  Created by superyang on 2021/2/16.
//

#if canImport(UIKit)
import UIKit
#endif

//MARK: - TableSectionIndexViewConfiguration
public final class TableSectionIndexViewConfiguration: NSObject {
    
    /// Default is 0.
    public var adjustedContentInset: CGFloat = 0
    
    /// Configure the `item` size.
    /// Default is CGSize.init(width: 20, height: 15).
    public var itemSize = CGSize.init(width: 20, height: 15)
    
    /// Configure the` indicator` always in centerY of `SectionIndexView`.
    /// Default is false.
    public var isItemIndicatorAlwaysInCenterY = false
    
    /// Configure the `indicator` horizontal offset.
    /// Default is -20.
    public var itemIndicatorHorizontalOffset: CGFloat = -20
    
    /// Default is UIEdgeInsets.zero.
    public var sectionIndexViewOriginInset = UIEdgeInsets.zero
    
}

//MARK: - UITableView Extension

public extension UITableView {
    
    func sectionIndexView(items: [TableSectionIndexViewItem]) {
        let configuration = TableSectionIndexViewConfiguration.init()
        self.sectionIndexView(items: items, configuration: configuration)
    }
    
    func sectionIndexView(items: [TableSectionIndexViewItem], configuration: TableSectionIndexViewConfiguration) {
        assert(self.superview != nil, "Call this method after setting tableView's superview.")
        self.sectionIndexViewManager = TableSectionIndexViewManager.init(self, items, configuration)
    }
}

private extension UITableView {
    private struct SectionIndexViewAssociationKey {
        static var manager = "SectionIndexViewAssociationKeyManager"
    }
    private var sectionIndexViewManager: TableSectionIndexViewManager? {
        set {
            objc_setAssociatedObject(self, &(SectionIndexViewAssociationKey.manager), newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &(SectionIndexViewAssociationKey.manager)) as? TableSectionIndexViewManager
        }
    }
}


//MARK: - TableSectionIndexViewManager
private class TableSectionIndexViewManager: NSObject, TableSectionIndexViewDelegate, TableSectionIndexViewDataSource {
    private struct KVOKey {
        static var context = "SectionIndexViewManagerKVOContext"
        static var contentOffset = "contentOffset"
    }
    private var isOperated = false
    private weak var tableView: UITableView?
    private let indexView: TableSectionIndexView
    private let items: [TableSectionIndexViewItem]
    private let configuration: TableSectionIndexViewConfiguration
    
    init(_ tableView: UITableView, _ items: [TableSectionIndexViewItem], _ configuration: TableSectionIndexViewConfiguration) {
        self.tableView = tableView
        self.items = items
        self.indexView = TableSectionIndexView.init()
        self.configuration = configuration
        self.indexView.isItemIndicatorAlwaysInCenterY = configuration.isItemIndicatorAlwaysInCenterY
        self.indexView.itemIndicatorHorizontalOffset = configuration.itemIndicatorHorizontalOffset
        super.init()
        
        indexView.delegate = self
        indexView.dataSource = self
        self.setLayoutConstraint()
        tableView.addObserver(self, forKeyPath: KVOKey.contentOffset, options: .new, context: &KVOKey.context)
    }
    
    deinit {
        self.indexView.removeFromSuperview()
        self.tableView?.removeObserver(self, forKeyPath: KVOKey.contentOffset)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &KVOKey.context, keyPath == KVOKey.contentOffset else { return }
        self.tableViewContentOffsetChange()
    }
    
    private func setLayoutConstraint() {
        guard let tableView = self.tableView, let superview = tableView.superview else { return }
        superview.addSubview(self.indexView)
        self.indexView.translatesAutoresizingMaskIntoConstraints = false
        let size = CGSize.init(width: self.configuration.itemSize.width, height: self.configuration.itemSize.height * CGFloat(self.items.count))
        let topOffset = self.configuration.sectionIndexViewOriginInset.bottom - self.configuration.sectionIndexViewOriginInset.top
        let rightOffset = self.configuration.sectionIndexViewOriginInset.right -  self.configuration.sectionIndexViewOriginInset.left
        
        let constraints = [
            self.indexView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: topOffset),
            self.indexView.widthAnchor.constraint(equalToConstant: size.width),
            self.indexView.heightAnchor.constraint(equalToConstant: size.height),
            self.indexView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: rightOffset)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func tableViewContentOffsetChange() {
        guard let tableView = self.tableView, !self.indexView.isTouching else { return }
        guard self.isOperated || tableView.isTracking else { return }
        guard let visible = tableView.indexPathsForVisibleRows else { return }
        guard let start = visible.first?.section, let end = visible.last?.section else { return }
        guard let topSection = (start..<end + 1).filter({ section($0, isVisibleIn: tableView) }).first else { return }
        guard let item = self.indexView.item(at: topSection), item.bounds != .zero  else { return }
        guard !(self.indexView.selectedItem?.isEqual(item) ?? false) else { return }
        self.isOperated = true
        self.indexView.deselectCurrentItem()
        self.indexView.selectItem(at: topSection)
    }
    
    private func section(_ section: Int, isVisibleIn tableView: UITableView) -> Bool {
        let rect = tableView.rect(forSection: section)
        return tableView.contentOffset.y + self.configuration.adjustedContentInset < rect.origin.y + rect.size.height
    }
    
    //MARK: - SectionIndexViewDelegate, SectionIndexViewDataSource
    public func numberOfScetions(in sectionIndexView: TableSectionIndexView) -> Int {
        return self.items.count
    }

    public func sectionIndexView(_ sectionIndexView: TableSectionIndexView, itemAt section: Int) -> TableSectionIndexViewItem {
        return self.items[section]
    }

    public func sectionIndexView(_ sectionIndexView: TableSectionIndexView, didSelect section: Int) {
        guard let tableView = self.tableView, tableView.numberOfSections > section else { return }
        sectionIndexView.hideCurrentItemIndicator()
        sectionIndexView.deselectCurrentItem()
        sectionIndexView.selectItem(at: section)
        sectionIndexView.showCurrentItemIndicator()
        sectionIndexView.impact()
        self.isOperated = true
        tableView.panGestureRecognizer.isEnabled = false
        if tableView.numberOfRows(inSection: section) > 0 {
            tableView.scrollToRow(at: IndexPath.init(row: 0, section: section), at: .top, animated: false)
        } else {
            tableView.scrollRectToVisible(tableView.rect(forSection: section), animated: false)
        }
    }
    
    public func sectionIndexViewToucheEnded(_ sectionIndexView: TableSectionIndexView) {
        UIView.animate(withDuration: 0.3) {
            sectionIndexView.hideCurrentItemIndicator()
        }
        self.tableView?.panGestureRecognizer.isEnabled = true
    }
}
