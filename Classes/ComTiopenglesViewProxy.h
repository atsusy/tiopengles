//
//  ComTiopenglesViewProxy.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/07.
//  Copyright 2011 LANGRISE Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TiViewProxy.h"
#import "ComTiopenglesView.h"

@interface ComTiopenglesViewProxy : TiViewProxy {
}
@property (nonatomic, readonly) id fps;
@property (nonatomic, readonly) id vertices;

- (void)addModel:(id)model;
@end
