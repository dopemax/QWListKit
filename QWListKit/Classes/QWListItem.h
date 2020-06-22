//
//  QWListItem.h
//  QWListKit
//
//  Created by guawaji on 2018/12/14.
//  Copyright © 2018 guawaji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QWListBindable;

@protocol QWListItem

- (Class<QWListBindable>)viewClass;
- (NSString *)viewReuseIdentifier;
- (CGSize)viewSize;

@end



@protocol QWListBindable <NSObject>

- (void)bindItem:(id<QWListItem>)item;

@end

NS_ASSUME_NONNULL_END
