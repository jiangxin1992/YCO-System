//
//  DD_GoodsViewController.h
//  DDAY
//
//  Created by yyj on 16/5/20.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseViewController.h"

@interface DD_GoodsViewController : DD_BaseViewController

//__bool(noTabbar);
@property(nonatomic,assign) BOOL noTabbar;

-(void)reload;

-(void)loadNewData;

@end
