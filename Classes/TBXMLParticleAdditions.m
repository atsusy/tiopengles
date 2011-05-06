//
//  TBXMLParticleAdditions.m
//  ParticleEmitterDemo
//
// Copyright (c) 2010 71Squared
//
// Copyright (c) 2010 71Squared
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TBXMLParticleAdditions.h"


@implementation TBXML (TBXMLParticleAdditions) 

- (float)intValueFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement {
	TBXMLElement * xmlElement = [TBXML childElementNamed:aName parentElement:aParentXMLElement];
	
	if (xmlElement) {
		return [[TBXML valueOfAttributeNamed:@"value" forElement:xmlElement] intValue];
	}
	
	return 0;
}

- (float)floatValueFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement {
	TBXMLElement * xmlElement = [TBXML childElementNamed:aName parentElement:aParentXMLElement];
	
	if (xmlElement) {
		return [[TBXML valueOfAttributeNamed:@"value" forElement:xmlElement] floatValue];
	}
	
	return 0.0f;
}

- (BOOL)boolValueFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement {
	TBXMLElement * xmlElement = [TBXML childElementNamed:aName parentElement:aParentXMLElement];
	
	if (xmlElement) {
		return [[TBXML valueOfAttributeNamed:@"value" forElement:xmlElement] boolValue];
	}
	
	return NO;
}

- (Vector2f)vector2fFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement {
	TBXMLElement * xmlElement = [TBXML childElementNamed:aName parentElement:aParentXMLElement];
	
	if (xmlElement) {
		float x = [[TBXML valueOfAttributeNamed:@"x" forElement:xmlElement] floatValue];
		float y = [[TBXML valueOfAttributeNamed:@"y" forElement:xmlElement] floatValue];
		return Vector2fMake(x, y);
	}
	
	return Vector2fMake(0, 0);
}

- (Color4f)color4fFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement {
	TBXMLElement * xmlElement = [TBXML childElementNamed:aName parentElement:aParentXMLElement];
	
	if (xmlElement) {
		float red = [[TBXML valueOfAttributeNamed:@"red" forElement:xmlElement] floatValue];
		float green = [[TBXML valueOfAttributeNamed:@"green" forElement:xmlElement] floatValue];
		float blue = [[TBXML valueOfAttributeNamed:@"blue" forElement:xmlElement] floatValue];
		float alpha = [[TBXML valueOfAttributeNamed:@"alpha" forElement:xmlElement] floatValue];
		return Color4fMake(red, green, blue, alpha);
	}
	
	return Color4fMake(0, 0, 0, 0);
}

@end
