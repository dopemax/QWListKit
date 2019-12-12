//
//  QWListSection.m
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import "QWListKit.h"

@implementation QWListSection

- (NSMutableArray<id<QWListItem>> *)items {
    if (!_items) {
        _items = @[].mutableCopy;
    }
    return _items;
}

@end
