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
                Text(arSceneView.statusText)
                    .font(.footnote)
                    .padding()
                    .foregroundColor(.white)
                    .shadow(radius: 4)
            }
        }
    }
}

#Preview {
    ContentView()
}
