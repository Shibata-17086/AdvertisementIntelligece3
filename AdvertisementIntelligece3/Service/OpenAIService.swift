//
//  OpenAIService.swift
//  AdvertisementIntelligece3
//
//  Created by 柴田紘希 on 2025/03/06.
//

// Services/OpenAIService.swift
import SwiftUI
import Foundation
import Combine

class OpenAIService {
    private let apiBaseURL = "https://api.openai.com/v1/chat/completions"
    private var apiKey: String {
        return UserDefaults.standard.string(forKey: "openaiApiKey") ?? ""
    }
    
    struct ChatCompletionRequest: Codable {
        let model: String
        let messages: [Message]
        let temperature: Float
        let max_tokens: Int
        
        struct Message: Codable {
            let role: String
            let content: String
        }
    }
    
    struct ChatCompletionResponse: Codable {
        let id: String
        let object: String
        let created: Int
        let choices: [Choice]
        
        struct Choice: Codable {
            let index: Int
            let message: Message
            let finish_reason: String
            
            struct Message: Codable {
                let role: String
                let content: String
            }
        }
    }
    
    func generateAdContent(
        based on: String,  // この行を修正（パラメータ名を単純化し、カンマを追加）
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard !apiKey.isEmpty else {
            completion(.failure(NSError(
                domain: "OpenAIService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "API キーが設定されていません。設定画面から追加してください。"]
            )))
            return
        }
        
        let prompt = """
        以下のシーンに適した広告文を作成してください。
        最初の行は魅力的なタイトル、その後に短い説明を続けてください。
        全体で2-3行以内にしてください。
        
        シーンの説明: \(on)
        """
        
        let request = ChatCompletionRequest(
            model: "gpt-3.5-turbo",
            messages: [
                ChatCompletionRequest.Message(role: "system", content: "あなたは広告文を作成する専門家です。商品の魅力を短く的確に伝えることが得意です。"),
                ChatCompletionRequest.Message(role: "user", content: prompt)
            ],
            temperature: 0.7,
            max_tokens: 150
        )
        
        guard let requestData = try? JSONEncoder().encode(request) else {
            completion(.failure(NSError(
                domain: "OpenAIService",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "リクエストのエンコードに失敗しました"]
            )))
            return
        }
        
        var urlRequest = URLRequest(url: URL(string: apiBaseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = requestData
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(
                    domain: "OpenAIService",
                    code: 500,
                    userInfo: [NSLocalizedDescriptionKey: "データの取得に失敗しました"]
                )))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
                if let content = response.choices.first?.message.content {
                    completion(.success(content.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else {
                    throw NSError(
                        domain: "OpenAIService",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "応答内容の解析に失敗しました"]
                    )
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
