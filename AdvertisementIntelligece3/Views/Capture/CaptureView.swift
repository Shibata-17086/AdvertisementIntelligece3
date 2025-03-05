import SwiftUICore
import AVFoundation
import SwiftUI
import UIKit

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
