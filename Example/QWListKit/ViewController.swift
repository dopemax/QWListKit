//
//  ViewController.swift
//  QWListKit
//
//  Created by guawaji on 12/06/2019.
//  Copyright (c) 2019 guawaji. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let titles: [String] = [
        "NSFWObject\nSwift, Objective-C runtime.\nOccasionally speaking at conferences, meetups, weddings and bar mitzvahs",
        "Organiser of #HNLondon | Former Director of Talent @Lyst | Currently building Talent Products @Makeshift | Occasionally mentoring @Seedcamp startups on hiring",
        "Follow us to find out about the latest official government news and information. Follow us on www.facebook.com/gvtmonaco",
        "UChicago 2018. CocoaPods. Bundler.",
        "I work on Swift, the pumpkinspice-oriented programming language.",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Demos"
        view.addSubview(tableView)
        
        let count = Int.random(in: 3...20)
        (0..<count).map { $0 }.forEach { (index) in
            let item = FeedItem(type: Bool.random() ? .type1 : .type2, title: titles[index % titles.count])
            demoSection.items.add(item)
        }
        adapter.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        return view
    }()
    
    lazy var adapter: QWTableViewAdapter = {
        let adapter = QWTableViewAdapter(tableView: tableView)
        adapter.didSelectRowBlock = { [unowned self] (tb, indexPath, item) in
            guard let model = item as? FeedItem else { return }
            tb.deselectRow(at: indexPath, animated: true)
            if model.type == .type1 {
                model.isExpanded.toggle()
                model.layout()
                tb.reloadRows(at: [indexPath], with: .automatic)
            } else {
                self.navigationController?.pushViewController(ViewController(), animated: true)
            }
        }
        return adapter
    }()
    
    let demoSection = QWListSection()
    
}

extension ViewController: QWTableViewAdapterDataSource {
    
    func sections(for adapter: QWTableViewAdapter) -> [QWListSection] {
        return [demoSection]
    }
    
    func emptyView(forListAdapter listAdapter: QWTableViewAdapter) -> UIView? {
        return nil
    }
    
}
