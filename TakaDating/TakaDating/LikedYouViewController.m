//
//  LikedYouViewController.m
//  TakaDating
//
//  Created by Sumit Ghosh on 28/01/15.
//  Copyright (c) 2015 Sumit Ghosh. All rights reserved.
//

#import "LikedYouViewController.h"
#import "CollectionHeaderTitleLabel.h"
#import "CustomCellView.h"
#import "CustomProfileView.h"
#import  "PromoteyourselfViewController.h"
#import "UserProfileViewController.h"
#import  "SingletonClass.h"
#import  "UIImageView+WebCache.h"
#import "AddphotosViewController.h"
#import "customCollectionCiewCell.h"

@interface LikedYouViewController (){
    CollectionHeaderTitleLabel * reuseableView;
    PromoteyourselfViewController * promote;
    UserProfileViewController * userProfileVC;
    AddphotosViewController *addPhoto;
}

@end

@implementation LikedYouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    windowSize=[UIScreen mainScreen].bounds.size;
  // self.view.backgroundColor = [UIColor colorWithRed:(CGFloat)251/255 green:(CGFloat)177/255 blue:(CGFloat)176/255 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)148/255 blue:(CGFloat)214/255 alpha:1.0];
    if (cellSelectedArr) {
        cellSelectedArr=nil;
    }
    cellSelectedArr=[[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(createUIBeforeCallService) name:@"likedYou" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(editLikeButtonAction) name:@"editLikeButtonAction" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelButtonAction) name:@"cancelLikeButtonAction" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectButtonAction:) name:@"selectLikeButtonAction" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deselectButtonAction) name:@"deselectLikeButtonAction" object:nil];
    CGRect frame;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        frame=CGRectMake(windowSize.width/2-40, 150, 40, 40);
    }
    else{
        frame=CGRectMake(140, 150, 40, 40);
    }
    
    self.refreshActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    
    self.refreshActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    self.refreshActivityIndicator.color = [UIColor blackColor];
    
    [self.view addSubview:self.refreshActivityIndicator];
    [self.view bringSubviewToFront:self.refreshActivityIndicator];
    self.refreshActivityIndicator.alpha = 1.0;
    
    useriId =[[NSMutableArray alloc]init];
    displayName=[[NSMutableArray alloc]init];
    imageCount=[[NSMutableArray alloc]init];
    sex=[[NSMutableArray alloc]init];
    thumbanailUrl=[[NSMutableArray alloc]init];
    isOnline=[[NSMutableArray alloc]init];
    
}

-(void)createUIBeforeCallService{
    [self.refreshActivityIndicator startAnimating];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self callWebServiceForLikedYou];
       // [self callWebServiceForLikedByYou]; need to work
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshActivityIndicator stopAnimating];
            
            [self createLikedYouUI];
        });
    });

    
    
    
}

-(void) createLikedYouUI{
    if (![SingletonClass shareSingleton].profileImg) {
         [self createUI];
    }
    else if (thumbanailUrl.count<1)
    {
        [self createUIIfNoPic];
       
    }
    else{
        [self createCollectionView];
    }
}

#pragma mark- Create UI if no Profile pic
-(void)createUIIfNoPic{
    CGFloat font_size;
    if (UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()) {
        font_size=20;
    }
    else{
        font_size=13;
    }
    UILabel * label=[[UILabel alloc]init];
    label.frame=CGRectMake(windowSize.width/2-130, windowSize.height/2-140, windowSize.width/2+100, 50);
    label.font=[UIFont systemFontOfSize:font_size];
    label.text=@"Nobody has liked you yet.Promote yourself to be shown to more people";
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor blackColor];
    label.numberOfLines=0;
    label.lineBreakMode=NSLineBreakByCharWrapping;
    [self.view addSubview:label];
    
    UIButton * addPhotoBtn=[[UIButton alloc]init];
    addPhotoBtn.frame=CGRectMake(windowSize.width/2-80, windowSize.height/2-50,167, 32);
    [addPhotoBtn setTitle:@"Promote yourself" forState:UIControlStateNormal];
    [addPhotoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //addPhoto.titleLabel.font=[UIFont systemFontOfSize:12];
    addPhotoBtn.clipsToBounds=YES;
    addPhotoBtn.layer.cornerRadius=5;
   
    [addPhotoBtn setBackgroundImage:[UIImage imageNamed:@"setting_btn_bg.png"] forState:UIControlStateNormal];
    [addPhotoBtn addTarget:self action:@selector(promoteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addPhotoBtn];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        addPhotoBtn.frame=CGRectMake(windowSize.width/2-100, windowSize.height/2-200,167, 32);
        label.frame=CGRectMake(windowSize.width/2-250, windowSize.height/2-140, windowSize.width/2+100, 50);
        [addPhotoBtn setBackgroundImage:[UIImage imageNamed:@"setting_btn_bg_ipad.png"] forState:UIControlStateNormal];
        
    }
}

#pragma mark-Create UI

-(void)createUI{
    CGFloat font_size;
    if (UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()) {
        font_size=20;
    }
    else{
        font_size=13;
    }
    UILabel * label=[[UILabel alloc]init];
    label.frame=CGRectMake(windowSize.width/2-130, windowSize.height/2-140, windowSize.width/2+100, 50);
    label.font=[UIFont systemFontOfSize:font_size];
    label.text=@"Nobody can vote you until you have added a photo of yourself.";
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor blackColor];
    label.numberOfLines=0;
    label.lineBreakMode=NSLineBreakByCharWrapping;
    [self.view addSubview:label];
    
    UIButton * addPhotoBtn=[[UIButton alloc]init];
    addPhotoBtn.frame=CGRectMake(windowSize.width/2-80, windowSize.height/2-50,167, 32);
    [addPhotoBtn setTitle:@"Add photos" forState:UIControlStateNormal];
    [addPhotoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //addPhoto.titleLabel.font=[UIFont systemFontOfSize:12];
    addPhotoBtn.clipsToBounds=YES;
    addPhotoBtn.layer.cornerRadius=5;
    
    [addPhotoBtn setBackgroundImage:[UIImage imageNamed:@"setting_btn_bg.png"] forState:UIControlStateNormal];
    [addPhotoBtn addTarget:self action:@selector(addPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addPhotoBtn];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        addPhotoBtn.frame=CGRectMake(windowSize.width/2-100, windowSize.height/2-200,167, 32);
        label.frame=CGRectMake(windowSize.width/2-250, windowSize.height/2-140, windowSize.width/2+100, 50);
        [addPhotoBtn setBackgroundImage:[UIImage imageNamed:@"setting_btn_bg_ipad.png"] forState:UIControlStateNormal];
        
    }
    
    
}

-(void)moveToPhotoclass{
    if (!addPhoto) {
        addPhoto=[[AddphotosViewController alloc]initWithNibName:@"AddphotosViewController" bundle:nil];
    }
    [self.navigationController pushViewController:addPhoto animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-
#pragma mark-editButtonAction

-(void)editLikeButtonAction{
    editAll=YES;
    [self.mainCollectionView reloadData];
    NSLog(@"edit button clicked in Like");
}
-(void)cancelButtonAction{
    editAll=NO;
    selectAll=NO;
    [self.mainCollectionView reloadData];
    NSLog(@"Like cancel clicked");
}

-(void)selectButtonAction:(id)sender{
    selectAll=YES;
    [self.mainCollectionView reloadData];
    UIActionSheet * actionsheet=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"" otherButtonTitles:@"Delete", nil];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        
        [actionsheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES ];
        
        
    }
    else{
        [actionsheet showInView:self.view];
    }
    NSLog(@"select Button  Like clicked");
    
}
-(void)deselectButtonAction{
    selectAll=NO;
    [self.mainCollectionView reloadData];
    
    NSLog(@"deselect Button Like clicked");
    
}

#pragma mark-

#pragma mark-

-(void) createCollectionView{
    self.view.backgroundColor = [UIColor colorWithRed:(CGFloat)251/255 green:(CGFloat)177/255 blue:(CGFloat)176/255 alpha:1.0];
    
    self.topCollectionArray = @[@"Abc",@"Bcd",@"Cde",@"Def",@"Efg"];
    //---------
    UICollectionViewFlowLayout *flowLayOut= [[UICollectionViewFlowLayout alloc] init];
    flowLayOut.minimumInteritemSpacing = (CGFloat)2.0;
    flowLayOut.minimumLineSpacing = (CGFloat)2.0;
    flowLayOut.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, self.view.bounds.size.height) collectionViewLayout:flowLayOut];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        flowLayOut.minimumInteritemSpacing = (CGFloat)2.0;
        flowLayOut.minimumLineSpacing = (CGFloat)10.0;

    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    //self.mainCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    [self.mainCollectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    self.mainCollectionView.dataSource = self;
    self.mainCollectionView.delegate = self;
    //self.mainCollectionView.backgroundColor = [UIColor colorWithRed:(CGFloat)59/255 green:(CGFloat)97/255 blue:(CGFloat)107/255 alpha:1];
    self.mainCollectionView.backgroundColor = [UIColor blackColor];
    [self.mainCollectionView registerClass:[customCollectionCiewCell class] forCellWithReuseIdentifier:@"CustomCollectionCell"];
    
    [self.view addSubview:self.mainCollectionView];
    //self.mainCollectionView.scrollEnabled = NO;
    [self.mainCollectionView registerClass:[CollectionHeaderTitleLabel class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.mainCollectionView registerClass:[CollectionHeaderTitleLabel class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderViewSectionTwo"];
    
    //-------------------------------------------
}
#pragma mark-
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   
        
    return thumbanailUrl.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    customCollectionCiewCell *customCellView=[collectionView dequeueReusableCellWithReuseIdentifier:@"CustomCollectionCell" forIndexPath:indexPath];
//CustomCellView *customCellView = [[CustomCellView alloc] initWithFrame:cell.bounds];
    if (indexPath.section==0) {
        
    
    if(editAll==YES)
    {
        toggleButton=[UIButton buttonWithType:UIButtonTypeCustom];
        toggleButton.frame=CGRectMake(60,5, 15, 15);
        [toggleButton setImage:[UIImage imageNamed:@"select_normal.png"] forState:UIControlStateNormal];
        [toggleButton setImage:[UIImage imageNamed:@"select_active.png"] forState:UIControlStateSelected];
        [customCellView addSubview:toggleButton];
        
        
        if (selectAll==NO) {
            
            // [customCellView.togglebutton setImage:[UIImage imageNamed:@"select_normal.png"] forState:UIControlStateNormal];
            [toggleButton setImage:[UIImage imageNamed:@"select_normal.png"] forState:UIControlStateNormal];
            [toggleButton setSelected:NO];
            toggleButton.tag=indexPath.row;
            NSNumber * index=[NSNumber numberWithInteger:indexPath.row];
            [cellSelectedArr removeObject:index];
        }
        else{
            [toggleButton setSelected:YES];
            [toggleButton setImage:[UIImage imageNamed:@"select_active.png"] forState:UIControlStateSelected];
            toggleButton.tag=indexPath.row;
            NSNumber * index=[NSNumber numberWithInteger:indexPath.row];
            [cellSelectedArr addObject:index];
            //[customCellView.togglebutton setImage:[UIImage imageNamed:@"select_active.png"] forState:UIControlStateSelected];
        }
        //customCellView.togglebutton.tag=indexPath.row;
        //[customCellView.togglebutton addTarget:self action:@selector(toggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [toggleButton addTarget:self action:@selector(toggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        toggleButton.hidden=YES;
        // customCellView.togglebutton.hidden=YES;
    }
         NSString * online,* offline;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            online=@"online_icon_ipad.png";
            offline=@"offline_icon_ipad.png";
        }
        else{
            online=@"online_icon.png";
            offline=@"offline_icon.png";
        }
        if ([isOnline[indexPath.row]isEqualToString:@"0"]) {
            customCellView.isOnlne.image=[UIImage imageNamed:offline];
        }
        else{
            customCellView.isOnlne.image=[UIImage imageNamed:online];
        }
       // if ([SingletonClass shareSingleton].superPower==0) {
       //     customCellView.profileImageView .image= [UIImage imageNamed:@"Blur.jpg"];
      //  }
      //  else{
        
        NSURL * imageUrl=[NSURL URLWithString:[NSString stringWithFormat:@"http://taka.dating/%@",[thumbanailUrl objectAtIndex:indexPath.row]]];
        [customCellView.profileImageView setImageWithURL:imageUrl] ;
      //  }
        customCellView.nameLabel.text =[displayName objectAtIndex:indexPath.row];
        NSString *totalCount= [NSString stringWithFormat:@"%d",(int)indexPath.row];
        CGFloat h = 25 + ([totalCount length]*5);
        if (h>70) {
            h = 70;
            customCellView.customImageCounterView.frame = CGRectMake(70-h, 55, h, 16);
            [customCellView.customImageCounterView.totalImageCountLabel sizeToFit];
        }
        else{
            customCellView.customImageCounterView.frame = CGRectMake(70-h, 55, h, 16);
        }
        
     //   customCellView.customImageCounterView.totalImageCountLabel.text = [imageCount objectAtIndex:indexPath.row];
    
    }
   
   
   // cell.backgroundColor = [UIColor clearColor];
   // [cell addSubview:customCellView];
    return customCellView;
}

-(void)toggleButtonAction:(id)sender{
    
    NSInteger  tag=[sender tag];
    NSNumber * indexPath=[NSNumber numberWithInteger:tag];
    
    if ([toggleButton isSelected]==YES) {
        
        
        if ([cellSelectedArr containsObject:indexPath]) {
            [cellSelectedArr removeObject:indexPath];
            [toggleButton setImage:[UIImage imageNamed:@"select_normal.png"]forState:UIControlStateSelected];
            [toggleButton setSelected:NO];
        }
        else{
            [toggleButton setImage:[UIImage imageNamed:@"select_active.png"]forState:UIControlStateSelected];
            [toggleButton setSelected:YES];
            [cellSelectedArr addObject:indexPath];
        }
    }
    else{
        
        [toggleButton setImage:[UIImage imageNamed:@"select_active.png"]forState:UIControlStateSelected];
        [toggleButton setSelected:YES];
        [cellSelectedArr addObject:indexPath];
        
        
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(73, 73);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    if (section==0) {
        CGSize size = CGSizeMake(self.view.frame.size.width, 25);
        return size;
    }
    CGSize size = CGSizeMake(self.view.frame.size.width, 25);
    return size;
    
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader){
        
        reuseableView = nil;
        
        if (indexPath.section==0) {
            reuseableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
            
            //[self createFirstSectionHeader:reuseableView];
        }
        else{
            reuseableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderViewSectionTwo" forIndexPath:indexPath];
        }
        
        
        reuseableView.backgroundColor = [UIColor whiteColor];
        if (indexPath.section==0) {
            //textLabel.frame = CGRectMake(0, 100, self.view.frame.size.width, 25);
            reuseableView.headerTitleLabel.text = @"  Liked me";
        }
        else{
            // textLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 25);
            reuseableView.headerTitleLabel.text = @"   Liked by me";
        }
        
        return reuseableView;
        
    }//End Header Kind Check
    return nil;
}




-(void) createFirstSectionHeader:(CollectionHeaderTitleLabel *)areuseableView{
    
    UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    backView.backgroundColor = [UIColor blackColor];
    [areuseableView addSubview:backView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(12, 14, 73, 73);
    //  button.backgroundColor = [UIColor colorWithRed:(CGFloat)88/255 green:(CGFloat)95/255 blue:(CGFloat)107/255 alpha:1];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"add_me_icon.png"] forState:UIControlStateNormal];
    button.titleLabel.font=[UIFont systemFontOfSize:12];
    [button setTitle:@"Add me here!" forState:UIControlStateNormal];
    // button.layer.borderWidth = 5;
    // button.layer.borderColor = [UIColor blueColor].CGColor;
    // button.layer.cornerRadius = 5.0;
    // button.clipsToBounds = YES;
    
    //[button addTarget:self action:@selector(addMeHereButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:button];
    //------------------------------------
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(92, 0, self.view.frame.size.width-92, 100)];
    self.scrollView.backgroundColor = [UIColor blackColor];
    [areuseableView addSubview:self.scrollView];
    [self addHeaderDetails];
}
-(void)addHeaderDetails{
    for (UIView *v in self.scrollView.subviews) {
        v.hidden = YES;
    }
    CGFloat x = 0;
    for (int i = 0; i<self.topCollectionArray.count; i++) {
        
        CustomProfileView *customProfileView = (CustomProfileView*)[self.scrollView viewWithTag:1000+i];
        if (customProfileView==nil) {
            customProfileView = [[CustomProfileView alloc]initWithFrame:CGRectMake(x, 14, 73, 73)];
            customProfileView.tag = 1000+i;
            [self.scrollView addSubview:customProfileView];
        }
        else{
            customProfileView.hidden = NO;
        }
        customProfileView.profileImageView.image = [UIImage imageNamed:@""];
        
        customProfileView.nameLabel.text = [NSString stringWithFormat:@"%@",[self.topCollectionArray objectAtIndex:i]];
        x = x+76;
    }//End For Loop
    [self.scrollView setContentSize:CGSizeMake(x, 100)];
}
#pragma mark-
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   // if ([SingletonClass shareSingleton].superPower==0) {
        return;
   // }
     [SingletonClass shareSingleton].fromChat=NO;
    if (userProfileVC) {
        userProfileVC=nil;
    }
    userProfileVC=[[UserProfileViewController alloc]initWithNibName:@"UserProfileViewController" bundle:nil];
    userProfileVC.index=[useriId objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:userProfileVC animated:YES];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSLog(@"Button action sheet ");
        [self callDeleteWebService];
    }
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark-Web service for delete
-(void)callDeleteWebService{
    NSError *error;
    NSURLResponse * urlResponse;
    NSMutableString * multipleId=[[NSMutableString alloc]init];
    for (int i=0; i<cellSelectedArr.count; i++) {
        
        
        if (i==0) {
            
            [multipleId appendFormat:[NSMutableString stringWithFormat:@"%@",useriId[i]]];
        }
        else
        {
            [multipleId appendFormat:[NSString stringWithFormat:@",%@",useriId[i]]];
        }
    }
    NSString * urlStr=[NSString stringWithFormat:@"http://taka.dating/mobile/deleteliked/%@/%@",[SingletonClass shareSingleton].userID,multipleId];
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url=[NSURL URLWithString:urlStr];
    
    NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
    NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (data==nil) {
        NSLog(@"No data available");
        return;
    }
    id parse=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSLog(@" delete parse of favorite %@",parse);
    if ([[parse objectForKey:@"code"] isEqualToNumber:[NSNumber numberWithInt:198]]) {
        NSLog(@"deletion is not successfull");
    }
    else{
        NSLog(@"deletion is  successfull");
        [self.refreshActivityIndicator startAnimating];
        [self callWebServiceForLikedYou];
        [self.refreshActivityIndicator stopAnimating];
    }
}

#pragma mark- call WebServiceFor LikedYou
-(void)callWebServiceForLikedYou{
    
    NSError * error=nil;
    NSURLResponse * urlResponse=nil;
    
    
    NSURL * url=[NSURL URLWithString:@"http://23.238.24.26/notification/liked-you"];
    
    NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString * body=[NSString stringWithFormat:@"userId=%@",[SingletonClass shareSingleton].userID];
    [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];

    
    if (data==nil) {
        NSLog(@"no data available");
        return;
    }
    
    id parse=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"people Like me %@",parse);
    
    //if ([[parse objectForKey:@"code"]isEqualToNumber:[NSNumber numberWithInt:200]]) {
        NSArray * userLikesMe=[parse objectForKey:@"resultlikeby"];
    if (userLikesMe.count>0) {
        NSMutableDictionary * dict=[[NSMutableDictionary alloc]init];
        for (int i=0; i<userLikesMe.count; i++) {
            dict=[userLikesMe objectAtIndex:i];
             [sex addObject:[dict objectForKey:@"sex"]];
             
             [isOnline addObject:[dict objectForKey:@"isOnline"]];
             [displayName addObject:[dict objectForKey:@"displayName"]];
             [useriId addObject:[dict objectForKey:@"userIdLikesTo"]];
             [thumbanailUrl addObject:[dict objectForKey:@"thumbanailUrl"]];
        }
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"likedYou" object:nil];
    
    // Grant award..
    if (awardSanction==NO) {
        
    
    if ([SingletonClass shareSingleton].userLikesAward==NO && useriId.count>=10) {
        
        
        NSURL * postUrl=[NSURL URLWithString:@"http://23.238.24.26/award/grant-award/"];
        
        NSMutableURLRequest *  request=[[NSMutableURLRequest alloc]initWithURL:postUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        
        NSString * body=[NSString stringWithFormat:@"userId=%@&awardId=%@",[SingletonClass shareSingleton].userID,@"2"];
        
        [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
        
        NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        
        if(data==nil){
            return;
        }
        
        id json=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"grnated award %@",json);
    }
        awardSanction=YES;
        [SingletonClass shareSingleton].userLikesAward=YES;
    }

}

#pragma mark- Promote button action

-(void)promoteButtonAction:(UIButton *)sender{
    if (promote) {
        promote=nil;
    }
    promote=[[PromoteyourselfViewController alloc]initWithNibName:@"PromoteyourselfViewController" bundle:nil];
    [self.navigationController pushViewController:promote animated:YES];
}

#pragma mark- add photo

-(void)addPhotoButtonAction:(UIButton *)sender{
    if (addPhoto) {
        addPhoto=nil;
    }
    addPhoto=[[AddphotosViewController alloc]initWithNibName:@"AddphotosViewController" bundle:nil];
    [self.navigationController pushViewController:addPhoto animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
