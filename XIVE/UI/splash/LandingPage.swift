//
//  LandingPage.swift
//  XIVE
//
//  Created by 나현흠 on 4/3/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var isContentReady : Bool = false
    
    var body: some View {
        
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            
            Text("Hello, world!")
                .padding()
            
            if !isContentReady {
                
                LottieView(jsonName: "logo_splash")
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                    .transition(.opacity)
                
//                LottieView()
//                    .background(Color.white.edgesIgnoringSafeArea(.all))
//                    .transition(.opacity)
                
//                mySplashScreenView.transition(.opacity)
            }
        }
        .onAppear{
            print("ContentView - onAppear() called")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                print("ContentView - 3초 뒤")
                withAnimation{isContentReady.toggle()}
            })
        }
    }
}

//MARK: - 스플래시 스크린
extension ContentView {
    var mySplashScreenView: some View {
        Color.yellow.edgesIgnoringSafeArea(.all)
            .overlay(alignment: .center){
                Text("스플래시 입니다!")
                    .font(.largeTitle)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


