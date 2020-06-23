//
//  QWCollectionViewAdapter.h
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QWListItem.h"
#import "QWListSection.h"

NS_ASSUME_NONNULL_BEGIN

@class QWCollectionViewAdapter;

@protocol QWCollectionViewAdapterDataSource <NSObject>

- (NSArray<QWListSection *> *)sectionsForCollectionViewAdapter:(QWCollectionViewAdapter *)adapter;

@optional
- (nullable UIView *)emptyViewForCollectionViewAdapter:(QWCollectionViewAdapter *)adapter;

@end



@interface QWCollectionViewAdapter : NSObject <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, weak, readonly) __kindof UICollectionView *collectionView;
@property (nonatomic, weak) id<QWCollectionViewAdapterDataSource> dataSource;

@property (nonatomic, copy) void (^willDisplayCellBlock)(__kindof UICollectionView *collectionView, __kindof UICollectionViewCell *cell, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) void (^willDisplaySupplementaryViewBlock)(__kindof UICollectionView *collectionView, __kindof UICollectionReusableView *view, NSString *elementKind, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) void (^didSelectRowBlock)(__kindof UICollectionView *collectionView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) BOOL (^canMoveItemBlock)(__kindof UICollectionView *collectionView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) void (^moveItemBlock)(__kindof UICollectionView *collectionView, NSIndexPath *sourceIndexPath, id<QWListItem> sourceItem, NSIndexPath *destinationIndexPath, id<QWListItem> destinationItem);

@property (nonatomic, copy) void (^scrollViewDidScrollBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewWillBeginDraggingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewDidEndDraggingBlock)(UIScrollView *scrollView, BOOL decelerate);
@property (nonatomic, copy) void (^scrollViewDidEndDeceleratingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewDidScrollToTopBlock)(UIScrollView *scrollView);

- (void)reloadListData;

@end

NS_ASSUME_NONNULL_END
