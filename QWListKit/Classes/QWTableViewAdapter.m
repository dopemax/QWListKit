//
//  QWTableViewAdapter.m
//  QWListKit
//
//  Created by dopemax on 2018/12/14.
//  Copyright © 2018 dopemax. All rights reserved.
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
        _sectionItemsMap = [NSMapTable weakToWeakObjectsMapTable];
    }
    return self;
}

- (void)_updateBackgroundViewHidden {
    if ([self.dataSource respondsToSelector:@selector(emptyViewForTableViewAdapter:)]) {
        UIView *backgroundView = [self.dataSource emptyViewForTableViewAdapter:self];
        if (backgroundView != _tableView.backgroundView) {
            [_tableView.backgroundView removeFromSuperview];
            _tableView.backgroundView = backgroundView;
        }
        _tableView.backgroundView.hidden = ![self _listIsEmpty];
    }
}

- (BOOL)_listIsEmpty {
    __block BOOL isEmpty = true;
    [_sections enumerateObjectsUsingBlock:^(QWListSection * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([_sectionItemsMap objectForKey:section].count > 0) {
            isEmpty = false;
            *stop = true;
        }
        if (section.header || section.footer) {
            isEmpty = false;
            *stop = true;
        }
    }];
    return isEmpty;
}

#pragma mark - Table view data source & Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.sections = [self.dataSource sectionsForTableViewAdapter:self];
    
    [_sectionItemsMap removeAllObjects];
    for (NSInteger i = 0; i < _sections.count; i++) {
        QWListSection *sectionModel = _sections[i];
        sectionModel.sectionIndex = i;
        sectionModel.isFirstSection = i == 0;
        sectionModel.isLastSection = i == _sections.count - 1;
        
        if (self.sectionItemsFilterBlock) {
            [_sectionItemsMap setObject:self.sectionItemsFilterBlock(sectionModel) forKey:sectionModel];
        } else {
            [_sectionItemsMap setObject:sectionModel.items forKey:sectionModel];
        }
    }
    
    [self _updateBackgroundViewHidden];
    
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    QWListSection *sectionModel = _sections[section];
    
    sectionModel.header.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    sectionModel.header.isInFirstSection = section == 0;
    sectionModel.header.isInLastSection = section == _sections.count - 1;
    
    sectionModel.footer.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    sectionModel.footer.isInFirstSection = section == 0;
    sectionModel.footer.isInLastSection = section == _sections.count - 1;
    
    NSArray<QWListItem *> *items = [_sectionItemsMap objectForKey:sectionModel];
    for (NSInteger i = 0; i < items.count; i++) {
        QWListItem *item = items[i];
        item.indexPath = [NSIndexPath indexPathForItem:i inSection:section];
        item.isInFirstSection = section == 0;
        item.isInLastSection = section == _sections.count - 1;
        item.isFirstItemInSection = i == 0;
        item.isLastItemInSection = i == items.count - 1;
    }
    
    if (sectionModel.isCollapsed) {
        return 1;
    } else {
        return [_sectionItemsMap objectForKey:sectionModel].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    Collapsable Sections: [Assert] Unable to determine new global row index for preReloadFirstVisibleRow (0)
    
    Solution:
    https://stackoverflow.com/questions/58225727/collapsable-sections-assert-unable-to-determine-new-global-row-index-for-prer
    */
    QWListSection *sectionModel = _sections[indexPath.section];
    if (sectionModel.isCollapsed) return UITableViewCell.new;
    
    NSMutableArray<QWListItem *> *items = [_sectionItemsMap objectForKey:sectionModel];
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
    QWListSection *sectionModel = _sections[indexPath.section];
    if (sectionModel.isCollapsed) return;
    
    NSMutableArray<QWListItem *> *items = [_sectionItemsMap objectForKey:sectionModel];
    QWListItem *item = items[indexPath.row];
    
    if ([cell conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)cell;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplayCellBlock) {
        self.willDisplayCellBlock(tableView, cell, sectionModel, item);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    if (sectionModel.isCollapsed) return 0.0;
    
    QWListItem *item = [_sectionItemsMap objectForKey:sectionModel][indexPath.row];
    const CGSize size = item.viewSizeBlock(tableView, sectionModel);
    return size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    QWListSection *sectionModel = _sections[section];
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
    QWListSection *sectionModel = _sections[section];
    QWListItem *item = sectionModel.header;
    if (!item) return;
    
    if ([view conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)view;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplayHeaderViewBlock) {
        self.willDisplayHeaderViewBlock(tableView, view, sectionModel, item);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    QWListSection *sectionModel = _sections[section];
    QWListItem *item = sectionModel.header;
    if (!item) return tableView.style == UITableViewStylePlain ? 0 : CGFLOAT_MIN;
    const CGSize size = item.viewSizeBlock(tableView, sectionModel);
    return size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    QWListSection *sectionModel = _sections[section];
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
    QWListSection *sectionModel = _sections[section];
    QWListItem *item = sectionModel.footer;
    if (!item) return;
    
    if ([view conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)view;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplayFooterViewBlock) {
        self.willDisplayFooterViewBlock(tableView, view, sectionModel, item);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    QWListSection *sectionModel = _sections[section];
    QWListItem *item = sectionModel.footer;
    if (!item) return tableView.style == UITableViewStylePlain ? 0 : CGFLOAT_MIN;
    const CGSize size = item.viewSizeBlock(tableView, sectionModel);
    return size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    QWListItem *item = [_sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.didSelectItemBlock) {
        self.didSelectItemBlock(tableView, sectionModel, item);
    }
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.indexTitlesBlock) {
        return self.indexTitlesBlock(tableView);
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    QWListItem *item = [_sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.canEditRowBlock) {
        return self.canEditRowBlock(tableView, sectionModel, item);
    }
    return false;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    QWListItem *item = [_sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.editingStyleForRowBlock) {
        return self.editingStyleForRowBlock(tableView, sectionModel, item);
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    QWListItem *item = [_sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.titleForDeleteConfirmationButtonForRowBlock) {
        return self.titleForDeleteConfirmationButtonForRowBlock(tableView, sectionModel, item);
    }
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    QWListItem *item = [_sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.commitEditingStyleBlock) {
        self.commitEditingStyleBlock(tableView, sectionModel, item);
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    QWListItem *item = [_sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.canMoveItemBlock) {
        return self.canMoveItemBlock(tableView, sectionModel, item);
    }
    return false;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    QWListSection *sourceSectionModel = _sections[sourceIndexPath.section];
    QWListItem *sourceItem = [_sectionItemsMap objectForKey:sourceSectionModel][sourceIndexPath.row];
    QWListSection *destinationSectionModel = _sections[destinationIndexPath.section];
    QWListItem *destinationItem = [_sectionItemsMap objectForKey:destinationSectionModel][destinationIndexPath.row];
    if (self.moveItemBlock) {
        self.moveItemBlock(tableView, sourceSectionModel, sourceItem, destinationSectionModel, destinationItem);
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
