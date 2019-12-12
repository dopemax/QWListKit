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

- (NSArray<QWListSection *> *)sectionsForListAdapter:(QWTableViewAdapter *)listAdapter;
- (nullable UIView *)emptyViewForListAdapter:(QWTableViewAdapter *)listAdapter;

@end

typedef void (^QWListConfigureHeaderViewBlock)(__kindof UIView *headerView, NSUInteger section, id<QWListItem> item);
typedef void (^QWListConfigureFooterViewBlock)(__kindof UIView *footerView, NSUInteger section, id<QWListItem> item);

@interface QWTableViewAdapter : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, weak, readonly) __kindof UITableView *tableView;
@property (nonatomic, weak) id<QWTableViewAdapterDataSource> dataSource;
@property (nonatomic, strong, readonly) NSArray<QWListSection *> *sections;

@property (nonatomic, copy) void (^configureCellBlock)(__kindof UITableViewCell *cell, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) QWListConfigureHeaderViewBlock configureHeaderViewBlock;
@property (nonatomic, copy) QWListConfigureFooterViewBlock configureFooterViewBlock;
@property (nonatomic, copy) void (^didSelectRowBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) BOOL (^canEditRowBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) UITableViewCellEditingStyle (^editingStyleForRowBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) NSString * (^titleForDeleteConfirmationButtonForRowBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) void * (^commitEditingStyleBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) BOOL (^canMoveItemBlock)(__kindof UITableView *tableView, NSIndexPath *indexPath, id<QWListItem> item);
@property (nonatomic, copy) void (^moveItemBlock)(__kindof UITableView *tableView, NSIndexPath *sourceIndexPath, id<QWListItem> sourceItem, NSIndexPath *destinationIndexPath, id<QWListItem> destinationItem);

- (void)reloadListData;

@end





@interface UITableView (QWListKit)

- (void)qw_registerClassIfFromNib:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (void)qw_registerClassIfFromNib:(Class)viewClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier;

- (BOOL)qw_listIsEmpty;
- (NSUInteger)qw_listItemsCount;

@end

NS_ASSUME_NONNULL_END
