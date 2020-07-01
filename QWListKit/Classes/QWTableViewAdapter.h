//
//  QWTableViewAdapter.h
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QWListItem.h"
#import "QWListSection.h"

NS_ASSUME_NONNULL_BEGIN

@class QWTableViewAdapter;

@protocol QWTableViewAdapterDataSource <NSObject>

- (NSArray<QWListSection *> *)sectionsForTableViewAdapter:(QWTableViewAdapter *)adapter;

@optional
- (nullable UIView *)emptyViewForTableViewAdapter:(QWTableViewAdapter *)adapter;

@end



@interface QWTableViewAdapter : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, weak, readonly) __kindof UITableView *tableView;
@property (nonatomic, weak) id<QWTableViewAdapterDataSource> dataSource;

@property (nonatomic, strong) NSArray<NSString *> *sectionIndexTitles;

@property (nonatomic, copy) NSMutableArray<id<QWListItem>> * (^sectionItemsFilterBlock)(QWListSection *sectionModel);

@property (nonatomic, copy) void (^willDisplayCellBlock)(__kindof UITableView *tableView, __kindof UITableViewCell *cell, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) void (^willDisplayHeaderViewBlock)(__kindof UITableView *tableView, __kindof UIView *headerView, NSInteger section, id<QWListItem> item);
@property (nonatomic, copy) void (^willDisplayFooterViewBlock)(__kindof UITableView *tableView, __kindof UIView *footerView, NSInteger section, id<QWListItem> item);
@property (nonatomic, copy) void (^didSelectRowBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) BOOL (^canEditRowBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) UITableViewCellEditingStyle (^editingStyleForRowBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) NSString * (^titleForDeleteConfirmationButtonForRowBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) void * (^commitEditingStyleBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) BOOL (^canMoveItemBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) void (^moveItemBlock)(__kindof UITableView *tableView, NSIndexPath *sourceIndexPath, id<QWListItem> sourceItem, NSIndexPath *destinationIndexPath, id<QWListItem> destinationItem);

@property (nonatomic, copy) void (^scrollViewDidScrollBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewWillBeginDraggingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewDidEndDraggingBlock)(UIScrollView *scrollView, BOOL decelerate);
@property (nonatomic, copy) void (^scrollViewDidEndDeceleratingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewDidScrollToTopBlock)(UIScrollView *scrollView);

- (void)reloadListData;

@end

NS_ASSUME_NONNULL_END
