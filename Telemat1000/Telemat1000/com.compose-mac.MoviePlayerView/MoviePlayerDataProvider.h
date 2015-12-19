//
//  MoviePlayerDataProvider.h
//
//

#import "DataSourceBase.h"
@class MoviePlayerView;

@interface MoviePlayerDataProvider : DataSourceBase

@property (nonatomic, weak)		IBOutlet MoviePlayerView * playerView;

- (void)updateContents;

@end

