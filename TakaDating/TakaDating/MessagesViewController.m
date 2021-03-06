//
//  MessagesViewController.m
//  TakaDating
//
//  Created by Sumit Ghosh on 30/11/14.
//  Copyright (c) 2014 Sumit Ghosh. All rights reserved.
//

#import "MessagesViewController.h"
#import  "MessageDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AddphotosViewController.h"


#import "XMPPMessageArchiving.h"
#import "XMPPStream.h"
#import "XMPPMessageArchivingCoreDataStorage.h"


// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif



@interface MessagesViewController ()
{
    XMPPStream * xmppStream;
}
@property(nonatomic,strong)MessageDetailViewController * mdVC;

@end

@implementation MessagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPRoster *)xmppRoster {
    return [[self appDelegate] xmppRoster];
}

/*-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [profileImage removeAllObjects];
    [userName removeAllObjects];
    [userId removeAllObjects];
    [self.messageTable removeFromSuperview];
    [self.refreshActivity startAnimating];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchUserList) name:@"fetchUserList" object:nil];
}
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    profileImage=[[NSMutableArray alloc]init];
    userName=[[NSMutableArray alloc]init];
    userId=[[NSMutableArray alloc]init];
    unreadMsg=[[NSMutableArray alloc]init];
    unreadMsgId=[[NSMutableArray alloc]init];
    unreadProfileImg=[[NSMutableArray alloc]init];
    unreadUserId=[[NSMutableArray alloc]init];
    unreadUserName=[[NSMutableArray alloc]init];
   // nameArr=[[NSMutableArray alloc]initWithObjects:@"One",@"Two",@"Three",@"Four",@"Five", nil];
   // self.view.backgroundColor=[UIColor colorWithRed:(CGFloat)251/255 green:(CGFloat)177/255 blue:(CGFloat)176/255 alpha:1.0];
    self.view.backgroundColor= [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)148/255 blue:(CGFloat)214/255 alpha:1.0];
    windowSize =[UIScreen mainScreen].bounds.size;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(editButtonAction) name:@"editButtonAction" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelButtonAction) name:@"cancelButtonAction" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectButtonAction) name:@"selectButtonAction" object:nil];
    
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deselectButtonAction) name:@"deselectButtonAction" object:nil];
   
    
    
    self.refreshActivity=[[UIActivityIndicatorView alloc]init];
    self.refreshActivity.frame=CGRectMake(windowSize.width/2-20,windowSize.height/2-20, 50, 50);
    self.refreshActivity.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
    self.refreshActivity.color=[UIColor blackColor];
    [self.view addSubview:self.refreshActivity];
    [self.view bringSubviewToFront:self.refreshActivity];
    [self.refreshActivity setAlpha:1.0];
     [self.refreshActivity startAnimating];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchUserList) name:@"fetchUserList" object:nil];
    
    
    // Do any additional setup after loading the view from its nib.
}

#pragma mark-
-(void)fetchUserList{
   
     dispatch_async(dispatch_get_main_queue(),^{
         [self fetchAllDatauserDataFromServer];
       dispatch_async(dispatch_get_main_queue(),^{
         [self.refreshActivity stopAnimating];
           
           [self createUI];
    
      });
    });
   
   
     [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark-editbutton action

-(void)editButtonAction{
    editbuttonSelect =YES;
    [self.messageTable reloadData];
}
-(void)cancelButtonAction{
    editbuttonSelect=NO;
    selectAll=NO;
    [self.messageTable reloadData];
}

-(void)selectButtonAction{
    NSLog(@"Select Button clicked");
    selectAll=YES;
    [self.messageTable reloadData];
   
}

-(void)deselectButtonAction{
    NSLog(@"Select Button clicked");
    selectAll=NO;
    [self.messageTable reloadData];
    
}


-(void)createUI{
   // self.view.backgroundColor=[UIColor colorWithRed:(CGFloat)251/255 green:(CGFloat)177/255 blue:(CGFloat)176/255 alpha:1.0];
    self.view.backgroundColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)148/255 blue:(CGFloat)214/255 alpha:1.0];
    
      CGRect   frame,srchFrame;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        fontSize=20;
        frame=CGRectMake(windowSize.width/2-290, windowSize.height/2-50, windowSize.width-140, 60);
        
    }
    else{
        frame=CGRectMake(windowSize.width/2-140, windowSize.height/2-50, windowSize.width-40, 60);
        fontSize=14;
    }
   
  
    if ([self fetchedResultsController].sections.count<=0) {// need to check if profile pic exists
        UIImageView * chatBigImg=[[UIImageView alloc]init];
        chatBigImg.frame=CGRectMake(windowSize.width/2-60, windowSize.height/2-200, 125, 125);
        chatBigImg.image=[UIImage imageNamed:@"chat_big_icon.png"];
        [self.view addSubview:chatBigImg];
        
        UILabel * chatLbl=[[UILabel alloc]init];
        chatLbl.frame=frame;
        chatLbl.text=@"You do not have messages yet. Add photos of yourself. People with photos get way more messages.";
        chatLbl.textColor=[UIColor blackColor];
        chatLbl.font=[UIFont boldSystemFontOfSize:fontSize];
        chatLbl.numberOfLines=0;
        [chatLbl setLineBreakMode:NSLineBreakByCharWrapping];
        [self.view addSubview:chatLbl];
        chatLbl.textAlignment=NSTextAlignmentCenter;
        
        
        UIButton * addPhoto=[UIButton buttonWithType:UIButtonTypeCustom];
        addPhoto.frame=CGRectMake(windowSize.width/2-50, windowSize.height/2+20, 120, 32);
        [addPhoto setTitle:@"Add Photos" forState:UIControlStateNormal];
        [addPhoto setTitleColor:[UIColor whiteColor ] forState:UIControlStateNormal];
        [addPhoto setBackgroundImage:[UIImage imageNamed:@"setting_btn_bg.png"] forState:UIControlStateNormal];
        [addPhoto addTarget:self action:@selector(movetoAddPhotoView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:addPhoto];
    }
    else{
        
        UIView * sectionView=[[UIView alloc]init];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            sectionView.frame=CGRectMake(0, 0, windowSize.width, 150);
        }
        else{
            sectionView.frame=CGRectMake(0, 0, windowSize.width, 60);
        }
        
        sectionView.backgroundColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)148/255 blue:(CGFloat)214/255 alpha:1.0];
        
    if (self.messageTable) {
        self.messageTable=nil;
    }
        self.messageTable=[[UITableView alloc]init];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
           
                self.messageTable.frame=CGRectMake(0, 10, windowSize.width, windowSize.height-50);
            frame=CGRectMake(10, 70, windowSize.width-20, 50);
            srchFrame=CGRectMake(10, 10, windowSize.width-20, 50);
            row_hh=80;
        }
        else{
        //if ([UIScreen mainScreen].bounds.size.height>500) {
            self.messageTable.frame=CGRectMake(0, 10, windowSize.width, windowSize.height-50);
            frame=CGRectMake(10, 35, windowSize.width-20, 20);
            srchFrame=CGRectMake(10, 10, windowSize.width-20, 20);
            row_hh=40;
      //  }
        }
//        else{
//             self.messageTable.frame=CGRectMake(0, 0, 320, self.view.frame.size.height-50);
//        }
        self.messageTable.delegate=self;;
        self.messageTable.dataSource=self;
            self.messageTable.backgroundColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)148/255 blue:(CGFloat)214/255 alpha:1.0];
        self.messageTable.separatorColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)148/255 blue:(CGFloat)214/255 alpha:1.0];
        
        [self.view addSubview:self.messageTable];
        
        self.searchbar =[[UISearchBar alloc]init];
        self.searchbar.frame=srchFrame;
        self.searchbar.layer.cornerRadius=7;
        self.searchbar.placeholder=@"Search";
        self.searchbar.clipsToBounds=YES;
        self.searchbar.delegate=self;
        
        self.searchbar.backgroundColor=[UIColor whiteColor];
        self.searchbar.searchBarStyle=UISearchBarStyleProminent;
       // [sectionView addSubview:self.searchbar];
        
        searchBar=[[UITextField alloc]init];
        searchBar.frame=srchFrame;
        searchBar.layer.cornerRadius=7;
        searchBar.clipsToBounds=YES;
        //[sectionView addSubview:searchBar];
        
        UIView * footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, windowSize.width, 60)];
        footerView.backgroundColor=[UIColor clearColor];
        self.messageTable.tableFooterView=footerView ;
        
         NSArray *arry=[NSArray arrayWithObjects:@"All",@"Online",@"Unread", nil];
        
        self.segment=[[UISegmentedControl alloc]initWithItems:arry];
        
        self.segment.frame=frame;
        [self.segment addTarget:self action:@selector(MySegmentControlAction:) forControlEvents: UIControlEventValueChanged];
        self.segment.selectedSegmentIndex = 0;
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:fontSize]
                                                               forKey:NSFontAttributeName];
        [self.segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
        //[self.segment setTintColor:[UIColor colorWithRed:50.0/255.0 green:49.0/255.0 blue:49.0/255.0 alpha:1.0]];
       

        [sectionView addSubview:self.segment];
       for (UIControl *subview in self.segment.subviews) {
            subview.tintColor = [subview isSelected] ? [UIColor colorWithRed:255.0/255.0 green:53.0/255.0 blue:153.0/255.0 alpha:1.0] : [UIColor blackColor];
       }
        self.messageTable.tableHeaderView=sectionView ;
    }
   // }
}


#pragma mark-Segment method

-(void)MySegmentControlAction:(UISegmentedControl *)sender{
        for (UIControl *subview in sender.subviews) {
           // subview.tintColor = [subview isSelected] ? [UIColor colorWithRed:135.0/255.0 green:10.0/255.0 blue:2.0/255.0 alpha:1.0] : [UIColor blackColor];
             subview.tintColor = [subview isSelected] ? [UIColor colorWithRed:255.0/255.0 green:53.0/255.0 blue:153.0/255.0 alpha:1.0] : [UIColor blackColor];
        }
    
 
    
    if (sender.selectedSegmentIndex==0) {
        online=NO;
        unread=NO;
        [self.messageTable reloadData];
        NSLog(@"index one selected");
    }
    else if (sender.selectedSegmentIndex==1)
    {
        online=YES;
        unread=NO;
        [self.messageTable reloadData];

        NSLog(@"index Online selected");
    }
    else{
        online=NO;
        unread=YES;
        [self getUnreadMessages];
        [self.messageTable reloadData];
    }
}

#pragma mark- get unread messages

-(void)getUnreadMessages{
    NSMutableDictionary * dict=[NSMutableDictionary dictionary];
    for (int i=0; i<[self appDelegate].unreadMsgArr.count; i++) {
        dict=[[self appDelegate].unreadMsgArr objectAtIndex:i];
        if ([dict objectForKey:@"msg"]) {
        if (![unreadMsgId containsObject:[dict objectForKey:@"jid"]]) {
            [unreadMsg addObject:[dict objectForKey:@"msg"]];
            [unreadMsgId addObject:[dict objectForKey:@"jid"]];
            [[self appDelegate].unreadMsgArr removeObjectAtIndex:i];
            [self fetchMessageUserDetails:[unreadMsgId objectAtIndex:i]];
        }
    }
 }
}

#pragma  mark- fetchMessageUserDetails
-(void)fetchMessageUserDetails : (NSString *)chatUserId{
    
    NSError * error;
    NSURLResponse * urlResponse;
    
    NSURL * url=[NSURL URLWithString:@"http://23.238.24.26/mobi/profile-details"];
    
    NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    NSString * body=[NSString stringWithFormat:@"userId=%@&loggedId=%@",chatUserId,[SingletonClass shareSingleton].userID];
    
    [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (data==nil) {
        return;
    }
    id parse=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"json response of user details %@",parse);
    if (![[parse objectForKey:@"code"]isEqualToNumber:[NSNumber numberWithInt:200]]) {
        NSLog(@"No data in parse");
    }
    else{
        NSMutableDictionary * dict=[parse objectForKey:@"userprofile"];
        [unreadProfileImg addObject:[dict objectForKey:@"thumbanailUrl"]];
        [unreadUserName addObject:[dict objectForKey:@"displayName"]];
        [unreadUserId addObject:[dict objectForKey:@"userId"]];
    }
}

#pragma mark- table delegate methods

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (sectionIndex < [sections count])
    {
//  id <NSFetchedResultsSectionInfo> sectionInfo = sections[sectionIndex];
        
        ///int section = [sectionInfo.name intValue];
       /* switch (section)
        {
            case 0  : return @"Available";
            case 1  : return @"Away";
            default : return @"Offline";
        }*/
    }
    
    return @"";
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return row_hh;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"count %lu",(unsigned long)[self fetchedResultsController].sections.count);
    //return [[[self fetchedResultsController] sections] count];
    return 1;
    }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (unread) {
        if (unreadMsg.count<1) {
            return 0;
        }
       return  unreadMsg.count;
    }
    else{
        
        if (!online) {
           // if (section < [sections count])
           // {
              //  id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
               // NSLog(@"number of rows delegate %ld",userName.count);
                //return sectionInfo.numberOfObjects;
                return userName.count;
           // }
            
        }
        else if(online){
            // NSArray *sections = [[self fetchedResultsController] sections];
            
            if (section < [sections count])
            {
                id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
                
                int sec = [sectionInfo.name intValue];
                if (sec==0) {
                    // NSLog(@"number of rows %ld",sectionInfo.numberOfObjects);
                    return sectionInfo.numberOfObjects;
                }
            }
        }
    }
    
    
    return 0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageTableViewCell * cell=(MessageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[MessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
  /*  if (editbuttonSelect==YES) {
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            cell.imgView.frame=CGRectMake(35, 10, 50, 50);
            cell.deleteButton.frame=CGRectMake(15, 10, 25, 25);
            cell.cellLabel.frame=CGRectMake(100, 15, 200, 30);
            cell.deleteButton.tag=indexPath.row;
            cell.cellLabel.font=[UIFont boldSystemFontOfSize:fontSize];
        }
        else{
        cell.imgView.frame=CGRectMake(25, 5, 30, 30);
        cell.deleteButton.frame=CGRectMake(5, 10, 15, 15);
        cell.cellLabel.frame=CGRectMake(70, 5, 150, 30);
        cell.deleteButton.tag=indexPath.row;
        }
       if (selectAll==YES) {
            [cell.deleteButton setSelected:YES];
            [cell.deleteButton setImage:[UIImage imageNamed:@"select_active.png"] forState:UIControlStateSelected];
        }
        else{
            [cell.deleteButton setSelected:NO];
            [cell.deleteButton setImage:[UIImage imageNamed:@"select_normal.png"] forState:UIControlStateSelected];
        }
        
    }
    else
    {*/
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            cell.cellLabel.frame=CGRectMake(70, 5, 200, 20);
            cell.cellDetailLbel.frame=CGRectMake(70, 20, 200, 15);
            cell.imgView.frame=CGRectMake(10, 10, 50, 50);
            cell.cellLabel.font=[UIFont boldSystemFontOfSize:fontSize];
        }
        else{
                cell.cellDetailLbel.frame=CGRectMake(50, 20, 200, 15);
                cell.cellLabel.frame=CGRectMake(50, 0, 150, 20);
                cell.imgView.frame=CGRectMake(5, 5, 30, 30);
        }
   // }
    if (unread==YES) {
        if (unreadMsg.count>0) {
            cell.cellDetailLbel.text = [unreadMsg objectAtIndex:indexPath.row];
            cell.cellLabel.text=[unreadUserName objectAtIndex:indexPath.row];
            NSURL * url=[NSURL URLWithString:[NSString stringWithFormat:@"http://taka.dating%@",[unreadProfileImg objectAtIndex:indexPath.row]]];
            [cell.imgView setImageWithURL:url];
        }
        
    }
    else{
        cell.cellLabel.text = [userName objectAtIndex:indexPath.row];
        NSURL * url=[NSURL URLWithString:[NSString stringWithFormat:@"http://taka.dating%@",[profileImage objectAtIndex:indexPath.row]]];
        [cell.imgView setImageWithURL:url];
    }
    return  cell;
   
   
    
}

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    
    if (user.photo != nil)
    {
        cell.imageView.image = user.photo;
    }
    else
    {
        NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
            cell.imageView.image = [UIImage imageWithData:photoData];
        else
            cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (editbuttonSelect==NO) {
       // XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
       
       
      if(self.mdVC)
      {
          self.mdVC=nil;
      }
        
        self.mdVC=[[MessageDetailViewController alloc]initWithUser:[userId objectAtIndex:indexPath.row]];
//        self.mdVC.titleStr= [userName objectAtIndex:indexPath.row];
//        self.mdVC.userId=[userId objectAtIndex:indexPath.row];
        //[self fetchAllChatHistory:user];
        [SingletonClass shareSingleton].chattingWith=[userId objectAtIndex:indexPath.row];
        if (unread==YES) {
            [self fetchChatConversation:[unreadUserId objectAtIndex:indexPath.row]];
            self.mdVC.titleStr= [unreadUserName objectAtIndex:indexPath.row];
            self.mdVC.userId=[unreadUserId objectAtIndex:indexPath.row];
            
            [unreadUserId removeObjectAtIndex:indexPath.row];
            [unreadProfileImg removeObjectAtIndex:indexPath.row];
            [unreadUserName removeObjectAtIndex:indexPath.row];
            [unreadMsg removeObjectAtIndex:indexPath.row];

        }
        else{
            self.mdVC.titleStr= [userName objectAtIndex:indexPath.row];
            self.mdVC.userId=[userId objectAtIndex:indexPath.row];

            [self fetchChatConversation:[userId objectAtIndex:indexPath.row]];
        }
    [self.navigationController pushViewController:self.mdVC animated:YES];
    }

    else{
        NSLog(@"Delete is selected");
    }
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   /* NSLog(@"%@",user.jidStr);
    XMPPJID *newBuddy = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",user.jidStr]];
    [self.xmppRoster removeUser:newBuddy];*/
    
    NSError * error;
    NSURLResponse * urlResponse;
    NSURL * postUrl=[NSURL URLWithString:@"http://takadating.com:9090/plugins/userService/userservic"];
    NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:postUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
   

    NSString * body=[NSString stringWithFormat:@"type=delete_roster&secret=3U3vCIjx&username=%@&item_jid=%@@takadating.com",[SingletonClass shareSingleton].userID,user.displayName];
    [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if(data==nil)
    {
        return;
    }
    
     NSArray *sections = [[self fetchedResultsController] sections];
    for (int j=0; j<sections.count;j++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[j];
        
        NSLog(@"number of rows %ld",sectionInfo.numberOfObjects);
        
        
        
        for (int i=0; i<sectionInfo.numberOfObjects; i++) {
            
            NSIndexPath * indexPath=[NSIndexPath indexPathForRow:i inSection:j];
            
            XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            
            if ([user.displayName isEqualToString:[SingletonClass shareSingleton].userID]) {
                [profileImage  removeObjectAtIndex:indexPath.row];
                [userName removeObjectAtIndex:indexPath.row];
            }
           }
    }
    [self.messageTable reloadData];
}


#pragma  amrk-  Get chat history
-(void)fetchAllChatHistory:(XMPPUserCoreDataStorageObject*)user{
    if ([SingletonClass shareSingleton].sortedData.count<=0) {
        return;
    }
    [[SingletonClass shareSingleton].messages removeAllObjects];
    NSMutableDictionary * dict=[NSMutableDictionary dictionary];
        for (int  i=0;  i<[SingletonClass shareSingleton].sortedData.count;i++) {
            dict=[[SingletonClass shareSingleton].sortedData objectAtIndex:i];
            if ([[dict objectForKey:@"fromJID"] isEqualToString:[NSString stringWithFormat:@"%@@takadating.com",[SingletonClass shareSingleton].userID]]&& [[dict objectForKey:@"toJID"]isEqualToString:[NSString stringWithFormat:@"%@@takadating.com",user.displayName]]) {
                
                
                NSMutableDictionary * dict2=[[NSMutableDictionary alloc]init];
                [dict2 setObject:[dict objectForKey:@"body"] forKey:@"msg"];
                [dict2 setObject:@"you" forKey:@"sender"];
               // [dict2 setObject:[dict objectForKey:<#(id)#>] forKey:@"time"]
                [[SingletonClass shareSingleton].messages addObject:dict2];
            }
            else if ([[dict objectForKey:@"toJID"] isEqualToString:[NSString stringWithFormat:@"%@@takadating.com",[SingletonClass shareSingleton].userID]]&& [[dict objectForKey:@"fromJID"]isEqualToString:[NSString stringWithFormat:@"%@@takadating.com",user.displayName]]) {
                
                
                NSMutableDictionary * dict2=[[NSMutableDictionary alloc]init];
                [dict2 setObject:[dict objectForKey:@"body"] forKey:@"msg"];
                [dict2 setObject:user.displayName forKey:@"sender"];
                [[SingletonClass shareSingleton].messages addObject:dict2];
                
            }
        }
        
    
    }
    
    


-(void)deleteButtonAction:(id)sender{
    
}

#pragma mark-textfield delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self filterContentForSearchText:textField.text
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    [textField resignFirstResponder];
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    searchImages =[[NSMutableArray alloc]init];
    searchIds=[[NSMutableArray alloc]init];
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    
    searchResults = [userName filteredArrayUsingPredicate:resultPredicate];
    for(int i=0;i<userName.count;i++)
    {
        for(int j=0;j<searchResults.count;j++)
        {
            if([searchResults[j] isEqualToString:userName[i]])
            {
                [searchImages addObject:profileImage[i]];
                [searchIds addObject:userId[i]];
            }
        }
        [self.messageTable reloadData];
        search=YES;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        
        NSArray *sortDescriptors = @[sd1, sd2];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            DDLogError(@"Error performing fetch: %@", error);
        }
        
    }
    
    return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [ self.messageTable reloadData];
}

#pragma mark- move to Add photo Class.

-(void)movetoAddPhotoView:(UIButton*)sender{
    AddphotosViewController * addPhoto=[[AddphotosViewController alloc]initWithNibName:@"AddphotosViewController" bundle:nil];
    [self.navigationController pushViewController:addPhoto animated:YES];
}

#pragma mark- get all data of user list from server

-(void)fetchAllDatauserDataFromServer{
    NSError * error=nil;
    NSURLResponse * urlResponse=nil;
    
  
    NSLog(@"xmmp Roster Friends list %lu",(unsigned long)[self fetchedResultsController].sections.count);
    NSArray *sections = [[self fetchedResultsController] sections];
    for (int j=0; j<sections.count;j++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[j];
        
        NSLog(@"number of rows %ld",(unsigned long)sectionInfo.numberOfObjects);

    
    
    for (int i=0; i<sectionInfo.numberOfObjects; i++) {
        
        NSIndexPath * indexPath=[NSIndexPath indexPathForRow:i inSection:j];
        
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        //if (![user.displayName isEqualToString:[SingletonClass shareSingleton].userID]) {
            
        
        
        NSURL * url=[NSURL URLWithString:@"http://23.238.24.26/mobi/profile-details"];
        
        NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
       
        
        NSString * body=[NSString stringWithFormat:@"userId=%@&loggedId=%@",user.jid,[SingletonClass shareSingleton].userID];
        
        [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
        
        NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        if (data==nil) {
            return;
        }
        id parse=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"json response of user details %@",parse);
        if (![[parse objectForKey:@"code"]isEqualToNumber:[NSNumber numberWithInt:200]]) {
            NSLog(@"No data in parse");
        }
        else{
                NSMutableDictionary * dict=[parse objectForKey:@"userprofile"];
                [profileImage addObject:[dict objectForKey:@"thumbanailUrl"]];
                [userName addObject:[dict objectForKey:@"displayName"]];
                [userId addObject:[dict objectForKey:@"userId"]];
        }
        }
 //   }
        NSLog(@"User id %@",userId);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
    // Dispose of any resources that can be recreated.
}

#pragma -mark Fetch history chat
-(void)fetchChatConversation:(NSString*)user{
    [[SingletonClass shareSingleton].messages removeAllObjects];
    NSError * error;
    NSURLResponse * urlResponse;
    
    NSURL * postUrl=[NSURL URLWithString:@"http://23.238.24.26/chat/get-chat-conv/"];
    
    NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:postUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString * body=[NSString stringWithFormat:@"fromJID=%@&toJID=%@",[SingletonClass shareSingleton].userID,user];
    [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (data==nil) {
        return;
    }
    id json=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
   // NSLog(@"Chat response %@",json);
    if ([[json objectForKey:@"code"]isEqualToNumber:[NSNumber numberWithInt:200]]) {
        NSArray * chatData=[json objectForKey:@"data"];
        if (chatData.count<1) {
            return;
        }
        [[SingletonClass shareSingleton].messages removeAllObjects];
         NSMutableDictionary * dict=[NSMutableDictionary dictionary];
        for (int i=0; i<chatData.count; i++) {
            dict=[chatData objectAtIndex:i];
            if ([[dict objectForKey:@"fromJID"] isEqualToString:[NSString stringWithFormat:@"%@@takadating.com",[SingletonClass shareSingleton].userID]]&& [[dict objectForKey:@"toJID"]isEqualToString:[NSString stringWithFormat:@"%@@takadating.com",user]]) {
                
                
                NSMutableDictionary * dict2=[[NSMutableDictionary alloc]init];
                [dict2 setObject:[dict objectForKey:@"body"] forKey:@"msg"];
                [dict2 setObject:@"you" forKey:@"sender"];
                [dict2 setObject:[dict objectForKey:@"sentDate"] forKey:@"time"];
                [[SingletonClass shareSingleton].messages addObject:dict2];
            }
            else if ([[dict objectForKey:@"toJID"] isEqualToString:[NSString stringWithFormat:@"%@@takadating.com",[SingletonClass shareSingleton].userID]]&& [[dict objectForKey:@"fromJID"]isEqualToString:[NSString stringWithFormat:@"%@@takadating.com",user]]) {
                
                
                NSMutableDictionary * dict2=[[NSMutableDictionary alloc]init];
                [dict2 setObject:[dict objectForKey:@"body"] forKey:@"msg"];
                [dict2 setObject:@"sender" forKey:@"sender"];
                [dict2 setObject:[dict objectForKey:@"sentDate"] forKey:@"time"];
                [[SingletonClass shareSingleton].messages addObject:dict2];
                
            }

        }
    }
}
@end
