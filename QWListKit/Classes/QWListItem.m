//
//  QWListItem.m
//  QWListKit
//
//  Created by guawaji on 2020/7/14.
//  Copyright © 2020 guawaji. All rights reserved.
//

#import "QWListItem.h"

@interface QWListItem ()

@property (nonatomic, readwrite) NSIndexPath *indexPath;
@property (nonatomic, readwrite) BOOL isInFirstSection;
@property (nonatomic, readwrite) BOOL isInLastSection;
@property (nonatomic, readwrite) BOOL isFirstItemInSection;
@property (nonatomic, readwrite) BOOL isLastItemInSection;

@end

@implementation QWListItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return self;
}

- (Class<QWListBindable>)viewClass {
    NSCAssert(NO, @"List Item %@ must override %s", self, __PRETTY_FUNCTION__);
    return nil;
}

- (NSString *)viewReuseIdentifier {
    NSCAssert(NO, @"List Item %@ must override %s", self, __PRETTY_FUNCTION__);
    return nil;
}

- (CGSize (^)(UIScrollView * _Nonnull, QWListSection * _Nonnull))viewSizeBlock {
    NSCAssert(NO, @"List Item %@ must override %s", self, __PRETTY_FUNCTION__);
    return nil;
}

@end
