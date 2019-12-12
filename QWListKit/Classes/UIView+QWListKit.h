//
//  UIView+QWListKit.h
//  QWListKit
//
//  Created by guawaji on 2018/12/15.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QWTableViewAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (QWListKit)

+ (BOOL)qw_isFromNib;

/**
 if instance created is not from nib and need reuse identifier, use the class name as reuse identifier as default;
 
 @return current class's instance
 */
+ (instancetype)qw_newIfFromNib;

@end





@interface UITableViewCell (QWListKit)

- (UITableView *)qw_tableView;
- (NSIndexPath *)qw_indexPath;

@end



@interface UICollectionViewCell (QWListKit)

- (UICollectionView *)qw_collectionView;
- (NSIndexPath *)qw_indexPath;

@end





@interface NSObject (QWListKit)

+ (NSString *)qw_className;

@end

NS_ASSUME_NONNULL_END
