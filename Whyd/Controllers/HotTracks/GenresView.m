//
//  GenresView.m
//  Whyd
//
//  Created by Damien Romito on 26/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "GenresView.h"
#import "GenreCell.h"

@interface GenresView()
@end
@implementation GenresView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = RGBACOLOR(255, 255, 255, 0.85);
        
        self.tableView = [[UITableView alloc] init];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = UICOLOR_CLEAR;
        self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        self.tableView.scrollsToTop = NO;
        [self addSubview:self.tableView];
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.tableView.frame = self.frame;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.genresArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString* CellIdentifier = @"GenreCell";
    
    GenreCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[GenreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:13];
    }

    cell.genre = [self.genresArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.selectedIndex) {
        if (self.selectedIndex >= 0 ) {
            ((Genre *)[self.genresArray objectAtIndex:self.selectedIndex]).isSelected = NO;
            GenreCell * oldCell = (GenreCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
            [oldCell stateSelected:NO];
        }
        self.selectedIndex = indexPath.row;
        ((Genre *)[self.genresArray objectAtIndex:indexPath.row]).isSelected = YES;
        [((GenreCell*)[self.tableView cellForRowAtIndexPath:indexPath]) stateSelected:YES];
    }

    [self.delegate pickGenre:[self.genresArray objectAtIndex:indexPath.row]];
}



@end
