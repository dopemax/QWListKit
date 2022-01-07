//
//  QWCollectionViewAdapter.m
//  QWListKit
//
//  Created by dopemax on 2018/12/14.
//  Copyright © 2018 dopemax. All rights reserved.
//

#import "QWCollectionViewAdapter.h"
#import "QWListItem.h"
#import "QWListItemInternal.h"
#import "QWListSection.h"
#import "UIView+QWListKit.h"

@interface QWCollectionViewAdapter ()

@property (nonatomic, copy) NSArray<QWListSection *> *sections;
@property (nonatomic, strong) NSMapTable<QWListSection *, NSMutableArray<QWListItem *> *> *sectionItemsMap;

@end

@implementation QWCollectionViewAdapter {
    NSMutableSet<NSString *> *_registeredCellReuseIdentifierSet;
    NSMutableDictionary<NSString *, NSMutableSet<NSString *> *> *_registeredSupplementaryReuseIdentifierMap;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    if (self = [super init]) {
        _collectionView = collectionView;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        _registeredCellReuseIdentifierSet = NSMutableSet.new;
        _registeredSupplementaryReuseIdentifierMap = @{}.mutableCopy;
        _sections = @[];
        _sectionItemsMap = [NSMapTable weakToWeakObjectsMapTable];
    }
    return self;
}

- (void)_updateBackgroundViewHidden {
    if ([self.dataSource respondsToSelector:@selector(emptyViewForCollectionViewAdapter:)]) {
        UIView *backgroundView = [self.dataSource emptyViewForCollectionViewAdapter:self];
        if (backgroundView != _collectionView.backgroundView) {
            [_collectionView.backgroundView removeFromSuperview];
            _collectionView.backgroundView = backgroundView;
        }
        _collectionView.backgroundView.hidden = ![self _listIsEmpty];
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

#pragma mark - Collection view data source & Collection view delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    self.sections = [self.dataSource sectionsForCollectionViewAdapter:self];
    
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    QWListSection *sectionModel = _sections[section];
    
    sectionModel.header.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    sectionModel.header.isInFirstSection = section == 0;
    sectionModel.header.isInLastSection = section == _sections.count - 1;
    
    sectionModel.footer.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    sectionModel.footer.isInFirstSection = section == 0;
    sectionModel.footer.isInLastSection = section == _sections.count - 1;
    
    for (NSMutableArray *supplementaryItems in sectionModel.supplementaryItemsMap.allValues) {
        for (NSInteger i = 0; i < supplementaryItems.count; i++) {
            QWListItem *item = supplementaryItems[i];
            item.indexPath = [NSIndexPath indexPathForItem:i inSection:section];
            item.isInFirstSection = section == 0;
            item.isInLastSection = section == _sections.count - 1;
            item.isFirstItemInSection = i == 0;
            item.isLastItemInSection = i == supplementaryItems.count - 1;
        }
    }
    
    NSArray *items = [_sectionItemsMap objectForKey:sectionModel];
    for (NSInteger i = 0; i < items.count; i++) {
        QWListItem *item = items[i];
        item.indexPath = [NSIndexPath indexPathForItem:i inSection:section];
        item.isInFirstSection = section == 0;
        item.isInLastSection = section == _sections.count - 1;
        item.isFirstItemInSection = i == 0;
        item.isLastItemInSection = i == items.count - 1;
    }
    
    if (sectionModel.isCollapsed) {
        return 0;
    } else {
        return [_sectionItemsMap objectForKey:sectionModel].count;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _sections[section].minimumInteritemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return _sections[section].minimumLineSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return _sections[section].inset;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    
    if (sectionModel.isCollapsed) return UICollectionViewCell.new;
    
    NSMutableArray<QWListItem *> *items = [_sectionItemsMap objectForKey:sectionModel];
    QWListItem *item = items[indexPath.row];
    NSString *reuseIdentifier = item.viewReuseIdentifier;
    if (![_registeredCellReuseIdentifierSet containsObject:reuseIdentifier]) {
        [collectionView qw_registerClassIfFromNib:item.viewClass forCellWithReuseIdentifier:reuseIdentifier];
        [_registeredCellReuseIdentifierSet addObject:reuseIdentifier];
    }
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    if (sectionModel.isCollapsed) return;
    
    NSMutableArray<QWListItem *> *items = [_sectionItemsMap objectForKey:sectionModel];
    QWListItem *item = items[indexPath.row];
    
    if ([cell conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> temp = (id<QWListBindable>)cell;
        if ([temp respondsToSelector:@selector(bindItem:)]) {
            [temp bindItem:item];
        }
    }
    if (self.willDisplayCellBlock) {
        self.willDisplayCellBlock(collectionView, cell, sectionModel, item);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    if (sectionModel.isCollapsed) return CGSizeZero;
    
    QWListItem *item = [_sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (item.viewSizeBlock) {
        const CGSize size = item.viewSizeBlock(collectionView, sectionModel);
        return size;
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    
    QWListSupplementaryItem *item;
    if ([sectionModel.header.elementKind isEqualToString:kind]) {
        item = sectionModel.header;
    } else if ([sectionModel.footer.elementKind isEqualToString:kind]) {
        item = sectionModel.footer;
    }
    
    if (!item) {
        NSMutableArray *supplementaryItems = sectionModel.supplementaryItemsMap[kind];
        if (indexPath.row < supplementaryItems.count) {
            item = supplementaryItems[indexPath.row];
        }
    }
    
    if (!item) return nil;
    
    NSMutableSet *set = _registeredSupplementaryReuseIdentifierMap[kind];
    if (!set) {
        set = NSMutableSet.new;
        _registeredSupplementaryReuseIdentifierMap[kind] = set;
    }
    NSString *reuseIdentifier = item.viewReuseIdentifier;
    if (![set containsObject:reuseIdentifier]) {
        [collectionView qw_registerClassIfFromNib:item.viewClass forSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier];
        [set addObject:reuseIdentifier];
    }
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    QWListSupplementaryItem *item;
    if ([sectionModel.header.elementKind isEqualToString:elementKind]) {
        item = sectionModel.header;
    } else if ([sectionModel.footer.elementKind isEqualToString:elementKind]) {
        item = sectionModel.footer;
    }
    
    if (!item) {
        NSMutableArray *supplementaryItems = sectionModel.supplementaryItemsMap[elementKind];
        if (indexPath.row < supplementaryItems.count) {
            item = supplementaryItems[indexPath.row];
        }
    }
    
    if (!item) return;
    
    if ([view conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)view;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplaySupplementaryViewBlock) {
        self.willDisplaySupplementaryViewBlock(collectionView, view, elementKind, sectionModel, item);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    QWListSection *sectionModel = _sections[section];
    QWListItem *item = sectionModel.header;
    if (item.viewSizeBlock) {
        const CGSize size = item.viewSizeBlock(collectionView, sectionModel);
        return size;
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    QWListSection *sectionModel = _sections[section];
    QWListItem *item = sectionModel.footer;
    if (item.viewSizeBlock) {
        const CGSize size = item.viewSizeBlock(collectionView, sectionModel);
        return size;
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    QWListItem *item = [_sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.didSelectItemBlock) {
        self.didSelectItemBlock(collectionView, sectionModel, item);
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = _sections[indexPath.section];
    QWListItem *item = [_sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.canMoveItemBlock) {
        return self.canMoveItemBlock(collectionView, sectionModel, item);
    }
    return false;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    QWListSection *sourceSectionModel = _sections[sourceIndexPath.section];
    QWListItem *sourceItem = [_sectionItemsMap objectForKey:sourceSectionModel][sourceIndexPath.row];
    QWListSection *destinationSectionModel = _sections[destinationIndexPath.section];
    QWListItem *destinationItem = [_sectionItemsMap objectForKey:destinationSectionModel][destinationIndexPath.row];
    if (self.moveItemBlock) {
        self.moveItemBlock(collectionView, sourceSectionModel, sourceItem, destinationSectionModel, destinationItem);
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
