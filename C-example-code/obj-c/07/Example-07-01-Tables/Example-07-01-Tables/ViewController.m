//
//  ViewController.m
//  Table View Test
//
//  Created by Philip Dow on 9/10/15.
//  Copyright (c) 2015 Phil Dow. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property NSArray *model;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Setting the dataSource and delegate here accomplish the same thing as
    // setting them in the storyboard
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.model = @[
        @YES, @NO, @NO, @YES, @YES, @NO, @NO, @YES, @NO, @YES,
        @NO, @NO, @NO, @YES, @YES, @NO, @YES, @YES, @NO, @YES,
        @YES, @NO, @NO, @NO, @YES, @NO, @NO, @YES, @NO, @NO,
        @YES, @NO, @NO, @YES, @YES, @YES, @NO, @YES, @NO, @YES
    ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the cell
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Set up its attributes
    
    cell.textLabel.text = [@"Table View Cell" stringByAppendingFormat:@" %ld", indexPath.row];
    
    if ( [self.model[indexPath.row] boolValue] ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.detailTextLabel.text = @"Detail";
    
    return cell;
}

#pragma mark - Table View Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // indexPath.row;
    // indexPath.section;
    
    // We must update both the cell and the data model
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL selected = [self.model[indexPath.row] boolValue];
    
    // Key-value coding gives us a shortcut
    
    [self mutableArrayValueForKey:@"model"][indexPath.row] = @(!selected);
    
    // NSMutableArray *model = [self.model mutableCopy];
    // model[indexPath.row] = @(!selected);
    // self.model = [model copy];
    
    cell.accessoryType = selected
        ? UITableViewCellAccessoryNone
        : UITableViewCellAccessoryCheckmark;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
