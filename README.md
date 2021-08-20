# ShareDemo

# UIActivityViewController 原生分享的使用


## 1. 简单调用

```Swift 
let controller = UIActivityViewController(activityItems: [UIImage(named: "logo")], applicationActivities: nil)
showDetailViewController(controller, sender: nil)
```

- 本质是一个controller，当然直接初始化就可以直接使用
- `activityItems` 的类型是一个Any对象，只要能分享的基本都是可以的常用的（URL、Image、File、String、等都是可以的）
- `applicationActivities` 自定义分享按钮（action、share）是下图所显示的两种样式

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5edf7232ca8e4268b4d211a31f1a13b1~tplv-k3u1fbpfcp-watermark.image)


## 2. 扩展分享

```Swift
let items = [UIImage(named: "logo")!, URL(string: "https://www.baidu.com/")!, "分享一个链接🔗"] as [Any]
let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)

showDetailViewController(controller, sender: nil)
```

- 这里分享出来的就是一个URL+Image+文字，理论其实只用写一个URL就可以的
- 这里是分享有一个优先级的URL > Iamge > 文本

### 自定义分享的activity，需要继承UIActivity

```Swift
class ShareCustomActivity: UIActivity {

    // 自定义属性
    var parentVC: UIViewController
    var shareURL: URL?

    init(parentVC: UIViewController, shareURL: URL? = nil) {
        self.parentVC = parentVC
        self.shareURL = shareURL
    }
    
    // 类型和上面说的action、share
    override class var activityCategory: UIActivity.Category {
        .action
    }

    // 展示这分享面板上的icon、一般是share 60 * 60、action 16 * 16 就够了
    override var activityImage: UIImage? {
        UIImage(named: "icon_43")
    }
    
    // 分享面板上展示的文字
    override var activityTitle: String? {
        "生成海报图"
    }

    // 自定义类型
    override var activityType: UIActivity.ActivityType? {
        .init("com.shared.Photo")
    }

    // 后面就是设置跳转，已经实现
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        true
    }

    override func perform() {
        let web = WebViewController()
        web.urlString = shareURL
        parentVC.show(web, sender: nil)
    }
}
```

### 调用直接添加自定义的activity就可以了，是一个数组可以放多个

```Swift 
let customActivity = ShareCustomActivity(parentVC: self, shareURL: URL(string: "https://www.baidu.com/"))
let items = [UIImage(named: "logo")!, URL(string: "https://www.baidu.com/")!, "分享一个链接🔗"] as [Any]
let controller = UIActivityViewController(activityItems: items, applicationActivities: [customActivity])
showDetailViewController(controller, sender: nil)
```

## 3. 自定义分享内容 UIActivityItemProvider

- `UIActivityItemProvider` 父类是一个`Operation` 对列 
- `UIActivityItemProvider` 默认实现 `UIActivityItemSource`协议
- `UIActivityItemSource` 主要用于修改数据源等,`类似与tableView的dataSource` 如果你设置分享的是一个URL 、可以设置小图， title等，就想不用这个对象直接封装一个数组, 系统会自动识别解析的

```Swift 
class ShareItemProvider :UIActivityItemProvider {
    override var item: Any {
        UIImage(named: "logo")!
    }
}

override func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
    return UIImage(named: "thumbnailImage")
}
```
- 最主要的就是实现item，代表的是分享的内容，大多数情况下一个item就够用了，如果需要详细设置，请参考 `UIActivityItemProvider` 、 `UIActivityItemSource`

## 4. `UIActivity.ActivityType` 
- 分享文本的类型，每一个分享的app、action有且仅有一个
- ActivityType 是一个结构体，我们可以自己去扩展

```Swift 
extension UIActivity.ActivityType {

    @available(iOS 6.0, *)
    public static let postToFacebook: UIActivity.ActivityType

    @available(iOS 6.0, *)
    public static let postToTwitter: UIActivity.ActivityType

    @available(iOS 6.0, *)
    public static let postToWeibo: UIActivity.ActivityType

    @available(iOS 6.0, *)
    public static let message: UIActivity.ActivityType

    @available(iOS 6.0, *)
    public static let mail: UIActivity.ActivityType

    @available(iOS 6.0, *)
    public static let print: UIActivity.ActivityType

    @available(iOS 6.0, *)
    public static let copyToPasteboard: UIActivity.ActivityType

    @available(iOS 6.0, *)
    public static let assignToContact: UIActivity.ActivityType

    @available(iOS 6.0, *)
    public static let saveToCameraRoll: UIActivity.ActivityType

    @available(iOS 7.0, *)
    public static let addToReadingList: UIActivity.ActivityType

    @available(iOS 7.0, *)
    public static let postToFlickr: UIActivity.ActivityType

    @available(iOS 7.0, *)
    public static let postToVimeo: UIActivity.ActivityType

    @available(iOS 7.0, *)
    public static let postToTencentWeibo: UIActivity.ActivityType

    @available(iOS 7.0, *)
    public static let airDrop: UIActivity.ActivityType

    @available(iOS 9.0, *)
    public static let openInIBooks: UIActivity.ActivityType

    @available(iOS 11.0, *)
    public static let markupAsPDF: UIActivity.ActivityType
}
```


- 这前面的版本更新中，apple内置了一些，类似于腾讯微博、新浪微博、Facebook、Twitter等app的跳转
```Swift
// 自定义的activityType
extension UIActivity.ActivityType {

    static let mobilenotesSharingExtension = UIActivity.ActivityType("com.apple.mobilenotes.SharingExtension")
    static let remindersRemindersEditorExtension = UIActivity.ActivityType("com.apple.reminders.RemindersEditorExtension")
    static let BaiduMobileShareExtension = UIActivity.ActivityType("com.baidu.BaiduMobile.ShareExtension")
    static let weChat = UIActivity.ActivityType("com.tencent.xin.sharetimeline")

}
```
- 由于没有找到很好的办法去获取这个type，我这边是根据点击事件的回调去实现的

```Swift
// 分享成功回调 参数1. activityType、completion、[Any]、error
controller.completionWithItemsHandler = { type, completion, arr, err in

    print("type:\(type?.rawValue ?? ""), \(completion), \(arr), \(err)")
    
    // 保存图片到本地
    if type?.rawValue == "com.apple.UIKit.activity.SaveToCameraRoll" {
        if completion {
                print("保存图片成功"）
        }
    }
}
```

```Swift 
// 自己设置忽略一些不想要分享或者点击的action，当然如果系统没用的话，就像上面的方法自定义就ok了
controller.excludedActivityTypes = [

    .addToReadingList,

    .addToiCloudDrive,

    .message,

    .mail,

    .openInIBooks,

    .postToTwitter,

    .postToLinkedIn,

    .postToWhatsApp,

    .postToTencentWeibo,

    .postToFacebook,

    .mobilenotesSharingExtension,

    .BaiduMobileShareExtension,

    .remindersRemindersEditorExtension,

    .airDrop

]
```

以上就是今天的内容，对原生分享还有什么想讨论的可以这下面留言哦～ 
