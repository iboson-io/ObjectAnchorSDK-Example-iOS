//
//  ContentView.swift
//  ObjectAnchor
//
//  Created by Atul Vasudev A on 03/02/25.
//

import SwiftUI

struct UIViewWrapper<V: UIView>: UIViewRepresentable {
    
    let view: UIView
    
    func makeUIView(context: Context) -> some UIView { view }
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

struct ContentView: View {
    
    @StateObject var arSceneView = ARSceneView()
    
    var body: some View {
        ZStack{
            UIViewWrapper(view: arSceneView.sceneView).ignoresSafeArea()
            VStack {
                Text(arSceneView.statusText)
                    .font(.footnote)
                    .padding()
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                Spacer()
                
                Button(action: {
                    arSceneView.startScan()
                }) {
                    Text("Start Scan")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(arSceneView.isScanning ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(arSceneView.isScanning)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    ContentView()
}
