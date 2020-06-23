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

@interface QWTableViewAdapter ()

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
    QWListSection *sectionModel = self.sections[section];
    return sectionModel.isCollapsed ? 1 : sectionModel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    Collapsable Sections: [Assert] Unable to determine new global row index for preReloadFirstVisibleRow (0)
    
    Solution:
    https://stackoverflow.com/questions/58225727/collapsable-sections-assert-unable-to-determine-new-global-row-index-for-prer
    */
    if (self.sections[indexPath.section].isCollapsed) return UITableViewCell.new;
    
    id<QWListItem> item = self.sections[indexPath.section].items[indexPath.row];
    NSString *reuseIdentifier = item.viewReuseIdentifier;
    if (![_registeredCellReuseIdentifierSet containsObject:reuseIdentifier]) {
        [tableView qw_registerClassIfFromNib:item.viewClass forCellReuseIdentifier:reuseIdentifier];
        [_registeredCellReuseIdentifierSet addObject:reuseIdentifier];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sections[indexPath.section].isCollapsed) return;
    
    id<QWListItem> item = self.sections[indexPath.section].items[indexPath.row];
    if ([cell conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)cell;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplayCellBlock) {
        self.willDisplayCellBlock(tableView, cell, indexPath, item);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sections[indexPath.section].isCollapsed) return 0.0;
    
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
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    id<QWListItem> item = self.sections[section].header;
    if (!item) return;
    if ([view conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)view;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplayHeaderViewBlock) {
        self.willDisplayHeaderViewBlock(tableView, view, section, item);
    }
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
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    id<QWListItem> item = self.sections[section].footer;
    if (!item) return;
    if ([view conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)view;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplayFooterViewBlock) {
        self.willDisplayFooterViewBlock(tableView, view, section, item);
    }
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

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionIndexTitles;
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.scrollViewWillBeginDraggingBlock) {
        self.scrollViewWillBeginDraggingBlock(scrollView);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.scrollViewDidEndDraggingBlock) {
        self.scrollViewDidEndDraggingBlock(scrollView, decelerate);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.scrollViewDidEndDeceleratingBlock) {
        self.scrollViewDidEndDeceleratingBlock(scrollView);
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (self.scrollViewDidScrollToTopBlock) {
        self.scrollViewDidScrollToTopBlock(scrollView);
    }
}

@end
