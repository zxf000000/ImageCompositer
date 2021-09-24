//
//  ModelData.swift
//  ImageCompositer
//
//  Created by mr.zhou on 2021/9/24.
//

import Foundation
import AppKit
import SwiftUI

var roleList: [String: [String: String]] = [:]
var soulList: [String: String] = [:]
var charmList: [String: String] = [:]
var backList: [String: String] = [:]
var frameList: [String: String] = [:]

var dataList: [[String: String]] = []

func loadAllFile(dir: String) -> [String: String] {
    let files = try! FileManager.default.contentsOfDirectory(atPath: dir)
    var dict: [String: String] = [:]
    for file in files {
        if file != ".DS_Store" {
            dict[file.replacingOccurrences(of: ".png", with: "")] = dir.appending("/\(file)")
        }
    }
    return dict
}

func handleDirs(panel: NSOpenPanel) {
    let dirUrl = panel.urls[0].path
    let names = ["人物", "御魂", "挂饰", "背景", "边框"]
    let role_dir = [
        "1": dirUrl.appending("/\(names[0])/1"),
        "2": dirUrl.appending("/\(names[0])/2"),
        "3": dirUrl.appending("/\(names[0])/3")]
    let soulDir = dirUrl.appending("/\(names[1])")
    let charmDir = dirUrl.appending("/\(names[2])")
    let backDir = dirUrl.appending("/\(names[3])")
    let frameDir = dirUrl.appending("/\(names[4])")
    for item in role_dir {
        roleList[item.key] = loadAllFile(dir: item.value)
    }
    soulList = loadAllFile(dir: soulDir)
    charmList = loadAllFile(dir: charmDir)
    backList = loadAllFile(dir: backDir)
    frameList = loadAllFile(dir: frameDir)
}

func loadXls(panel: NSOpenPanel) {
    var dirUrl = panel.urls[0]
    dirUrl.appendPathComponent("SpiritLand.csv")
    let contents = try! String(contentsOfFile: dirUrl.path)
    let arr = contents.split(separator: "\r\n")
    for i in 1...arr.count - 1 {
        let data = arr[i].split(separator: ",")
        dataList.append([
            "role": String(data[1]),
            "back": String(data[2]),
            "soul": String(data[3]),
            "frame": String(data[4]),
            "blood": String(data[5]),
            "charm": String(data[6]),
            "name": "\(i).png"
        ])
    }
}

func loadImg(index: Int) -> NSImage {
    let data = dataList[index]
    let backPath = backList[data["back"] ?? ""]
    let soulPath = soulList[data["soul"] ?? ""]
    let framePath = frameList[data["frame"] ?? ""]
    let charmPath = charmList[data["charm"] ?? ""]
    let rolePath = roleList[data["blood"] ?? ""]?[data["role"] ?? ""]
    var image: NSImage?
    autoreleasepool {
        // 合成
        let backImg = CIImage(contentsOf: URL(fileURLWithPath: backPath!))
        let frameImg = CIImage(contentsOf: URL(fileURLWithPath: framePath!))
        let roleImg = CIImage(contentsOf: URL(fileURLWithPath: rolePath!))
        let soulImg = CIImage(contentsOf: URL(fileURLWithPath: soulPath!))
        let charmImg = CIImage(contentsOf: URL(fileURLWithPath: charmPath!))
        var imageFilter = CIFilter(name: "CISourceOverCompositing")!
        imageFilter.setValue(roleImg, forKey: kCIInputImageKey)
        imageFilter.setValue(backImg, forKey: kCIInputBackgroundImageKey)
        var res = imageFilter.outputImage
        imageFilter = CIFilter(name: "CISourceOverCompositing")!
        imageFilter.setValue(frameImg, forKey: kCIInputImageKey)
        imageFilter.setValue(res, forKey: kCIInputBackgroundImageKey)
        res = imageFilter.outputImage
        imageFilter = CIFilter(name: "CISourceOverCompositing")!
        imageFilter.setValue(soulImg, forKey: kCIInputImageKey)
        imageFilter.setValue(res, forKey: kCIInputBackgroundImageKey)
        res = imageFilter.outputImage
        imageFilter = CIFilter(name: "CISourceOverCompositing")!
        imageFilter.setValue(charmImg, forKey: kCIInputImageKey)
        imageFilter.setValue(res, forKey: kCIInputBackgroundImageKey)
        res = imageFilter.outputImage
        let ciContext = CIContext(options: nil)
        let cgImg = ciContext.createCGImage(res!, from: res?.extent ?? CGRect.zero)
        image = NSImage(cgImage: cgImg!, size: res?.extent.size ?? NSSize.zero)
    }
    return image!

//    for data in dataList {
//        let backPath = backList[data["back"] ?? ""]
//        let img = NSImage(contentsOfFile: backPath!)
//    }
}
