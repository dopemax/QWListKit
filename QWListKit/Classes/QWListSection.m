//
//  QWListSection.m
//  QWListKit
//
//  Created by dopemax on 2018/12/14.
//  Copyright © 2018 dopemax. All rights reserved.
//

#import "QWListSection.h"
#import "QWListItem.h"

@interface QWListSection ()

@property (nonatomic, readwrite) NSInteger sectionIndex;
@property (nonatomic, readwrite) BOOL isFirstSection;
@property (nonatomic, readwrite) BOOL isLastSection;

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
