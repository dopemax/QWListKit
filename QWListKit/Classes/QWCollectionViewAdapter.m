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

@interface QWCollectionViewAdapter () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, copy) NSArray<QWListSection *> *sections;

@end

@implementation QWCollectionViewAdapter {
    NSMutableSet *_registeredCellReuseIdentifierSet;
    NSMutableSet *_registeredHeaderFooterReuseIdentifierSet;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    if (self = [super init]) {
        _collectionView = collectionView;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        _registeredCellReuseIdentifierSet = NSMutableSet.new;
        _registeredHeaderFooterReuseIdentifierSet = NSMutableSet.new;
        _sections = @[];
    }
    return self;
}

- (void)reloadListData {
    self.sections = [self.dataSource sectionsForListAdapter:self];
    [_collectionView reloadData];
    
    if ([self.dataSource respondsToSelector:@selector(emptyViewForListAdapter:)]) {
        UIView *backgroundView = [self.dataSource emptyViewForListAdapter:self];
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
    return self.sections[section].items.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.sections[section].minimumInteritemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.sections[section].minimumLineSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.sections[section].sectionInset;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<QWListItem> item = self.sections[indexPath.section].items[indexPath.row];
    NSString *reuseIdentifier = item.viewReuseIdentifier;
    if (![_registeredCellReuseIdentifierSet containsObject:reuseIdentifier]) {
        [collectionView qw_registerClassIfFromNib:item.viewClass forCellWithReuseIdentifier:reuseIdentifier];
        [_registeredCellReuseIdentifierSet addObject:reuseIdentifier];
    }
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> temp = (id<QWListBindable>)cell;
        if ([temp respondsToSelector:@selector(bindItem:)]) {
            [temp bindItem:item];
        }
    }
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, indexPath, item);
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<QWListItem> item = self.sections[indexPath.section].items[indexPath.row];
    return item.viewSize;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    QWListSection *section = self.sections[indexPath.section];
    id<QWListItem> item;
    if (kind == UICollectionElementKindSectionHeader) {
        item = section.header;
    } else if (kind == UICollectionElementKindSectionFooter) {
        item = section.footer;
    } else {
        return nil;
    }
    NSString *reuseIdentifier = item.viewReuseIdentifier;
    if (![_registeredHeaderFooterReuseIdentifierSet containsObject:reuseIdentifier]) {
        [collectionView qw_registerClassIfFromNib:item.viewClass forSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier];
        [_registeredHeaderFooterReuseIdentifierSet addObject:reuseIdentifier];
    }
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if ([reusableView conformsToProtocol:@protocol(QWListBindable)]) {
        id<QWListBindable> bindable = (id<QWListBindable>)reusableView;
        if ([bindable respondsToSelector:@selector(bindItem:)]) {
            [bindable bindItem:item];
        }
    }
    if (self.configureSupplementaryViewBlock) {
        self.configureSupplementaryViewBlock(reusableView, kind, indexPath, item);
    }
    return reusableView;
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

@end




@implementation UICollectionView (QWListKit)

- (void)qw_registerClassIfFromNib:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    NSAssert([cellClass isSubclassOfClass:UICollectionViewCell.class], @"cellClass must be subclass of UICollectionViewCell");
    if ([cellClass qw_isFromNib]) {
        NSBundle *bundle = [NSBundle bundleForClass:cellClass];
        [self registerNib:[UINib nibWithNibName:cellClass.qw_className bundle:bundle] forCellWithReuseIdentifier:identifier];
    } else {
        [self registerClass:cellClass forCellWithReuseIdentifier:identifier];
    }
}

- (void)qw_registerClassIfFromNib:(Class)viewClass forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier {
    if ([viewClass qw_isFromNib]) {
        NSBundle *bundle = [NSBundle bundleForClass:viewClass];
        [self registerNib:[UINib nibWithNibName:viewClass.qw_className bundle:bundle] forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    } else {
        [self registerClass:viewClass forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    }
}

- (BOOL)qw_listIsEmpty {
    __block BOOL isEmpty = true;
    const NSInteger sections = [self.dataSource numberOfSectionsInCollectionView:self];
    for (NSInteger section = 0; section < sections; section++) {
        if ([self.dataSource collectionView:self numberOfItemsInSection:section] > 0) {
            isEmpty = false;
            break;
        }
    }
    return isEmpty;
}

- (NSUInteger)qw_listItemsCount {
    __block NSUInteger listItemsCount = 0;
    const NSInteger sections = [self.dataSource numberOfSectionsInCollectionView:self];
    for (NSInteger section = 0; section < sections; section++) {
        const NSInteger rows = [self.dataSource collectionView:self numberOfItemsInSection:section];
        listItemsCount += rows;
    }
    return listItemsCount;
}

@end
