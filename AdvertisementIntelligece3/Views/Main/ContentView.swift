import SwiftUICore
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "ar"
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            // メイン UI
            VStack {
                // ヘッダー
                VisionProStyleHeader()
                
                // タブビュー
                ZStack {
                    // AR表示ビュー
                    if selectedTab == "ar" {
                        ARDisplayView()
                    }
                    // 設定ビュー
                    else if selectedTab == "settings" {
                        SettingsView()
                    }
                    // 画像キャプチャービュー
                    else if selectedTab == "capture" {
                        CaptureView()
                    }
                }
                
                Spacer()
                
                // フローティングコントロールメニュー
                VisionProFloatingMenu(selectedTab: $selectedTab)
            }
        }
    }
}

// Vision Pro スタイルのヘッダー
struct VisionProStyleHeader: View {
    var body: some View {
        HStack {
            Text("AdvertisementIntelligence")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            // ステータスインジケーター
            HStack(spacing: 12) {
                // バッテリーインジケーター
                HStack(spacing: 4) {
                    Image(systemName: "battery.75")
                    Text("75%")
                }
                .foregroundColor(.green)
                
                // Wi-Fi インジケーター
                Image(systemName: "wifi")
                    .foregroundColor(.blue)
                
                // 時計
                Text("12:34")
                    .fontWeight(.medium)
            }
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .background(
            // フロストエフェクト
            Color.white.opacity(0.1)
                .background(Material.ultraThinMaterial)
                .blur(radius: 3)
        )
    }
}

// フローティングメニュー
struct VisionProFloatingMenu: View {
    @Binding var selectedTab: String
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 20) {
            // AR表示ボタン
            MenuButton(
                icon: "arkit",
                title: "AR Display",
                isSelected: selectedTab == "ar",
                action: { selectedTab = "ar" }
            )
            
            // キャプチャーボタン
            MenuButton(
                icon: "camera",
                title: "Capture",
                isSelected: selectedTab == "capture",
                action: { selectedTab = "capture" }
            )
            
            // 設定ボタン
            MenuButton(
                icon: "gear",
                title: "Settings",
                isSelected: selectedTab == "settings",
                action: { selectedTab = "settings" }
            )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(
            // ガラスエフェクト
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.1))
                .background(Material.ultraThinMaterial)
                .shadow(color: Color.white.opacity(0.2), radius: 20, x: 0, y: 0)
        )
        .scaleEffect(scale)
        .onAppear {
            // プルサティングエフェクト
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever()) {
                scale = 1.02
            }
        }
    }
}

// メニューボタン
struct MenuButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Text(title)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .frame(width: 80, height: 80)
            .background(
                Circle()
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                    .shadow(color: isSelected ? Color.blue.opacity(0.6) : Color.clear, radius: 10, x: 0, y: 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
