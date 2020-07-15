//
//  QWCollectionViewAdapter.m
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
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
    NSMutableSet<NSString *> *_registeredHeaderReuseIdentifierSet;
    NSMutableSet<NSString *> *_registeredFooterReuseIdentifierSet;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    if (self = [super init]) {
        _collectionView = collectionView;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        _registeredCellReuseIdentifierSet = NSMutableSet.new;
        _registeredHeaderReuseIdentifierSet = NSMutableSet.new;
        _registeredFooterReuseIdentifierSet = NSMutableSet.new;
        _sections = @[];
        _sectionItemsMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (void)reloadListData {
    self.sections = [self.dataSource sectionsForCollectionViewAdapter:self];
    for (QWListSection *section in self.sections) {
        if (self.sectionItemsFilterBlock) {
            [self.sectionItemsMap setObject:self.sectionItemsFilterBlock(section) forKey:section];
        } else {
            [self.sectionItemsMap setObject:section.items forKey:section];
        }
    }
    [_collectionView reloadData];
    
    if ([self.dataSource respondsToSelector:@selector(emptyViewForCollectionViewAdapter:)]) {
        UIView *backgroundView = [self.dataSource emptyViewForCollectionViewAdapter:self];
        if (backgroundView != _collectionView.backgroundView) {
            [_collectionView.backgroundView removeFromSuperview];
            _collectionView.backgroundView = backgroundView;
        }
        _collectionView.backgroundView.hidden = ![_collectionView qw_listIsEmpty];
    }
}

#pragma mark - Collection view data source & Collection view delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    QWListSection *sectionModel = self.sections[section];
    if (sectionModel.isCollapsed) {
        return 0;
    } else {
        return [self.sectionItemsMap objectForKey:sectionModel].count;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.sections[section].minimumInteritemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.sections[section].minimumLineSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.sections[section].inset;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    if (sectionModel.isCollapsed) return UICollectionViewCell.new;
    
    NSMutableArray<QWListItem *> *items = [self.sectionItemsMap objectForKey:sectionModel];
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
        id<QWListBindable> temp = (id<QWListBindable>)cell;
        if ([temp respondsToSelector:@selector(bindItem:)]) {
            [temp bindItem:item];
        }
    }
    if (self.willDisplayCellBlock) {
        self.willDisplayCellBlock(self, cell, sectionModel, item);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    if (sectionModel.isCollapsed) return CGSizeZero;
    
    QWListItem *item = [self.sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (item.viewSizeBlock) {
        return item.viewSizeBlock(collectionView, sectionModel.inset);
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    QWListItem *item;
    NSMutableSet *set;
    if (kind == UICollectionElementKindSectionHeader) {
        item = sectionModel.header;
        set = _registeredHeaderReuseIdentifierSet;
    } else if (kind == UICollectionElementKindSectionFooter) {
        item = sectionModel.footer;
        set = _registeredFooterReuseIdentifierSet;
    }
    
    if (!item) return nil;
    
    NSString *reuseIdentifier = item.viewReuseIdentifier;
    if (![set containsObject:reuseIdentifier]) {
        [collectionView qw_registerClassIfFromNib:item.viewClass forSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier];
        [set addObject:reuseIdentifier];
    }
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    QWListItem *item;
    if (elementKind == UICollectionElementKindSectionHeader) {
        item = sectionModel.header;
    } else if (elementKind == UICollectionElementKindSectionFooter) {
        item = sectionModel.footer;
    }
    
    if (!item) return;
    
    item.indexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    item.isInFirstSection = indexPath.section == 0;
    item.isInLastSection = indexPath.section == self.sections.count - 1;
    
    if ([view conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)view;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplaySupplementaryViewBlock) {
        self.willDisplaySupplementaryViewBlock(self, view, elementKind, sectionModel, item);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    QWListSection *sectionModel = self.sections[section];
    QWListItem *item = sectionModel.header;
    if (item.viewSizeBlock) {
        return item.viewSizeBlock(collectionView, sectionModel.inset);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    QWListSection *sectionModel = self.sections[section];
    QWListItem *item = sectionModel.footer;
    if (item.viewSizeBlock) {
        return item.viewSizeBlock(collectionView, sectionModel.inset);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    QWListItem *item = [self.sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.didSelectItemBlock) {
        self.didSelectItemBlock(self, sectionModel, item);
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    QWListSection *sectionModel = self.sections[indexPath.section];
    QWListItem *item = [self.sectionItemsMap objectForKey:sectionModel][indexPath.row];
    if (self.canMoveItemBlock) {
        return self.canMoveItemBlock(self, sectionModel, item);
    }
    return false;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
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
