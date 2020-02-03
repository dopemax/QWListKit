//
//  QWTableViewAdapter.m
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import "QWTableViewAdapter.h"
#import <objc/runtime.h>
#import "UIView+QWListKit.h"

@interface QWTableViewAdapter () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray<QWListSection *> *sections;

@end

@implementation QWTableViewAdapter {
    NSMutableSet *_registeredCellReuseIdentifierSet;
    NSMutableSet *_registeredHeaderFooterReuseIdentifierSet;
}

- (instancetype)initWithTableView:(UITableView *)tableView {
    if (self = [super init]) {
        _tableView = tableView;
        tableView.dataSource = self;
        tableView.delegate = self;
        _registeredCellReuseIdentifierSet = NSMutableSet.new;
        _registeredHeaderFooterReuseIdentifierSet = NSMutableSet.new;
        _sections = @[];
    }
    return self;
}

- (void)reloadListData {
    self.sections = [self.dataSource sectionsForTableViewAdapter:self];
    [_tableView reloadData];
    
    if ([self.dataSource respondsToSelector:@selector(emptyViewForTableViewAdapter:)]) {
        UIView *backgroundView = [self.dataSource emptyViewForTableViewAdapter:self];
        if (backgroundView != _tableView.backgroundView) {
            [_tableView.backgroundView removeFromSuperview];
            _tableView.backgroundView = backgroundView;
        }
        _tableView.backgroundView.hidden = ![_tableView qw_listIsEmpty];
    }
}

#pragma mark - Table view data source & Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<QWListItem> item = self.sections[indexPath.section].items[indexPath.row];
    NSString *reuseIdentifier = item.viewReuseIdentifier;
    if (![_registeredCellReuseIdentifierSet containsObject:reuseIdentifier]) {
        [tableView qw_registerClassIfFromNib:item.viewClass forCellReuseIdentifier:reuseIdentifier];
        [_registeredCellReuseIdentifierSet addObject:reuseIdentifier];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)cell;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, indexPath, item);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<QWListItem> item = self.sections[indexPath.section].items[indexPath.row];
    return item.viewSize.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    id<QWListItem> item = self.sections[section].header;
    if (!item) return nil;
    NSString *reuseIdentifier = item.viewReuseIdentifier;
    if (![_registeredHeaderFooterReuseIdentifierSet containsObject:reuseIdentifier]) {
        [tableView qw_registerClassIfFromNib:item.viewClass forHeaderFooterViewReuseIdentifier:reuseIdentifier];
        [_registeredHeaderFooterReuseIdentifierSet addObject:reuseIdentifier];
    }
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    if ([headerView conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)headerView;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.configureHeaderViewBlock) {
        self.configureHeaderViewBlock(headerView, section, item);
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    id<QWListItem> item = self.sections[section].header;
    if (!item) return tableView.style == UITableViewStylePlain ? 0 : CGFLOAT_MIN;
    return item.viewSize.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    id<QWListItem> item = self.sections[section].footer;
    if (!item) return nil;
    NSString *reuseIdentifier = item.viewReuseIdentifier;
    if (![_registeredHeaderFooterReuseIdentifierSet containsObject:reuseIdentifier]) {
        [tableView qw_registerClassIfFromNib:item.viewClass forHeaderFooterViewReuseIdentifier:reuseIdentifier];
        [_registeredHeaderFooterReuseIdentifierSet addObject:reuseIdentifier];
    }
    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    if ([footerView conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)footerView;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.configureFooterViewBlock) {
        self.configureFooterViewBlock(footerView, section, item);
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    id<QWListItem> item = self.sections[section].footer;
    if (!item) return tableView.style == UITableViewStylePlain ? 0 : CGFLOAT_MIN;
    return item.viewSize.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.sections[indexPath.section].items[indexPath.row];
    if (self.didSelectRowBlock) {
        self.didSelectRowBlock(tableView, indexPath, item);
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.sections[indexPath.section].items[indexPath.row];
    if (self.canEditRowBlock) {
        return self.canEditRowBlock(tableView, indexPath, item);
    }
    return false;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.sections[indexPath.section].items[indexPath.row];
    if (self.editingStyleForRowBlock) {
        return self.editingStyleForRowBlock(tableView, indexPath, item);
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.sections[indexPath.section].items[indexPath.row];
    if (self.titleForDeleteConfirmationButtonForRowBlock) {
        return self.titleForDeleteConfirmationButtonForRowBlock(tableView, indexPath, item);
    }
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.sections[indexPath.section].items[indexPath.row];
    if (self.commitEditingStyleBlock) {
        self.commitEditingStyleBlock(tableView, indexPath, item);
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.sections[indexPath.section].items[indexPath.row];
    if (self.canMoveItemBlock) {
        return self.canMoveItemBlock(tableView, indexPath, item);
    }
    return false;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id sourceItem = self.sections[sourceIndexPath.section].items[sourceIndexPath.row];
    id destinationItem = self.sections[destinationIndexPath.section].items[destinationIndexPath.row];
    if (self.didSelectRowBlock) {
        self.moveItemBlock(tableView, sourceIndexPath, sourceItem, destinationIndexPath, destinationItem);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollViewDidScrollBlock) {
        self.scrollViewDidScrollBlock(scrollView);
    }
}

@end







@implementation UITableView (QWListKit)

- (void)qw_registerClassIfFromNib:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    NSAssert([cellClass isSubclassOfClass:UITableViewCell.class], @"cellClass must be subclass of UITableViewCell");
    if ([cellClass qw_isFromNib]) {
        NSBundle *bundle = [NSBundle bundleForClass:cellClass];
        [self registerNib:[UINib nibWithNibName:cellClass.qw_className bundle:bundle] forCellReuseIdentifier:identifier];
    } else {
        [self registerClass:cellClass forCellReuseIdentifier:identifier];
    }
}

- (void)qw_registerClassIfFromNib:(Class)viewClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier {
    if ([viewClass qw_isFromNib]) {
        NSBundle *bundle = [NSBundle bundleForClass:viewClass];
        [self registerNib:[UINib nibWithNibName:viewClass.qw_className bundle:bundle] forHeaderFooterViewReuseIdentifier:identifier];
    } else {
        [self registerClass:viewClass forHeaderFooterViewReuseIdentifier:identifier];
    }
}

- (BOOL)qw_listIsEmpty {
    __block BOOL isEmpty = true;
    const NSInteger sections = [self.dataSource numberOfSectionsInTableView:self];
    for (NSInteger section = 0; section < sections; section++) {
        if ([self.dataSource tableView:self numberOfRowsInSection:section] > 0) {
            isEmpty = false;
            break;
        }
    }
    return isEmpty;
}

- (NSUInteger)qw_listItemsCount {
    __block NSUInteger listItemsCount = 0;
    const NSInteger sections = [self.dataSource numberOfSectionsInTableView:self];
    for (NSInteger section = 0; section < sections; section++) {
        const NSInteger rows = [self.dataSource tableView:self numberOfRowsInSection:section];
        listItemsCount += rows;
    }
    return listItemsCount;
}

@end
