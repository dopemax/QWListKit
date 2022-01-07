//
//  QWTableViewAdapter.h
//  QWListKit
//
//  Created by dopemax on 2018/12/14.
//  Copyright © 2018 dopemax. All rights reserved.
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
@property (nonatomic, nullable, weak) id<QWTableViewAdapterDataSource> dataSource;

@property (nonatomic, copy, nullable) NSMutableArray<QWListItem *> * (^sectionItemsFilterBlock)(QWListSection *sectionModel);

@property (nonatomic, copy, nullable) void (^willDisplayCellBlock)(UITableView *tableView, __kindof UITableViewCell *cell, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void (^willDisplayHeaderViewBlock)(UITableView *tableView, __kindof UIView *headerView, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void (^willDisplayFooterViewBlock)(UITableView *tableView, __kindof UIView *footerView, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void (^didSelectItemBlock)(UITableView *tableView, QWListSection *sectionModel, QWListItem *item);

@property (nonatomic, copy, nullable) NSArray<NSString *> * (^indexTitlesBlock)(UITableView *tableView);
@property (nonatomic, copy, nullable) BOOL (^canEditRowBlock)(UITableView *tableView, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) UITableViewCellEditingStyle (^editingStyleForRowBlock)(UITableView *tableView, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) NSString * (^titleForDeleteConfirmationButtonForRowBlock)(UITableView *tableView, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void * (^commitEditingStyleBlock)(UITableView *tableView, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) BOOL (^canMoveItemBlock)(UITableView *tableView, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void (^moveItemBlock)(UITableView *tableView, QWListSection *sourceSectionModel, QWListItem *sourceItem, QWListSection *destinationSectionModel, QWListItem *destinationItem);

@property (nonatomic, copy, nullable) void (^scrollViewDidScrollBlock)(UIScrollView *scrollView);
@property (nonatomic, copy, nullable) void (^scrollViewWillBeginDraggingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy, nullable) void (^scrollViewDidEndDraggingBlock)(UIScrollView *scrollView, BOOL decelerate);
@property (nonatomic, copy, nullable) void (^scrollViewDidEndDeceleratingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy, nullable) void (^scrollViewDidScrollToTopBlock)(UIScrollView *scrollView);

@end

NS_ASSUME_NONNULL_END
