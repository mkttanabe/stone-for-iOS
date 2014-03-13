//
// stone for iOS : ViewControllerFile.m
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
#import "ViewControllerFile.h"
#import "ViewControllerMain.h"
#import "Setting.h"
#import "Uty.h"

@interface ViewControllerFile ()

@property (strong, nonatomic) NSMutableArray *rows;

@end

@implementation ViewControllerFile

#define ALERTVIEW_FILENAME          0
#define ALERTVIEW_FILENAMEERROR     1
#define ALERTVIEW_FILEDELETE        2
#define ALERTVIEW_FILEDELETEEERROR  3
#define ALERTVIEW_FILENOTFOUND      4

-(void)viewWillAppear:(BOOL)animated
{
    // show navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL localFileExist = NO;
    setting = [[Setting alloc] init];
    uty = [[Uty alloc] init];
    
    // get viewController of Main View
    viewControllerMain = [self.navigationController.viewControllers objectAtIndex:0];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.navigationItem.backBarButtonItem setEnabled:YES];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:TEXT(@"Operation")
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(didTapEditButton)];
    // file names
    NSArray *files = [uty getDirEntryList:[uty getAppDocumentsPath]];
    NSUInteger num = [files count];
    self.rows = [NSMutableArray arrayWithCapacity:num];
    for (NSUInteger i = 0; i < num; i++) {
        BOOL isDir;
        NSString *path = [uty createAppDocumentsFilePath:files[i]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: &isDir]) {
            if (!isDir) {
                [self.rows addObject:files[i]];
                localFileExist = YES;
            }
        }
    }
    
    // show description if there ara no filess
    if (!localFileExist) {
        [uty showMessageDialog:TEXT(@"NoLocalFiles")
                         title:APP_NAME
                           tag:ALERTVIEW_FILENOTFOUND
                      delegate:self];
    }
}

- (void)didTapEditButton
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing) {
        self.navigationItem.rightBarButtonItem.title = TEXT(@"OperationDone");
    } else {
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        self.navigationItem.rightBarButtonItem.title = TEXT(@"Operation");
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
    NSString *name = [self.rows objectAtIndex:indexPath.row];
    cell.textLabel.text = name;
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        selectedRow = [indexPath row];
        [uty showQueryDialog:TEXT(@"QueryDeleteFile")
                       title:TEXT(@"DeleteFile")
                 buttonText0:TEXT(@"Cancel")
                 buttonText1:TEXT(@"OK")
                         tag:ALERTVIEW_FILEDELETE
                    delegate:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// cell is tapped
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = [indexPath row];
    [self showFileNameDialog];
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // unselect cell
}

- (void)showFileNameDialog
{
    NSString *oldName = self.rows[selectedRow];
    [uty showInputDialog:TEXT(@"EnterNewFileName")
                   title:TEXT(@"RenameFile")
                     tag:ALERTVIEW_FILENAME
                delegate:self
                  secure:NO
             defaultText:oldName];
}

// alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSFileManager *fMan = [NSFileManager defaultManager];
    NSError *err;
    NSIndexPath *idxPath;
    NSString *fname;
    
    if (alertView.tag == ALERTVIEW_FILENOTFOUND) {
        // go back to Tools menu
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == ALERTVIEW_FILEDELETE) {
        if (buttonIndex == 1) { // OK
            idxPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
            fname = [uty createAppDocumentsFilePath:self.rows[selectedRow]];
            if (![fMan removeItemAtPath:fname error:&err]) {
                [uty showMessageDialog:TEXT(@"FileDeleteError")
                                 title:APP_NAME
                                   tag:ALERTVIEW_FILEDELETEEERROR
                              delegate:self];
                return;
            }
            // remove from array
            [self.rows removeObjectAtIndex:idxPath.row];
            // remove cell
            [self.tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    else if (alertView.tag == ALERTVIEW_FILENAME) {
        if (buttonIndex == 1) { // OK
            idxPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
            // get specified file name
            fname  = [[alertView textFieldAtIndex:0] text];
            // blank
            if ([fname length] <= 0) {
                [uty showMessageDialog:TEXT(@"SpecifyFileName")
                                 title:APP_NAME
                                   tag:ALERTVIEW_FILENAMEERROR
                              delegate:self];
                return;
            }
            // not changed
            if ([fname isEqualToString:self.rows[selectedRow]]) {
                return;
            }
            // duplication check
            NSInteger num = self.rows.count;
            for (int i = 0; i < num; i++) {
                if (i == selectedRow) {
                    continue;
                }
                if ([self.rows[i] isEqualToString:fname]) {
                    [uty showMessageDialog:TEXT(@"NotUniqueFileName")
                                     title:APP_NAME
                                       tag:ALERTVIEW_FILENAMEERROR
                                  delegate:self];
                    return;
                }
            }
            NSString *oldName = [uty createAppDocumentsFilePath:self.rows[selectedRow]];
            NSString *newName = [uty createAppDocumentsFilePath:fname];
            if (![fMan moveItemAtPath:oldName toPath:newName error:&err]) {
                [uty showMessageDialog:TEXT(@"FileRenameError")
                                 title:APP_NAME
                                   tag:ALERTVIEW_FILENAMEERROR
                              delegate:self];
                return;
            }
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:idxPath];
            // change display name
            cell.textLabel.text = fname;
            // change array data
            self.rows[selectedRow] = fname;
        }
    }
    // show alertView again if got some error
    else if (alertView.tag == ALERTVIEW_FILENAMEERROR) {
        [self showFileNameDialog];
    }
}

@end
