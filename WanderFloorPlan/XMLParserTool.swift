//
//  XMLParserTool.swift
//  Sand
//
//  Created by Hu on 2017/8/11.
//  Copyright © 2017年 xx. All rights reserved.
//

import Cocoa

extension String{

    var encode:String? {
        
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet(charactersIn: "!*'\";:@&=+$,?%#[]%").inverted)
    
    }
    
    var decode:String?{
    
        return self.removingPercentEncoding
    }
    

}

class XMLParserTool: NSObject {
    
   private func getXMLData(filePath:String?) -> GDataXMLElement? {
        
        guard let fileTargetpath = filePath else {
            
            return nil
        }
        
        var xmlString = String()
        
        
        do {
            
            xmlString = try String.init(contentsOfFile: fileTargetpath, encoding: String.Encoding.utf8)
            
        } catch {
            
            return nil
        }
        
        var element = GDataXMLElement()
        
        do {
            
              element = try GDataXMLElement.init(xmlString: xmlString)
            
        } catch {
            
            return nil
        }
        
        return element
    }
    
   private func saveXMLFile(doc:GDataXMLDocument,to path:String) {
        
        guard let xmlData = doc.xmlData() else { return  }
        
        guard var xmlStrrring = String.init(data: xmlData, encoding: String.Encoding.utf8) else { return  }
        
        xmlStrrring.removeSubrange((xmlStrrring.startIndex)...(xmlStrrring.index((xmlStrrring.startIndex), offsetBy: 21)))
        
        try! xmlStrrring.decode?.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        
    }
    
    //添加id元素
  public  func addXMLFileElement(targetXMLPath targetpath:String?, addProperty propertyString:String? ,withElementName elementName:String) {
        
        guard let idString = propertyString else { return  }
        
        guard let element = self.getXMLData(filePath: targetpath) else { return  }
        
        let str = idString.encode
        
        let pathEle = GDataXMLNode.element(withName: elementName, stringValue: str)
        
        element.addChild(pathEle)
        
        guard let doc = GDataXMLDocument.init(rootElement: element) else {
            
            return
        }
        
        self.saveXMLFile(doc: doc, to: targetpath!)
    }
    
    //根据字符串生成xml文件
   public func createXMLFile(xmlString:String,savePath path:String?){
        
        var element = GDataXMLElement()
        
        do {
            
            element = try GDataXMLElement.init(xmlString: xmlString)
            
        } catch {
            
        }
        
        guard let doc = GDataXMLDocument.init(rootElement: element) else {
            
            return
        }
        
        self.saveXMLFile(doc: doc, to: path!)
    }
    
    //添加序列路径属性
  public  func changeXMLRootElementProperty(targetXMLPath targetpath:String?, addProperty propertyString:String?) {
        
        guard let propertyStr = propertyString else { return  }
        
        guard let element = self.getXMLData(filePath: targetpath) else { return  }
        
        guard let doc = GDataXMLDocument.init(rootElement: element) else {
            
            return
        }
        
        let str = propertyStr.encode
        
        let attr = GDataXMLNode.attribute(withName: "sequenceFile", stringValue:str ) as! GDataXMLNode
        
        let attr1 = GDataXMLNode.attribute(withName: "decorateBundle", stringValue:"subs/" + "装饰".encode! ) as! GDataXMLNode
        
        let attr2 = GDataXMLNode.attribute(withName: "submodulesBundle", stringValue:"subs/" + "模块".encode! ) as! GDataXMLNode
        
        doc.rootElement().addAttribute(attr)
        
        doc.rootElement().addAttribute(attr1)
        
        doc.rootElement().addAttribute(attr2)
        
        self.saveXMLFile(doc: doc, to: targetpath!)
        
    }
    
    public func changeNodeElement(XMLFilePath filePath:String ,nodeName node:String, elementDic dic:Dictionary<String, String>){
        
        guard let element = self.getXMLData(filePath: filePath) else { return  }
        
        guard let doc = GDataXMLDocument.init(rootElement: element) else {
            
            return
        }
        //判断该属性是否存在
        
        let root = doc.rootElement()
        
        for (key, value) in dic {
            
            let eleAttr = root?.attribute(forName: key)
            
            eleAttr?.setStringValue(value)
            
        }
        self.saveXMLFile(doc: doc, to: filePath)
    
    }
    
    public func getXMLNodeArr(xmlFile:String!,nodeString:String) ->[GDataXMLElement]?{
        
        
        let doc = try! GDataXMLDocument.init(xmlString: xmlFile)
        
        let root = doc.rootElement()
        
        guard let nodeArr = root?.elements(forName: nodeString) else {
            
            return nil
        }
        
        return nodeArr as? [GDataXMLElement]
    
    }
}
