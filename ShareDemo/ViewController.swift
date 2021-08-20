//
//  ViewController.swift
//  ShareDemo
//
//  Created by Mac on 2021/8/20.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func shareAction(_ sender: Any) {
        let controller = UIActivityViewController(activityItems: [UIImage(named: "logo")], applicationActivities: nil)
        showDetailViewController(controller, sender: nil)
    }
    
    @IBAction func shareImage(_ sender: Any) {
        let controller = UIActivityViewController(activityItems: [URL(string: "https://www.baidu.com/"), UIImage(named: "logo"), "系统分享"], applicationActivities: nil)
        showDetailViewController(controller, sender: nil)
    }
    
    @IBAction func shareURL(_ sender: Any) {
        let controller = UIActivityViewController(activityItems: [URL(string: "https://www.baidu.com/")], applicationActivities: nil)
    }
    
    @IBAction func shareCustomItem(_ sender: Any) {
        let pro = ItemProvider(placeholderItem: UIImage(named: "logo")!)
        let controller = UIActivityViewController(activityItems: [pro], applicationActivities: nil)
        showDetailViewController(controller, sender: nil)
    }
    
    @IBAction func shareCustomActivity(_ sender: Any) {
        let activity = ShareCustomActivity(parentVC: self, shareURL: URL(string: "https://www.baidu.com/"))
        let controller = UIActivityViewController(activityItems: [URL(string: "https://www.baidu.com/"), UIImage(named: "logo"), "系统分享"], applicationActivities: [activity])
        controller.excludedActivityTypes = [
            .addToReadingList,
            .message,
            .mail,
            .openInIBooks,
            .postToTwitter,
            .postToTencentWeibo,
            .postToFacebook,
            .airDrop
        ]
        
        controller.completionWithItemsHandler = { type, completion, arr, err in
            print("type:\(type?.rawValue ?? ""), \(completion), \(arr), \(err)")
            if type?.rawValue == "com.apple.UIKit.activity.SaveToCameraRoll" {
                if completion {
                    print("保存成功")
                }
            }
        }
        
        showDetailViewController(controller, sender: nil)
    }
}

extension UIActivity.ActivityType {
    
    static let mobilenotesSharingExtension = UIActivity.ActivityType("com.apple.mobilenotes.SharingExtension")
    static let remindersRemindersEditorExtension = UIActivity.ActivityType("com.apple.reminders.RemindersEditorExtension")
    static let BaiduMobileShareExtension = UIActivity.ActivityType("com.baidu.BaiduMobile.ShareExtension")

    static let weChat = UIActivity.ActivityType("com.tencent.xin.sharetimeline")
}

class ItemProvider: UIActivityItemProvider {
    
    override var item: Any {
        UIImage(named: "logo")!
    }
}

class ShareCustomActivity: UIActivity {
    
    var parentVC: UIViewController
    var shareURL: URL?
    
    init(parentVC: UIViewController, shareURL: URL? = nil) {
        self.parentVC = parentVC
        self.shareURL = shareURL
    }
    
    override var activityImage: UIImage? {
        UIImage(named: "logo")
    }
    
    override var activityTitle: String? {
        "自定义分享"
    }
    
    override class var activityCategory: UIActivity.Category {
        .share
    }
    
    override var activityType: UIActivity.ActivityType? {
        .init("com.share.chuck.activityType")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        true
    }
    
    override func perform() {
        self.parentVC.performSegue(withIdentifier: "web", sender: nil)
    }
}


