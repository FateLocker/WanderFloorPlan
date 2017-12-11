//
//  ViewController.swift
//  WanderFloorPlan
//
//  Created by Hu on 2017/11/6.
//  Copyright © 2017年 IDEAMAKE. All rights reserved.
//

import Cocoa
import WebKit
import GCDWebServer

protocol ViewControllerDelegate {
    
    func removeSelf()
}


class ViewController: NSViewController,WebFrameLoadDelegate,NSApplicationDelegate{
    
    var delegate:ViewControllerDelegate?
    
    @IBOutlet weak var customView: NSView!
    
    @IBOutlet weak var textField: NSTextField!
    
    @IBOutlet weak var serverAddress: NSTextField!
    
    @IBOutlet weak var floorPlanImgView: MouseEventImageView!
    
    @IBOutlet weak var rightCustomView: NSView!
    
    @IBOutlet weak var spaceName: NSTextField!
    
    @IBOutlet weak var backView: NSView!
    
    @IBOutlet weak var sizeTextField: NSTextField!
    
    var webView = WKWebView()

    var navigationImageView = MouseEventImageView()
    
    var dic:Dictionary<String,MouseEventImageView> = [:]
    
    let webServer = GCDWebServer()
    
    lazy var dotArr:[DotImgaeView] = {
    
        return []
    }()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initFloorPlanImageView()
        
        self.initWebView()
        
        //关闭按钮直接退出程序
        
        let mainWindow = NSWindowController()
        
        NSApp.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeWindow), name: .NSWindowWillClose, object: mainWindow)
    }
    func closeWindow(){
        
        NSApp.terminate(self)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        return true
    }
    
    //初始化网页视图
    private func initWebView(){
        
        self.serverAddress.isEditable = false
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.webView.frame = self.customView.bounds
        
        self.customView.wantsLayer = true
        
        self.customView.layer?.backgroundColor = NSColor.clear.cgColor
        
        self.customView.addSubview(self.webView)
        
        //添加网页视图的约束
        let top:NSLayoutConstraint = NSLayoutConstraint.init(item: self.webView, attribute: .top, relatedBy: .equal, toItem: self.customView, attribute: .top, multiplier: 1.0, constant: 0)
        let left:NSLayoutConstraint = NSLayoutConstraint.init(item: self.webView, attribute: .left, relatedBy: .equal, toItem: self.customView, attribute: .left, multiplier: 1.0, constant: 0)
        let bottom:NSLayoutConstraint = NSLayoutConstraint.init(item: self.webView, attribute: .bottom, relatedBy: .equal, toItem: self.customView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let right:NSLayoutConstraint = NSLayoutConstraint.init(item: self.webView, attribute: .right, relatedBy: .equal, toItem: self.customView, attribute: .right, multiplier: 1.0, constant: 0)
        self.webView.superview?.addConstraint(top)
        self.webView.superview?.addConstraint(left)
        self.webView.superview?.addConstraint(bottom)
        self.webView.superview?.addConstraint(right)
    
    
    }
    
    //初始化户型图视图
    private func initFloorPlanImageView(){
        
        
        self.sizeTextField.isEnabled = false
        
        self.backView.wantsLayer = true
        
        self.backView.layer?.borderWidth = 2
        
        self.backView.layer?.borderColor = NSColor.white.cgColor
        
        self.backView.layer?.cornerRadius = 5
        
        self.backView.layer?.setNeedsLayout()
        
        self.floorPlanImgView.type = .Floor
        
        self.floorPlanImgView.isEnabled = true
        
        let imageMenu = NSMenu(title: "添加")
        
        self.floorPlanImgView.menu = imageMenu
        
        imageMenu.delegate = self
    
    }
    
    @IBAction func selectFile(_ sender: NSButton) {
        
        self.openPanel(path: nil)
    }
    
    private func openPanel(path:String?){
    
        let panel = NSOpenPanel.init()
        
        panel.canChooseDirectories = true
        
        panel.begin { (result) in
            
            if result == NSFileHandlingPanelOKButton{
            
                self.textField.stringValue = (panel.url!.path)
                
                if self.webServer.isRunning{
                    
                    self.webServer.stop()
                }
                
                //初始化本地静态服务器
                self.initGCDWebServer(serverPath: self.textField.stringValue)
            }
            
        }
    }
    
    
    //本地静态服务器并加载资源
    private func initGCDWebServer(serverPath:String){
        
        self.webServer.addGETHandler(forBasePath: "/", directoryPath: serverPath, indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)
        
        let port = arc4random()%60000 + 1024
        
        self.webServer.start(withPort:UInt(port), bonjourName:"GCD Web Server")
        
        guard let serverString = webServer.serverURL else { return
            
        }
        
        self.serverAddress.stringValue = "\(serverString)"
        
        self.webView.load(URLRequest.init(url: URL(string: "\(serverString)" + "vtour/tour.html")!))
        
        //获取户型图
        let floorPlanImg = NSImage.init(contentsOf: NSURL.init(fileURLWithPath: "\(serverPath)/vtour/panos/map.png") as URL)
        
        self.floorPlanImgView.image = floorPlanImg
        
        self.floorPlanImgView.sizeToFit()
        
        if let size = floorPlanImg?.size {
            
            self.sizeTextField.stringValue = "\(size.width) x \(size.height)"
        }
        
    }
    
    //导出xml
    @IBAction func export(_ sender: NSButton) {
        
        let fileManager = ModuleFileManger()
        
        fileManager.createFile("data.xml", toPath: self.textField.stringValue)
        
        var dataFile = String()
        
        for item in self.dic {
            
            let lat = String(format: "%.2f", item.value.center.x)
            
            let lng = String(format: "%.2f", self.floorPlanImgView.bounds.height - item.value.center.y)
            
            let heading = String(format: "%.2f", item.value.rotation)
            
            let title = item.key
            
            dataFile += "<scene title='\(title.encode!)' lat='\(lat)' lng='\(lng)' heading='\(heading)'>\n</scene>\n"
            
        }
        
        let xmlManager = XMLParserTool()
        
        xmlManager.createXMLFile(xmlString: "<root>" + dataFile + "</root>", savePath: self.textField.stringValue + "/data.xml")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //确认添加空间导航点
    @IBAction func countersignNavigationDot(_ sender: NSButton) {
                
        let imageView = DotImgaeView.init(frame: NSRect.init(x: self.navigationImageView.center.x - 5, y: self.navigationImageView.center.y - 5, width: 10, height: 10))
        
        imageView.wantsLayer = true
        
        imageView.layer?.cornerRadius = 5
        
        imageView.layer?.backgroundColor = NSColor.green.cgColor
        
        imageView.setNeedsDisplay()
        
//        imageView.delegate = self
        
//        let dotBtn = NSButton.init(frame: NSRect.init(x: self.navigationImageView.center.x - 5, y: self.navigationImageView.center.y - 5, width: 10, height: 10))
//        
//        dotBtn.mouseDown(with: <#T##NSEvent#>)
        
        
        //删除导航点
        
        imageView.isEnabled = true
        
        let delMenu = NSMenu(title: "删除")
        
        imageView.menu = delMenu
        
        delMenu.delegate = self
        
        self.floorPlanImgView.addSubview(imageView)
        
        self.navigationImageView.imageViewName = self.spaceName.stringValue
        
        self.dic.updateValue(self.navigationImageView, forKey: navigationImageView.imageViewName)
        
        imageView.id = self.navigationImageView.imageViewName
        
        self.navigationImageView.removeFromSuperview()
        
        self.dotArr.append(imageView)
        
    }
}

extension ViewController:NSMenuDelegate{
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        menu.removeAllItems()
        
        if menu.title == "添加" {
            
            menu.addItem(NSMenuItem.init(title: "添加导航点", action: #selector(addPlanDot), keyEquivalent: ""))
            
        }else if menu.title == "删除"{
            
            menu.addItem(NSMenuItem.init(title: "删除导航点", action: #selector(removePlanDot), keyEquivalent: ""))
        
        }
        
    }
    
    func addPlanDot(menu:NSMenu) {
        
        let navigationImage = NSImage.init(named: "navigationImage.png")
        
        self.navigationImageView = MouseEventImageView.init(frame: NSRect.init(x: IMInstance.getSharedInstance().mousePoint.x - 150, y: IMInstance.getSharedInstance().mousePoint.y - 150, width: 300, height: 300))
        
        self.navigationImageView.center = IMInstance.getSharedInstance().mousePoint
        
        self.navigationImageView.isEnabled = true
        
        self.navigationImageView.image = navigationImage
        
        self.floorPlanImgView.addSubview(self.navigationImageView)
        
    }
    
    func removePlanDot(menu:NSMenu) {
        
        for item in self.dotArr {
            
            if item.selected{
                
                item.removeFromSuperview()
                
                self.dic.removeValue(forKey: item.id)
                
            }
        }
        
    }
}
