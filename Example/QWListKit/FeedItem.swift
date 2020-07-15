//
//  FeedItem.swift
//  QWListKit_Example
//
//  Created by guawaji on 2019/12/12.
//  Copyright © 2019 guawaji. All rights reserved.
//

import Foundation

struct Feed {
    
    enum ItemType {
        case type1
        case type2
    }
    
    let type: ItemType
    
    let title: String
    
}

class FeedItem: QWListItem {
    
    let model: Feed
    
    init(model: Feed) {
        self.model = model
        super.init()
        
        layout()
    }
    
    var height: CGFloat = 0.0
    
    var isExpanded: Bool = false
    
    func layout() {
        
        let width = UIScreen.main.bounds.width
        
        if self.viewClass() == LabelCell.self {
            height = isExpanded ? LabelCell.textHeight(model.title, width: width) : LabelCell.singleLineHeight
        } else if self.viewClass() == ImageCell.self {
            height = 90.0
        }
    }
    
    
    
    override func viewClass() -> QWListBindable.Type {
        switch model.type {
        case .type1:
            return LabelCell.self
        case .type2:
            return ImageCell.self
        }
    }
    
    override func viewReuseIdentifier() -> String {
        return "\(viewClass())"
    }
    
    override func viewSizeBlock() -> (UIScrollView, UIEdgeInsets) -> CGSize {
        return { (listView, sectionInset) in
            return .init(width: listView.bounds.width, height: self.height)
        }
    }
    
}
