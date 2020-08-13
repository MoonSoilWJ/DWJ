//
//  RBBJDCViewController.m
//  Rainbow
//
//  Created by 单车 on 2020/3/18.
//  Copyright © 2020 gwh. All rights reserved.
//
//----------viewController
#import "RBBJDCViewController.h"
#import "RBDJDCConfirmViewController.h"
#import "RBOnListRuleViewController.h"

//----------view
#import "RBBJDCSectionHeadView.h"
#import "RBBJDCCell.h"
#import "RBBJDCScreenView.h"
#import "NoContentReminderView.h"

//----------model
#import "RBBJDCModel.h"

@interface RBBJDCViewController ()
<UITableViewDelegate,
UITableViewDataSource,
RBBJDCSectionHeadViewDelegate,
RBBJDCScreenViewDelegate>
{
    NSDictionary *_response;
    BOOL flag[1];
    NSInteger selectCount;

}
/** 数据模型 */
@property(nonatomic,strong)RBBJDCModel *bjdcModel;

/** 列表视图 */
@property(nonatomic,strong)UITableView *bjdcTableView;

/** 筛选视图 */
@property(nonatomic,retain) RBBJDCScreenView *selectedView;

@property(nonatomic,strong)UIView *bottomView;
/** 底部视图Label */
@property(nonatomic,weak)UILabel *bottomlabel;


/** 赛事选中的比赛数据 */
//@property(nonatomic,strong)NSMutableArray *selectedRaceMuArr;

@property(nonatomic,retain) NoContentReminderView *noDataView;

/** 通知 */
@property (nonatomic,weak)id notice;
@end

static NSString *const cellId = @"cellId";
static NSString *const sectionHeadId = @"sectionHeadId";

@implementation RBBJDCViewController

#pragma mark -lazy
-(NoContentReminderView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[NoContentReminderView alloc] initWithFrame:CGRectMake(0, STATUS_AND_NAV_BAR_HEIGHT, SCREEN_WIDTH, (SCREEN_HEIGHT - STATUS_AND_NAV_BAR_HEIGHT - (RH(50)+HOME_INDICATOR_HEIGHT))) withNoContentStyle:NoContentReminderNoDataError];
    }
    return _noDataView;
}
/** 表视图 */
- (UITableView *)bjdcTableView{
    if (_bjdcTableView == nil) {
        _bjdcTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, STATUS_AND_NAV_BAR_HEIGHT, SCREEN_WIDTH, (SCREEN_HEIGHT - STATUS_AND_NAV_BAR_HEIGHT - (RH(50)+HOME_INDICATOR_HEIGHT))) style:UITableViewStylePlain];
        _bjdcTableView.delegate = self;
        _bjdcTableView.dataSource = self;
        [_bjdcTableView registerClass:[RBBJDCCell class] forCellReuseIdentifier:cellId];
        [_bjdcTableView registerClass:[RBBJDCSectionHeadView class] forHeaderFooterViewReuseIdentifier:sectionHeadId];
        
        [_bjdcTableView setRowHeight:RH(106)];
        _bjdcTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _bjdcTableView.separatorInset = UIEdgeInsetsMake(10, 0, 0, 10);
        
        [_bjdcTableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
        
    }
    return _bjdcTableView;
}
- (UIView *)bottomView{
    if (_bottomView == nil) {
        UIView *bottomView=[[UIView alloc]init];
        CGFloat bottomViewH = RH(50) + HOME_INDICATOR_HEIGHT;
        bottomView.frame = CGRectMake(0, SCREEN_HEIGHT - bottomViewH, SCREEN_WIDTH, bottomViewH);
        bottomView.backgroundColor=[UIColor whiteColor];

        //2.1 grayLine
        UIView *grayLineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
//        grayLineView.backgroundColor=[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
        grayLineView.backgroundColor = UIColorFromRGB(0xF8F8F8);
        [bottomView addSubview:grayLineView];

        //2.2 label
        UILabel*bottomLabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, SCREEN_WIDTH-160, RH(50))];
        bottomLabel.font=[UIFont systemFontOfSize:14];
        bottomLabel.text=@"已选0场";
        bottomLabel.textColor=[UIColor blackColor];
        bottomLabel.textAlignment=NSTextAlignmentCenter;
        self.bottomlabel = bottomLabel;
        [bottomView addSubview:bottomLabel];

        //2.4 deleteBtn
        UIButton *delButton=[UIButton buttonWithType:UIButtonTypeCustom];
        delButton.frame=CGRectMake(20, 7, RH(25), RH(25));
        [bottomView addSubview:delButton];
        [delButton setBackgroundImage:[UIImage imageNamed:@"清空.png"] forState:UIControlStateNormal];
        [delButton setBackgroundImage:[UIImage imageNamed:@"清空1.png"] forState:UIControlStateHighlighted];
        [delButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [delButton addTarget:self action:@selector(emptyAction) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:delButton];

        UILabel *qingkongTextLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, delButton.bottom, 65, 10)];
        [bottomView addSubview:qingkongTextLabel];
        qingkongTextLabel.text=@"清空";
        qingkongTextLabel.textAlignment=NSTextAlignmentCenter;
        qingkongTextLabel.textColor=[UIColor grayColor];
        qingkongTextLabel.font=[UIFont systemFontOfSize:10];
        [bottomView addSubview:qingkongTextLabel];
        
        CC_Button *nextBtn = [CC_Button buttonWithType:(UIButtonTypeCustom)];
        nextBtn.frame = CGRectMake(SCREEN_WIDTH - RH(75), RH(10), RH(65), RH(30));
        [nextBtn setTitle:@"下一步" forState:(UIControlStateNormal)];
        [nextBtn setTitleColor:rgba(255, 255, 255, 1) forState:(UIControlStateNormal)] ;
        nextBtn.backgroundColor = rgba(255, 52, 36, 1) ;
        nextBtn.titleLabel.font = [ccui getRFS:14] ;
        nextBtn.clipsToBounds = YES ;
        nextBtn.layer.cornerRadius = 5;
//        nextBtn.hidden = YES ;
        [bottomView addSubview:nextBtn];
        [nextBtn addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
        
        _bottomView = bottomView;
    }
    return _bottomView;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.bjdcTableView reloadData];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
    selectCount = 0;
    [self.view addSubview:self.bjdcTableView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.noDataView];

    [self bjdcSellableIssueQuery];

//    WS(weakSelf);
    _notice = [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_DEL_COMPETITION_DATA_BJDC object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [self bjdcSellableIssueQuery];
    }];
}


- (void)setNav{
    [self setUserDefinedNavigationBar];
    [self setUdNavBarTitle:@"胜平负"];
    [self.UD_navigationBarView.titleLabel sizeToFit];
    CGRect titleLabelFrame = self.UD_navigationBarView.titleLabel.frame;
    
    titleLabelFrame.origin.x = (SCREEN_WIDTH - titleLabelFrame.size.width)/2;
    titleLabelFrame.origin.y = STATUS_BAR_HEIGHT;
    titleLabelFrame.size.height = 44;
    self.UD_navigationBarView.titleLabel.frame = titleLabelFrame;
    
    CC_Button *tipBtn = [[CC_Button alloc]initWithFrame:CGRectMake(self.UD_navigationBarView.titleLabel.right, (self.UD_navigationBarView.titleLabel.centerY - RH(15)), RH(30), RH(30))];
    [tipBtn setImage:Img(@"white_bill_icon") forState:UIControlStateNormal];
    WS(weakSelf);
    [tipBtn addTappedOnceDelay:0.5 withBlock:^(UIButton *button) {
        SS(strongSelf);
        RBOnListRuleViewController *listRuleVC = [[RBOnListRuleViewController alloc]init];
        listRuleVC.infoCode=@"BJDC_PALY_RULE";
        listRuleVC.titleStr = @"北京单场玩法说明";
        [strongSelf.navigationController pushViewController:listRuleVC animated:YES];
        
    }];
    [self.UD_navigationBarView addSubview:tipBtn];
    
    CC_Button *selectButton=[[CC_Button alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-30, STATUS_BAR_HEIGHT+19, 15, 15)];
    [selectButton setBackgroundImage:[UIImage imageNamed:@"shaixuan"] forState:UIControlStateNormal];
    [self.view addSubview:selectButton];
    [selectButton addTarget:self action:@selector(selectButtonTapped) forControlEvents:UIControlEventTouchUpInside];

}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return self.RBBJDCModel.bjdcIssueDataList.count;
    return self.bjdcModel.bjdcIssueDataScreenList.count;
}
- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return RH(44);
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    RBBJDCSectionHeadView *sectionHeadView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:sectionHeadId];
    sectionHeadView.delegate = self;
    sectionHeadView.tag = section;
    BOOL f = flag[section]; //NO :展开
    sectionHeadView.headButton.selected = f;
    
    RBBJDCIssueModel *issue = self.bjdcModel.bjdcIssueDataScreenList[section];
    NSString *titleStr = [NSString stringWithFormat:@"第%@期  %zi场比赛可以选",issue.issueNo,issue.dataList.count];
    [sectionHeadView setTitleString:titleStr];
    return sectionHeadView;

}
- (CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return RH(10);
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *grayFootView = [[UIView alloc]init];
    grayFootView.backgroundColor = UIColorFromRGB(0xF8F8F8);
    return grayFootView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    RBBJDCIssueModel *issue = self.bjdcModel.bjdcIssueDataScreenList[section];

    BOOL f = flag[section]; //NO :展开
    if(f){
        return 0;  //场景列表不展开
    }
    else{
        return issue.dataList.count;
        
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RBBJDCIssueModel *issue = self.bjdcModel.bjdcIssueDataScreenList[indexPath.section];
    RBBJDCDataModel *data = issue.dataList[indexPath.row];
    
    NSLog(@"%@",data);
    
    RBBJDCCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.race = data;
    WS(weakSelf)
    cell.btnSelected = ^(RBBJDCDataModel * _Nonnull race) {
        SS(strongSelf)
        //先清空数据
        for (RBBJDCIssueModel *issure in strongSelf.bjdcModel.bjdcIssueDataList) {
            [issure.dataList enumerateObjectsUsingBlock:^(RBBJDCDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.Id == race.Id) {

                    obj.rqspfSp = race.rqspfSp;
                }
            }];
        }
        [strongSelf setBottomTitleInfor];
    };
    
    return cell;
}

#pragma mark - RBBJDCSectionHeadViewDelegate
- (void)RBBJDCSectionHeadViewDidClicked:(RBBJDCSectionHeadView *)RBBJDCSectionHeadView withHeadBtnStatus:(BOOL)btnSelected{
    NSInteger section = RBBJDCSectionHeadView.tag;

    flag[section] = !flag[section];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [_bjdcTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];

}
#pragma mark - touch
- (void)selectButtonTapped{
    if (!_selectedView) {
        _selectedView = [[RBBJDCScreenView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)withRBBJDCModel:self.bjdcModel];
        _selectedView.delegate = self;
        [self.view addSubview:_selectedView];
//        WS(weakSelf)
//        _selectedView.sureBlock = ^{
//            SS(strongSelf)
//            [strongSelf.bjdcTableView reloadData];
//        };

    }
    _selectedView.hidden = NO;
}
#pragma mark 清空操作
- (void)emptyAction{
    for (RBBJDCIssueModel *issue in self.bjdcModel.bjdcIssueDataScreenList) {
        for (RBBJDCDataModel *data in issue.dataList) {
            data.rqspfSp.winSelected = NO;
            data.rqspfSp.lostSelected = NO;
            data.rqspfSp.drawSelected = NO;
        }
    }
    
    for (RBBJDCIssueModel *issue in self.bjdcModel.bjdcIssueDataList) {
        for (RBBJDCDataModel *data in issue.dataList) {
            data.rqspfSp.winSelected = NO;
            data.rqspfSp.lostSelected = NO;
            data.rqspfSp.drawSelected = NO;
        }
    }
    selectCount = 0;
    [self.bjdcTableView reloadData];
    [self setBottomTitleInfor];
}

- (void)nextAction{
    

    
    NSMutableArray *issueSelectList = [NSMutableArray array];
    for (int i=0; i<[_bjdcModel.bjdcIssueDataList count]; i++) {
        RBBJDCIssueModel *issueModel=_bjdcModel.bjdcIssueDataList[i];
        
        RBBJDCIssueModel *issueModeCopy = [[RBBJDCIssueModel alloc]init];
        issueModeCopy.dataList = [issueModel.dataList copy];
        issueModeCopy.issueNo = [issueModel.issueNo copy];
        
        NSMutableArray *dataListArray=[[NSMutableArray alloc]init];
        for (RBBJDCDataModel *data in issueModeCopy.dataList) {
            if (data.rqspfSp.winSelected == YES|
                data.rqspfSp.drawSelected == YES|
                data.rqspfSp.lostSelected == YES) {
                [dataListArray addObject:data];
            }
        }
        if (dataListArray.count > 0) {
            issueModeCopy.dataList = dataListArray;
            [issueSelectList addObject:issueModeCopy];
        }
    }
    RBBJDCIssueModel *issueModeCopy = [issueSelectList firstObject];
    if (issueModeCopy.dataList == 0) {
        [CC_NoticeView showError:@"至少选择一场比赛"] ;
        return;
    }
    
    if (issueSelectList.count > 1) {
        [CC_NoticeView showError:@"只能投注同一期次的比赛"] ;
        return;
    }
    
    RBBJDCIssueModel *issueModel= [issueSelectList firstObject];
    if (issueModel.dataList.count > 15) {
        [CC_NoticeView showError:@"用户最多可选择15场比赛"] ;
        return;
    }
    
    
    RBDJDCConfirmViewController *ConfirmVC = [[RBDJDCConfirmViewController alloc]init];
    ConfirmVC.storeId = self.storeId;
    ConfirmVC.issueSelectList = issueSelectList;
    [self.navigationController pushViewController:ConfirmVC animated:YES];
    
}
#pragma mark - 设置底部选中比赛场数的文字显示
- (void)setBottomTitleInfor{
    selectCount = 0;
    for (RBBJDCIssueModel *issure in self.bjdcModel.bjdcIssueDataList) {
        for (RBBJDCDataModel *data in issure.dataList) {
            if (data.rqspfSp.isWinSelected == YES|
                data.rqspfSp.isDrawSelected == YES |
                data.rqspfSp.isLostSelected == YES) {
                selectCount ++;
            }
        }
    }
    self.bottomlabel.text = [NSString stringWithFormat:@"已选%zi场",selectCount];

    
}
#pragma mark - request
-(void)bjdcSellableIssueQuery
{
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setObject:@"BJDC_SELLABLE_ISSUE_QUERY" forKey:@"service"];
    [self.view showMaskProgressHUD];
    
    [[CC_HttpTask getInstance]post:[CSNetWorkConfig currentUrl] params:para model:nil finishCallbackBlock:^(NSString *error, ResModel *resmodel) {
        [self.view hiddenMaskProgressHUD];
        if (error) {
            self.noDataView.hidden = NO;

            [CC_NoticeView showError:error];
        }else
        {


            NSDictionary *result = resmodel.resultDic[@"response"];
            _response = result;
            
            self.bjdcModel = [RBBJDCModel mj_objectWithKeyValues:_response];

            RBBJDCIssueModel *issueModel = [self.bjdcModel.bjdcIssueDataList firstObject];
            NSLog(@"%@",issueModel.dataList);
            
            NSArray *bjdcIssueDataList = [NSArray arrayWithArray:result[@"bjdcIssueDataList"]];
            if (bjdcIssueDataList.count <= 0) {
                [CC_NoticeView showError:@"暂无可售期次"];
                self.noDataView.hidden = NO;

                return;
            }
            self.noDataView.hidden = YES;

            [self.bjdcTableView reloadData];
            
            [self setBottomTitleInfor];
        }
    }];
}
//数据回传处理替换下个页面修改的值 更新当前页
- (void)handleChoseRace:(void(^)(void))finish{
    
}
#pragma mark - RBBJDCScreenViewDelegate

- (void)RBBJDCScreenViewDidSure:(RBBJDCScreenView *)screenView{
    [self.bjdcTableView reloadData];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
