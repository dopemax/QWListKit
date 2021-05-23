//
//  QWListItem.h
//  QWListKit
//
//  Created by dopemax on 2018/12/14.
//  Copyright © 2018 dopemax. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QWListBindable;
@class QWListSection;

@interface QWListItem : NSObject

@property (nonatomic, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) BOOL isInFirstSection;
@property (nonatomic, readonly) BOOL isInLastSection;
@property (nonatomic, readonly) BOOL isFirstItemInSection;
@property (nonatomic, readonly) BOOL isLastItemInSection;

- (Class<QWListBindable>)viewClass;
- (NSString *)viewReuseIdentifier;
- (CGSize (^)(UIScrollView *listView, QWListSection *section))viewSizeBlock;

@end


@interface QWListSupplementaryItem : QWListItem

@property (nonatomic, copy) NSString *elementKind;

@end


@protocol QWListBindable <NSObject>

- (void)bindItem:(QWListItem *)item;

@end

NS_ASSUME_NONNULL_END
