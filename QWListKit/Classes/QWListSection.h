//
//  QWListSection.h
//  QWListKit
//
//  Created by dopemax on 2018/12/14.
//  Copyright © 2018 dopemax. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QWListItem, QWListSupplementaryItem;

@interface QWListSection : NSObject

@property (nonatomic, strong, nullable) QWListSupplementaryItem *header;
@property (nonatomic, strong, nullable) QWListSupplementaryItem *footer;
@property (nonatomic, strong) NSMutableArray<QWListItem *> *items NS_REFINED_FOR_SWIFT;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<QWListSupplementaryItem *> *> *supplementaryItemsMap NS_REFINED_FOR_SWIFT;

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) UIEdgeInsets inset;

/// Determine whether the section is collapsed. Default is false.
@property (nonatomic) BOOL isCollapsed;

@property (nonatomic, readonly) NSInteger sectionIndex;
@property (nonatomic, readonly) BOOL isFirstSection;
@property (nonatomic, readonly) BOOL isLastSection;

@end

NS_ASSUME_NONNULL_END
