//
//  QWListSection.m
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import "QWListSection.h"
#import "QWListItem.h"

@implementation QWListSection

- (NSMutableArray<QWListItem *> *)items {
    if (!_items) {
        _items = @[].mutableCopy;
    }
    return _items;
}

@end
