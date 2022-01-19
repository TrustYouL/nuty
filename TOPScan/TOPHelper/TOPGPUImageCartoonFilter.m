#import "TOPGPUImageCartoonFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

@implementation TOPGPUImageCartoonFilter

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }

    UIImage *image = [UIImage imageNamed:@"lookup_cartoon.png"];
    
    lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    [self addFilter:lookupFilter];
    
    [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [lookupImageSource processImage];

    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
    self.terminalFilter = lookupFilter;
    
    return self;
}


@end
