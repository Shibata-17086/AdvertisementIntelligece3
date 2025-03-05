import SwiftUI
import ARKit
import RealityKit
import AVFoundation
import Vision

// 1. アプリエントリポイント
@main
struct AdvertisementIntelligenceApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}

// 2. スプラッシュ画面
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

// 3. メインコンテンツビュー
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

// 4. AR表示ビュー
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

// 5. キャプチャービュー
struct CaptureView: View {
    @StateObject private var captureViewModel = CaptureViewModel()
    @State private var showingImagePreview = false
    @State private var capturedImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            // カメラプレビュー
            CameraPreviewView(captureSession: captureViewModel.captureSession)
                .edgesIgnoringSafeArea(.all)
            
            // オーバーレイコントロール
            VStack {
                // ヘッダー情報
                HStack {
                    Text("画像キャプチャー")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.4))
                        )
                    
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                Spacer()
                
                // ステータス表示
                if let statusMessage = captureViewModel.statusMessage {
                    Text(statusMessage)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Material.ultraThinMaterial)
                        )
                        .padding()
                }
                
                // キャプチャーボタン
                Button(action: {
                    captureViewModel.captureImage { image in
                        if let image = image {
                            self.capturedImage = image
                            self.showingImagePreview = true
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 4)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                    }
                }
                .padding(.bottom, 40)
                .sheet(isPresented: $showingImagePreview) {
                    if let image = capturedImage {
                        ImageAnalysisView(image: image)
                    }
                }
            }
        }
        .onAppear {
            captureViewModel.checkPermissionsAndSetupSession()
        }
        .onDisappear {
            captureViewModel.stopSession()
        }
    }
}

// カメラプレビュー表示
struct CameraPreviewView: UIViewRepresentable {
    let captureSession: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = MyCustomView(frame: .zero)
        view.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        return view
    }

    class MyCustomView: UIView {
        override func layoutSubviews() {
            super.layoutSubviews()
            // プレビューレイヤーのサイズを更新
            if let previewLayer = self.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
                previewLayer.frame = self.bounds
            }
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// キャプチャービューモデル
class CaptureViewModel: NSObject, ObservableObject {
    @Published var statusMessage: String? = nil
    
    let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var completionHandler: ((UIImage?) -> Void)? = nil
    
    func checkPermissionsAndSetupSession() {
        // カメラ権限チェック
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    self.setStatus("カメラへのアクセスが拒否されました")
                }
            }
        case .denied, .restricted:
            self.setStatus("カメラへのアクセスが拒否されています。設定から権限を変更してください。")
        @unknown default:
            self.setStatus("カメラの権限状態が不明です")
        }
    }
    
    private func setupCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.beginConfiguration()
            
            // 入力の設定
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                self.setStatus("カメラの初期化に失敗しました")
                return
            }
            
            if self.captureSession.canAddInput(videoInput) {
                self.captureSession.addInput(videoInput)
            }
            
            // 出力の設定
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
            }
            
            self.captureSession.commitConfiguration()
            
            // セッション開始
            self.captureSession.startRunning()
            self.setStatus("カメラの準備ができました")
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func captureImage(completion: @escaping (UIImage?) -> Void) {
        guard captureSession.isRunning else {
            setStatus("カメラセッションが実行されていません")
            completion(nil)
            return
        }
        
        self.completionHandler = completion
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        setStatus("画像をキャプチャしています...")
    }
    
    private func setStatus(_ message: String) {
        DispatchQueue.main.async {
            self.statusMessage = message
        }
    }
}

// 写真キャプチャの処理
extension CaptureViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            setStatus("エラー: \(error.localizedDescription)")
            completionHandler?(nil)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            setStatus("画像の処理に失敗しました")
            completionHandler?(nil)
            return
        }
        
        setStatus("画像をキャプチャしました")
        completionHandler?(image)
    }
}

// キャプチャした画像の解析ビュー
struct ImageAnalysisView: View {
    let image: UIImage
    @State private var analysisResults: [String] = []
    @State private var isAnalyzing = true
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)
                
                VStack {
                    // 画像表示
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .padding()
                        .shadow(color: Color.blue.opacity(0.5), radius: 20, x: 0, y: 0)
                    
                    // 解析結果
                    VStack(alignment: .leading, spacing: 16) {
                        Text("画像解析結果")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        if isAnalyzing {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                
                                Text("解析中...")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(analysisResults, id: \.self) { result in
                                    Text(result)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 4)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Material.ultraThinMaterial)
                    )
                    .padding()
                    
                    // アクションボタン
                    HStack(spacing: 20) {
                        // 閉じるボタン
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("閉じる")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.3))
                            )
                        }
                        
                        // AR表示ボタン
                        Button(action: {
                            // AR表示への遷移（実際の実装では適切な画面遷移を行う）
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arkit")
                                Text("ARで表示")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.3))
                            )
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitle("画像解析", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.white)
            })
            .onAppear {
                // 画像解析を実行（実際にはCloud Vision APIに送信）
                analyzeImage()
            }
        }
    }
    
    private func analyzeImage() {
        // ここではダミーの解析を行う（実際はGoogle Cloud Vision APIを使用）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // サンプルの解析結果
            self.analysisResults = [
                "オブジェクト: スマートフォン (95%)",
                "オブジェクト: テーブル (87%)",
                "シーン: 室内 (92%)",
                "色調: 明るい (78%)",
                "テキスト検出: なし"
            ]
            self.isAnalyzing = false
        }
    }
}

// 6. 設定ビュー
struct SettingsView: View {
    @State private var apiKey: String = ""
    @State private var enableAutoRefresh = true
    @State private var refreshInterval = 4.0
    @State private var maxAdsCount = 2
    @State private var showDebugInfo = false
    @State private var preferredTheme = 0
    @State private var isLoading = false
    
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
        // ここではアニメーションのためだけに遅延を入れている
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // UserDefaultsに保存する実装をここに追加
            UserDefaults.standard.set(self.apiKey, forKey: "visionApiKey")
            UserDefaults.standard.set(self.enableAutoRefresh, forKey: "enableAutoRefresh")
            UserDefaults.standard.set(self.refreshInterval, forKey: "refreshInterval")
            UserDefaults.standard.set(self.maxAdsCount, forKey: "maxAdsCount")
            UserDefaults.standard.set(self.showDebugInfo, forKey: "showDebugInfo")
            UserDefaults.standard.set(self.preferredTheme, forKey: "preferredTheme")
            
            self.isLoading = false
            
            // 保存完了メッセージなどを表示
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
    }
}

// セクションヘッダーコンポーネント
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.blue)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
            
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}
