//
//  REFINED.swift
//  App
//
//  Created by dopemax on 2020/12/4.
//  Copyright © 2020 dopemax. All rights reserved.
//

import Foundation

public extension QWListSection {
    var items: [QWListItem] {
        get {
            return __items as? [QWListItem] ?? []
        }
        set {
            __items = NSMutableArray(array: newValue)
        }
    }
    
    var supplementaryItemsMap: [String: [QWListSupplementaryItem]] {
        get {
            return __supplementaryItemsMap as? [String: [QWListSupplementaryItem]] ?? [:]
        }
        set {
            __supplementaryItemsMap = newValue as? NSMutableDictionary ?? .init()
        }
    }
    
}
