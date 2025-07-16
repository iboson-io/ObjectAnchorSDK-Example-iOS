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
                Spacer()
                Button(action: {
                    // Action for the button
                    print("Button pressed")
                    arSceneView.savePCDFile = true
                }) {
                    Text("Save point cloud")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
