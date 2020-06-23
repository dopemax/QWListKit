//
//  QWListSection.h
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QWListItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface QWListSection : NSObject

@property (nonatomic, strong, nullable) id<QWListItem> header;
@property (nonatomic, strong, nullable) id<QWListItem> footer;
@property (nonatomic, strong) NSMutableArray<id<QWListItem>> *items;

/// Determine whether the section is collapsed. Default is false.
@property (nonatomic) BOOL isCollapsed;

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) UIEdgeInsets inset;

@end

NS_ASSUME_NONNULL_END
