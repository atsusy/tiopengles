//
//  TiBlob+TiBlob_Composite.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 2013/04/12.
//
//

#import "TiBlob+Composite.h"

@implementation TiBlob (Composite)
-(TiBlob *)imageWithComposite:(id)args
{
    ENSURE_ARRAY(args);
    TiBlob *overlay = nil;
    ENSURE_ARG_OR_NIL_AT_INDEX(overlay, args, 0, TiBlob);

    if(self.type != TiBlobTypeImage || overlay.type != TiBlobTypeImage) { return self; }
    
    CGRect r = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, r.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, r, self.image.CGImage);
    CGContextDrawImage(context, r, overlay.image.CGImage);
    
    UIImage *composited = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [[[TiBlob alloc] initWithImage:composited] autorelease];
}
@end
