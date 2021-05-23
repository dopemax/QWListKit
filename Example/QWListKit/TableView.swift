//
//  TableView.swift
//  App
//
//  Created by dopemax on 2020/12/4.
//  Copyright © 2020 dopemax. All rights reserved.
//

import UIKit
import QWListKit

public class TableView: UITableView {
    
    public var sections: [QWListSection] = []
    
    public var emptyView: UIView?
    
    public lazy var adapter: QWTableViewAdapter = QWTableViewAdapter(tableView: self)
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        tableFooterView = UIView()
        
        adapter.dataSource = self
    }
    
}

extension TableView: QWTableViewAdapterDataSource {
    
    public func sections(for adapter: QWTableViewAdapter) -> [QWListSection] {
        return sections
    }
    
    public func emptyView(for adapter: QWTableViewAdapter) -> UIView? {
        return emptyView
    }
    
}
