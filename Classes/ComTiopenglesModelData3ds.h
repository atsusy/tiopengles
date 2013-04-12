//
//  ComTiopenglesModelData3ds.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/21.
//  Copyright 2013 MARSHMALLOW MACHINE All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ComTiopenglesModelDataProtocol.h"


@interface ComTiopenglesModelData3ds : NSObject <ComTiopenglesModelDataProtocol> {
    NSData *dataSource;
    
    NSMutableArray *materials;
    MODEL_CHUNK *model_chunk;
}
- (id)initWithData:(NSData *)data;
@end
