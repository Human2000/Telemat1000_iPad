//
//  MoviePlayerView.h
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MoviePlayerDataProvider.h"
//@class MoviePlayerDataProvider;
@interface MoviePlayerView : UIView

@property (strong, nonatomic) NSString * movieURLString;
@property (strong, nonatomic) MPMoviePlayerController * moviePlayer;
@property (nonatomic) BOOL autoplay;
@property (nonatomic) BOOL showsControls;
@property (readonly, nonatomic) BOOL isPlaying;
@property (nonatomic, weak) MoviePlayerDataProvider * dataProvider;

- (void)play;
- (void)pause;
- (void)pauseOrPlay;
- (void)toggleFullScreen;
- (void)seekBackward;
- (void)seekForward;
- (void)beginSeekingBackward;
- (void)beginSeekingForward;
- (void)endSeeking;

- (void)viewWillAppear:(BOOL)animated;

@end
