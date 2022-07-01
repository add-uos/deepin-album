import QtQuick 2.11
import QtQuick.Controls 2.4

Item {

    property var imgPaths
    property var imgCurrentPath
    property int imgCurrentIndex: 0
    property int minHeight: 300
    property int minWidth: 628
    property int albumMinHeight: 300
    property int albumMinWidth: 628

    property int minHideHeight: 428
    property int floatMargin: 60
    property int titleHeight: 50
    property int showBottomY: 80
    property int actionMargin: 9//应用图标距离顶栏

    property int thumbnailViewTitleHieght: 85 // 缩略图视图区域标题显示区域高度
    property int verticalScrollBarWidth: 15 // 垂直滚动条宽度

    property int rightMenuItemHeight: 32//右键菜单item的高度
    property int rightMenuSeparatorHeight: 12//右键菜单分割层的高度
    property bool ctrlPressed: false//记录ctrl键是否按下
    property var selectedPaths: [] // 已选路径
    property bool bRefreshFavoriteIconFlag: false //刷新收藏图标标记，翻转一次，图标就刷新一次
    property bool bRefreshRangeBtnState: false //刷新显示比例图标激活状态标记，翻转一次，图标就刷新一次
    property int currentViewIndex: 0// 0:导入图片视图 1:无图片视图 2:合集视图 3:已导入视图 4:我的收藏视图 5:最近删除视图 6:系统/自定义相册视图 7:搜索结果视图 8:设备视图
    property int currentCustomAlbumUId: 0// 当前自定义相册所在UId，0:我的收藏 1:截图录屏 2:相机 3:画板 其他:自定义相册
    property int stackControlCurrent: 0// 0:相册界面 1:看图界面 2:幻灯片
    property int stackControlLastCurrent: -1 //记录上一次显示的主界面索引 0:相册界面 1:看图界面 2:幻灯片

    property int thumbnailSizeLevel: 0 //缩略图缩放等级
    property string statusBarNumText: "" //状态栏显示的总数文本内容
    property string searchEditText: ""

    property bool albumChangeList: false //自定义相册改变
    property ButtonGroup siderGroup: ButtonGroup {} //控制导航栏的group

    property bool deviceChangeList: false //设备相册改变
    property int deviceCurrentIndex: 0 //设备index
    property string deviceCurrentName: albumControl.getDeviceName(deviceCurrentPath) //设备当前名称
    property string deviceCurrentPath: "" //设备当前P
    property bool windowDisActived: false

    property bool haveCreateAlbum: false //未知原因导致global.siderGroup.buttons内部index混乱，先这样规避

    function objIsEmpty(obj) {
        var ret = (String(obj) === "undefined" || String(obj) === "null")
        //console.log("obj is", ret ? "empty." : "not empty.", "objStr:", String(obj))
        return ret
    }

    signal sigWindowStateChange()
    signal sigThumbnailStateChange()
    signal sigRunSearch(int UID, string keywords) //执行搜索
    signal sigFlushAllCollectionView()   // 刷新合集所有项目视图内容
    signal sigFlushHaveImportedView()   // 刷新已导入视图内容
    signal sigFlushRecentDelView()      // 刷新最近删除视图内容
    signal sigFlushCustomAlbumView(int customAlbumUId)    //刷新我的收藏/自定义相册视图内容 customAlbumUId: >= 0 刷新指定视图，-1: 默认刷新所有视图
    signal sigCollectionViewIndexChanged(int index) //合集页面发生改变
    signal sigFlushSearchView() // 刷新搜索结果视图内容
    signal sigThumbnailSizeLevelChanged()

    Component.onCompleted: {
        currentViewIndex = GlobalVar.ThumbnailViewType.Collecttion
    }

    enum ThumbnailViewType {
        Import = 0,            // 导入图片视图
        NoPicture,             // 无图片视图
        Collecttion,           // 合集视图
        HaveImported,          // 已导入视图
        Favorite,              // 我的收藏视图
        RecentlyDeleted,       // 最近删除视图
        CustomAlbum,           // 系统/自定义相册视图
        SearchResult,          // 搜索结果视图
        Device                 // 设备视图
    }

    //缩略图类型枚举
    enum ThumbnailType {
        Normal,       //普通模式
        Trash,        //最近删除
        CustomAlbum,  //自定义相册
        AutoImport,   //自动导入路径
        AllCollection //合集模式
    }

    // 框选超出边界朝向类型
    enum RectScrollDirType {
        NoType,   // 框选没有朝向
        ToTop,    // 框选超出边界朝上
        ToBottom  // 框选超出边界朝下
    }

    //刷新自定义相册
    Connections {
        target: albumControl
        onSigRefreshCustomAlbum: {
           sigFlushCustomAlbumView(UID)
        }
    }

    //数据库监听-刷新合集所有项目
    Connections {
        target: albumControl
        onSigRefreshAllCollection: {
            sigFlushAllCollectionView()
        }
    }

    //数据库监听-刷新已导入
    Connections {
        target: albumControl
        onSigRefreshImportAlbum: {
            sigFlushHaveImportedView()
            bRefreshRangeBtnState = !bRefreshRangeBtnState
        }
    }

    //数据库监听-刷新搜索结果
    Connections {
        target: albumControl
        onSigRefreshSearchView: {
            if (global.currentViewIndex === GlobalVar.ThumbnailViewType.SearchResult)
                sigFlushSearchView()
        }
    }

    //左侧菜单栏刷新
    Connections {
        target: albumControl
        onSigRefreshSlider: {
            albumChangeList = !albumChangeList
        }
    }

    onCurrentViewIndexChanged: {
        console.log("currentViewIndex   :", currentViewIndex)
        if(albumControl.getAllCount() <= 0) {
            switch (currentViewIndex) {
                case GlobalVar.ThumbnailViewType.Import:
                case GlobalVar.ThumbnailViewType.NoPicture:
                    break
                case GlobalVar.ThumbnailViewType.Collecttion:
                    currentViewIndex = GlobalVar.ThumbnailViewType.Import
                    break
                case GlobalVar.ThumbnailViewType.SearchResult:
                    currentViewIndex = GlobalVar.ThumbnailViewType.NoPicture
                    break
            }
        }
    }

    onThumbnailSizeLevelChanged: {
        sigThumbnailSizeLevelChanged()
    }
}
