//
//  BJNewsAssetViewController.m
//  BJNewsMediaPicker
//
//  Created by wolffy on 2018/11/22.
//  Copyright © 2018年 新京报社. All rights reserved.
//

#import "BJNewsAssetViewController.h"
#import "BJNewsAssetCollectionViewCell.h"

@interface BJNewsAssetViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,strong) NSMutableArray * cellArray;
@property (nonatomic,strong) NSMutableArray * selectedArray;

@end

@implementation BJNewsAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishButtonClick:)];
    self.navigationItem.rightBarButtonItem = item;
    
    
    [self createView];
    [self initData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initData

- (void)initData{
    __weak UICollectionView * weak_collectionView = self.collectionView;
    [self requestAuthorizationCompleted:^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weak_collectionView reloadData];
        });
    }];
}

- (NSMutableArray *)dataArray{
    if(_dataArray == nil){
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (NSMutableArray *)cellArray{
    if(_cellArray == nil){
        _cellArray = [[NSMutableArray alloc]init];
    }
    return _cellArray;
}

- (NSMutableArray *)selectedArray{
    if(_selectedArray == nil){
        _selectedArray = [[NSMutableArray alloc]init];
    }
    return _selectedArray;
}

#pragma mark - create View

- (void)createView{
    [self.view addSubview:self.collectionView];
}

- (UICollectionView *)collectionView{
    if(_collectionView == nil){
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = [BJNewsAssetCollectionViewCell itemSize];
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"BJNewsAssetCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ID"];
    };
    return _collectionView;
}

#pragma mark - collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
    //    return 100;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BJNewsAssetCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ID" forIndexPath:indexPath];
    cell.imageView1.contentMode = UIViewContentModeScaleAspectFill;
    BJNewsMediaItem * model = self.dataArray[indexPath.row];
    [cell selectedItem:model.isSelected];
    cell.localID = model.phAsset.localIdentifier;
    if(self.mediaType == BJNewsAssetMediaTypeVideo){
        cell.timeLabel.hidden = NO;
        NSInteger t = (NSInteger)model.phAsset.duration;
        NSInteger min = t / 60;
        NSInteger sec = t % 60;
        cell.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",min,sec];
    }else{
        cell.timeLabel.hidden = YES;
    }
//    [model requestImageResultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
////        cell.imageView1.image = result;
//        NSLog(@"%f",result.size.width);
//    }];
 
    

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    BJNewsAssetCollectionViewCell * cell = (BJNewsAssetCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    BJNewsMediaItem * model = self.dataArray[indexPath.row];
    if(model.isSelected){
        model.isSelected = NO;
        [self.selectedArray removeObject:model];
    }else{
        if(self.selectedArray.count >= self.maxCount){
            return;
        }
        model.isSelected = YES;
        [self.selectedArray addObject:model];
    }
    [cell selectedItem:model.isSelected];
    [self checkCollectionViewAlpha];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.cellArray addObject:cell];
    [self checkCollectionViewAlpha];
    
    __weak BJNewsAssetCollectionViewCell * weak_cell = (BJNewsAssetCollectionViewCell *)cell;
    BJNewsMediaItem * model = self.dataArray[indexPath.row];
//    PHImageRequestOptions * assetOptions = [[PHImageRequestOptions alloc]init];
//    assetOptions.synchronous = NO;
//    assetOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
//    assetOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:model.phAsset targetSize:CGSizeMake(500, 500) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        NSLog(@"%ld",(long)indexPath.row);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if([weak_cell.localID isEqualToString:model.phAsset.localIdentifier]){
//                                    weak_cell.imageView1.image = result;
//            }
//        });
//    }];
    PHImageRequestID requestID = [[BJNewsMediaManager defaultManager] requestImageForAsset:model.phAsset resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([weak_cell.localID isEqualToString:model.phAsset.localIdentifier]){
                weak_cell.imageView1.image = result;
            }
        });
    }];
    model.requestID = requestID;
    
    
    
    NSLog(@"%f",model.phAsset.duration);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.cellArray removeObject:cell];
    [self checkCollectionViewAlpha];
    
    BJNewsMediaItem * model = self.dataArray[indexPath.row];
//    [[PHImageManager defaultManager] cancelImageRequest:model.requestID];
    [[BJNewsMediaManager defaultManager] cancelImageRequestWithID:model.requestID];
}

- (void)checkCollectionViewAlpha{
    if(self.selectedArray.count < self.maxCount){
        for (BJNewsAssetCollectionViewCell * cell in self.cellArray) {
            [cell setSelectedEnabled:YES];
        }
        return;
    }
    for (BJNewsAssetCollectionViewCell * cell in self.cellArray) {
        if(cell.isSelected == YES){
            [cell setSelectedEnabled:YES];
        }else{
            [cell setSelectedEnabled:NO];
        }
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)requestAuthorizationCompleted:(void (^) (void))completed{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(status == PHAuthorizationStatusDenied){
            NSLog(@"用户拒绝当前应用访问相册，我们需要提醒用户打开访问开关");
        }else if (status == PHAuthorizationStatusRestricted){
            NSLog(@"家长空中，不允许访问");
        }else if (status == PHAuthorizationStatusNotDetermined){
            NSLog(@"用户还没有做出选择");
        }else if (status == PHAuthorizationStatusAuthorized){
            NSLog(@"用户允许当前应用访问相册");
            [self getAllPhotos:completed];
        }
    }];
}

- (void)getAllPhotos:(void (^) (void))completed{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //    获取所有智能相册
        PHFetchResult * smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        NSLog(@"系统相册的数目:%lu",(unsigned long)smartAlbums.count);
        if(smartAlbums.count != 0){
            //            for (PHAssetCollection * collection in smartAlbums) {
            ////
            //                PHFetchResult * results = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:<#(nullable PHFetchOptions *)#>]
            //            }
            
            
            
            
            
            
            //            获取资源时的参数
            PHFetchOptions * options = [[PHFetchOptions alloc]init];
            //            按时间排序
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            //            选取本地相册，
            PHAssetMediaType type = PHAssetMediaTypeImage;
            if(self.mediaType == BJNewsAssetMediaTypeVideo){
                type = PHAssetMediaTypeVideo;
            }
            PHFetchResult * results = [PHAsset fetchAssetsWithMediaType:type options:options];
            NSLog(@"%lu\n%@",(unsigned long)results.count,results);
            
            for (PHAsset * asset in results) {
                //                PHImageRequestOptions * assetOptions = [[PHImageRequestOptions alloc]init];
                //                assetOptions.synchronous = YES;
                //                assetOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
                //                assetOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                //                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                //
                //                }];
                
                
                
                //                PHVideoRequestOptions * videoOptions = [[PHVideoRequestOptions alloc]init];
                //                videoOptions.version = PHImageRequestOptionsVersionCurrent;
                //                videoOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                //                [[PHImageManager defaultManager] requestExportSessionForVideo:asset options:videoOptions exportPreset:AVAssetExportPresetMediumQuality resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                //
                //                }];
                
                BJNewsMediaItem * model = [[BJNewsMediaItem alloc]init];
                model.phAsset = asset;
                [self.dataArray addObject:model];
            }
            if(completed){
                completed();
            }
        }
    });
}

- (void)finishButtonClick:(id)sender{
    if(self.callBack && self.selectedArray.count > 0){
        self.callBack(self.selectedArray);
    }
    if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

@end
