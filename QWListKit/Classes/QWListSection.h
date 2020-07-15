//
//  QWListSection.h
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QWListItem;

@interface QWListSection : NSObject

@property (nonatomic, strong, nullable) QWListItem *header;
@property (nonatomic, strong, nullable) QWListItem *footer;
@property (nonatomic, strong) NSMutableArray<QWListItem *> *items;

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) UIEdgeInsets inset;

/// Determine whether the section is collapsed. Default is false.
@property (nonatomic) BOOL isCollapsed;

@end

NS_ASSUME_NONNULL_END
