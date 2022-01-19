#import "TOPReStoreItemTableViewCell.h"

@implementation TOPReStoreItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"top_delete_language"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(top_clickDeleteItem:) forControlEvents:UIControlEventTouchUpInside];
    
        _reStoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reStoreButton setImage:[UIImage imageNamed:@"top_restore_drive"] forState:UIControlStateNormal];
        [_reStoreButton addTarget:self action:@selector(top_clickRestore:) forControlEvents:UIControlEventTouchUpInside];
    
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.numberOfLines = 2;
   
        UILabel *lineLabel = [UILabel new];
        lineLabel.numberOfLines = 2;
        lineLabel.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:UIColorFromRGB(0xF0F0F0)];
       
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_reStoreButton];
        [self.contentView addSubview:_deleteButton];
        [self.contentView addSubview:lineLabel];

        [_deleteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.trailing.equalTo(self.contentView).offset(-15);
            make.size.mas_equalTo(CGSizeMake(35, 35));
        }];
        [_reStoreButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.trailing.equalTo(_deleteButton.mas_leading).offset(-15);
            make.size.mas_equalTo(CGSizeMake(35, 35));
        }];
        [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(15);
            make.trailing.equalTo(_reStoreButton.mas_leading).offset(-5);
            make.top.equalTo(self.contentView).offset(5);
            make.bottom.equalTo(self.contentView).offset(-5);
        }];
        [lineLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(15);
            make.height.mas_equalTo(1.0);
        }];
    }
    return self;
}
- (void)top_clickRestore:(UIButton *)sender
{
    if (self.top_didItemClick) {
        self.top_didItemClick(RestoreClickStyleRestore,self.driveFile);
    }
    if (self.top_didDropBoxItemClick) {
        self.top_didDropBoxItemClick(RestoreClickStyleRestore,self.dropBoxFile);
    }
    if (self.top_didBoxDriveItemClick) {
        self.top_didBoxDriveItemClick(RestoreClickStyleRestore,self.boxDriveFile);
    }
    if (self.top_didOneBoxDriveItemClick) {
        self.top_didOneBoxDriveItemClick(RestoreClickStyleRestore,self.oneDriveFile);
    }
}

- (void)top_clickDeleteItem:(UIButton *)sender
{
    if (self.top_didItemClick) {
        self.top_didItemClick(RestoreClickStyleDelete,self.driveFile);
    }
    if (self.top_didDropBoxItemClick) {
        self.top_didDropBoxItemClick(RestoreClickStyleDelete,self.dropBoxFile);
    }
    if (self.top_didBoxDriveItemClick) {
        self.top_didBoxDriveItemClick(RestoreClickStyleDelete,self.boxDriveFile);
    }
    if (self.top_didOneBoxDriveItemClick) {
        self.top_didOneBoxDriveItemClick(RestoreClickStyleDelete,self.oneDriveFile);
    }
}

- (void)setDriveFile:(GTLRDrive_File *)driveFile
{
    _driveFile = driveFile;
    self.titleLab.text = [NSString stringWithFormat:@"%@(%.2fM)",driveFile.name,[driveFile.size doubleValue]/(1024.0*1024.0)];
}

- (void)setDropBoxFile:(DBFILESMetadata *)dropBoxFile
{
    _dropBoxFile = dropBoxFile;
    if ([dropBoxFile isKindOfClass:[DBFILESFileMetadata class]]) {
        DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)dropBoxFile;
        self.titleLab.text = [NSString stringWithFormat:@"%@(%.2fM)",fileMetadata.name,[fileMetadata.size doubleValue]/(1024.0*1024.0)];
    }
}

- (void)setOneDriveFile:(ODItem *)oneDriveFile
{
    _oneDriveFile = oneDriveFile;
        self.titleLab.text = [NSString stringWithFormat:@"%@(%.2fM)",oneDriveFile.name,oneDriveFile.size/(1024.0*1024.0)];
}
- (void)setBoxDriveFile:(BOXItem *)boxDriveFile
{
    _boxDriveFile = boxDriveFile;
        self.titleLab.text = [NSString stringWithFormat:@"%@(%.2fM)",boxDriveFile.name,[boxDriveFile.size doubleValue]/(1024.0*1024.0)];
}

@end
