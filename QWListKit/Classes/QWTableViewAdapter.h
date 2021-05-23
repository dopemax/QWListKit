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

@property (nonatomic, copy, nullable) void (^willDisplayCellBlock)(QWTableViewAdapter *adapter, __kindof UITableViewCell *cell, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void (^willDisplayHeaderViewBlock)(QWTableViewAdapter *adapter, __kindof UIView *headerView, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void (^willDisplayFooterViewBlock)(QWTableViewAdapter *adapter, __kindof UIView *footerView, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void (^didSelectItemBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);

@property (nonatomic, copy, nullable) NSArray<NSString *> * (^indexTitlesBlock)(QWTableViewAdapter *adapter);
@property (nonatomic, copy, nullable) BOOL (^canEditRowBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) UITableViewCellEditingStyle (^editingStyleForRowBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) NSString * (^titleForDeleteConfirmationButtonForRowBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void * (^commitEditingStyleBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) BOOL (^canMoveItemBlock)(QWTableViewAdapter *adapter, QWListSection *sectionModel, QWListItem *item);
@property (nonatomic, copy, nullable) void (^moveItemBlock)(QWTableViewAdapter *adapter, QWListSection *sourceSectionModel, QWListItem *sourceItem, QWListSection *destinationSectionModel, QWListItem *destinationItem);

@property (nonatomic, copy, nullable) void (^scrollViewDidScrollBlock)(UIScrollView *scrollView);
@property (nonatomic, copy, nullable) void (^scrollViewWillBeginDraggingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy, nullable) void (^scrollViewDidEndDraggingBlock)(UIScrollView *scrollView, BOOL decelerate);
@property (nonatomic, copy, nullable) void (^scrollViewDidEndDeceleratingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy, nullable) void (^scrollViewDidScrollToTopBlock)(UIScrollView *scrollView);

@end

NS_ASSUME_NONNULL_END
