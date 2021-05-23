//
//  LabelCell.swift
//  QWListKit_Example
//
//  Created by dopemax on 2019/12/12.
//  Copyright © 2019 dopemax. All rights reserved.
//

import UIKit

class LabelCell: UITableViewCell {
    
    static let insets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    static let font = UIFont.systemFont(ofSize: 17)

    static var singleLineHeight: CGFloat {
        return font.lineHeight + insets.top + insets.bottom
    }

    static func textHeight(_ text: String, width: CGFloat) -> CGFloat {
        let constrainedSize = CGSize(width: width - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: font]
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (text as NSString).boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
        return ceil(bounds.height) + insets.top + insets.bottom
    }
    
    fileprivate lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        self.contentView.addSubview(label)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds.inset(by: LabelCell.insets)
    }

}

extension LabelCell: QWListBindable {

    func bindItem(_ item: QWListItem) {
        guard let item = item as? FeedItem else { return }
        label.text = item.model.title
        label.numberOfLines = item.isExpanded ? 0 : 1
    }

}
