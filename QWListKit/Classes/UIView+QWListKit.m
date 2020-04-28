//
//  UIView+QWListKit.m
//  QWListKit
//
//  Created by guawaji on 2018/12/15.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import "UIView+QWListKit.h"
#import <objc/runtime.h>

@implementation UIView (QWListKit)

+ (BOOL)qw_isFromNib {
    NSBundle *bundle = [NSBundle bundleForClass:self];
    NSString *path = [bundle pathForResource:self.qw_className ofType:@"nib"];
    return path.length;
}

+ (instancetype)qw_newIfFromNib {
    if ([self qw_isFromNib]) {
        NSBundle *bundle = [NSBundle bundleForClass:self];
        return [bundle loadNibNamed:self.qw_className owner:nil options:nil].firstObject;
    } else {
        if ([self isKindOfClass:UITableViewCell.class]) {
            return [[self alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:self.qw_className];
        } else if ([self isKindOfClass:UITableViewHeaderFooterView.class]) {
            return [[self alloc] initWithReuseIdentifier:self.qw_className];
        } else {
            return self.new;
        }
    }
}

@end



@implementation UITableView (QWListKit)

- (void)qw_registerClassIfFromNib:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    NSAssert([cellClass isSubclassOfClass:UITableViewCell.class], @"cellClass must be subclass of UITableViewCell");
    if ([cellClass qw_isFromNib]) {
        NSBundle *bundle = [NSBundle bundleForClass:cellClass];
        [self registerNib:[UINib nibWithNibName:cellClass.qw_className bundle:bundle] forCellReuseIdentifier:identifier];
    } else {
        [self registerClass:cellClass forCellReuseIdentifier:identifier];
    }
}

- (void)qw_registerClassIfFromNib:(Class)viewClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier {
    if ([viewClass qw_isFromNib]) {
        NSBundle *bundle = [NSBundle bundleForClass:viewClass];
        [self registerNib:[UINib nibWithNibName:viewClass.qw_className bundle:bundle] forHeaderFooterViewReuseIdentifier:identifier];
    } else {
        [self registerClass:viewClass forHeaderFooterViewReuseIdentifier:identifier];
    }
}

- (BOOL)qw_listIsEmpty {
    __block BOOL isEmpty = true;
    const NSInteger sections = [self.dataSource numberOfSectionsInTableView:self];
    for (NSInteger section = 0; section < sections; section++) {
        if ([self.dataSource tableView:self numberOfRowsInSection:section] > 0) {
            isEmpty = false;
            break;
        }
    }
    return isEmpty;
}

- (NSUInteger)qw_listItemsCount {
    __block NSUInteger listItemsCount = 0;
    const NSInteger sections = [self.dataSource numberOfSectionsInTableView:self];
    for (NSInteger section = 0; section < sections; section++) {
        const NSInteger rows = [self.dataSource tableView:self numberOfRowsInSection:section];
        listItemsCount += rows;
    }
    return listItemsCount;
}

@end



@implementation UICollectionView (QWListKit)

- (void)qw_registerClassIfFromNib:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    NSAssert([cellClass isSubclassOfClass:UICollectionViewCell.class], @"cellClass must be subclass of UICollectionViewCell");
    if ([cellClass qw_isFromNib]) {
        NSBundle *bundle = [NSBundle bundleForClass:cellClass];
        [self registerNib:[UINib nibWithNibName:cellClass.qw_className bundle:bundle] forCellWithReuseIdentifier:identifier];
    } else {
        [self registerClass:cellClass forCellWithReuseIdentifier:identifier];
    }
}

- (void)qw_registerClassIfFromNib:(Class)viewClass forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier {
    if ([viewClass qw_isFromNib]) {
        NSBundle *bundle = [NSBundle bundleForClass:viewClass];
        [self registerNib:[UINib nibWithNibName:viewClass.qw_className bundle:bundle] forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    } else {
        [self registerClass:viewClass forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    }
}

- (BOOL)qw_listIsEmpty {
    __block BOOL isEmpty = true;
    const NSInteger sections = [self.dataSource numberOfSectionsInCollectionView:self];
    for (NSInteger section = 0; section < sections; section++) {
        if ([self.dataSource collectionView:self numberOfItemsInSection:section] > 0) {
            isEmpty = false;
            break;
        }
    }
    return isEmpty;
}

- (NSUInteger)qw_listItemsCount {
    __block NSUInteger listItemsCount = 0;
    const NSInteger sections = [self.dataSource numberOfSectionsInCollectionView:self];
    for (NSInteger section = 0; section < sections; section++) {
        const NSInteger rows = [self.dataSource collectionView:self numberOfItemsInSection:section];
        listItemsCount += rows;
    }
    return listItemsCount;
}

@end



@implementation UITableViewCell (QWListKit)

- (UITableView *)qw_tableView {
    for (UIView *view = self; view; view = view.superview) {
        if ([view isKindOfClass:UITableView.class]) {
            return (UITableView *)view;
        }
    }
    return nil;
}

- (NSIndexPath *)qw_indexPath {
    return [[self qw_tableView] indexPathForCell:self];
}

@end



@implementation UICollectionViewCell (QWListKit)

- (UICollectionView *)qw_collectionView {
    for (UIView *view = self; view; view = view.superview) {
        if ([view isKindOfClass:UICollectionView.class]) {
            return (UICollectionView *)view;
        }
    }
    return nil;
}

- (NSIndexPath *)qw_indexPath {
    return [[self qw_collectionView] indexPathForCell:self];
}

@end



@implementation NSObject (QWListKit)

+ (NSString *)qw_className {
    return [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
}

@end
