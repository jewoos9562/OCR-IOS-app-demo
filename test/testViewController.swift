
import UIKit
import AVFoundation
import Vision



class testViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()

    private var isTapped = false
    
    
    lazy var item : UINavigationItem = {
        let item = UINavigationItem()
        
        item.setRightBarButton(UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(doScan(sender:))), animated: false)
        
        return item
    }()
    
    private var maskLayer = CAShapeLayer()
    private var guideLayer = CAShapeLayer()
    private var recognitionTimer: Timer?
    private var recognizedObservation: VNRectangleObservation?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setCameraInput()
        self.showCameraFeed()
        self.setCameraOutput()

        // 가이드 사각형 그리기
        drawGuideRect()
        
        // Scan 버튼 추가
        let scanButton = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(doScan(sender:)))
        navigationItem.rightBarButtonItem = scanButton
    }
    
    override func viewDidAppear(_ animated: Bool) {

        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.videoDataOutput.setSampleBufferDelegate(nil, queue: nil)
        self.captureSession.stopRunning()
    }
    
    func doPerspectiveCorrection(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) {
        var ciImage = CIImage(cvImageBuffer: buffer)

        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)

        // pass those to the filter to extract/rectify the image
        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight),
        ])

        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let correctedImage = UIImage(cgImage: cgImage!)
        
        let testShowVC = testShowController()
        testShowVC.correctedImage = correctedImage
        self.navigationController?.pushViewController(testShowVC, animated: true)
        
    }
    
    @objc func doScan(sender: UIButton!){
        self.isTapped = true
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        
        self.detectRectangle(in: frame)
    }
    
    private func setCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .back).devices.first else {
                fatalError("No back camera device found.")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    private func showCameraFeed() {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.frame
    }
    
    private func setCameraOutput() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        
        connection.videoOrientation = .portrait
    }
    
    private func detectRectangle(in image: CVPixelBuffer) {

        let request = VNDetectRectanglesRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                
                guard let results = request.results as? [VNRectangleObservation] else { return }
                self.removeMask()
                
                guard let rect = results.first else{return}
                    self.drawBoundingBox(rect: rect)
                
                    if self.isTapped{
                        self.isTapped = false
                        self.doPerspectiveCorrection(rect, from: image)
                    }
            }
        })
        
        request.minimumAspectRatio = VNAspectRatio(1.3)
        request.maximumAspectRatio = VNAspectRatio(1.6)
        request.minimumSize = Float(0.5)
        request.maximumObservations = 1

        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? imageRequestHandler.perform([request])
    }
    
    func drawBoundingBox(rect : VNRectangleObservation) {
    
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.previewLayer.frame.height)
        let scale = CGAffineTransform.identity.scaledBy(x: self.previewLayer.frame.width, y: self.previewLayer.frame.height)

        let bounds = rect.boundingBox.applying(scale).applying(transform)
        createLayer(in: bounds)

    }

    private func createLayer(in rect: CGRect) {

        maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.cornerRadius = 10
        maskLayer.opacity = 0.75
        maskLayer.borderColor = UIColor.red.cgColor
        maskLayer.borderWidth = 5.0
        
        previewLayer.insertSublayer(maskLayer, at: 1)

    }
    
    func removeMask() {
            maskLayer.removeFromSuperlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateGuideRect()
    }
    
    private func drawGuideRect() {
        let guideRect = CGRect(x: 50, y: 50, width: view.frame.width - 100, height: view.frame.height - 100)
        let guidePath = UIBezierPath(rect: guideRect)
        
        guideLayer.path = guidePath.cgPath
        guideLayer.strokeColor = UIColor.green.cgColor
        guideLayer.lineWidth = 2.0
        guideLayer.fillColor = UIColor.clear.cgColor
        guideLayer.opacity = 0.7
        
        view.layer.addSublayer(guideLayer)
    }
    
    
    private func updateGuideRect() {
        let guideRect = CGRect(x: (view.bounds.width - 300)/2, y: (view.bounds.height - 190) / 2, width: 300, height: 190)
        let guidePath = UIBezierPath(rect: guideRect)
        
        guideLayer.path = guidePath.cgPath
    }
    
}

extension CGPoint {
   func scaled(to size: CGSize) -> CGPoint {
       return CGPoint(x: self.x * size.width,
                      y: self.y * size.height)
   }
}

