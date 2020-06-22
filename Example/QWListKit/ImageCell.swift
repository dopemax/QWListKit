//
//  ImageCell.swift
//  QWListKit_Example
//
//  Created by guawaji on 2019/12/12.
//  Copyright © 2019 guawaji. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    
    fileprivate let marginVertical: CGFloat = 12.0
    fileprivate let padding: CGFloat = 15.0

    fileprivate lazy var avatarView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        self.contentView.addSubview(view)
        return view
    }()

    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 17)
        label.textColor = .lightGray
        self.contentView.addSubview(label)
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = contentView.bounds.insetBy(dx: padding, dy: 0)
        let avatarWidth = frame.height - marginVertical * 2
        avatarView.frame = CGRect(x: padding,
                                  y: marginVertical,
                                  width: avatarWidth,
                                  height: avatarWidth)
        titleLabel.frame = CGRect(x: avatarView.frame.maxX + padding,
                                  y: avatarView.frame.minY,
                                  width: frame.width - avatarWidth - padding,
                                  height: avatarWidth)
    }

}

extension ImageCell: QWListBindable {

    func bindItem(_ item: QWListItem) {
        guard let model = item as? FeedItem else { return }
        titleLabel.text = model.title
    }

}
