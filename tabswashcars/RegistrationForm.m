//
//  RegistrationForm.m
//  BasicExample
//
//  Created by Nick Lockwood on 04/03/2014.
//  Copyright (c) 2014 Charcoal Design. All rights reserved.
//

#import "RegistrationForm.h"


@implementation RegistrationForm

//because we want to rearrange how this form
//is displayed, we've implemented the fields array
//which lets us dictate exactly which fields appear
//and in what order they appear

- (NSArray *)fields
{
    return @[
             
             //we want to add a group header for the field set of fields
             //we do that by adding the header key to the first field in the group
             
             @{FXFormFieldKey: @"phone", FXFormFieldTitle:@"手机号", FXFormFieldHeader: @"账户"},
             
             //we don't need to modify these fields at all, so we'll
             //just refer to them by name to use the default settings
             @{FXFormFieldKey: @"email", FXFormFieldTitle:@"邮箱"},
             @{FXFormFieldKey: @"Password", FXFormFieldTitle:@"密码"},
             @{FXFormFieldKey: @"repeatPassword", FXFormFieldTitle:@"确认密码"},
             
             //we want to add another group header here, and modify the auto-capitalization
             
             @{FXFormFieldKey: @"name", FXFormFieldHeader: @"用户资料",
               @"textField.autocapitalizationType": @(UITextAutocapitalizationTypeWords)},
             
             //this is a multiple choice field, so we'll need to provide some options
             //because this is an enum property, the indexes of the options should match enum values
             
             @{FXFormFieldKey: @"gender", FXFormFieldOptions: @[@"男", @"女", @"保密"]},
             
             
             //the country value in our form is a locale code, which isn't human readable
             //so we've used the FXFormFieldValueTransformer option to supply a value transformer
             
            @{FXFormFieldTitle: @"注册", FXFormFieldHeader: @"", FXFormFieldAction: @"submitRegistrationForm:"},
             
             ];
}

@end
