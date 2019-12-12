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

- (NSArray<QWListSection *> *)sectionsForListAdapter:(QWCollectionViewAdapter *)listAdapter;
- (nullable UIView *)emptyViewForListAdapter:(QWCollectionViewAdapter *)listAdapter;

@end

@interface QWCollectionViewAdapter : NSObject

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, weak, readonly) __kindof UICollectionView *collectionView;
@property (nonatomic, weak) id<QWCollectionViewAdapterDataSource> dataSource;
@property (nonatomic, strong, readonly) NSArray<QWListSection *> *sections;

@property (nonatomic, copy) void (^configureCellBlock)(__kindof UICollectionViewCell *cell, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) void (^configureSupplementaryViewBlock)(__kindof UICollectionReusableView *view, NSString *kind, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) void (^didSelectRowBlock)(__kindof UICollectionView *collectionView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) BOOL (^canMoveItemBlock)(__kindof UICollectionView *collectionView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) void (^moveItemBlock)(__kindof UICollectionView *collectionView, NSIndexPath *sourceIndexPath, id<QWListItem> sourceItem, NSIndexPath *destinationIndexPath, id<QWListItem> destinationItem);


@end



@interface UICollectionView (QWListKit)

- (void)qw_registerClassIfFromNib:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)qw_registerClassIfFromNib:(Class)viewClass forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier;

- (BOOL)qw_listIsEmpty;
- (NSUInteger)qw_listItemsCount;

@end

NS_ASSUME_NONNULL_END
