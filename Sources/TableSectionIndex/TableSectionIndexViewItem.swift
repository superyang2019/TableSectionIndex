//
//  TableSectionIndexViewItem.swift
//  TableSectionIndexDemo
//
//  Created by superyang on 2021/2/16.
//

#if canImport(UIKit)
import UIKit
#endif


//MARK: - TableSectionIndexViewItem
@objc public protocol TableSectionIndexViewItem where Self: UIView {
    
    var isSelected: Bool { get set }
    
    var indicator: UIView? { get set }
}

public class TableSectionIndexViewItemView: UIView, TableSectionIndexViewItem {
    
     public var isSelected: Bool = false {
        didSet {
            self.selectItem(isSelected)
        }
    }
     public var indicator: UIView?
    
     public var image: UIImage? {
        set { imageView.image = newValue }
        get { imageView.image }
    }
     public var selectedImage: UIImage? {
        set { imageView.highlightedImage = newValue }
        get { imageView.highlightedImage }
    }
     public var title: String? {
        set { titleLabel.text = newValue }
        get { titleLabel.text }
    }
     public var titleFont: UIFont {
        set { titleLabel.font = newValue }
        get { titleLabel.font }
    }
     public var titleColor: UIColor {
        set { titleLabel.textColor = newValue }
        get { titleLabel.textColor }
    }
     public var titleSelectedColor: UIColor? {
        set { titleLabel.highlightedTextColor = newValue }
        get { titleLabel.highlightedTextColor }
    }
    
     public var selectedColor: UIColor? {
        set { selectedView.backgroundColor = newValue }
        get { selectedView.backgroundColor }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel.init()
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = #colorLiteral(red: 0.3005631345, green: 0.3005631345, blue: 0.3005631345, alpha: 1)
        label.highlightedTextColor = #colorLiteral(red: 0, green: 0.5291740298, blue: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 10)
        return label
    }()
    
    private let imageView: UIImageView = {
        let v = UIImageView.init()
        v.contentMode = .center
        return v
    }()
    
    private let selectedView: UIView = {
        let v = UIView.init()
        v.backgroundColor = .clear
        v.isHidden = true
        return v
    }()
    
    public required init() {
        super.init(frame: .zero)
        addSubview(selectedView)
        addSubview(imageView)
        addSubview(titleLabel)
        setLayoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayoutConstraint() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.heightAnchor.constraint(equalTo: titleLabel.widthAnchor)
        ])
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            selectedView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            selectedView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            selectedView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        ])
    }
    
    private func selectItem(_ select: Bool) {
        if selectedView.layer.cornerRadius == 0, selectedView.bounds.width > 0 {
            selectedView.layer.cornerRadius = selectedView.bounds.width * 0.5
        }
        titleLabel.isHighlighted = select
        imageView.isHighlighted = select
        selectedView.isHidden = !select
    }
}
