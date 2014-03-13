//
// stone for iOS : ViewControllerHistory.m
//
// Copyright (c) 2014 KLab Inc. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GNU Emacs; see the file COPYING.  If not, write to
// the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
//

#import "Common.h"
#import "ViewControllerHistory.h"
#import "ViewControllerMain.h"
#import "Setting.h"
#import "Uty.h"

@interface ViewControllerHistory ()

@property (strong, nonatomic) NSMutableArray *rows;
@end

@implementation ViewControllerHistory

#define COLOR_LIGHT_YELLOW  ([UIColor colorWithRed:1.0   green:1.0 blue:0.878 alpha:1.0])
#define COLOR_LIGHT_CYAN    ([UIColor colorWithRed:0.878 green:1.0 blue:1.0 alpha:1.0])
#define COLOR_WHITE         ([UIColor whiteColor]);

-(void)viewWillAppear:(BOOL)animated
{
    // show navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    setting = [[Setting alloc] init];
    
    // ViewController of Main UI
    viewControllerMain = [self.navigationController.viewControllers objectAtIndex:0];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.navigationItem.backBarButtonItem setEnabled:YES];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:TEXT(@"Edit")
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(didTapEditButton)];
    
    int num = [setting countCommandHistory];
    self.rows = [NSMutableArray arrayWithCapacity:num];
    NSArray *history = [setting getCommandHistory];
    for (int i = 0; i < num; i++) {
        [self.rows addObject:history[i]];
    }
}

- (void)didTapEditButton
{
    NSIndexPath *idxPath;
    UITableViewCell *cell;
    NSInteger num = [self.tableView numberOfRowsInSection:0];
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing) {
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
        self.navigationItem.rightBarButtonItem.title = TEXT(@"EditDone");
        // set cell color to white
        for (int i = 0; i < num; i++) {
            idxPath = [NSIndexPath indexPathForRow:i inSection:0];
            cell = [self.tableView cellForRowAtIndexPath:idxPath];
            cell.backgroundColor =  COLOR_WHITE;
        }
    } else {
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        self.navigationItem.rightBarButtonItem.title = TEXT(@"Edit");
        // save current list
        NSArray *list = [self.rows copy];
        [setting setCommandHistoryArray:list];
        // set color for cells
        for (int i = 0; i < num; i++) {
            idxPath = [NSIndexPath indexPathForRow:i inSection:0];
            cell = [self.tableView cellForRowAtIndexPath:idxPath];
            if (i % 2) {
                cell.backgroundColor =  COLOR_LIGHT_YELLOW;
            } else {
                cell.backgroundColor = COLOR_LIGHT_CYAN;
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.minimumFontSize = 8.0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.numberOfLines = 0; // no limit
    NSString *text = [self.rows objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete an item
        [self.rows removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (destinationIndexPath.row >= self.rows.count) {
        return;
    }
    // sort items
    NSString *text = [self.rows objectAtIndex:sourceIndexPath.row];
    [self.rows removeObjectAtIndex:sourceIndexPath.row];
    [self.rows insertObject:text atIndex:destinationIndexPath.row];
}

// cell is tapped
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger idx = [indexPath row];
    NSString *cmd = self.rows[idx];
    // save the text of selected item to the top of the list
    [setting setCommandHistory:cmd];
    // set text to the Command field in Main View
    [viewControllerMain setCommandString:cmd];
    // close Command History View
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set colors for cells
    if (indexPath.row % 2) {
        cell.backgroundColor =  COLOR_LIGHT_YELLOW;
    } else {
        cell.backgroundColor = COLOR_LIGHT_CYAN;
    }
}

@end
