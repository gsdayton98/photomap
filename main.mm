#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>
#include <iostream>

int main() {
    @autoreleasepool {
        // Request Photos authorization if needed
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];

        if (status == PHAuthorizationStatusNotDetermined) {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite
                                                       handler:^(PHAuthorizationStatus s) {
                dispatch_semaphore_signal(sema);
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
        }

        if (status != PHAuthorizationStatusAuthorized && status != PHAuthorizationStatusLimited) {
            std::cerr << "Error: Photos library access denied or restricted." << std::endl;
            return 1;
        }

        // Fetch all image assets from the user's library
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage
                                                                     options:options];

        printf("index,filename,date,latitude,longitude,altitude\n");

        [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            CLLocation *location = asset.location;
            if (!location) return;

            NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:asset];
            NSString *filename = resources.firstObject.originalFilename ?: @"unknown";

            NSString *dateStr = @"";
            if (asset.creationDate) {
                NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
                fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                dateStr = [fmt stringFromDate:asset.creationDate];
            }

            printf("%lu,%s,%s,%.6f,%.6f,%.1f\n",
                   (unsigned long)idx + 1,
                   [filename UTF8String],
                   [dateStr UTF8String],
                   location.coordinate.latitude,
                   location.coordinate.longitude,
                   location.altitude);
        }];
    }
    return 0;
}
