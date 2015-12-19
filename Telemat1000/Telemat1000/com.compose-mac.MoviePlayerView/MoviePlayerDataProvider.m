//
//  MoviePlayerDataProvider.m
//
//

#import "MoviePlayerDataProvider.h"
#import "MoviePlayerView.h"

static NSString * formatTimeInSeconds(int totalSeconds) {

	if (totalSeconds <= 0)
		return @"0:00";

	int minutes = (totalSeconds/60),
		seconds = (totalSeconds-minutes*60);
		
	return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
	
}

@implementation MoviePlayerDataProvider {
	NSDictionary * _contents;
}

- (void)updateContents {
	
	double currentPlaybackTime = _playerView.moviePlayer.currentPlaybackTime;
	if (isnan(currentPlaybackTime)) currentPlaybackTime = 0;
	double totalPlaybackTime = _playerView.moviePlayer.duration;
	if (!totalPlaybackTime || isnan(totalPlaybackTime)) totalPlaybackTime = -1;
	
	_contents = @{
				  @"currentPlaybackTime": [NSNumber numberWithDouble:currentPlaybackTime],
				  @"currentPlaybackTimeString": formatTimeInSeconds((int)currentPlaybackTime),
				  @"remainingPlaybackTimeString": formatTimeInSeconds((int)totalPlaybackTime - (int)currentPlaybackTime),
				  @"currentPlaybackProgress": [NSNumber numberWithDouble:currentPlaybackTime/totalPlaybackTime],
				  @"isPlaying": _playerView.isPlaying ? @YES : @NO,
				  @"isNotPlaying": !_playerView.isPlaying ? @YES : @NO
				  };
	[self notifyObservers];
}

- (id)contents {
	return _contents;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
	if ([keyPath hasPrefix:@"contents."]) {
		NSString * key = [keyPath substringFromIndex:9];
		if ([key isEqualToString:@"currentPlaybackProgress"]) {
			//[_playerView pause];
			double current = _playerView.moviePlayer.duration * [value doubleValue];
			_playerView.moviePlayer.currentPlaybackTime = current;
			//NSLog(@"current: %f -> %f", current, _playerView.moviePlayer.currentPlaybackTime);
			[self updateContents];
			
		}
		//NSLog(@"setValue: %@ forKeyPath: %@", value, keyPath);
	}
	else [super setValue:value forKeyPath:keyPath];
}

@end
