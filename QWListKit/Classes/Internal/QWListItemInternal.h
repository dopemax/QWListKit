//
//  QWListItem.m
//  QWListKit
//
//  Created by dopemax on 2020/7/14.
//  Copyright © 2020 dopemax. All rights reserved.
//

#import "QWListItem.h"

@interface QWListItem ()

@property (nonatomic, readwrite) NSIndexPath *indexPath;
@property (nonatomic, readwrite) BOOL isInFirstSection;
@property (nonatomic, readwrite) BOOL isInLastSection;
@property (nonatomic, readwrite) BOOL isFirstItemInSection;
@property (nonatomic, readwrite) BOOL isLastItemInSection;

@end



#import "QWListSection.h"

@interface QWListSection ()

@property (nonatomic, readwrite) NSInteger sectionIndex;
@property (nonatomic, readwrite) BOOL isFirstSection;
@property (nonatomic, readwrite) BOOL isLastSection;

@end


