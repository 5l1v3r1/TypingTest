//
//  TestDocument.m
//  TypingTest
//
//  Created by Alex Nichol on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestDocument.h"

@implementation TestDocument

@synthesize testContainer;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (NSString *)windowNibName {
    return @"TestDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    
    if (!loadedTest) {
        ANTypingTest * defaultTest = [[ANTypingTest alloc] initWithTestString:@"The quick brown fox."];
        [self loadTest:defaultTest];
    } else if (!testContainer) {
        [self loadTest:loadedTest];
    }
    
    editButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 120, 80, 24)];
    [editButton setBezelStyle:NSRoundedBezelStyle];
    [editButton setTitle:@"Edit"];
    [editButton setTarget:self];
    [editButton setAction:@selector(modifyTestText:)];
    [[[self mainWindow] contentView] addSubview:editButton];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    if (!testContainer.testView.typingTest) {
        if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:0 userInfo:NULL];
        return nil;
    }
    return [NSKeyedArchiver archivedDataWithRootObject:testContainer.testView.typingTest];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    ANTypingTest * test = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (![test isKindOfClass:[ANTypingTest class]] || !test) {
        if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:0 userInfo:NULL];
        return NO;
    }
    loadedTest = test;
    return YES;
}

+ (BOOL)autosavesInPlace {
    return NO;
}

#pragma mark - User Interface -

- (NSWindow *)mainWindow {
    return [[[self windowControllers] objectAtIndex:0] window];
}

#pragma mark UI Actions

- (void)modifyTestText:(id)sender {
    EnterTextWindow * window = [[EnterTextWindow alloc] initWithSize:NSMakeSize(300, 120) initialText:@""];
    [NSApp beginSheet:window modalForWindow:[self mainWindow] modalDelegate:self didEndSelector:nil contextInfo:NULL];
    [NSApp runModalForWindow:window];
    [NSApp endSheet:window];
    [window orderOut:nil];
}

#pragma mark - Test Container -

- (void)loadTest:(ANTypingTest *)theTest {
    if (testContainer) {
        [testContainer removeFromSuperview];
    }
    
    NSWindow * window = [self mainWindow];
    NSRect frame = NSMakeRect(0, 150, [window.contentView frame].size.width,
                              [window.contentView frame].size.height - 150);
    ANTypingTestView * testView = [[ANTypingTestView alloc] initWithFrame:frame typingTest:theTest];
    
    testContainer = [[ANTypingTestContainer alloc] initWithFrame:frame typingTestView:testView];
    [testContainer setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [window.contentView addSubview:testContainer];
    [window makeFirstResponder:testContainer];
}

@end
