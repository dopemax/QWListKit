//
//  QWTableViewAdapter.m
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import "QWTableViewAdapter.h"
#import "QWListItem.h"
#import "QWListItemInternal.h"
#import "QWListSection.h"
#import "UIView+QWListKit.h"

@interface QWTableViewAdapter ()

@property (nonatomic, copy) NSArray<QWListSection *> *sections;
@property (nonatomic, strong) NSMapTable<QWListSection *, NSMutableArray<QWListItem *> *> *sectionItemsMap;

@end

@implementation QWTableViewAdapter {
    NSMutableSet<NSString *> *_registeredCellReuseIdentifierSet;
    NSMutableSet<NSString *> *_registeredHeaderFooterReuseIdentifierSet;
}

- (instancetype)initWithTableView:(UITableView *)tableView {
    if (self = [super init]) {
        _tableView = tableView;
        tableView.dataSource = self;
        tableView.delegate = self;
        _registeredCellReuseIdentifierSet = NSMutableSet.new;
        _registeredHeaderFooterReuseIdentifierSet = NSMutableSet.new;
        _sections = @[];
        _sectionItemsMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (void)reloadListData {
    self.sections = [self.dataSource sectionsForTableViewAdapter:self];
    for (QWListSection *section in self.sections) {
        if (self.sectionItemsFilterBlock) {
            [self.sectionItemsMap setObject:self.sectionItemsFilterBlock(section) forKey:section];
        } else {
            [self.sectionItemsMap setObject:section.items forKey:section];
        }
    }
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
//    return sectionModel.isCollapsed ? 1 : sectionModel.items.count;
    if (sectionModel.isCollapsed) {
        return 1;
    } else {
        return [self.sectionItemsMap objectForKey:sectionModel].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    Collapsable Sections: [Assert] Unable to determine new global row index for preReloadFirstVisibleRow (0)
    
    Solution:
    https://stackoverflow.com/questions/58225727/collapsable-sections-assert-unable-to-determine-new-global-row-index-for-prer
    */
    QWListSection *sectionModel = self.sections[indexPath.section];
    if (sectionModel.isCollapsed) return UITableViewCell.new;
    
    NSMutableArray<QWListItem *> *items = [self.sectionItemsMap objectForKey:sectionModel];
    QWListItem *item = items[indexPath.row];
    NSString *reuseIdentifier = item.viewReuseIdentifier;
    if (![_registeredCellReuseIdentifierSet containsObject:reuseIdentifier]) {
        [tableView qw_registerClassIfFromNib:item.viewClass forCellReuseIdentifier:reuseIdentifier];
        [_registeredCellReuseIdentifierSet addObject:reuseIdentifier];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    if (sectionModel.isCollapsed) return;
    
    NSMutableArray<QWListItem *> *items = [self.sectionItemsMap objectForKey:sectionModel];
    QWListItem *item = items[indexPath.row];
    
    item.indexPath = indexPath;
    item.isInFirstSection = indexPath.section == 0;
    item.isInLastSection = indexPath.section == self.sections.count - 1;
    item.isFirstItemInSection = indexPath.row == 0;
    item.isLastItemInSection = indexPath.row == items.count - 1;
    
    if ([cell conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)cell;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplayCellBlock) {
        self.willDisplayCellBlock(self, cell, sectionModel, item);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    if (sectionModel.isCollapsed) return 0.0;
    
    QWListItem *item = [self.sectionItemsMap objectForKey:sectionModel][indexPath.row];
    return item.viewSizeBlock(tableView, sectionModel.inset).height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    QWListSection *sectionModel = self.sections[section];
    QWListItem *item = sectionModel.header;
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
    QWListSection *sectionModel = self.sections[section];
    QWListItem *item = sectionModel.header;
    if (!item) return;
    
    item.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    item.isInFirstSection = section == 0;
    item.isInLastSection = section == self.sections.count - 1;
    
    if ([view conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)view;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplayHeaderViewBlock) {
        self.willDisplayHeaderViewBlock(self, view, sectionModel, item);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    QWListSection *sectionModel = self.sections[section];
    QWListItem *item = sectionModel.header;
    if (!item) return tableView.style == UITableViewStylePlain ? 0 : CGFLOAT_MIN;
    return item.viewSizeBlock(tableView, sectionModel.inset).height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    QWListSection *sectionModel = self.sections[section];
    QWListItem *item = sectionModel.footer;
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
    QWListSection *sectionModel = self.sections[section];
    QWListItem *item = sectionModel.footer;
    if (!item) return;
    
    item.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    item.isInFirstSection = section == 0;
    item.isInLastSection = section == self.sections.count - 1;
    
    if ([view conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)view;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplayFooterViewBlock) {
        self.willDisplayFooterViewBlock(self, view, sectionModel, item);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    QWListSection *sectionModel = self.sections[section];
    QWListItem *item = sectionModel.footer;
    if (!item) return tableView.style == UITableViewStylePlain ? 0 : CGFLOAT_MIN;
    return item.viewSizeBlock(tableView, sectionModel.inset).height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    QWListItem *item = [self.sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.didSelectItemBlock) {
        self.didSelectItemBlock(self, sectionModel, item);
    }
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionIndexTitles;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    QWListItem *item = [self.sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.canEditRowBlock) {
        return self.canEditRowBlock(self, sectionModel, item);
    }
    return false;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    QWListItem *item = [self.sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.editingStyleForRowBlock) {
        return self.editingStyleForRowBlock(self, sectionModel, item);
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    QWListItem *item = [self.sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.titleForDeleteConfirmationButtonForRowBlock) {
        return self.titleForDeleteConfirmationButtonForRowBlock(self, sectionModel, item);
    }
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    QWListItem *item = [self.sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.commitEditingStyleBlock) {
        self.commitEditingStyleBlock(self, sectionModel, item);
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    QWListItem *item = [self.sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.canMoveItemBlock) {
        return self.canMoveItemBlock(self, sectionModel, item);
    }
    return false;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    QWListSection *sourceSectionModel = self.sections[sourceIndexPath.section];
    QWListItem *sourceItem = [self.sectionItemsMap objectForKey:sourceSectionModel][sourceIndexPath.row];
    QWListSection *destinationSectionModel = self.sections[destinationIndexPath.section];
    QWListItem *destinationItem = [self.sectionItemsMap objectForKey:destinationSectionModel][destinationIndexPath.row];
    if (self.moveItemBlock) {
        self.moveItemBlock(self, sourceSectionModel, sourceItem, destinationSectionModel, destinationItem);
    }
}

#pragma mark Scroll view delegate

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
