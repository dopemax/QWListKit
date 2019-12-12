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
