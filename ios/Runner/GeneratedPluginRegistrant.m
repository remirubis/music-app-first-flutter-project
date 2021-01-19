//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"

#if __has_include(<audioplayer2/AudioplayerPlugin.h>)
#import <audioplayer2/AudioplayerPlugin.h>
#else
@import audioplayer2;
#endif

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

#if __has_include(<system_shortcuts/SystemShortcutsPlugin.h>)
#import <system_shortcuts/SystemShortcutsPlugin.h>
#else
@import system_shortcuts;
#endif

#if __has_include(<volume/VolumePlugin.h>)
#import <volume/VolumePlugin.h>
#else
@import volume;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AudioplayerPlugin registerWithRegistrar:[registry registrarForPlugin:@"AudioplayerPlugin"]];
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
  [SystemShortcutsPlugin registerWithRegistrar:[registry registrarForPlugin:@"SystemShortcutsPlugin"]];
  [VolumePlugin registerWithRegistrar:[registry registrarForPlugin:@"VolumePlugin"]];
}

@end
