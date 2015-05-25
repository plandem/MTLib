//
// Created by Andrey on 22/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>
#import "MTFormNumberInput.h"

@interface MTFormNumberInputCell : FXFormBaseCell <UIKeyInput>
@property (nonatomic, readonly) MTFormNumberInput *numberInput;

#pragma mark UITextInputTraits delegate
@property(nonatomic) UITextAutocapitalizationType autocapitalizationType; // default is UITextAutocapitalizationTypeSentences
@property(nonatomic) UITextAutocorrectionType autocorrectionType;         // default is UITextAutocorrectionTypeDefault
@property(nonatomic) UITextSpellCheckingType spellCheckingType;           // default is UITextSpellCheckingTypeDefault;
@property(nonatomic) UIKeyboardType keyboardType;                         // default is UIKeyboardTypeDefault
@property(nonatomic) UIKeyboardAppearance keyboardAppearance;             // default is UIKeyboardAppearanceDefault
@property(nonatomic) UIReturnKeyType returnKeyType;                       // default is UIReturnKeyDefault (See note under UIReturnKeyType enum)
@property(nonatomic) BOOL enablesReturnKeyAutomatically;                  // default is NO (when YES, will automatically disable return key when text widget has zero-length contents, and will automatically enable when text widget has non-zero-length contents)
@property(nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;       // default is NO
@end