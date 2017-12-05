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


class ViewController: NSViewController,WebFrameLoadDelegate{
    
    @IBOutlet weak var customView: NSView!
    
    @IBOutlet weak var textField: NSTextField!
    
    @IBOutlet weak var serverAddress: NSTextField!
    
    @IBOutlet weak var floorPlanImgView: MouseEventImageView!
    
    @IBOutlet weak var rightCustomView: NSView!
    @IBOutlet weak var spaceName: NSTextField!
    
    var webView = WKWebView()
    
    
    var navigationImageView = MouseEventImageView()
    
    
    var dic:Dictionary<String,MouseEventImageView> = [:]
    
    let webServer = GCDWebServer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.serverAddress.isEditable = false
        
        self.floorPlanImgView.isEnabled = true
        
        let imageMenu = NSMenu()
        
        self.floorPlanImgView.menu = imageMenu
        
        self.floorPlanImgView.imageViewIdentify = "floorImageView"
        
        imageMenu.delegate = self
        
        self.webView.navigationDelegate = self
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.webView.frame = self.customView.bounds
        
        self.customView.wantsLayer = true
        
        self.customView.layer?.backgroundColor = NSColor.clear.cgColor
        
        self.customView.addSubview(self.webView)
        
        let top:NSLayoutConstraint = NSLayoutConstraint.init(item: self.webView, attribute: .top, relatedBy: .equal, toItem: self.customView, attribute: .top, multiplier: 1.0, constant: 0)
        let left:NSLayoutConstraint = NSLayoutConstraint.init(item: self.webView, attribute: .left, relatedBy: .equal, toItem: self.customView, attribute: .left, multiplier: 1.0, constant: 0)
        let bottom:NSLayoutConstraint = NSLayoutConstraint.init(item: self.webView, attribute: .bottom, relatedBy: .equal, toItem: self.customView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let right:NSLayoutConstraint = NSLayoutConstraint.init(item: self.webView, attribute: .right, relatedBy: .equal, toItem: self.customView, attribute: .right, multiplier: 1.0, constant: 0)
        self.webView.superview?.addConstraint(top)
        self.webView.superview?.addConstraint(left)
        self.webView.superview?.addConstraint(bottom)
        self.webView.superview?.addConstraint(right)
    }
    override func mouseMoved(with event: NSEvent) {
        
        
    }
    
    override func rightMouseUp(with event: NSEvent) {
        
        print(IMInstance.getSharedInstance().mousePoint)
        
    }
    
    private func addAnPointToImageVIew(pointLocation location:NSPoint,floorPlanImageView floorView:NSImageView){
    
    
    }
    
    private func initGCDWebServer(serverPath:String){
        
        self.webServer.addGETHandler(forBasePath: "/", directoryPath: serverPath, indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)
        
        self.webServer.start(withPort:8080, bonjourName:"GCD Web Server")
        
        guard let serverString = webServer.serverURL else { return
            
        }
        
        self.serverAddress.stringValue = "\(serverString)"
        
        self.webView.load(URLRequest.init(url: URL(string: "\(serverString)" + "vtour/tour.html")!))
        
        //获取户型图
        let floorPlanImg = NSImage.init(contentsOf: NSURL.init(fileURLWithPath: "\(serverPath)/vtour/panos/map.png") as URL)
        
        self.floorPlanImgView.image = floorPlanImg
        
        self.floorPlanImgView.sizeToFit()
        
        
        
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
    //获取tour.xml内的scene节点
    
    
    //导出xml
    @IBAction func export(_ sender: NSButton) {
        
        let fileManager = ModuleFileManger()
        
        fileManager.createFile("data.xml", toPath: self.textField.stringValue)
        
//        <scene name="scene_ct" title="餐厅" onstart="" thumburl="panos/ct.tiles/thumb.jpg" lat="143" lng="336" heading="260">
        
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
        
        
//        let doc = try! GDataXMLDocument(xmlString: String.init(contentsOfFile: "\(self.textField.stringValue)/vtour/tour.xml"))
//        
//        let root = doc.rootElement()
//        
//        let elements = root?.elements(forName: "scene") as! [GDataXMLElement]
//        
//        for element in elements {
//            
//            guard let sceneName = element.attribute(forName: "title") else {
//                return
//            }
//            
//            print(sceneName.stringValue())
//            
//            //坐标
//            let locationX = element.attribute(forName: "lat")
//            let locationY = element.attribute(forName: "lng")
//            
//            //角度
//            let rotation = element.attribute(forName: "heading")
//            
//            guard let mod = self.dic[sceneName.stringValue()] else {
//                
//                return
//            }
//            
//            locationX?.setStringValue("\(mod.center.x)")
//            
//            locationY?.setStringValue("\(mod.center.y)")
//            
//            rotation?.setStringValue("\(mod.rotation)")
//            
//        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //确认添加
    @IBAction func countersignNavigationDot(_ sender: NSButton) {
                
        let imageView = NSImageView.init(frame: NSRect.init(x: self.navigationImageView.center.x - 5, y: self.navigationImageView.center.y - 5, width: 10, height: 10))
        
        imageView.wantsLayer = true
        
        imageView.layer?.cornerRadius = 5
        
        imageView.layer?.backgroundColor = NSColor.green.cgColor
        
        imageView.setNeedsDisplay()
        
        self.floorPlanImgView.addSubview(imageView)
        
        self.navigationImageView.imageViewName = self.spaceName.stringValue
        
        self.dic.updateValue(self.navigationImageView, forKey: navigationImageView.imageViewName)
        
        self.navigationImageView.removeFromSuperview()
        
    }
}

//WKWebView
extension ViewController:WKNavigationDelegate{

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
//        print(<#T##items: Any...##Any#>)
        
    }

}

extension ViewController:NSMenuDelegate{
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        menu.addItem(NSMenuItem.init(title: "添加导航点", action: #selector(addPlanDot), keyEquivalent: ""))
        
    }
    
    func addPlanDot(menu:NSMenu) {
        
        let navigationImage = NSImage.init(named: "navigationImage.png")
        
        self.navigationImageView = MouseEventImageView.init(frame: NSRect.init(x: IMInstance.getSharedInstance().mousePoint.x - 150, y: IMInstance.getSharedInstance().mousePoint.y - 150, width: 300, height: 300))
        
        self.navigationImageView.center = IMInstance.getSharedInstance().mousePoint
        
        self.navigationImageView.isEnabled = true
        
        self.navigationImageView.image = navigationImage
        
        self.floorPlanImgView.addSubview(self.navigationImageView)
        
    }
}