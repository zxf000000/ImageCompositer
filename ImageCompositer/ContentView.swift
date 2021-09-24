//
//  ContentView.swift
//  ImageCompositer
//
//  Created by mr.zhou on 2021/9/24.
//

import SwiftUI



struct ContentView: View {
    @State private var dirUrl = ""
    @State private var img: NSImage? = nil
    @State private var currentIndex = 0
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button("Select") {
                // 选取文档
                let panel = NSOpenPanel()
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
                panel.allowsMultipleSelection = false
                panel.begin { response in
                    if response.rawValue != 1 {
                        return
                    }
                    let path = panel.urls[0]
                    // 处理文档
                    handleDirs(panel: panel)
                    // 读取 excel
                    loadXls(panel: panel)
//                    img = loadImg(index: 0)
                    let queue1 = DispatchQueue(label: "1")
                    let queue2 = DispatchQueue(label: "2")
                    let queue3 = DispatchQueue(label: "3")
                    let queue4 = DispatchQueue(label: "4")
                    let queue5 = DispatchQueue(label: "5")
                    let queue6 = DispatchQueue(label: "6")
                    let queue7 = DispatchQueue(label: "7")
                    let queue8 = DispatchQueue(label: "8")
                    let queues = [queue1, queue2, queue3, queue4, queue5, queue6, queue7, queue8]
                        let step = dataList.count / 8
                        for i in 1...8 {
                            DispatchQueue.global().async {
                                let queue = queues[i - 1]
                                for index in step * (i - 1)..<step * i {
                                    queue.async {
                                        autoreleasepool {
                                            currentIndex = index
                                            img = loadImg(index: index)
                                            do {
                                                let fileURL = path.appendingPathComponent("output").appendingPathComponent(dataList[index]["name"] ?? "")
                                                let tiffData = img?.tiffRepresentation
                                                let imgRep = NSBitmapImageRep(data: tiffData!)
                                                let imageData = imgRep?.representation(using: .png, properties: [:])
                                                try! imageData?.write(to: fileURL)
                                            } catch { }
                                        }
                                    }
                                }
                            }
                        
                    }
                }
            }
            Text("Selected Dir: \(dirUrl)")
            Text("Index: \(currentIndex)")
            Image(nsImage: img ?? NSImage())
                .resizable()
                .aspectRatio(nil, contentMode: .fit)
                .frame(width: 200, height: 300, alignment: .top)
                
        }
        .frame(width: 400, height: 800, alignment: .top)
        .padding(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
