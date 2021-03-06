//
//  DD_CircleChooseDetailView.m
//  DDAY
//
//  Created by yyj on 16/6/20.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_CircleChooseDetailView.h"

//#import "DD_GoodsDetailViewController.h"
#import "MJRefresh.h"

#import "Waterflow.h"
#import "WaterflowCell.h"
#import "DD_CircleSearchView.h"

#import "DD_CirclePublishTool.h"
#import "DD_CricleChooseItemModel.h"
#import "Tools.h"
#import "DD_ImageModel.h"
#import "DD_CircleModel.h"
//#import "DD_ItemsModel.h"
//#import "DD_CricleCategoryModel.h"

@interface DD_CircleChooseDetailView ()<WaterflowDataSource,WaterflowDelegate>

@end

@implementation DD_CircleChooseDetailView
{
    UIView *_upView;//上部view
    UIView *_downView;//下部view
    UIView *_chooseImgBackView;
    Waterflow *mywaterflow;
    UIScrollView *_scrollView;
    
    CGFloat _width;//已选款式view宽度
    CGFloat intes;
    long _page;//当前页
    NSString *queryStr;//关键词
    NSMutableArray *btnArr;//存放的按钮数组
    NSMutableArray *_dataArr;//当前款式列表数据
    
    UIButton *searchBtn;
    DD_CircleSearchView *_searchView;

//    void (^cellblock)(NSString *type,NSInteger index);//cell回调block
    //    NSString *categoryCode;//当前选择分类code
    //    UILabel *_numLabel;//剩余可选款数
    //    UIButton *_screeningBtn;//选择分类按钮
    //    UITableView *_tableView;//选择款式tableview
    //    UITableView *_chooseTableView;//下拉框
    //    BOOL _isShow;// 当前下拉框是否显示
    //    NSMutableArray *_categoryArr;//下拉框数据
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}
#pragma mark - 初始化
-(instancetype)initWithCircleModel:(DD_CircleModel *)CircleModel WithLimitNum:(NSInteger )num WithBlock:(void (^)(NSString *type,NSInteger index))block
{
    self=[super init];
    if(self)
    {
        _circleModel=CircleModel;
        _block=block;
        _num=num;
    }
    return self;
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
//    [self SomeBlock];
}

-(void)PrepareData
{
    btnArr=[[NSMutableArray alloc] init];
    _dataArr=[[NSMutableArray alloc] init];
    _page=1;
    queryStr=@"";
    intes=12;//间距为12
    _width=(ScreenWidth-intes*2-kEdge*2)/3.0f;
    //    _categoryArr=[[NSMutableArray alloc] init];
    //    _isShow=NO;
    //    categoryCode=@"";
}
-(void)PrepareUI
{
    self.navigationItem.titleView=[regular returnNavView:@"款式选择" withmaxwidth:200];
}

#pragma mark - UIConfig
-(void)UIConfig
{
    [self CreateUpView];
    [self createDoneView];
    [self CreateImgView];
    [self CreateDownView];
    
}
-(void)CreateUpView
{
    [self initUpView];
    [self CreateSearchBar];
}
-(void)initUpView
{
    _upView=[UIView getCustomViewWithColor:nil];
    [self.view addSubview:_upView];
    [_upView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(ScreenWidth);
        make.top.mas_equalTo(kStatusBarAndNavigationBarHeight);
        make.height.mas_equalTo(42);
    }];
}
-(void)CreateSearchBar
{
    UIView *searchView=[UIView getCustomViewWithColor:nil];
    [_upView addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(6);
        make.height.mas_equalTo(30);
    }];
    
    UIView *backView = [UIView getCustomViewWithColor:_define_light_gray_color3];
    [searchView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20+25+10);
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-20);
    }];
    backView.layer.masksToBounds=YES;
    backView.layer.cornerRadius=4;
    
//    31 22
    searchBtn=[UIButton getCustomTitleBtnWithAlignment:1 WithFont:12.0f WithSpacing:0 WithNormalTitle:[queryStr isEqualToString:@""]?@"请输入设计师、品牌、款式名称":queryStr WithNormalColor:_define_light_gray_color1 WithSelectedTitle:nil WithSelectedColor:nil];
    [searchView addSubview:searchBtn];
    [searchBtn setImage:[UIImage imageNamed:@"System_Search"] forState:UIControlStateNormal];
    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(3, 20, 3, ScreenWidth-19-25-kEdge)];
    [searchBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 0)];
    [searchBtn addTarget:self action:@selector(ShowSearchView) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.mas_equalTo(0);
        make.right.mas_equalTo(-kEdge);
    }];
    
}
-(void)UpdateImgView
{
    [btnArr enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        [btn removeFromSuperview];
    }];
    [self CreateImgSubView];
//    _numLabel.text=[[NSString alloc] initWithFormat:@"还可选择%ld款",_num-_circleModel.chooseItem.count];
}
-(void)CreateImgView
{
    [self CreateImgBackView];
    [self CreateImgSubView];
}
-(void)CreateImgBackView
{
    _chooseImgBackView=[UIView getCustomViewWithColor:_define_white_color];
    [self.view addSubview:_chooseImgBackView];
    [_chooseImgBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(- kInteractionHeight - kSafetyZoneHeight);
    }];
}
-(void)CreateImgSubView
{
    if(_circleModel.chooseItem.count)
    {
        [_chooseImgBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(_width+21+12);
        }];
        [_downView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-_width-21-12- kInteractionHeight -kSafetyZoneHeight);
        }];
        [mywaterflow mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_downView);
        }];
        
        if(!_scrollView)
        {
            _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(kEdge, 0, ScreenWidth-kEdge*2, _width+21+12)];
            [_chooseImgBackView addSubview:_scrollView];
            _scrollView.showsHorizontalScrollIndicator=NO;
        }
        _scrollView.contentSize=CGSizeMake((_circleModel.chooseItem.count-1)*intes+_width*_circleModel.chooseItem.count, _width);
        __block CGFloat _x_p=0;
        
        [_circleModel.chooseItem enumerateObjectsUsingBlock:^(DD_CricleChooseItemModel *item, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *backView=[UIView getCustomViewWithColor:nil];
            [_scrollView addSubview:backView];
            backView.frame=CGRectMake(_x_p, 12, _width, _width);
            
            UIImageView *imgView=[UIImageView getCustomImg];
            [backView addSubview:imgView];
            imgView.contentMode=2;
            [regular setZeroBorder:imgView];
            imgView.userInteractionEnabled=YES;
            imgView.frame=CGRectMake(0, 16, _width-16, _width-16);
            [imgView JX_ScaleAspectFill_loadImageUrlStr:item.pic.pic WithSize:400 placeHolderImageName:nil radius:0];
            
            CGFloat _p_w=[regular getWidthWithHeight:40 WithContent:[[NSString alloc] initWithFormat:@"￥%@",item.price] WithFont:[regular getSemiboldFont:12.0f]];
            UILabel *priceLabel=[UILabel getLabelWithAlignment:1 WithTitle:[[NSString alloc] initWithFormat:@"￥%@",item.price] WithFont:12.0f WithTextColor:_define_white_color WithSpacing:0];
            [imgView addSubview:priceLabel];
            priceLabel.font=[regular getSemiboldFont:12.0f];
            priceLabel.backgroundColor=_define_black_color;
            [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.mas_equalTo(0);
                make.width.mas_equalTo(_p_w+5);
            }];
            
            UIButton *deleteBtn=[UIButton getCustomImgBtnWithImageStr:@"System_Delete" WithSelectedImageStr:nil];
            [backView addSubview:deleteBtn];
            deleteBtn.tag=150+idx;
            [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            [deleteBtn setEnlargeEdge:10];
            deleteBtn.frame=CGRectMake(CGRectGetWidth(backView.frame)-25-3.5, 3.5, 25, 25);
            
            _x_p+=_width+intes;
            
            [btnArr addObject:backView];
        }];
        
    }else
    {
        [_chooseImgBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [_downView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(- kInteractionHeight - kSafetyZoneHeight);
        }];
        [mywaterflow mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_downView);
        }];


    }
}
-(void)createDoneView
{
    UIButton *doneBtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:18.0f WithSpacing:0 WithNormalTitle:@"完   成" WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
    [self.view addSubview:doneBtn];
    doneBtn.backgroundColor=_define_black_color;
    [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kInteractionHeight);
        make.bottom.mas_equalTo(-kSafetyZoneHeight);
    }];
}

-(void)CreateDownView
{
    [self initDownView];
    [self CreateWaterFlow];
    [self MJRefresh];
}
-(void)initDownView
{
    _downView=[[UIView alloc] init];
    [self.view addSubview:_downView];
    [_downView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(ScreenWidth);
        make.top.mas_equalTo(_upView.mas_bottom).with.offset(20);
        make.bottom.mas_equalTo(_chooseImgBackView.mas_top).with.offset(0);
    }];
    
}
-(void)CreateWaterFlow
{
    mywaterflow = [[Waterflow alloc] init];
    [_downView addSubview:mywaterflow];
    mywaterflow.dataSource = self;
    
    mywaterflow.delegate = self;
    
    [mywaterflow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_downView);
    }];
  
}

#pragma mark - RequestData
-(void)RequestData
{

    NSDictionary *_parameters=@{@"queryStr":queryStr,@"page":[NSNumber numberWithLong:_page],@"token":[DD_UserModel getToken]};
    [[JX_AFNetworking alloc] GET:@"item/queryColorItemsByParam.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            if(_page==1)
            {
                [_dataArr removeAllObjects];//删除所有数据
            }
            NSArray *getarr=[DD_CricleChooseItemModel getItemsModelArr:[data objectForKey:@"items"] WithDetail:_circleModel.chooseItem];
            [_dataArr addObjectsFromArray:getarr];
            [mywaterflow reloadData];
        }else
        {
            if(_page==1)
            {
                [_dataArr removeAllObjects];//删除所有数据
            }
            [mywaterflow reloadData];
            [self presentViewController:successAlert animated:YES completion:nil];
        }
        [mywaterflow.mj_header endRefreshing];
        [mywaterflow.mj_footer endRefreshing];
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
        [mywaterflow.mj_header endRefreshing];
        [mywaterflow.mj_footer endRefreshing];
    }];
}
#pragma mark - WaterflowDelegate
// cell的个数，必须实现
- (NSUInteger)numberOfCellsInWaterflow:(Waterflow *)waterflow{
    
    return _dataArr.count+1;
}
// 返回cell，必须实现
- (WaterflowCell *)waterflow:(Waterflow *)waterflow cellAtIndex:(NSUInteger)index{
    if(index)
    {
        DD_CricleChooseItemModel *item=_dataArr[index-1];
        CGFloat _height=((ScreenWidth-water_margin*2-water_Spacing)/2.0f)*([item.pic.height floatValue]/[item.pic.width floatValue]);
        return [[DD_CirclePublishTool alloc] getCustomWaterflowCell:waterflow cellAtIndex:index-1 WithItemsModel:item WithHeight:_height WithBlock:^(NSString *type,NSInteger _index) {
            DD_CricleChooseItemModel *_itemModel=_dataArr[_index];
            if(!_itemModel.isSelect)
            {
                _itemModel.isSelect=YES;
                if(_circleModel.chooseItem.count<_num)
                {
                    [_circleModel.chooseItem addObject:_dataArr[_index]];
                    //                _numLabel.text=[[NSString alloc] initWithFormat:@"还可选择%ld款",___num-___chooseItem.count];
                }else
                {
                    [self presentViewController:[regular alertTitle_Simple:[[NSString alloc] initWithFormat:@"最多可选择%ld款",_num]] animated:YES completion:nil];
                }
                [self UpdateImgView];
            }else
            {
                _itemModel.isSelect=NO;
                _block(@"delete_choose_item",_index);
                [self UpdateImgView];
            }
            [waterflow reloadData];
        }];
    }else
    {
        return [WaterflowCell waterflowCellWithWaterflow:waterflow];
    }
}
// 这个方法可选不是必要的，默认是3列
- (NSUInteger)numberOfColumnsInWaterflow:(Waterflow *)waterflow{
    return 2;
}
// 返回每一个cell的高度，非必要，默认为80
- (CGFloat)waterflow:(Waterflow *)waterflow heightAtIndex:(NSUInteger)index{
    if(index)
    {
        DD_CricleChooseItemModel *item=_dataArr[index-1];
        if(item.pic)
        {
            CGFloat _height=((ScreenWidth-water_margin*2-water_Spacing)/2.0f)*([item.pic.height floatValue]/[item.pic.width floatValue]);
            return _height+56+water_Top;
        }
        return 56+water_Top+44;
    }else
    {
        return 0;
    }
    
}
// 间隔，非必要，默认均为10
- (CGFloat)waterflow:(Waterflow *)waterflow marginOfWaterflowMarginType:(WaterflowMarginType)type{
    switch (type) {
            
            case WaterflowMarginTypeLeft:return water_margin;
            case WaterflowMarginTypeRight:return water_margin;
            case WaterflowMarginTypeRow:return water_Spacing;
            case WaterflowMarginTypeColumn:return 0;
//            case WaterflowMarginTypeColumn:return water_Bottom;
            case WaterflowMarginTypeBottom:return water_Bottom;
            default:return 0;
    }
}
// 非必要
- (void)waterflow:(Waterflow *)waterflow didSelectCellAtIndex:(NSUInteger)index{
    if(index)
    {
        DD_CricleChooseItemModel *_itemModel=_dataArr[index-1];
        if(!_itemModel.isSelect)
        {
            
            if(_circleModel.chooseItem.count<_num)
            {
                _itemModel.isSelect=YES;
                [_circleModel.chooseItem addObject:_dataArr[index-1]];
                //                _numLabel.text=[[NSString alloc] initWithFormat:@"还可选择%ld款",___num-___chooseItem.count];
            }else
            {
                [self presentViewController:[regular alertTitle_Simple:[[NSString alloc] initWithFormat:@"最多可选择%ld款",_num]] animated:YES completion:nil];
            }
            [self UpdateImgView];
        }else
        {
            //            删除已选款式
            DD_CricleChooseItemModel *item=_dataArr[index-1];
            item.isSelect=NO;
            //    删除item 对应的已选款式
            [DD_CirclePublishTool delChooseItemModel:item WithCircleModel:_circleModel];
            
            _block(@"delete_choose_item",index-1);
            [self UpdateImgView];
        }
        [waterflow reloadData];
    }
}
#pragma mark - SomeAction
-(void)doneAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)ShowSearchView
{
    _searchView=[[DD_CircleSearchView alloc] initWithQueryStr:queryStr WithChooseItem:_circleModel.chooseItem WithBlock:^(NSString *type, NSString *_queryStr,DD_CricleChooseItemModel *chooseItemModel) {
        if([type isEqualToString:@"back"])
        {
            [_searchView removeFromSuperview];
        }else if([type isEqualToString:@"search"])
        {
            queryStr=_queryStr;
            [searchBtn setTitle:queryStr forState:UIControlStateNormal];
            [mywaterflow.mj_header beginRefreshing];
            [_searchView removeFromSuperview];
        }
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view addSubview:_searchView];
}
-(void)MJRefresh
{
    //    MJRefreshNormalHeader *header= [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    NSArray *refreshingImages=[regular getGifImg];
    
    //     Set the ordinary state of animated images
    [header setImages:refreshingImages duration:1.5 forState:MJRefreshStateIdle];
    //     Set the pulling state of animated images（Enter the status of refreshing as soon as loosen）
    [header setImages:refreshingImages duration:1.5 forState:MJRefreshStatePulling];
    //     Set the refreshing state of animated images
    [header setImages:refreshingImages duration:1.5 forState:MJRefreshStateRefreshing];
    
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    mywaterflow.mj_header = header;
    
    MJRefreshAutoNormalFooter *_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [_footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    [_footer setTitle:@"" forState:MJRefreshStateIdle];
    [_footer setTitle:@"" forState:MJRefreshStatePulling];
    [_footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [_footer setTitle:@"" forState:MJRefreshStateWillRefresh];
    _footer.refreshingTitleHidden = YES;
    _footer.stateLabel.textColor = _define_light_gray_color1;
    mywaterflow.mj_footer = _footer;
    
    [mywaterflow.mj_header beginRefreshing];
}
-(void)loadNewData
{
    // 进入刷新状态后会自动调用这个block
    _page=1;
    [self RequestData];
}
-(void)loadMoreData
{
    // 进入刷新状态后会自动调用这个block
    _page+=1;
    [self RequestData];
}
/**
 * 删除已选款式
 */
-(void)deleteAction:(UIButton *)btn
{
    //            删除已选款式
    DD_CricleChooseItemModel *item=_circleModel.chooseItem[btn.tag-150];
    item.isSelect=NO;
    //    删除item 对应的已选款式
    [DD_CirclePublishTool delChooseItemModel:item WithCircleModel:_circleModel];
    
    _block(@"delete_choose_item",btn.tag-150);
    [self UpdateImgView];
    [mywaterflow reloadData];
    
}

#pragma mark - Others
-(void)viewWillDisappear:(BOOL)animated
{
    _block(@"choose_item",0);
    [super viewWillDisappear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 弃用代码

@end
