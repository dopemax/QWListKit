//
//  QWListSection.h
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QWListItem, QWListSupplementaryItem;

@interface QWListSection : NSObject

@property (nonatomic, strong, nullable) QWListSupplementaryItem *header;
@property (nonatomic, strong, nullable) QWListSupplementaryItem *footer;
@property (nonatomic, strong) NSMutableArray<QWListItem *> *items;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<QWListSupplementaryItem *> *> *supplementaryItemsMap;

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) UIEdgeInsets inset;

/// Determine whether the section is collapsed. Default is false.
@property (nonatomic) BOOL isCollapsed;

@property (nonatomic, assign, readonly) NSInteger section;
@property (nonatomic, assign, readonly) BOOL isFirstSection;
@property (nonatomic, assign, readonly) BOOL isLastSection;

@end

NS_ASSUME_NONNULL_END
