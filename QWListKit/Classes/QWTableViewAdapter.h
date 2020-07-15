//
//  QWTableViewAdapter.h
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QWTableViewAdapter, QWListItem, QWListSection;

@protocol QWTableViewAdapterDataSource <NSObject>

- (NSArray<QWListSection *> *)sectionsForTableViewAdapter:(QWTableViewAdapter *)adapter;

@optional
- (nullable UIView *)emptyViewForTableViewAdapter:(QWTableViewAdapter *)adapter;

@end



@interface QWTableViewAdapter : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, unsafe_unretained, readonly) __kindof UITableView *tableView;
@property (nonatomic, weak) id<QWTableViewAdapterDataSource> dataSource;

@property (nonatomic, strong) NSArray<NSString *> *sectionIndexTitles;

@property (nonatomic, copy) NSMutableArray<QWListItem *> * (^sectionItemsFilterBlock)(QWListSection *sectionModel);

@property (nonatomic, copy) void (^willDisplayCellBlock)(QWTableViewAdapter *adapter, __kindof UITableViewCell *cell, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) void (^willDisplayHeaderViewBlock)(QWTableViewAdapter *adapter, __kindof UIView *headerView, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) void (^willDisplayFooterViewBlock)(QWTableViewAdapter *adapter, __kindof UIView *footerView, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) void (^didSelectItemBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) BOOL (^canEditRowBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) UITableViewCellEditingStyle (^editingStyleForRowBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) NSString * (^titleForDeleteConfirmationButtonForRowBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) void * (^commitEditingStyleBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) BOOL (^canMoveItemBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy) void (^moveItemBlock)(QWTableViewAdapter *adapter, QWListSection *sourceSectionModel, QWListItem *sourceItem, QWListSection *destinationSectionModel, QWListItem *destinationItem);

@property (nonatomic, copy) void (^scrollViewDidScrollBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewWillBeginDraggingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewDidEndDraggingBlock)(UIScrollView *scrollView, BOOL decelerate);
@property (nonatomic, copy) void (^scrollViewDidEndDeceleratingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewDidScrollToTopBlock)(UIScrollView *scrollView);

- (void)reloadListData;

@end

NS_ASSUME_NONNULL_END
