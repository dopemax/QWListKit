//
//  QWCollectionViewAdapter.h
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QWCollectionViewAdapter, QWListItem, QWListSection;

@protocol QWCollectionViewAdapterDataSource <NSObject>

- (NSArray<QWListSection *> *)sectionsForCollectionViewAdapter:(QWCollectionViewAdapter *)adapter;

@optional
- (nullable UIView *)emptyViewForCollectionViewAdapter:(QWCollectionViewAdapter *)adapter;

@end



@interface QWCollectionViewAdapter : NSObject <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, unsafe_unretained, readonly) __kindof UICollectionView *collectionView;
@property (nonatomic, weak) id<QWCollectionViewAdapterDataSource> dataSource;

@property (nonatomic, copy) NSMutableArray<QWListItem *> * (^sectionItemsFilterBlock)(QWListSection *sectionModel);

@property (nonatomic, copy) void (^willDisplayCellBlock)(QWCollectionViewAdapter *adapter, __kindof UICollectionViewCell *cell, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) void (^willDisplaySupplementaryViewBlock)(QWCollectionViewAdapter *adapter, __kindof UICollectionReusableView *view, NSString *elementKind, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) void (^didSelectItemBlock)(QWCollectionViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) BOOL (^canMoveItemBlock)(QWCollectionViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) void (^moveItemBlock)(QWCollectionViewAdapter *adapter, QWListSection *sectionSectionModel, QWListItem *sourceItem, QWListSection *destinationSectionModel, QWListItem *destinationItem);

@property (nonatomic, copy) void (^scrollViewDidScrollBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewWillBeginDraggingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewDidEndDraggingBlock)(UIScrollView *scrollView, BOOL decelerate);
@property (nonatomic, copy) void (^scrollViewDidEndDeceleratingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewDidScrollToTopBlock)(UIScrollView *scrollView);

- (void)reloadListData;

/// Only update sections, will not call reloadData. ( Support insert or delete sections )
- (void)updateListData;

- (void)performBatchUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates completion:(void (^ _Nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
