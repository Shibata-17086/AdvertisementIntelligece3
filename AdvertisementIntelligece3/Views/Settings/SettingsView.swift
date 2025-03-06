// Views/Settings/SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "visionApiKey") ?? ""
    @State private var enableAutoRefresh = UserDefaults.standard.bool(forKey: "enableAutoRefresh")
    @State private var refreshInterval = UserDefaults.standard.double(forKey: "refreshInterval")
    @State private var maxAdsCount = UserDefaults.standard.integer(forKey: "maxAdsCount")
    @State private var showDebugInfo = UserDefaults.standard.bool(forKey: "showDebugInfo")
    @State private var preferredTheme = UserDefaults.standard.integer(forKey: "preferredTheme")
    @State private var isLoading = false
    
    // OpenAI API 設定追加
    @State private var openaiApiKey: String = UserDefaults.standard.string(forKey: "openaiApiKey") ?? ""
    
    private let themes = ["システムデフォルト", "ダーク", "ライト", "Vision Pro風"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ヘッダー
                Text("設定")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                
                // セクション：API設定
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "API設定", icon: "key.fill")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Google Cloud Vision API キー")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        ZStack(alignment: .trailing) {
                            TextField("APIキーを入力", text: $apiKey)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            
                            if !apiKey.isEmpty {
                                Button(action: { apiKey = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 12)
                                }
                            }
                        }
                        
                        Text("APIキーはGoogle Cloud Platformから取得できます")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                }
                
                // OpenAI API設定セクション追加
                APISettingsSection(openaiApiKey: $openaiApiKey)
                
                // セクション：表示設定
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "表示設定", icon: "display")
                    
                    VStack(spacing: 16) {
                        // 自動更新設定
                        Toggle(isOn: $enableAutoRefresh) {
                            Text("広告の自動更新")
                                .foregroundColor(.white)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        // 更新間隔設定
                        VStack(alignment: .leading, spacing: 8) {
                            Text("更新間隔: \(Int(refreshInterval))秒")
                                .foregroundColor(.white)
                            
                            Slider(value: $refreshInterval, in: 2...10, step: 1)
                                .accentColor(.blue)
                                .disabled(!enableAutoRefresh)
                        }
                        
                        // 最大広告数設定
                        VStack(alignment: .leading, spacing: 8) {
                            Text("最大広告表示数: \(maxAdsCount)")
                                .foregroundColor(.white)
                            
                            Stepper("", value: $maxAdsCount, in: 1...5)
                                .labelsHidden()
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                }
                
                // セクション：外観設定
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "外観設定", icon: "paintbrush.fill")
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // テーマ選択
                        VStack(alignment: .leading, spacing: 8) {
                            Text("テーマ")
                                .foregroundColor(.white)
                            
                            Picker("テーマ", selection: $preferredTheme) {
                                ForEach(0..<themes.count, id: \.self) { index in
                                    Text(themes[index])
                                        .foregroundColor(.white)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // デバッグ情報表示
                        Toggle(isOn: $showDebugInfo) {
                            Text("デバッグ情報を表示")
                                .foregroundColor(.white)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                }
                
                // アクションボタン
                VStack(spacing: 16) {
                    Button(action: saveSettings) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("設定を保存")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.6))
                    .cornerRadius(12)
                    .disabled(isLoading)
                    
                    Button(action: resetSettings) {
                        Text("デフォルトに戻す")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.vertical)
            }
            .padding()
        }
        .background(
            // グラデーション背景
            LinearGradient(
                gradient: Gradient(colors: [Color(UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1)), Color(UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1))]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
    
    // 設定を保存
    private func saveSettings() {
        isLoading = true
        
        // 設定の保存処理（UserDefaultsなどに保存）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 既存の設定値を保存
            UserDefaults.standard.set(self.apiKey, forKey: "visionApiKey")
            UserDefaults.standard.set(self.enableAutoRefresh, forKey: "enableAutoRefresh")
            UserDefaults.standard.set(self.refreshInterval, forKey: "refreshInterval")
            UserDefaults.standard.set(self.maxAdsCount, forKey: "maxAdsCount")
            UserDefaults.standard.set(self.showDebugInfo, forKey: "showDebugInfo")
            UserDefaults.standard.set(self.preferredTheme, forKey: "preferredTheme")
            
            // OpenAI APIキーを保存（新規追加）
            UserDefaults.standard.set(self.openaiApiKey, forKey: "openaiApiKey")
            
            self.isLoading = false
        }
    }
    
    // 設定をリセット
    private func resetSettings() {
        apiKey = ""
        enableAutoRefresh = true
        refreshInterval = 4.0
        maxAdsCount = 2
        showDebugInfo = false
        preferredTheme = 0
        openaiApiKey = ""  // OpenAI APIキーもリセット
    }
}
