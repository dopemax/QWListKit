//
//  UIView+QWListKit.h
//  QWListKit
//
//  Created by dopemax on 2018/12/15.
//  Copyright © 2018 dopemax. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (QWListKit)

+ (BOOL)qw_isNibFileExisted;

@end



@interface UITableView (QWListKit)

- (void)qw_registerClassIfFromNib:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (void)qw_registerClassIfFromNib:(Class)viewClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier;

@end



@interface UICollectionView (QWListKit)

- (void)qw_registerClassIfFromNib:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)qw_registerClassIfFromNib:(Class)viewClass forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier;

@end



@interface NSObject (QWListKit)

+ (NSString *)qw_className;

@end

NS_ASSUME_NONNULL_END
