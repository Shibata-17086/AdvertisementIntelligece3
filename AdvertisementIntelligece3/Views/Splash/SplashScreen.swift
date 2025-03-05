import SwiftUICore
import UIKit

struct SplashScreen: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                // 宇宙をモチーフにした背景
                LinearGradient(
                    gradient: Gradient(colors: [Color(UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1)), Color(UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1))]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // 星のエフェクト
                StarsView()
                
                // ロゴ
                VStack {
                    Image("app_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .shadow(color: Color.white.opacity(0.5), radius: 20, x: 0, y: 0)
                    
                    Text("AdvertisementIntelligence")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.blue.opacity(0.8), radius: 10, x: 0, y: 0)
                }
                .scaleEffect(1.2)
                .opacity(opacity)
            }
            .onAppear {
                // アニメーション開始
                withAnimation(.easeIn(duration: 1.5)) {
                    self.opacity = 1.0
                }
                
                // メイン画面へ遷移
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

// 星のエフェクト
struct StarsView: View {
    @State private var animationAmount = 0.7
    
    var body: some View {
        ZStack {
            ForEach(0..<100, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.5)))
                    .frame(width: Double.random(in: 1...3))
                    .position(
                        x: Double.random(in: 0...UIScreen.main.bounds.width),
                        y: Double.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: Double.random(in: 0...0.5))
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 3).repeatForever()) {
                self.animationAmount = 1.0
            }
        }
    }
}
