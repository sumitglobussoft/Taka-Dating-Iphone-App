//
//  AwardSectionViewController.m
//  TakaDating
//
//  Created by Sumit Ghosh on 14/03/15.
//  Copyright (c) 2015 Sumit Ghosh. All rights reserved.
//

#import "AwardSectionViewController.h"
#import "AwardTableViewCell.h"


@interface AwardSectionViewController ()

@end

@implementation AwardSectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    windowSize=[UIScreen mainScreen].bounds.size;
    self.view.backgroundColor = [UIColor colorWithRed:(CGFloat)251/255 green:(CGFloat)177/255 blue:(CGFloat)176/255 alpha:1.0];
   
    
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = CGRectMake(0, 0, windowSize.width, 55);
    UIColor *firstColor = [UIColor colorWithRed:(CGFloat)207/255 green:(CGFloat)42/255 blue:(CGFloat)43/255 alpha:1.0];
    UIColor *secColor = [UIColor colorWithRed:(CGFloat)121/255 green:(CGFloat)2/255 blue:(CGFloat)0/255 alpha:1.0];
    layer.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor],(id)[secColor CGColor], nil];
    [self.view.layer insertSublayer:layer atIndex:0];
    
    self.titleLabel = [[UILabel alloc] init];
   self.titleLabel.frame= CGRectMake(windowSize.width/2-60, 20, windowSize.width-200, 35);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.titleLabel.text = @"Awards";
    [self.view addSubview:self.titleLabel];
    //Add Cancel BUTTON
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(windowSize.width/2-145, 25, 60, 25);
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelButton.layer.borderColor = [UIColor redColor].CGColor;
    self.cancelButton.layer.borderWidth = 0.7;
    self.cancelButton.layer.cornerRadius = 4;
    self.cancelButton.clipsToBounds = YES;
    [self.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
         layer.frame = CGRectMake(0, 0, windowSize.width, 75);
        self.titleLabel.frame= CGRectMake(windowSize.width/2-270, 20, windowSize.width-200, 35);

        self.cancelButton.frame = CGRectMake(windowSize.width/2-350, 25, 120, 40);
        self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:30];
        height=75;
    }
    else{
        height=55;
    }

    [self createUI];
    
    // Do any additional setup after loading the view from its nib.
}


#pragma mark-

-(void)createUI{
    
    if (awardTbl) {
        awardTbl=nil;
    }
    awardTbl=[[UITableView alloc]init];
    awardTbl.frame=CGRectMake(0, height, windowSize.width, windowSize.height-50);
    awardTbl.delegate=self;
    awardTbl.dataSource=self;
    awardTbl.backgroundColor=[UIColor colorWithRed:(CGFloat)251/255 green:(CGFloat)177/255 blue:(CGFloat)176/255 alpha:1.0];
    awardTbl.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:awardTbl];
}

#pragma mark- Table Delegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        return  180;
    }
    return 90.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * cellIdentifier=@"Cell";
    
    AwardTableViewCell * cell=(AwardTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell=[[AwardTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()) {
        cell.containerView.frame=CGRectMake(0, 0, windowSize.width, 180);
        cell.cellLable.frame=CGRectMake(120,10,windowSize.width-240,80);
        cell.cellSubLbl.frame=CGRectMake(120, 50, windowSize.width-240, 90);
        cell.imgView.frame=CGRectMake(25, 25, 80, 80);
        cell.imgView.image=[UIImage imageNamed:@"award_ipad.png"];
    }
    else{
        cell.containerView.frame=CGRectMake(0, 0, 320 , 90);
        cell.cellLable.frame=CGRectMake(80,5,230,40);
        cell.cellSubLbl.frame=CGRectMake(80, 40, 230, 45);
        cell.imgView.frame=CGRectMake(15, 15, 40, 40);
        cell.imgView.image=[UIImage imageNamed:@"award.png"];
    }
    
    
    if (indexPath.row==0) {
        cell.cellLable.text=@"Most Active People!";
        cell.cellSubLbl.text=@"Use Taka 7 times in a week to win this award (If you log in everyday in a week then this award will be available)";
    }
    else if (indexPath.row==1)
    {
        cell.cellLable.text=@"One of the top voters of the week!";
         cell.cellSubLbl.text=@"Like 1000 different people to win this award.";
    }
    else if (indexPath.row==2)
    {
        cell.cellLable.text=@"The most liked people!";
         cell.cellSubLbl.text=@"Get 10 likes from different people to win this award.";
    }
    else if (indexPath.row==3)
    {
        cell.cellLable.text=@"The most Interested person!";
         cell.cellSubLbl.text=@"Add 15 interests in your profile to get this award.";
    }
    else if (indexPath.row==4)
    {
        cell.cellLable.text=@"The most checked out people!";
         cell.cellSubLbl.text=@"Get visited by 50 people in a week to win this award.";
    }
    else{
        cell.cellLable.text=@"The biggest window shoppers!";
         cell.cellSubLbl.text=@"Visit 200 user profiles in a week to win this award.";
    }
   
    
    return  cell;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 45;
}

-(void)cancelButtonAction:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
