//
//  MoviePlayerView.m
//

#import "MoviePlayerView.h"
#import "MoviePlayerDataProvider.h"
#import "FileURLHelper.h"

@implementation MoviePlayerView {
	NSTimer * _publishCurrentStateTimer;
	BOOL _isPlaying;
	BOOL _didPrepare;
}

- (BOOL)isPlaying {
	return _isPlaying;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self prepare];
	[self publishCurrentState];
}
	
- (void)dealloc {
	NSLog(@"dealloc: %@", self);
	if (_moviePlayer) [self unsetMoviePlayer];
}

- (void)removeFromSuperview {
	[super removeFromSuperview];
	if (_moviePlayer) [self unsetMoviePlayer];
}
	
- (void)setMovieURLString:(NSString *)movieURLString {
	_movieURLString = [movieURLString copy];

	NSURL * url = GetFileURLFromString(self.movieURLString);
	if (!url) return;
	
	if (!self.moviePlayer) {
		_moviePlayer =  [[MPMoviePlayerController alloc] initWithContentURL:url];
		_moviePlayer.view.frame = self.bounds;
		_moviePlayer.view.autoresizingMask = 18;
		self.showsControls = self.showsControls;
		self.autoplay = self.autoplay;
		[self prepare];
		[_moviePlayer prepareToPlay];
	}
	else {
		[_moviePlayer stop];
		_moviePlayer.contentURL = url;
		[_moviePlayer prepareToPlay];
	}
   
}

- (void)setShowsControls:(BOOL)showsControls {
	_showsControls = showsControls;
	_moviePlayer.controlStyle = showsControls ? MPMovieControlStyleDefault : MPMovieControlStyleNone;
}

- (void)setAutoplay:(BOOL)autoplay {
	_autoplay = autoplay;
	_moviePlayer.shouldAutoplay = autoplay;
}
	
- (void)unsetMoviePlayer {
	
    [[NSNotificationCenter defaultCenter] removeObserver:self
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:_moviePlayer];

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackStateDidChangeNotification
												  object:_moviePlayer];

	[self.moviePlayer stop];
	[self.moviePlayer.view removeFromSuperview];
	self.moviePlayer = nil;
	if (_publishCurrentStateTimer) [_publishCurrentStateTimer invalidate];
	_publishCurrentStateTimer = nil;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"AudioPlayerDidDisappear" object:self];
}

- (void)prepare {
	if (!_moviePlayer || _didPrepare) return;
	_didPrepare = YES;
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviePlaybackDidFinish:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:_moviePlayer];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviePlaybackStateDidChange:)
												 name:MPMoviePlayerPlaybackStateDidChangeNotification
											   object:_moviePlayer];

    [self addSubview:_moviePlayer.view];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AudioPlayerDidPrepare" object:self];
}

- (void)publishCurrentState {
	[self.dataProvider updateContents];
}

- (void)moviePlaybackDidFinish:(NSNotification*)notification {
	
    MPMoviePlayerController *player = [notification object];
	if (player.isFullscreen) {
		[player setFullscreen:NO animated:YES];
	}
}

- (void)moviePlaybackStateDidChange:(NSNotification*)notification {
    MPMoviePlaybackState playbackState = [_moviePlayer playbackState];
	if (playbackState == MPMoviePlaybackStatePlaying) {
		[self beginPublishingCurrentState];
		_isPlaying = YES;
	}
	if (playbackState == MPMoviePlaybackStateInterrupted || playbackState == MPMoviePlaybackStatePaused || playbackState == MPMoviePlaybackStateStopped) {
		[self endPublishingCurrentState];
		_isPlaying = NO;
	}
	[self publishCurrentState];
}
		
- (void)beginPublishingCurrentState {
	if (_publishCurrentStateTimer) [self endPublishingCurrentState];
	_publishCurrentStateTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(publishCurrentState) userInfo:nil repeats:YES];

}

- (void)endPublishingCurrentState {
	[self publishCurrentState];
	[_publishCurrentStateTimer invalidate];
	_publishCurrentStateTimer = nil;
}


- (void)play {
	[self.moviePlayer play];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AudioPlayerDidPrepare" object:self];
}

- (void)pause {
	[self.moviePlayer pause];
}

- (void)pauseOrPlay {
	if (_isPlaying) {
		[_moviePlayer pause];
	}
	else {
		[_moviePlayer play];
	}
}

- (void)stop {
	[self.moviePlayer stop];
}

- (void)toggleFullScreen {
	if (_moviePlayer.isFullscreen) {
		[_moviePlayer setFullscreen:NO animated:YES];
	}
	else {
		[_moviePlayer setFullscreen:YES animated:YES];
	}
}

- (void)seekBackward {
	_moviePlayer.currentPlaybackTime -= 5;
	
}

- (void)seekForward {
	_moviePlayer.currentPlaybackTime += 5;
}

- (void)beginSeekingBackward {
	[_moviePlayer beginSeekingBackward];
}

- (void)beginSeekingForward {
	[_moviePlayer beginSeekingForward];
}

- (void)endSeeking {
	[_moviePlayer endSeeking];
}

- (void)setDataProvider:(MoviePlayerDataProvider *)dataProvider {
	dataProvider.playerView = self;
	_dataProvider = dataProvider;
}

- (void)destroy {
	[self unsetMoviePlayer];
}

- (void)viewWillAppear:(BOOL)animated {
	if (!_moviePlayer.isPreparedToPlay) [_moviePlayer prepareToPlay];
}

@end
