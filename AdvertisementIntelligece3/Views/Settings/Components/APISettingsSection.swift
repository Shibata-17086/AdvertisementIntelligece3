//
//  APISettingsSection.swift
//  AdvertisementIntelligece3
//
//  Created by 柴田紘希 on 2025/03/06.
//

// Views/Settings/Components/APISettingsSection.swift

import SwiftUI

struct APISettingsSection: View {
    @Binding var openaiApiKey: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "OpenAI設定", icon: "brain")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("OpenAI API キー")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                ZStack(alignment: .trailing) {
                    if openaiApiKey.isEmpty {
                        SecureField("APIキーを入力", text: $openaiApiKey)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    } else {
                        SecureField("••••••••••••••••••••", text: $openaiApiKey)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        Button(action: { openaiApiKey = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    }
                }
                
                Text("OpenAI APIを使用して広告テキストを生成します")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
}
