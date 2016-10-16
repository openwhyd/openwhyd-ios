//
//  UIView+UpdateAutoLayoutConstant.m
//  ConstraintsCodeDemo
//
//  Created by Damien Romito on 13/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "UIView+UpdateAutoLayoutConstraints.h"

@implementation UIView (UpdateAutoLayoutConstraints)


- (BOOL) setConstraintConstant:(CGFloat)constant forAttribute:(NSLayoutAttribute)attribute
{
    NSLayoutConstraint * constraint = [self constraintForAttribute:attribute];
    if(constraint)
    {
        [constraint setConstant:constant];
        return YES;
    }else
    {
        [self.superview addConstraint: [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:constant]];
        return NO;
    }
}


- (CGFloat) constraintConstantforAttribute:(NSLayoutAttribute)attribute
{
    NSLayoutConstraint * constraint = [self constraintForAttribute:attribute];
    
    if (constraint) {
        return constraint.constant;
    }else
    {
        return NAN;
    }
    
}


- (NSLayoutConstraint*) constraintForAttribute:(NSLayoutAttribute)attribute
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d && firstItem = %@", attribute, self];
    NSArray *fillteredArray = [[self.superview constraints] filteredArrayUsingPredicate:predicate];
    if(fillteredArray.count == 0)
    {
        return nil;
    }else
    {
        return fillteredArray.firstObject;
    }
}


- (void)hideByHeight:(BOOL)hidden
{
    [self hideView:hidden byAttribute:NSLayoutAttributeHeight];
}


- (void)hideByWidth:(BOOL)hidden
{
    [self hideView:hidden byAttribute:NSLayoutAttributeWidth];
}



- (void)hideView:(BOOL)hidden byAttribute:(NSLayoutAttribute)attribute
{
    if (self.hidden != hidden) {
        CGFloat constraintConstant = [self constraintConstantforAttribute:attribute];
        
        if (hidden && !isnan(constraintConstant))
        {
            self.alpha = constraintConstant;
            [self setConstraintConstant:0 forAttribute:attribute];
            self.hidden = YES;
            
        }else
        {
            if (!isnan(constraintConstant) )
            {
                [self setConstraintConstant:self.alpha forAttribute:attribute];
            }
            self.hidden = NO;
            self.alpha = 1;
        }
    }
}


- (CGSize) getSize
{
    [self updateSizes];
    return CGSizeMake(self.bounds.size.width, self.bounds.size.height);
}

- (void)updateSizes
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)sizeToSubviews
{
    [self updateSizes];
    CGSize fittingSize = [self systemLayoutSizeFittingSize: UILayoutFittingCompressedSize];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, fittingSize.height);
}


@end
