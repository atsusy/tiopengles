//
//  ComTiopengles3DModel.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/10.
//  Copyright 2011 LANGRISE Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TiProxy.h"


@interface ComTiopengles3DModel : TiProxy {
	float rotation[3];
	float translation[3];
}

+ (id)load:(NSString *)name;
- (void)rotation:(id)value;
- (void)translation:(id)value;
- (void)draw;
@end
