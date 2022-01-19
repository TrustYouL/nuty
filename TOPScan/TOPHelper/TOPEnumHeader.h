#ifndef TOPEnumHeader_h
#define TOPEnumHeader_h

#pragma mark -- 复制/移动文件相关
//列表的排列方式
typedef NS_ENUM(NSUInteger, TOPDocumentListShowType) {
    ShowDefault,
    ShowTwoGoods,  //一行2个cell
    ShowThreeGoods, //一行3个cell
    ShowListGoods, //tableView第一种排列
    ShowListNextGoods, //tableView第二种排列
    ShowListDetailGoods, //TOPHomeChildViewController的排列
    ShowListChildBatch, //TOPHomeChildBatchViewController的排列
};

//列表的排列顺序
typedef NS_ENUM(NSUInteger, TOPFolderDocumentOrderType) {
    FolderDocumentCreateDescending,//创建由新到旧
    FolderDocumentCreateAscending, //创建由旧到新
    FolderDocumentFileNameAToZ, //首字母A到Z
    FolderDocumentFileNameZToA, //首字母Z到A
    FolderDocumentUpdateDescending,//修改由新到旧
    FolderDocumentUpdateAscending, //修改由旧到新
};

//列表的排列顺序
typedef NS_ENUM(NSUInteger, TOPSortType) {
    HomeViewShowSortType,//首页视图的显示样式
    DocumentSortType,    //doc文件夹是按照什么顺序排列的
    TagsDocumentSortType,//tags标签是按照什么样的顺序排列的
};

typedef NS_ENUM(NSUInteger, TOPFileHandleType) {
    TOPFileHandleTypeCopy, //拷贝
    TOPFileHandleTypeMove, //移动
};

typedef NS_ENUM(NSUInteger, TOPFileTargetType) {
    TOPFileTargetTypeFolder, //文件夹 操作文档
    TOPFileTargetTypeDocument, //文档 操作图片
};

#pragma mark -- 菜单按钮
typedef NS_ENUM(NSUInteger, TOPMenuItemsFunction) {//代表了按钮的标识
    TOPMenuItemsFunctionShare = 0,    //分享
    TOPMenuItemsFunctionMerge,        //合并
    TOPMenuItemsFunctionCopyMove,     //拷贝/移动
    TOPMenuItemsFunctionDelete,       //删除
    TOPMenuItemsFunctionSaveToGallery,   //保存
    TOPMenuItemsFunctionPrint,        //打印
    TOPMenuItemsFunctionAddTo,        //添加
    TOPMenuItemsFunctionMore,         //更多
    TOPMenuItemsFunctionPushVC,       //跳转到childVC
    TOPMenuItemsFunctionRename,       //重命名
    TOPMenuItemsFunctionLeft,         //左旋
    TOPMenuItemsFunctionRight,        //右旋
    TOPMenuItemsFunctionCrop,         //裁剪
    TOPMenuItemsFunctionFilter,       //渲染
    TOPMenuItemsFunctionAddto,        //进入相机添加(入口在工具箱)
    TOPMenuItemsFunctionExtract,      //页面图片提取(入口在工具箱)
    TOPMenuItemsFunctionAdjustSave,   //页面调整的保存(入口在工具箱)
    TOPMenuItemsFunctionEmail,        //email
    TOPMenuItemsFunctionDoc,          //跳转到doc文档详情
    TOPMenuItemsFunctionFax,          //跳转到Fax
};

#pragma mark -- 文件选中

typedef NS_ENUM(NSUInteger, TOPItemsSelectedState) {
    TOPItemsSelectedNone = 0,//未选
    TOPItemsSelectedOneDoc = 1 << 0,//0001 选中一个文档
    TOPItemsSelectedSomeDoc = 1 << 1,//0010 选中多个文档 >=2
    TOPItemsSelectedOneFolder = 1 << 2,//0100 选中多一个文件夹
    TOPItemsSelectedSomeFolder = 1 << 3,//1000 选中多个文件夹 >=2
    TOPItemsSelectedOnePic = 1 << 4,//一张图片
    TOPItemsSelectedSomePic = 1 << 5,//多张图片>=2
};

#pragma mark -- 首页头部视图

typedef NS_ENUM(NSUInteger,TOPHomeHeaderFunction) {
    TOPHomeHeaderFunctionAddFolder = 0, //添加folder
    TOPHomeHeaderFunctionCameraPicture, //选中进入系统相册
    TOPHomeHeaderFunctionViewType,      //列表的样式
    TOPHomeHeaderFunctionSortBy,        //排序
    TOPHomeHeaderFunctionSelectState,   //进入选择状态
    TOPHomeHeaderFunctionMore,          //更多
    TOPHomeHeaderFunctionPop,           //返回
    TOPHomeHeaderFunctionDownDriveFile, //选择网盘文件下载

};
#pragma mark -- 首页更多
typedef NS_ENUM(NSUInteger,TOPHomeMoreFunction) {
    TOPHomeMoreFunctionSaveToGrallery = 100, //保存到Grallery文件夹
    TOPHomeMoreFunctionFolderLocation,     //folder的位置 顶部和底部
    TOPHomeMoreFunctionFax,                //传真
    TOPHomeMoreFunctionEmail,              //发邮件
    TOPHomeMoreFunctionEmailMySelef,       //给自己发邮件
    TOPHomeMoreFunctionviewby,             //排序
    TOPHomeMoreFunctionHidePage,           //图片详情是否隐藏
    TOPHomeMoreFunctionShareAppURL,        //分享app链接
    TOPHomeMoreFunctionSetTags,            //documents文件夹设置标签
    TOPHomeMoreFunctionSetLock,            //documents文件夹设置(修改)密码
    TOPHomeMoreFunctionUnLock,             //documents文件夹清除密码
    TOPHomeMoreFunctionSetLockFirst,       //documents文件夹第一次设置密码 此时保存本地的密码是没有的
    TOPHomeMoreFunctionPDFPassword,        //pdf加密
    TOPHomeMoreFunctionPDFChangeLock,      //pdf修改设置密码
    TOPHomeMoreFunctionEnterTagsManager,   //跳转到标签标签管理
    TOPHomeMoreFunctionDeleteAllPic,       //删除文档下所有图片
    TOPHomeMoreFunctionPrint,              //打印
    TOPHomeMoreFunctionManualSorting,      //手动拖拽排序
    TOPHomeMoreFunctionUserDefinedSize,    //自定义文件大小
    TOPHomeMoreFunctionImportFromGallery,  //从图库导入图片
    TOPHomeMoreFunctionDocTag,             //文档标签
    TOPHomeMoreFunctionPicCollage,         //拼图
    TOPHomeMoreFunctionFolderRename,       //folder文件夹重命名
    TOPHomeMoreFunctionDocRename,          //doc文档文件夹重命名
    TOPHomeMoreFunctionSearch,             //搜索
    TOPHomeMoreFunctionBatchEdit,          //批处理
    TOPHomeMoreFunctionPDF,                //pdf
    TOPHomeMoreFunctionBox,                //工具箱
    TOPHomeMoreFunctionToDrive,            //网盘更新
    TOPHomeMoreFunctionUpload,             //上传
    TOPHomeMoreFunctionOCR,                //ocr识别
    TOPHomeMoreFunctionDocRemaind,         //文档提醒
    TOPHomeMoreFunctionDownDriveFile,      //选择网盘文件下载
    TOPHomeMoreFunctionSortBy,        //排序
    TOPHomeMoreFunctionDataRefresh,        //自检刷新数据
    TOPHomeMoreFunctionTakePhoto,        //拍照
    TOPHomeMoreFunctionRecycleBin,           //回收站
    TOPHomeMoreFunctionPicDetail,           //图片详情
    TOPHomeMoreFunctionDocCollection,       //文档收藏
};

#pragma mark -- 首页更多展示类型 即不同的类型展示不同的功能组合
typedef NS_ENUM(NSUInteger,TOPHomeMoreFunctionType) {
    TOPHomeMoreFunctionTypeDefault = 0,      //不展示设置密码和设置标签的功能
    TOPHomeMoreFunctionTypeSetLock,          //展示设置密码和设置标签的功能
    TOPHomeMoreFunctionTypeDeleteLock,       //展示清除密码和设置标签的功能
    
    TOPHomeMoreFunctionTypeSomeDocUnLock,      //选中的都是doc文档 且数量多于一个(doc都有密码)
    TOPHomeMoreFunctionTypeOneDocUnLock,      //选中的都是doc文档 且数量只有一个(doc有密码)
    TOPHomeMoreFunctionTypeSomeDocSetLock,      //选中的都是doc文档 且数量多于一个(doc只要一个没有密码)
    TOPHomeMoreFunctionTypeOneDocSetLock,      //选中的都是doc文档 且数量只有一个(doc没有密码)
    
    TOPHomeMoreFunctionTypeFolderAndDoc,      //选中的有doc文档和folder类文件夹
    TOPHomeMoreFunctionTypeSomeFolder,      //选中的都是Folder文件夹 且数量多于一个
    TOPHomeMoreFunctionTypeOneFolder,      //选中的都是Folder文档 且数量只有一个
};


typedef NS_ENUM(NSUInteger,TOPPhotoReEditFilterFunction) {
    TOPPhotoReEditFilterBrightness = 1, //亮度调节
    TOPPhotoReEditFilterStaturation,    //饱和度调节
    TOPPhotoReEditFilterContrast,       //对比度调节
};

#pragma mark -- 相机功能入口
typedef NS_ENUM(NSUInteger, TOPEnterCameraType) {
    TOPShowFolderCameraType = 1, //TOPHomeViewController相机入口
    TOPShowNextFolderCameraType,//TOPNextFolderViewController相机入口
    TOPShowDocumentCameraType,//TOPHomeChildViewController相机入口
    TOPShowPhotoShowCameraType,//TOPPhotoShowViewController相机入口retake
    TOPShowPhotoShowReEditType, //TOPPhotoShowViewController进入裁剪界面的入口
    TOPShowToTextCameraType, //To text 拍照入口 入口在工具箱
    TOPShowIDCardCameraType, //Id card 拍照入口 入口在工具箱
    TOPShowSCamerBatchRetakeCameraType, //TOPCamerBatchViewController 拍照入口 retake
    TOPEnterCameraTypePDFSignature, //PDF签名拍照入口
    TOPEnterCameraTypeQRCode, //扫码 入口在工具箱
    TOPEnterHomeCameraTypeLibrary,//从首页的图库到批处理点击添加跳转到相机
    TOPEnterNextFolderCameraTypeLibrary,//从次级页面的图库到批处理点击添加跳转到相机
    TOPEnterDocumentCameraTypeLibrary,//从TOPHomeChildViewController页面的图库到批处理点击添加跳转到相机
};

#pragma mark -- 设置pdf纸张大小
typedef NS_ENUM(NSUInteger, TOPPDFPageSize) {
    TOPPDFPageSizeLetter = 1,  //Letter
    TOPPDFPageSizeA4,          //A4
    TOPPDFPageSizeLegal,       //Legal
    TOPPDFPageSizeA3,          //A3
    TOPPDFPageSizeA5,          //A5
    TOPPDFPageSizeBusiness,    //Business
    TOPPDFPageSizeB4,          //B4
    TOPPDFPageSizeB5,          //B5
    TOPPDFPageSizeTabloid,     //Tabloid
    TOPPDFPageSizeExecutive,   //Executive
    TOPPDFPageSizePostcard,    //Postcard
    TOPPDFPageSizeFlsa,        //Flsa
    TOPPDFPageSizeFlse,        //Flse
    TOPPDFPageSizeArch_A,      //Arch_A
    TOPPDFPageSizeArch_B,      //Arch_B

};
#pragma mark -- 设置拼图纸张大小
typedef NS_ENUM(NSUInteger, TOPCollagePageSizeType) {
    TOPCollagePageSizeTypeA3 = 1, //A3
    TOPCollagePageSizeTypeA4,     //A4
    TOPCollagePageSizeTypeA5,     //A5
    TOPCollagePageSizeTypeB4,     //B4
    TOPCollagePageSizeTypeB5,     //B5
};
 //渲染模式
typedef NS_ENUM(NSUInteger, TOPProcessType) {
    TOPProcessTypeOriginal = 1, //Original
    TOPProcessTypeBW,           //B&W
    TOPProcessTypeBW2,           //B&W2
    TOPProcessTypeGrayscale,    //Grayscale
    TOPProcessTypeMagicColor,   //MagicColor
    TOPProcessTypeNostalgic,    //Nostalgic
    TOPProcessTypeBW3,    //B&W3
    TOPProcessTypeMagicColor2,    //MagicColor2
    TOPProcessTypeLastFilter,   //LastFilter
};
//是否保存
typedef NS_ENUM(NSUInteger, TOPSettingSaveType) {
    TOPSettingSaveNO = 1,//不保存/不裁剪
    TOPSettingSaveYES,   //保存/裁剪
};

//TOPPhotoShowViewController的入口类型
typedef NS_ENUM(NSUInteger, TOPPhotoShowViewEnterType) {
    TOPHomeChildCellClickEnterType = 1,//点击HomeChildVC里的cell
    TOPHomeChildCellShowBackBtnType,   //点击HomeChildVC里cell上的ShowBackBtn按钮和textView的跳转
};

//TOPPhotoShowViewController的显示类型 是显示image 还是 text
typedef NS_ENUM(NSUInteger, TOPPhotoShowViewShowType) {
    TOPPhotoShowViewImageType = 1,//显示图片
    TOPPhotoShowViewTextType,     //显示text文本
    TOPPhotoShowViewTextAgain,    //再次编辑
    TOPPhotoShowViewTextOCR,      //ocr
};
typedef NS_ENUM(NSUInteger, TOPPhotoShowViewImageTopViewAction) {
    TOPPhotoShowViewImageTopViewActionBack = 1,      //返回
    TOPPhotoShowViewImageTopViewActionTailoring,     //裁剪
    TOPPhotoShowViewImageTopViewActionRotating,      //旋转
    TOPPhotoShowViewImageTopViewActionSignature,          //涂鸦
    TOPPhotoShowViewImageTopViewActionSelect,        //选择
    TOPPhotoShowViewImageTopViewActionRecogn,        //ocr识别
    TOPPhotoShowViewImageTopViewActionSaveText,      //保存
    TOPPhotoShowViewImageTopViewActionShareText,     //分享text
    TOPPhotoShowViewImageTopViewActionOCRText,
    TOPPhotoShowViewImageTopViewActionOCRLanguage,   //语言
    TOPPhotoShowViewImageTopViewActionOCRStart,      //开始识别
    TOPPhotoShowViewImageBottomViewActionShare ,     //分享图片
    TOPPhotoShowViewImageBottomViewActionEmail,          //email
    TOPPhotoShowViewImageBottomViewActionSaveGallery,    //保存文件夹
    TOPPhotoShowViewImageBottomViewActionPrint,          //打印
    TOPPhotoShowViewImageBottomViewActionMore,           //更多
    TOPPhotoShowViewImageBottomViewActionDelecte,        //删除
    TOPPhotoShowViewImageBottomViewActionEdit,           //编辑
    TOPPhotoShowViewImageBottomViewActionCopy,           //拷贝
    TOPPhotoShowViewImageBottomViewActionTranslation,    //翻译
    TOPPhotoShowViewImageBottomViewActionExport,         //导出
    TOPPhotoShowViewImageBottomViewActionNote,           //note
    TOPPhotoShowViewImageBottomViewActionRetake,          //重拍
    TOPPhotoShowViewImageBottomViewActionOcrRecognizer,    //ocr识别
    TOPPhotoShowViewImageBottomViewActionWatermark,       //添加水印
    TOPPhotoShowViewImageBottomViewActionUpload,       //单个图片上传网盘
    TOPPhotoShowViewImageBottomViewActionOcrNum,       //OCR识别余额
};

//TOPPhotoShowTextAgainVC的返回类型 用于判断返回的父试图
typedef NS_ENUM(NSUInteger, TOPPhotoShowTextAgainVCBackType) {
    TOPPhotoShowTextAgainVCBackTypePopVC = 1,   //返回父试图
    TOPPhotoShowTextAgainVCBackTypePopRoot,     //返回根试图
    TOPPhotoShowTextAgainVCBackTypePopChild,    //返回ChildVC
    TOPPhotoShowTextAgainVCBackTypePopFolder,   //返回TOPNextFolderViewController类的控制器
    TOPPhotoShowTextAgainVCBackTypePopReEdit,   //返回到TOPPhotoReEditVC类的控制器
    TOPPhotoShowTextAgainVCBackTypePopPhotoShow,//返回到TOPPhotoShowViewController类的控制器

    TOPPhotoShowTextAgainVCBackTypeDismiss,  //dismiss返回根试图
};

//TOPHomeChildViewController的返回类型 用于判断返回的父试图
typedef NS_ENUM(NSUInteger, TOPHomeChildViewControllerBackType) {
    TOPHomeChildViewControllerBackTypeDismiss = 1,  //dismiss返回根试图
    TOPHomeChildViewControllerBackTypePopVC,        //返回父试图
    TOPHomeChildViewControllerBackTypePopRoot,      //返回根试图
    TOPHomeChildViewControllerBackTypePopFolder,    //返回TOPNextFolderViewController类的控制器
    TOPHomeChildViewControllerBackTypePopCollList,   //返回到TOPFunctionColletionListVC类的控制器
};

//TOPPhotoShowOCRVC用于区分 识别过的图片再次识别时 如果识别的图片没有做过裁剪处理时 需不需要再次识别
typedef NS_ENUM(NSUInteger, TOPPhotoShowOCRVCAgainType) {
    TOPPhotoShowOCRVCAgainTypeOCRAgain = 1,   //已经识别过的图片没有裁剪时需要再次识别
    TOPPhotoShowOCRVCAgainTypeOCRNot,         //已经识别过的图片没有裁剪时不需要再次识别
};

typedef NS_ENUM(NSUInteger, TOPPhotoShowOCRVCAgainFinishType) {
    TOPPhotoShowOCRVCAgainFinishNot = 1,   //识别完成需要重开OCR详情界面
    TOPPhotoShowOCRVCAgainFinishAlready,   //识别完成直接返回详情界面
};

//提示框入口
typedef NS_ENUM(NSUInteger, TOPFormatterViewEnterType) {
    TOPFormatterViewEnterTypeSetting = 1,           //设置Document Name的入口
    TOPFormatterViewEnterTypeTextAgainLanguage,     //识别选择语言
    TOPFormatterViewEnterTypeTextAgainEndpoint,     //识别选择节点
    TOPFormatterViewEnterTypeTextAgainExport,       //导出的弹框
    TOPFormatterViewEnterTypeJPGQuality,            //图片质量800万-1400万像素
    TOPFormatterViewEnterTypeTextAgainShare,       //分享的弹框
    TOPFormatterViewEnterTypeDefaultProcess,       //渲染模式
    TOPFormatterViewEnterTypeDocTime,              //文档显示的时间格式
    TOPFormatterViewEnterTypeImgMore,              //图片展示界面的更多弹出试图

};

//TOPHomeShowView的展示样式
typedef NS_ENUM(NSUInteger, TOPHomeShowViewLocationType) {
    TOPHomeShowViewLocationTypeTopRight = 1,//首界面右上角的更多
    TOPHomeShowViewLocationTypeMiddle,      //ocr识别的识别类型弹框
    TOPHomeShowViewLocationTypeTopLeft,    //首界面右上角的标签列表
};

//TOPExportType的类型
typedef NS_ENUM(NSUInteger, TOPExportType) {
    TOPExportTypeTxt = 1,
    TOPExportTypeText,
    TOPExportTypeCopyToClipboard,
};

#pragma mark -- 涂鸦工具栏
typedef NS_ENUM(NSUInteger, TOPGraffitiToolType) {
    TOPGraffitiToolTypeText,//文字
    TOPGraffitiToolTypeBrush,   //画笔
    TOPGraffitiToolTypeEraser,   //橡皮擦
    TOPGraffitiToolTypeUndo,   //撤销
    TOPGraffitiToolTypeRedo,   //恢复
};

#pragma mark -- 拼图菜单栏
typedef NS_ENUM(NSUInteger, TOPCollageFunctionType) {
    TOPCollageFunctionTypeAddBlank=100,//空白页
    TOPCollageFunctionTypeWaterMark,   //水印
    TOPCollageFunctionTypePaperSize,   //纸张大小
    TOPCollageFunctionTypeTemplate,   //选择模板
};

#pragma mark -- 拼图模板
typedef NS_ENUM(NSUInteger, TOPCollageTemplateType) {
    TOPCollageTemplateTypeDriverLicense = 1,//驾驶证
    TOPCollageTemplateTypeIDCard,   //身份证
    TOPCollageTemplateTypePassport,   //护照
    TOPCollageTemplateTypeAccountBook,   //户口本
    TOPCollageTemplateTypeProofOfProperty,   //房产证
    TOPCollageTemplateTypeVerticalHalf,   //2*1
    TOPCollageTemplateTypeHorizontalHalf,   //1*2
};

#pragma mark -- 添加水印菜单栏
typedef NS_ENUM(NSUInteger, TOPWaterMarkFunctionType) {
    TOPWaterMarkFunctionTypeAdd,   //添加
    TOPWaterMarkFunctionTypeClear,   //清空
    TOPWaterMarkFunctionTypeShare,   //分享
};

#pragma mark --ocr识别的数据源 是来自同一个文件夹 还是多个文件夹
typedef NS_ENUM(NSUInteger, TOPOCRDataType) {
    TOPOCRDataTypeSingleDocument,  //数据来自同一个文件夹
    TOPOCRDataTypeMultipleDocument,//数据来自多个文件夹

};
#pragma mark --网盘
typedef NS_ENUM(NSInteger, TOPDownLoadDataStyle) {
    TOPDownLoadDataStyleDefaultGoogle = 0,//google
    TOPDownLoadDataStyleStyleOneDrice = 1, //oneDrive
    TOPDownLoadDataStyleStyleBox = 2, //box
    TOPDownLoadDataStyleStyleDropBox = 3 //DropBox
};


#pragma mark --网盘
typedef NS_ENUM(NSInteger, TOPUpLoadToDriveFileType) {
    TOPUpLoadToDriveFileTypePDF = 1,//PDF
    TOPUpLoadToDriveFileTypeJPG = 2, //JPG
    TOPUpLoadToDriveFileTypeJPG_PDF = 3 //JPG_PDF
};

#pragma mark --网盘下载到哪个目录下
typedef NS_ENUM(NSInteger, TOPDownloadFileToDriveAddPathType) {
    TOPDownloadFileToDriveAddPathTypeHome = 1,//下载到首页
    TOPDownloadFileToDriveAddPathTypeNextFolder = 2, //下载到文件夹下
    TOPDownloadFileToDriveAddPathTypeHomeChild = 3 //文档内添加
};

#pragma mark --ocr识别的数据源 是来自同一个文件夹 还是多个文件夹
typedef NS_ENUM(NSUInteger, TOPSettingVCAction) {
    TOPSettingVCActionJumpFax = 1,          //跳转到Fax
    TOPSettingVCActionGeneral,              //基本设置
    TOPSettingVCActionSupportShareApp,      //分享app
    TOPSettingVCActionSupportBackupRestore, //同步app数据到云盘
    TOPSettingVCActionSupportRateApp,       //app评分
    TOPSettingVCActionSupportPrivacy,       //Privacy
    TOPSettingVCActionSupportFAQ,           //FAQ
    TOPSettingVCActionSupportUserAgreement, //用户条款
    TOPSettingVCActionSupportUserSuggestion, //用户反馈
    TOPSettingVCActionSupportSendFeedBack,  //SendFeedBack
    TOPSettingVCActionSupportVersion,       //Version
    TOPSettingVCActionDocManagement,        //文档管理
    TOPSettingVCActionDocManagementName,     //文档名称
    TOPSettingVCActionDocManagementDate,     //文档时间
    TOPSettingVCActionDocManagementFileSize,  //文件大小
    TOPSettingVCActionDocManagementAutoSave,  //保存路径
    TOPSettingVCActionDocManagementSaveOriginalPic,  //保存源图
    TOPSettingVCActionDocManagementCropImgAutomatic, //是否开启图片自动裁剪
    TOPSettingVCActionSupportAppSafeSet,  //设置App密码

    TOPSettingVCActionGeneralPageSize,  //纸张大小 A4、A5
    TOPSettingVCActionGeneralDefaultProcess,  //默认渲染模式
    TOPSettingVCActionGeneralEmail,  //邮箱
    TOPSettingVCActionGeneralJPGQuality,  //图片质量
    TOPSettingVCActionSubscriptionMember,  //设置页面 订阅会员
    TOPSettingVCActionOCRAccount,  //通用 管理ocr页面
    TOPSettingVCActionRestoreSubscript,  //设置页面 恢复订阅
    TOPSettingVCBackgroundDarkStyle,  //app背景颜色
    TOPSettingVCBackgroundStstemStyle,  //背景根据系统颜色来定
    TOPSettingVCBackgroundNotStstemWhiteStyle,  //背景不根据系统颜色来定 自定义为白色
    TOPSettingVCBackgroundNotStstemDarkStyle,  //背景不根据系统颜色来定 自定义为白色
    TOPSettingVCActionSendDataToOthers, //传输数据到其他设备
    TOPSettingVCBackgroundScreenShotState,  //截屏时 截屏通知执行各种事件的判断状态
    TOPSettingVCCheckRecycleBin,  //进入回收站查看
    TOPSettingVCDeleteAlertSwitch,  //回收站文件删除提醒开关
    TOPSettingVCSaveBinFileTime,  //设置回收站文件保留时间
    TOPSettingActionGeneralMore,  //更多
};

#pragma mark --首页最顶部隐藏视图的点击事件
typedef NS_ENUM(NSInteger, TOPHomeVCTopHideViewState) {
    TOPHomeVCTopHideViewStateBackup = 0,//备份与还原
    TOPHomeVCTopHideViewStateImportPic = 1, //导入图片
    TOPHomeVCTopHideViewStateSyntheticPDF = 2, //合并PDF
    TOPHomeVCTopHideViewStateImportDoc = 3, //导入文档
    TOPHomeVCTopHideViewStateFunctionMore, //更多
};

#pragma mark -- PDF页码排版
typedef NS_ENUM(NSInteger, TOPPDFPageNumLayoutType) {
    TOPPDFPageNumLayoutTypeNull = 0,//无页码
    TOPPDFPageNumLayoutTypeTopLeft = 1, //上左
    TOPPDFPageNumLayoutTypeTopCenter = 2, //上中
    TOPPDFPageNumLayoutTypeTopRight = 3, //上右
    TOPPDFPageNumLayoutTypeBottomLeft = 4, //下左
    TOPPDFPageNumLayoutTypeBottomCenter = 5, //下中
    TOPPDFPageNumLayoutTypeBottomRight = 6, //下右
};

#pragma mark -- PDF纸张朝向
typedef NS_ENUM(NSInteger, TOPPDFPageDirectionType) {
    TOPPDFPageDirectionTypeAutoSize = 0,//自适应
    TOPPDFPageDirectionTypeLandscape = 1, //横向
    TOPPDFPageDirectionTypePortrait = 2, //纵向
};

#pragma mark -- PDF菜单栏
typedef NS_ENUM(NSUInteger, TOPEditPDFFunctionType) {
    TOPEditPDFFunctionTypeMore,         //更多
    TOPEditPDFFunctionTypeWaterMark,   //水印
    TOPEditPDFFunctionTypePaperSize,   //纸张大小
    TOPEditPDFFunctionTypePassword,   //密码
    TOPEditPDFFunctionTypeCompress,   //压缩
    TOPEditPDFFunctionTypeSignature,   //签名
};

#pragma mark -- PDF更多功能选项
typedef NS_ENUM(NSUInteger, TOPEditPDFMoreMenu) {
    TOPEditPDFMoreMenuFax,         //传真
    TOPEditPDFMoreMenuPrint,   //打印
    TOPEditPDFMoreMenuPassword,   //密码
};

#pragma mark -- PDF签名方式选项
typedef NS_ENUM(NSUInteger, TOPSignaturePDFMoreMenu) {
    TOPSignaturePDFMoreMenuScan,     //扫描
    TOPSignaturePDFMoreMenuAlbum,   //导入
    TOPSignaturePDFMoreWrite,      //手写
};

#pragma mark -- app密码
typedef NS_ENUM(NSInteger, TOPAppSetSafePasswordState) {
    TOPAppSetSafePasswordStateFirstSetSafe = 0,//第一次进入设置密码
    TOPAppSetSafePasswordStateEnterSafe = 1, //确认密码
    TOPAppSetSafePasswordStateChangePwd = 2,//已经有密码修改密码
    TOPAppSetSafePasswordStateSafeInLocalInput = 3, //密码设置完成后后续解锁密码模式
    TOPAppSetSafePasswordStateClosePwd = 4,//已经有密码关闭密码
    TOPAppSetSafePasswordStateRestartPwd = 5,//已经有密码重启密码
    TOPAppSetSafePasswordStateChangeTouchIdType = 6,//启用指纹模式验证
    TOPAppSetSafePasswordStateChangeFaceIdType = 7//启用刷脸模式验证
};

#pragma mark -- app密码
typedef NS_ENUM(NSInteger, TOPAppSetTouchAFaceState) {
    TOPAppSetTouchAFaceStateOpen = 0,//开启
    TOPAppSetTouchAFaceStateClose = 1, //关闭
    TOPAppSetTouchAFaceStateLocalInput = 2,//验证密码
    TOPAppSetTouchAFaceStateChangePassWord = 3,//切换数字密码
    TOPAppSetTouchAFaceStateChangeCreatNewPassWord = 4//切换数字密码数组密码不存在新建


};
//解锁模式
typedef NS_ENUM(NSInteger, TOPAppSetSafeUnlockType) {
    TOPAppSetSafeUnlockTypePwd = 0,//密码解锁
    TOPAppSetSafeUnlockTypeTouchID = 1, //指纹解锁
    TOPAppSetSafeUnlockTypeFaceID = 2,//面容解锁
};

typedef NS_ENUM(NSInteger, TOPLAContextSupportType) {
    TOPLAContextSupportTypeNone,              // 不支持指纹或者faceID
    TOPLAContextSupportTypeTouchID,           // 指纹识别
    TOPLAContextSupportTypeFaceID,            // faceid
    TOPLAContextSupportTypeTouchIDNotEnrolled,      // 支持指纹没有设置指纹
    TOPLAContextSupportTypeFaceIDNotEnrolled        // 支持faceid没有设置faceid
};

#pragma mark --Batch Edit 批量处理的类型
typedef NS_ENUM(NSInteger, TOPBatchEditActionType) {
    TOPBatchEditActionTypeImageOrientationOriginal=1,        //默认状态
    TOPBatchEditActionTypeImageOrientationLeft,            //左转
    TOPBatchEditActionTypeImageOrientationRight,           //右转
    TOPBatchEditActionTypeImageOrientationFilter,          //渲染
    TOPBatchEditActionTypeImageAll,                        //裁剪框是图片大小
    TOPBatchEditActionTypeImageAuto,                       //裁剪框自动识别
    TOPBatchEditActionTypeImageFinish,                     //处理完毕

};

#pragma mark --拍照时多张图片处理界 面底部试图的事件类型
typedef NS_ENUM(NSInteger, TOPScamerBatchBottomViewFunction) {
    TOPScamerBatchBottomViewFunctionRetake=1,        //重新拍照
    TOPScamerBatchBottomViewFunctionRota,            //旋转
    TOPScamerBatchBottomViewFunctionCrop,            //批量裁剪
    TOPScamerBatchBottomViewFunctionFilter,          //渲染
    TOPScamerBatchBottomViewFunctionFinish,          //操作完成
    TOPScamerBatchBottomViewFunctionWatermark,       //水印
    TOPScamerBatchBottomViewFunctionEdit,            //编辑
};

#pragma mark --拍照类型
typedef NS_ENUM(NSInteger, TOPScameraType) {
    TOPScameraTypeOriginal,        //正常拍照
    TOPScameraTypeRetake,          //没有数据模型的重新拍照
};

#pragma mark --拍照类型
typedef NS_ENUM(NSInteger, TOPScameraTakeMode) {
    TOPScameraTakeModeOCR,        //OCR
    TOPScameraTakeModeIDCard,     //证件照
    TOPScameraTakeModeSingle,        //单拍
    TOPScameraTakeModeBatch,     //多拍
    TOPScameraTakeModeCodeReader, //二维码
};

#pragma mark --批量裁剪的入口
typedef NS_ENUM(NSInteger, TOPBatchCropType) {
    TOPBatchCropTypeCamera,        //从相机
    TOPBatchCropTypeChildBatchVC,  //从TOPHomeChildBatchViewController和从相机的ID Card进入
};


#pragma mark --设置界面的cell类型 用于设置cell时区分用哪种cell
typedef NS_ENUM(NSInteger, TOPSettingCellType) {
    TOPSettingCellTypeFirstKind = 1,
    TOPSettingCellTypeSecondKind,
    TOPSettingCellTypeThirdKind,

};
#pragma mark -- 功能集合(工具箱)的功能类别
typedef NS_ENUM(NSInteger, TopFunctionType) {
    TopFunctionTypePDFToLongPicture = 1,//pdf转长图
    TopFunctionTypePDFToImage,          //pdf转图片
    TopFunctionTypePDFPassword,         //pdf密码
    TopFunctionTypeDocPassword,         //doc文档密码
    TopFunctionTypeImportImage,         //云盘导入图片
    TopFunctionTypeBackup,              //第三方网盘
    TopFunctionTypeImportFile,          //导入文档 导入pdf并拆分成图片
    TopFunctionTypeScanIDCard,          //ID Card
    TopFunctionTypeBatchEdit,           //批处理
    TopFunctionTypeMergePDF,            //合并pdf
    TopFunctionTypePDFAddWatermark,     //pdf水印
    TopFunctionTypeSetTags,             //文档添加标签
    TopFunctionTypePDFSignature,        //pdf签名
    TopFunctionTypePDFExtract,          //文档提取
    TopFunctionTypeOCR,                 //OCR
    TopFunctionTypeImageToPDF,          //进入相册选择图片
    TopFunctionTypePDFPageAdjustment,   //ChildVC页面调整
    TopFunctionTypeQRBarCode,           //二维码扫描
    TopFunctionTypeDriveDownloadFile,   //网盘下载
    TopFunctionTypeRecycelBin,          //回收站
    TopFunctionTypeDocCollection,       //文档收藏
};

#pragma mark --相机界面二维码 条形码扫描结果的处理
typedef NS_ENUM(NSInteger, TOPCameraCodeResultActionType) {
    TOPCameraCodeResultActionTypeShare = 1, //分享
    TOPCameraCodeResultActionTypeCopy,      //复制 粘贴到剪贴板
    TOPCameraCodeResultActionTypeDelete,    //删除试图
    TOPCameraCodeResultActionTypeOpenURL,   //跳转到链接

};

#pragma mark --弹框的弹出类型（分享，排序）
typedef NS_ENUM(NSInteger, TOPPopUpBounceViewType) {
    TOPPopUpBounceViewTypeShare = 1, //分享
    TOPPopUpBounceViewTypeSort,      //排序
    TOPPopUpBounceViewTypeTagSort,   //标签排序
    TOPPopUpBounceViewTypeViewType,  //视图展示的样式
};
#pragma mark --相机界面闪光灯的开启状态
typedef NS_ENUM(NSInteger, TOPCameraFlashType) {
    TOPCameraFlashTypeAuto = 1, //自动
    TOPCameraFlashTypeOn,       //开启
    TOPCameraFlashTypeOff,      //关闭
    TOPCameraFlashTypeTroch,    //火炬（一直开启）
};

typedef NS_ENUM(NSInteger, TOPCollectionConstantType) {//TOPPhotoShowTextAgainVC里用到
    TOPCollectionConstantTypeAuto = 1, //collectionView高度自动适配
    TOPCollectionConstantTypeSpe,    //collectionView高度是定值
};

typedef NS_ENUM(NSInteger, TOPEnterShowOCRVCType) {//进入TOPPhotoShowOCRVC界面的入口类型
    TOPEnterShowOCRVCTypeCamera = 1, //从相机进入
    TOPEnterShowOCRVCTypeOther,    //其他入口
};

typedef NS_ENUM(NSInteger, TOPCropBtnState) {//裁剪按钮三种状态
    TOPCropBtnStateAuto = 1, //自动
    TOPCropBtnStateFull,    //撑满
    TOPCropBtnStateFit,    //手动
};

typedef NS_ENUM(NSInteger, TOPPermissionType) {//功能权限 -- vip到期后：图片质量还原为普通，密码清除、PDF页码还原
    TOPPermissionTypeAdvertising = 1,      //广告
    TOPPermissionTypeOCROnline,    //ocr云识别
    TOPPermissionTypeCollageSave,      //拼图-保存
    TOPPermissionTypePDFWaterMark,     //PDF-水印
    TOPPermissionTypePDFSignature,     //PDF-签名
    TOPPermissionTypePDFPageNO,        //PDF-页码
    TOPPermissionTypePDFPassword,      //PDF-加密
    TOPPermissionTypeEmailMySelf,      //Doc-EmailMySelf
    TOPPermissionTypeImageSign,        //Image-签名(保存)
    TOPPermissionTypeImageGraffiti,    //Image-涂鸦(保存)
    TOPPermissionTypeImageHigh,        //Image-高清
    TOPPermissionTypeImageSuperHigh,   //Image-超清
    TOPPermissionTypeCreateFolder,     //创建文件夹
    TOPPermissionTypeUploadFile,       //上传文件
};
    
typedef NS_ENUM(NSInteger, TOPShareFileType) {//分享文件的类型
    TOPShareFilePDF = 0, //pdf
    TOPShareFileJPG,    //jpg
    TOPShareFileLongJPG,    //long image
    TOPShareFileTxt,    //txt
};
    
typedef NS_ENUM(NSInteger, TOPLoginSuccessfulJumpType) {//登录成功后跳转到哪个页面
    TOPLoginSuccessfulJumpTypeClose = 0, //默认直接关闭
    TOPLoginSuccessfulJumpTypePurchase,    //登录或注册完成跳转到充值页面
    TOPLoginSuccessfulJumpTypeSubscript,    //登录完成后跳转订阅页面
    TOPLoginSuccessfulJumpTypeSubscriptDetail,    //登录完成后跳转订阅详情页面
    TOPLoginSuccessfulJumpTypePopToGeneral , //登陆注册完成返回到OCR账户管理页面
};

typedef NS_ENUM(NSInteger, TOPSubscriptOverCloseType) {//订阅完成后关闭页面的方式
    TOPSubscriptOverCloseTypePop = 0, //默认pop到上个页面
    TOPSubscriptOverCloseTypeDissmiss,    //模态关闭
    TOPSubscriptOverCloseTypeOCRSub,    //OCR识别页进入
    TOPSubscriptOverCloseTypePopToSetting,    //返回到设置页面
    TOPSubscriptOverCloseTypeLoginSuccess,    //从登陆成功页面进入 关闭
};

typedef NS_ENUM(NSInteger, TOPAppInterfaceID) {//界面的id 用于插页广告的显示判断
    TOPAppInterfaceIDChild = 1,  //TOPHomeChildViewController
    TOPAppInterfaceIDNextFolder, //TOPNextFolderViewController
    TOPAppInterfaceIDShowView,   //TOPPhotoShowViewController
    TOPAppInterfaceIDEditPDF,    //TOPEditPDFViewController
};

typedef NS_ENUM(NSInteger, TOPSubscribeEvent) {//界面的id 用于插页广告的显示判断
    TOPSubscribeEventPay = 1,       //订阅购买
    TOPSubscribeEventLimitVersion,  //
    TOPSubscribeEventRestore,       //恢复订阅
};
typedef NS_ENUM(NSInteger, TOPDriveOpenStyleType) {//网盘的操作类型
    TOPDriveOpenStyleTypeUpload = 0,  //上传
    TOPDriveOpenStyleTypeDownFile, //下载

};

typedef NS_ENUM(NSInteger, TOPDeviceShotFinction) {//网盘的操作类型
    TOPDeviceShotFinctionSaveDoc = 0,  //保存文档
    TOPDeviceShotFinctionOCR,          //OCR文本识别
    TOPDeviceShotFinctionQuestion,     //意见与反馈
    TOPDeviceShotFinctionShare,        //分享
    TOPDeviceShotFinctionCancel,       //取消
    TOPDeviceShotFinctionSetting,      //跳转到设置
};


typedef NS_ENUM(NSUInteger,TOPBinMoreFunction) {
    TOPBinMoreFunctionDeleteAll = 1, //删除全部
    TOPBinMoreFunctionSetting,    //设置
};

typedef NS_ENUM(NSUInteger,TOPCustomCellType) {
    TOPCustomCellTypeSingleSwitch = 1, //右边单switch
    TOPCustomCellTypeSingleText,    //右边单文本
};
typedef NS_ENUM(NSUInteger,TOPChildVCListType) {
    TOPChildVCListTypeFirst = 1, //一行只有一个cell
    TOPChildVCListTypeSecond,    //一行有两个cell
    TOPChildVCListTypeThird      //一行有三个cell
};
typedef NS_ENUM(NSUInteger,TOPPhotoReEditFinishFunctionType) {
    TOPPhotoReEditFinishFunctionTypeCamera = 1,
    TOPPhotoReEditFinishFunctionTypeImport,
    TOPPhotoReEditFinishFunctionTypePDF,
    TOPPhotoReEditFinishFunctionTypeEmail,
    TOPPhotoReEditFinishFunctionTypeShare,
    TOPPhotoReEditFinishFunctionTypeMore,
    TOPPhotoReEditFinishFunctionTypeDocDetail,
};
typedef NS_ENUM(NSUInteger,TopFileNameEditType) {
    TopFileNameEditTypeChangeFolderName = 1,//更改folder名称
    TopFileNameEditTypeAddFolder,           //新建folder
    TopFileNameEditTypeChangeDocName,       //更改doc名称
    TopFileNameEditTypeAddDoc,              //新建doc，操作图片
};
typedef NS_ENUM(NSUInteger,TopReEditFinishBottomFunctionType) {
    TopReEditFinishBottomFunctionTypeRotate = 1,       //旋转
    TopReEditFinishBottomFunctionTypeAddtext,          //addtext
    TopReEditFinishBottomFunctionTypeSignature,        //signature
    TopReEditFinishBottomFunctionTypeGraffiti,         //graffiti
    TopReEditFinishBottomFunctionTypeFinish,           //finish
};
#endif /* TOPEnumHeader_h */
