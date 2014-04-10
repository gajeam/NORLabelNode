#import "NORLabelNode.h"


@interface NORLabelNode ()
@property (nonatomic, strong) NSArray *subNodes;
@property (nonatomic, strong) SKLabelNode *propertyStateholderNode; 
@end


@implementation NORLabelNode

const CGFloat kLineSpaceMultiplier    = 1.5;
@synthesize text    = _text;
@synthesize position    = _position;
@synthesize fontColor    = _fontColor;
@synthesize color    = _color;
@synthesize colorBlendFactor    = _colorBlendFactor;
@synthesize blendMode    = _blendMode;

+ (NORLabelNode *)labelNodeWithFontNamed:(NSString *)fontName{
    NORLabelNode *node    = [[[self class] alloc] initWithFontNamed:fontName];
    return node;
}


- (instancetype)initWithFontNamed:(NSString *)fontName{
	self    = [super initWithFontNamed:fontName];
	if (self) {
		[self setupStateholderNode];
		self.lineSpacing    = kLineSpaceMultiplier;
	}
	return self;
}


- (instancetype)init{
	self    = [super init];
	if (self) {
		[self setupStateholderNode];
		self.lineSpacing    = kLineSpaceMultiplier;
	}
	return self;
}


- (void)setupStateholderNode{
	if (!self.propertyStateholderNode) {
		self.propertyStateholderNode    = [SKLabelNode node];
		self.propertyStateholderNode.fontName    = self.fontName;
	}
}


- (NSArray *)labelNodesFromText:(NSString *)text{
	NSArray *substrings    = [text componentsSeparatedByString:@"\n"];
	NSMutableArray *labelNodes    = [[NSMutableArray alloc] initWithCapacity:[substrings count]];

	NSUInteger labelNumber    = 0;
	for (NSString *substring in substrings) {
		SKLabelNode *labelNode    = [SKLabelNode labelNodeWithFontNamed:self.fontName];
		labelNode.text    = substring;
		labelNode.fontColor    = self.fontColor;
		labelNode.fontSize    = self.fontSize;
		labelNode.horizontalAlignmentMode    = self.horizontalAlignmentMode;
		labelNode.verticalAlignmentMode    = self.verticalAlignmentMode;
		CGFloat y    = self.position.y - (labelNumber * self.fontSize * self.lineSpacing);
		labelNode.position    = CGPointMake(self.position.x, y);
		labelNode.color    = self.color;
		labelNode.colorBlendFactor    = self.colorBlendFactor;
		labelNode.blendMode    = self.blendMode;
		labelNumber++;
		[labelNodes addObject:labelNode];
	}
	
	return [labelNodes copy];
}


#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone{
	NORLabelNode *copy    = [[NORLabelNode alloc] initWithFontNamed:nil];
	if (copy) {
		copy.fontName    = [self.fontName copyWithZone:zone];
		copy.fontColor    = [self.fontColor copyWithZone:zone];
		copy.fontSize    = self.fontSize;
		copy.text    = [self.text copyWithZone:zone];
		copy.color   = [self.color copyWithZone:zone];
		copy.colorBlendFactor    = self.colorBlendFactor;
		copy.blendMode    = self.blendMode;
		copy.horizontalAlignmentMode    = self.horizontalAlignmentMode;
		copy.verticalAlignmentMode    = self.verticalAlignmentMode;
		
		copy.propertyStateholderNode    = [self.propertyStateholderNode copyWithZone:zone];
		copy.subNodes    = [self.subNodes copyWithZone:zone];
		for (SKLabelNode *labelNode in self.children) {
			[copy addChild:[labelNode copyWithZone:zone]];
		}
	}
	return copy;
}


#pragma mark setterOverriders

- (void)setText:(NSString *)text{
	self.propertyStateholderNode.text    = text;
	self.subNodes    = [self labelNodesFromText:text];
	[self removeAllChildren];
	for (SKLabelNode *childNode in self.subNodes) {
		[self addChild:childNode];
	}
	_text    = @"";
}


- (void)setPosition:(CGPoint)position{
	[super setPosition:position];
//	CGFloat xChange    = position.x - self.propertyStateholderNode.position.x;
//	CGFloat yChange    = self.propertyStateholderNode.position.y - position.y;
	
    self.propertyStateholderNode.position    = position;
	position.y    -= position.y;
	_position    = position;
	
	NSInteger lastIndex    = [self.children count] - 1;
	for (NSInteger index = 0; index < lastIndex; index++){
		SKLabelNode *childLabel    = [self.children objectAtIndex:index];
		childLabel.position    = CGPointMake(_position.x, _position.y - (index * self.fontSize * self.lineSpacing));
	}
	[self repositionSubNodesBasedOnParentPosition:position];
}


- (void)setHorizontalAlignmentMode:(SKLabelHorizontalAlignmentMode)horizontalAlignmentMode{
	[super setHorizontalAlignmentMode:horizontalAlignmentMode];
	self.propertyStateholderNode.horizontalAlignmentMode    = horizontalAlignmentMode;
	for (SKLabelNode *subNode in self.subNodes) {
		subNode.horizontalAlignmentMode    = horizontalAlignmentMode;
	}
}


- (void)setVerticalAlignmentMode:(SKLabelVerticalAlignmentMode)verticalAlignmentMode{
	[super setVerticalAlignmentMode:verticalAlignmentMode];
	self.propertyStateholderNode.verticalAlignmentMode    = verticalAlignmentMode;
	for (SKLabelNode *subNode in self.subNodes) {
		subNode.verticalAlignmentMode    = verticalAlignmentMode;
	}
}


- (void)setFontSize:(CGFloat)fontSize{
	[super setFontSize:fontSize];
	self.propertyStateholderNode.fontSize    = fontSize;
	for (SKLabelNode *subNode in self.subNodes) {
		subNode.fontSize    = fontSize;
	}
	[self repositionSubNodesBasedOnParentPosition:self.position];
}


- (void)setFontName:(NSString *)fontName{
	[super setFontName:fontName];
	self.propertyStateholderNode.fontName    = fontName;
	for (SKLabelNode *subNode in self.subNodes) {
		subNode.fontName    = fontName;
	}
	
}


- (void)setFontColor:(UIColor *)fontColor{
	[super setFontColor: fontColor];
	self.propertyStateholderNode.fontColor    = fontColor;
	for (SKLabelNode *subNode in self.subNodes) {
		subNode.fontColor    = fontColor;
	}
	_fontColor    = fontColor;
}


- (void)setColor:(UIColor *)color{
	[super setColor:color];
	self.propertyStateholderNode.color = color;
	for (SKLabelNode *subNode in self.subNodes) {
		subNode.color    = color;
	}
	_color    = color;
}


- (void)setColorBlendFactor:(CGFloat)colorBlendFactor{
	[super setColorBlendFactor:colorBlendFactor];
	self.propertyStateholderNode.colorBlendFactor = colorBlendFactor;
	for (SKLabelNode *subNode in self.subNodes) {
		subNode.colorBlendFactor    = colorBlendFactor;
	}
	_colorBlendFactor    = colorBlendFactor;
}


- (void)setBlendMode:(SKBlendMode)blendMode{
	[super setBlendMode:blendMode];
	self.propertyStateholderNode.blendMode    = blendMode;
	for (SKLabelNode *subNode in self.subNodes) {
		subNode.blendMode    = blendMode;
	}
	_blendMode    = blendMode;
}



#pragma mark -

- (void)repositionSubNodesBasedOnParentPosition:(CGPoint)position {
	CGFloat lineSpacingAdjustment    = self.fontSize * self.lineSpacing;
	CGFloat y    = position.y; // her kan vi justere...
	
	if (self.verticalAlignmentMode == SKLabelHorizontalAlignmentModeCenter) {
		CGFloat numberOfPositionsLabelsShouldMoveUp    = 1; // for a three line vertically centered label
		y    += numberOfPositionsLabelsShouldMoveUp * lineSpacingAdjustment;
	}
	
	for (SKLabelNode *subNode in self.subNodes) {
		CGFloat x    =  0;
		subNode.position    = CGPointMake(x, y);
		y    -= lineSpacingAdjustment;
	}
}


#pragma mark - frame

- (CGRect)frame{
	CGFloat largestWidth    = 0;
	for (SKLabelNode *childNode in self.subNodes) {
		if (childNode.frame.size.width > largestWidth) {
			largestWidth    = childNode.frame.size.width;
		}
	}
	CGRect frame    = self.propertyStateholderNode.frame;
	frame.size.width    = largestWidth;
	SKLabelNode *topNode    = [self.subNodes firstObject];
	CGFloat top    = CGRectGetMaxY(topNode.frame);
	SKLabelNode *bottomNode    = [self.subNodes lastObject];
	CGFloat bottom    = CGRectGetMinY(bottomNode.frame);
	CGFloat height    = bottom - top;
	if (height < 0) {
		height    *= -1;
	}
	frame.size.height    = height;
	return frame;
}



#pragma mark - property getters

-(NSUInteger)numberOfLines{
	return [self.subNodes count];
}


- (NSString *)text{
	return self.propertyStateholderNode.text;
}


- (CGPoint)position{
    return self.propertyStateholderNode.position;
}

#pragma mark - description

- (NSString *)description{
	NSString *positionString    = [NSString stringWithFormat:@"%@", NSStringFromCGPoint(self.position)];
	NSString *descriptionString    = [NSString stringWithFormat:@"<%@> name:'%@' text:'%@' fontName:'%@' position:%@", [self class], self.name, self.propertyStateholderNode.text, self.fontName, positionString];
	return descriptionString;
}


@end
