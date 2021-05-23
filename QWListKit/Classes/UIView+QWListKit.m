//
//  UIView+QWListKit.m
//  QWListKit
//
//  Created by dopemax on 2018/12/15.
//  Copyright © 2018 dopemax. All rights reserved.
//

#import "UIView+QWListKit.h"
#import <objc/runtime.h>

@implementation UIView (QWListKit)

+ (BOOL)qw_isNibFileExisted {
    NSBundle *bundle = [NSBundle bundleForClass:self];
    NSString *path = [bundle pathForResource:self.qw_className ofType:@"nib"];
    return path.length;
}

@end



@implementation UITableView (QWListKit)

- (void)qw_registerClassIfFromNib:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    NSAssert([cellClass isSubclassOfClass:UITableViewCell.class], @"cellClass must be subclass of UITableViewCell");
    if ([cellClass qw_isNibFileExisted]) {
        NSBundle *bundle = [NSBundle bundleForClass:cellClass];
        [self registerNib:[UINib nibWithNibName:cellClass.qw_className bundle:bundle] forCellReuseIdentifier:identifier];
    } else {
        [self registerClass:cellClass forCellReuseIdentifier:identifier];
    }
}

- (void)qw_registerClassIfFromNib:(Class)viewClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier {
    if ([viewClass qw_isNibFileExisted]) {
        NSBundle *bundle = [NSBundle bundleForClass:viewClass];
        [self registerNib:[UINib nibWithNibName:viewClass.qw_className bundle:bundle] forHeaderFooterViewReuseIdentifier:identifier];
    } else {
        [self registerClass:viewClass forHeaderFooterViewReuseIdentifier:identifier];
    }
}

@end



@implementation UICollectionView (QWListKit)

- (void)qw_registerClassIfFromNib:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    NSAssert([cellClass isSubclassOfClass:UICollectionViewCell.class], @"cellClass must be subclass of UICollectionViewCell");
    if ([cellClass qw_isNibFileExisted]) {
        NSBundle *bundle = [NSBundle bundleForClass:cellClass];
        [self registerNib:[UINib nibWithNibName:cellClass.qw_className bundle:bundle] forCellWithReuseIdentifier:identifier];
    } else {
        [self registerClass:cellClass forCellWithReuseIdentifier:identifier];
    }
}

- (void)qw_registerClassIfFromNib:(Class)viewClass forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier {
    if ([viewClass qw_isNibFileExisted]) {
        NSBundle *bundle = [NSBundle bundleForClass:viewClass];
        [self registerNib:[UINib nibWithNibName:viewClass.qw_className bundle:bundle] forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    } else {
        [self registerClass:viewClass forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    }
}

@end



@implementation NSObject (QWListKit)

+ (NSString *)qw_className {
    return [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
}

@end
