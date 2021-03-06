//
//  CollectionCellView.h
//  TakaDating
//
//  Created by Sumit Ghosh on 04/12/14.
//  Copyright (c) 2014 Sumit Ghosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImageCountView.h"

@interface CollectionCellView : UIView

@property (nonatomic, strong)  UIImageView *profileImageView;
@property (nonatomic, strong)  UILabel *nameLabel,*toplabel;
@property (nonatomic, strong) UIImageView *loginIndicatorImageView;
@property(nonatomic,strong)UIButton *promoteButton,*togglebutton;
@property (nonatomic, strong) CustomImageCountView *customImageCounterView;
@property(nonatomic,strong)UIImageView * isOnlne,*toggleImgeView;
@end
