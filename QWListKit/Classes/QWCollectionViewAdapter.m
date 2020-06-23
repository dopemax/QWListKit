//
//  QWCollectionViewAdapter.m
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import "QWCollectionViewAdapter.h"
#import <objc/runtime.h>
#import "UIView+QWListKit.h"

@interface QWCollectionViewAdapter ()

@property (nonatomic, copy) NSArray<QWListSection *> *sections;

@end

@implementation QWCollectionViewAdapter {
    NSMutableSet *_registeredCellReuseIdentifierSet;
    NSMutableSet *_registeredHeaderReuseIdentifierSet;
    NSMutableSet *_registeredFooterReuseIdentifierSet;
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
    }
    return self;
}

- (void)reloadListData {
    self.sections = [self.dataSource sectionsForCollectionViewAdapter:self];
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
    return sectionModel.isCollapsed ? 0 : sectionModel.items.count;
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
    id<QWListItem> item = self.sections[indexPath.section].items[indexPath.row];
    NSString *reuseIdentifier = item.viewReuseIdentifier;
    if (![_registeredCellReuseIdentifierSet containsObject:reuseIdentifier]) {
        [collectionView qw_registerClassIfFromNib:item.viewClass forCellWithReuseIdentifier:reuseIdentifier];
        [_registeredCellReuseIdentifierSet addObject:reuseIdentifier];
    }
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    id<QWListItem> item = self.sections[indexPath.section].items[indexPath.row];
    if ([cell conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> temp = (id<QWListBindable>)cell;
        if ([temp respondsToSelector:@selector(bindItem:)]) {
            [temp bindItem:item];
        }
    }
    if (self.willDisplayCellBlock) {
        self.willDisplayCellBlock(collectionView, cell, indexPath, item);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<QWListItem> item = self.sections[indexPath.section].items[indexPath.row];
    return item.viewSize;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    QWListSection *section = self.sections[indexPath.section];
    id<QWListItem> item;
    NSMutableSet *set;
    if (kind == UICollectionElementKindSectionHeader) {
        item = section.header;
        set = _registeredHeaderReuseIdentifierSet;
    } else if (kind == UICollectionElementKindSectionFooter) {
        item = section.footer;
        set = _registeredFooterReuseIdentifierSet;
    } else {
        return nil;
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
    QWListSection *section = self.sections[indexPath.section];
    id<QWListItem> item;
    if (elementKind == UICollectionElementKindSectionHeader) {
        item = section.header;
    } else if (elementKind == UICollectionElementKindSectionFooter) {
        item = section.footer;
    } else {
        return;
    }
    if ([view conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)view;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.willDisplaySupplementaryViewBlock) {
        self.willDisplaySupplementaryViewBlock(collectionView, view, elementKind, indexPath, item);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    id<QWListItem> item = self.sections[section].header;
    return item.viewSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    id<QWListItem> item = self.sections[section].footer;
    return item.viewSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.sections[indexPath.section].items[indexPath.row];
    if (self.didSelectRowBlock) {
        self.didSelectRowBlock(collectionView, indexPath, item);
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.sections[indexPath.section].items[indexPath.row];
    if (self.canMoveItemBlock) {
        return self.canMoveItemBlock(collectionView, indexPath, item);
    }
    return false;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id sourceItem = self.sections[sourceIndexPath.section].items[sourceIndexPath.row];
    id destinationItem = self.sections[destinationIndexPath.section].items[destinationIndexPath.row];
    if (self.moveItemBlock) {
        self.moveItemBlock(collectionView, sourceIndexPath, sourceItem, destinationIndexPath, destinationItem);
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
