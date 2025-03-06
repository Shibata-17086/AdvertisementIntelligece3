import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                // グラデーション背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1)),
                        Color(UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1))
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // メインコンテンツ
                VStack(spacing: 20) {
                    // アイコン
                    Image(systemName: "eye")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 120)
                        .background(
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.blue.opacity(0.8),
                                                Color.purple.opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                // 微妙な光彩効果
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            }
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 0)
                    
                    // アプリ名
                    Text("Advertisement")
                        .font(.system(size: 30, weight: .light, design: .default))
                        .foregroundColor(.white)
                    
                    Text("Intelligence")
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    // サブタイトル
                    Text("Intelligent AR Advertising")
                        .font(.system(size: 16, weight: .light, design: .default))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 5)
                }
                .scaleEffect(scale)
                .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    self.opacity = 1.0
                    self.scale = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
