//
//  FeedItem.swift
//  QWListKit_Example
//
//  Created by guawaji on 2019/12/12.
//  Copyright © 2019 guawaji. All rights reserved.
//

import Foundation

final class FeedItem {
    
    enum ItemType {
        case type1
        case type2
    }
    
    let type: ItemType
    
    let title: String
        
    init(type: ItemType, title: String) {
        self.type = type
        self.title = title
        
        layout()
    }
    
    var cachedSize: CGSize = .zero
    
    var isExpanded: Bool = false
}

extension FeedItem: QWListItem {
    
    func viewClass() -> QWListBindable.Type {
        switch type {
        case .type1:
            return LabelCell.self
        case .type2:
            return ImageCell.self
        }
    }
    
    func viewReuseIdentifier() -> String {
        return "\(viewClass())"
    }
    
    func viewSize() -> CGSize {
        return cachedSize
    }
    
    func viewModel() -> Any {
        return self
    }
    
    func layout() {
        
        let width = UIScreen.main.bounds.width
        
        if self.viewClass() == LabelCell.self {
            cachedSize = isExpanded ? CGSize(width: width, height: LabelCell.textHeight(title, width: width)) : CGSize(width: width, height: LabelCell.singleLineHeight)
        } else if self.viewClass() == ImageCell.self {
            cachedSize = CGSize(width: width, height: 90)
        }
    }
}
