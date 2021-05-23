//
//  ViewController.swift
//  QWListKit
//
//  Created by dopemax on 12/06/2019.
//  Copyright (c) 2019 dopemax. All rights reserved.
//

import UIKit
@_exported import QWListKit
@_exported import Then

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
            let feed = Feed(type: Bool.random() ? .type1 : .type2, title: titles[index % titles.count])
            let item = FeedItem(model: feed)
            demoSection.items.add(item)
        }
        adapter.dataSource = self
//        tableView.reloadData()
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
        adapter.dataSource = self
        adapter.didSelectItemBlock = { [unowned self] (adapter, section, item) in
            guard let item = item as? FeedItem else { return }
            adapter.tableView.deselectRow(at: item.indexPath, animated: true)
            if item.model.type == .type1 {
                item.isExpanded.toggle()
                item.layout()
                adapter.tableView.reloadRows(at: [item.indexPath], with: .automatic)
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
    
    func emptyView(for adapter: QWTableViewAdapter) -> UIView? {
        return nil
    }
    
}
