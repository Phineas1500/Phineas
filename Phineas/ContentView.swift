//
//  ContentView.swift
//  Phineas
//
//

import SwiftUI

struct ContentView: View {
    
    @State private var animateGradient: Bool = false
    
    private let startColor: Color = Color(red: 0.5882, green: 0.2941, blue: 0)
    private let endColor: Color = Color(red: 0.3, green: 0.15, blue: 0)
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.black)
            Text("Hello, world!")
                .font(.title)
                .bold()
            
            Spacer()
                        
            Button {
                
            } label: {
                Image(systemName: "arrow.right")
            }
            .frame(width: 50, height: 50)
            .background(Color.white)
            .cornerRadius(25)
            .padding(10)
            .overlay {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(.white)
            }
            Spacer()
            
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.black)
        .padding(.horizontal)
        .background {
            LinearGradient(colors: [startColor, endColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .hueRotation(.degrees(animateGradient ? 10 : 0))
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
        }
        
        
    }
    
}

#Preview {
    ContentView()
}
