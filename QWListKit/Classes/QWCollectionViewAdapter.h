//
//  QWCollectionViewAdapter.h
//  QWListKit
//
//  Created by dopemax on 2018/12/14.
//  Copyright © 2018 dopemax. All rights reserved.
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
@property (nonatomic, nullable, weak) id<QWCollectionViewAdapterDataSource> dataSource;

@property (nonatomic, copy, nullable) NSMutableArray<QWListItem *> * (^sectionItemsFilterBlock)(QWListSection *sectionModel);

@property (nonatomic, copy, nullable) void (^willDisplayCellBlock)(QWCollectionViewAdapter *adapter, __kindof UICollectionViewCell *cell, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void (^willDisplaySupplementaryViewBlock)(QWCollectionViewAdapter *adapter, __kindof UICollectionReusableView *view, NSString *elementKind, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void (^didSelectItemBlock)(QWCollectionViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);

@property (nonatomic, copy, nullable) BOOL (^canMoveItemBlock)(QWCollectionViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) void (^moveItemBlock)(QWCollectionViewAdapter *adapter, QWListSection *sectionSectionModel, QWListItem *sourceItem, QWListSection *destinationSectionModel, QWListItem *destinationItem);

@property (nonatomic, copy, nullable) void (^scrollViewDidScrollBlock)(UIScrollView *scrollView);
@property (nonatomic, copy, nullable) void (^scrollViewWillBeginDraggingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy, nullable) void (^scrollViewDidEndDraggingBlock)(UIScrollView *scrollView, BOOL decelerate);
@property (nonatomic, copy, nullable) void (^scrollViewDidEndDeceleratingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy, nullable) void (^scrollViewDidScrollToTopBlock)(UIScrollView *scrollView);

@end

NS_ASSUME_NONNULL_END
