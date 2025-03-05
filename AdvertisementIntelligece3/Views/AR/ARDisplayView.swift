import SwiftUICore
import ARKit
import RealityKit
import SwiftUI

struct ARDisplayView: View {
    @StateObject private var arViewModel = ARViewModel()
    
    var body: some View {
        ZStack {
            // ARView をラップ
            ARViewContainer(arViewModel: arViewModel)
                .edgesIgnoringSafeArea(.all)
            
            // AR操作用のオーバーレイ
            VStack {
                Spacer()
                
                // インジケーターと説明
                VStack(spacing: 12) {
                    Text(arViewModel.statusMessage)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Material.ultraThinMaterial)
                        .cornerRadius(20)
                    
                    if arViewModel.isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    }
                }
                .foregroundColor(.white)
                .padding(.bottom, 100) // フローティングメニューの上部に表示
            }
        }
    }
}

// ARビューコンテナ
struct ARViewContainer: UIViewRepresentable {
    
    let arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // AR設定
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical] // 垂直面（壁）の検出
        arView.session.run(configuration)
        
        // デリゲートの設定
        arView.session.delegate = arViewModel
        
        // ARビューをビューモデルに設定
        arViewModel.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

// ARビューモデル
// ARビューモデル
class ARViewModel: NSObject, ObservableObject, ARSessionDelegate {
    @Published var statusMessage = "壁を検索中..."
    @Published var isProcessing = false
    
    weak var arView: ARView?
    private var anchors = [UUID: ARAnchor]()
    private var adEntities = [UUID: Entity]()
    private var advertQueue = [(UUID, String)]() // 広告のキュー (ID, テキスト)
    
    private var lastAnalysisTime = Date()
    private let analysisCooldown: TimeInterval = 4.0 // 4秒ごとに解析
    
    // ARセッションの更新
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentTime = Date()
        
        // 4秒ごとに画像解析を実行
        if currentTime.timeIntervalSince(lastAnalysisTime) >= analysisCooldown {
            analyzeCurrentFrame(frame)
            lastAnalysisTime = currentTime
        }
    }
    
    // 平面検出時
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical {
                DispatchQueue.main.async {
                    self.statusMessage = "壁を検出しました"
                    
                    // 広告がまだなければ生成
                    if self.adEntities.count < 2 {
                        self.generateAd(for: planeAnchor)
                    }
                }
            }
        }
    }
    
    // 現在のフレームを解析
    private func analyzeCurrentFrame(_ frame: ARFrame) {
        guard !isProcessing, let _ = arView else { return }
        
        isProcessing = true
        DispatchQueue.main.async {
            self.statusMessage = "シーンを解析中..."
        }
        
        // 画像をキャプチャ
        let _ = frame.capturedImage
        
        // バックグラウンドで画像解析を実行
        DispatchQueue.global(qos: .userInitiated).async {
            // ここではダミーの解析結果を生成（実際にはGoogle Cloud Vision APIに送信）
            // 解析とAI広告生成処理（実装略）
            
            // 解析結果からテキストを生成（サンプル）
            let dummyAdTexts = [
                "新発売：究極のスマート家電\n音声で操作できる未来型デバイス",
                "家でくつろぐ時間に\n高品質ヘッドフォンを体験しよう",
                "あなたの毎日を彩る\n最新スマートウォッチ",
                "今だけ30%オフ\n快適な睡眠をサポートするマットレス"
            ]
            
            let adText = dummyAdTexts.randomElement() ?? "素敵な一日を過ごしましょう\nAdvertisementIntelligenceがあなたをサポート"
            
            // メインスレッドで広告表示を更新
            DispatchQueue.main.async {
                // 既存の壁面アンカーを使用して広告を表示
                if let planeAnchor = self.findBestWallAnchor() {
                    self.addAdToWall(text: adText, anchor: planeAnchor)
                }
                
                self.statusMessage = "広告を更新しました"
                self.isProcessing = false
            }
        }
    }
    
    // 最適な壁のアンカーを取得
    private func findBestWallAnchor() -> ARPlaneAnchor? {
        guard let frame = arView?.session.currentFrame else { return nil }
        
        // カメラ位置
        let cameraPosition = frame.camera.transform.columns.3
        var bestAnchor: ARPlaneAnchor? = nil
        var minDistance: Float = 100.0 // 初期値（大きな値）
        
        // 全アンカーをチェック
        for anchor in arView?.session.currentFrame?.anchors ?? [] {
            guard let planeAnchor = anchor as? ARPlaneAnchor,
                  planeAnchor.alignment == .vertical else { continue }
            
            let anchorPosition = planeAnchor.transform.columns.3
            let distance = simd_distance(
                SIMD3<Float>(anchorPosition.x, anchorPosition.y, anchorPosition.z),
                SIMD3<Float>(cameraPosition.x, cameraPosition.y, cameraPosition.z)
            )
            
            // 1メートル前後の最も近い壁を選択
            if distance < 2.0 && (bestAnchor == nil || abs(distance - 1.0) < abs(minDistance - 1.0)) {
                bestAnchor = planeAnchor
                minDistance = distance
            }
        }
        
        return bestAnchor
    }
    
    // 広告生成
    private func generateAd(for planeAnchor: ARPlaneAnchor) {
        // ダミー広告テキスト
        let adText = "AdvertisementIntelligenceへようこそ\nスマートな広告体験"
        
        // 広告を追加
        addAdToWall(text: adText, anchor: planeAnchor)
    }
    
    // 壁面に広告を追加（修正版）
    private func addAdToWall(text: String, anchor: ARPlaneAnchor) {
        guard let arView = arView else { return }
        
        // 古い広告を管理 (最大2件まで)
        manageAdQueue(newAdText: text, anchorID: anchor.identifier)
        
        // A3サイズに合わせたサイズ設定 (0.297m x 0.42m)
        let adWidth: Float = 0.297
        let adHeight: Float = 0.42
        
        // アンカーの位置に配置
        let anchorEntity = AnchorEntity(anchor: anchor)
        
        // ポスター平面を作成 - 実体のある板として表示
        let posterMesh = MeshResource.generateBox(width: adWidth, height: adHeight, depth: 0.005)
        let posterMaterial = SimpleMaterial(color: UIColor.white, roughness: 0.2, isMetallic: false)
        
        let posterModel = ModelEntity(mesh: posterMesh, materials: [posterMaterial])
        
        // 壁の法線ベクトルを使用して向きを調整
        let normalVector = SIMD3<Float>(anchor.transform.columns.2.x, anchor.transform.columns.2.y, anchor.transform.columns.2.z)
        
        // ポスターが壁に対して少し前に出るように配置
        let positionOffsetFromWall: Float = 0.01 // 1cmほど壁から離す
        
        // ポスターエンティティを作成して位置調整
        let adEntity = Entity()
        adEntity.addChild(posterModel)
        
        // テキストを追加
        let textEntity = createSimpleTextEntity(text: text, width: adWidth, height: adHeight)
        posterModel.addChild(textEntity)
        
        // ポスターを壁に対して垂直に配置
        anchorEntity.addChild(adEntity)
        
        // ポスターを壁から少し前に出して配置
        adEntity.position = normalVector * positionOffsetFromWall
        
        // ポスターが壁に対して垂直になるように回転
        let wallRotation = simd_quatf(from: SIMD3<Float>(0, 0, 1), to: -normalVector)
        adEntity.orientation = wallRotation
        
        // シーンに追加
        arView.scene.addAnchor(anchorEntity)
        
        // エンティティを保存
        adEntities[anchor.identifier] = adEntity
    }
    
    // シンプルなテキスト表示方法
    private func createSimpleTextEntity(text: String, width: Float, height: Float) -> Entity {
        let textEntity = Entity()
        
        // テキストを行に分割
        let lines = text.components(separatedBy: "\n")
        let lineCount = Float(lines.count)
        
        // 各行の位置計算用
        let lineHeight = height / (lineCount + 1)
        let startY = height / 2 - lineHeight
        
        for (index, line) in lines.enumerated() {
            // iOS 15以上での実装
            // iOS 15以上での実装
            let mesh = MeshResource.generateText(
                line,
                extrusionDepth: 0.001,
                font: .systemFont(ofSize: 0.02),
                containerFrame: CGRect(
                    x: CGFloat(-width/2),
                    y: CGFloat(-lineHeight/2),
                    width: CGFloat(width),
                    height: CGFloat(lineHeight)
                ),
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
            
            let material = SimpleMaterial(color: UIColor.black, roughness: 0.0, isMetallic: false)
            let lineEntity = ModelEntity(mesh: mesh, materials: [material])
            
            // 各行の位置を設定
            let yPos = startY - (lineHeight * Float(index))
            lineEntity.position = SIMD3<Float>(0, yPos, 0.003)
            
            textEntity.addChild(lineEntity)
        }
        
        return textEntity
    }
    
    // 広告キューの管理
    private func manageAdQueue(newAdText: String, anchorID: UUID) {
        // キューに追加
        advertQueue.append((anchorID, newAdText))
        
        // 最大2件を超える場合は古いものを削除
        if advertQueue.count > 2 {
            let (oldID, _) = advertQueue.removeFirst()
            removeOldAd(id: oldID)
        }
    }
    
    // 古い広告を削除
    private func removeOldAd(id: UUID) {
        if let entity = adEntities[id] {
            entity.removeFromParent()
            adEntities.removeValue(forKey: id)
        }
    }
}
