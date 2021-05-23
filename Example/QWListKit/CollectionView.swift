//
//  CollectionView.swift
//  App
//
//  Created by dopemax on 2020/12/4.
//  Copyright © 2020 dopemax. All rights reserved.
//

import UIKit
import QWListKit

public class CollectionView: UICollectionView {

    public var sections: [QWListSection] = []
    
    public var emptyView: UIView?
    
    public lazy var adapter: QWCollectionViewAdapter = QWCollectionViewAdapter(collectionView: self)
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .clear
        
        adapter.dataSource = self
    }

}

extension CollectionView: QWCollectionViewAdapterDataSource {
    
    public func sections(for adapter: QWCollectionViewAdapter) -> [QWListSection] {
        return sections
    }
    
    public func emptyView(for adapter: QWCollectionViewAdapter) -> UIView? {
        return emptyView
    }
    
}
