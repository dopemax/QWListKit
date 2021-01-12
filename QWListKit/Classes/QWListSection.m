//
//  QWListSection.m
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import "QWListSection.h"
#import "QWListItem.h"

@interface QWListSection ()

@property (nonatomic, assign, readwrite) NSInteger section;
@property (nonatomic, assign, readwrite) BOOL isFirstSection;
@property (nonatomic, assign, readwrite) BOOL isLastSection;

@end

@implementation QWListSection

- (NSMutableArray<QWListItem *> *)items {
    if (!_items) {
        _items = @[].mutableCopy;
        _supplementaryItemsMap = @{}.mutableCopy;
    }
    return _items;
}

- (void)setHeader:(QWListSupplementaryItem *)header {
    header.elementKind = UICollectionElementKindSectionHeader;
    _header = header;
}

- (void)setFooter:(QWListSupplementaryItem *)footer {
    footer.elementKind = UICollectionElementKindSectionFooter;
    _footer = footer;
}

@end
