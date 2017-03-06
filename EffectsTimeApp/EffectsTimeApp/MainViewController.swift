//
//  MainViewController.swift
//  EffectsTimeApp
//
//  Created by Ivan Slobodiuk
//  Copyright © 2017 sLab. All rights reserved.
//

import UIKit
import GLKit
import AVFoundation

class MainViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: Class members
    
    /* Class members
     * ------------------------------------------- */
    
    @IBOutlet weak var viewOriginal         : UIImageView!
    @IBOutlet weak var viewOpenCV           : UIImageView!
    @IBOutlet weak var viewOpenGL           : GLViewer!
    @IBOutlet weak var recordButton         : UIButton!
    @IBOutlet weak var flipSwitch           : UISwitch!
    @IBOutlet weak var invertcolorSwitch    : UISwitch!
    @IBOutlet weak var switch_viewOriginal  : UISwitch!
    @IBOutlet weak var switch_viewOpenCV    : UISwitch!
    @IBOutlet weak var switch_viewOpenGL    : UISwitch!
    @IBOutlet weak var permissionDialog     : UIView!

    
    /* ------------------------------------------- */
    
    private var av_captureSession           : AVCaptureSession?
    private var av_captureInputDevice       : AVCaptureDeviceInput?
    private var av_captureVideoDataOutput   : AVCaptureVideoDataOutput?
    
    /* ------------------------------------------- */
    
    private let queue_session   = DispatchQueue(label: "queue.effectstime.session", attributes: [], target: nil)
    
    private var state_recording                 : Bool = false
    private var state_permissionGranted         : Bool = false
    private var state_videoSessionConfigured    : Bool = false
    
    private var config_effects                  : UInt8 = 0
    
    private var config_currentOrientation       : UIInterfaceOrientation = .portrait
    
    /* ------------------------------------------- */
    /* ------------------------------------------- */
    
    // MARK: Configuration Methods
    
    /* Configuration methods
     * ------------------------------------------- */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config_currentOrientation = UIApplication.shared.statusBarOrientation
        config_effects = Effects.flipX.rawValue | Effects.invertColor.rawValue
        self.enableUI( false )
        
        checkCameraPermission()
        
        clearScreens()

        queue_session.async {
            if self.configureVideoSession() {
                self.enableUI( true )
            }
        }
        
       startNotifications()
    }
    
    /* ------------------------------------------- */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /* ------------------------------------------- */
    
    func startNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
                                               object: nil)
    }
    
    /* ------------------------------------------- */
    
    func stopNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.UIDeviceOrientationDidChange,
                                                  object: nil);
    }

    /* ------------------------------------------- */
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            self.state_permissionGranted = true
            break
            
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
                self.state_permissionGranted = granted
                self.enableUI( granted )
            })
            break
            
        default:
            // indetermined
            self.state_permissionGranted = false
            break;
        }
        
        self.enableUI( self.state_permissionGranted )
        
    }
    
    /* ------------------------------------------- */
    
    func configureVideoSession() -> (Bool){
        if !state_permissionGranted {
            return false
        }
        
        if state_videoSessionConfigured {
            return true
        }
        
        av_captureSession = AVCaptureSession()
        av_captureSession!.beginConfiguration()
        
        /*
         * Available Session Presets:
             - AVCaptureSessionPreset352x288     11:9
             - AVCaptureSessionPreset640x480      4:3
             - AVCaptureSessionPreset1280x720    16:9
             - AVCaptureSessionPreset1920x1080   16:9
             - AVCaptureSessionPreset3840x2160   16:9
         */
        av_captureSession!.sessionPreset = AVCaptureSessionPreset1280x720;
        
        // This could be the front camera too
        let videoCamera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        
        do {
            let inputDevice = try AVCaptureDeviceInput.init(device: videoCamera!)
            if av_captureSession!.canAddInput(inputDevice) {
                av_captureSession!.addInput(inputDevice)
            }
        } catch {
            print("Error - Input Device")
            return false
        }
        
        av_captureVideoDataOutput = AVCaptureVideoDataOutput.init()
        if av_captureVideoDataOutput == nil {
            print("Error - Vide Data Output")
            return false
        }
        
        if av_captureSession!.canAddOutput(av_captureVideoDataOutput) {
            av_captureSession!.addOutput(av_captureVideoDataOutput)
        }
        
        /*
         * It's better to drop the last frames than lagging everything
         * Different would be the case if we were recording.
         */
        av_captureVideoDataOutput!.alwaysDiscardsLateVideoFrames = true
        
        /* 
         * After a frame is captured, the sample buffer will be sent to the delegate
         * calling the function 
         *      captureOutput(.. didOutputSampleBuffer .. from )
         */
        let queue = DispatchQueue(label: "video_output")
        av_captureVideoDataOutput!.setSampleBufferDelegate(self, queue: queue)
        
        // Set the capture orientation to portrait
        let connection = av_captureVideoDataOutput!.connection(withMediaType: AVMediaTypeVideo)
        connection!.videoOrientation = AVCaptureVideoOrientation.portrait
        
        // Pixel Format
        let videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey) : kCVPixelFormatType_32BGRA ]
        av_captureVideoDataOutput!.videoSettings = videoSettings
        
        av_captureSession!.commitConfiguration()
        state_videoSessionConfigured = true
        return true
    }
    
    /* ------------------------------------------- */
    
    func setRecording(_ record : Bool ) {
        if record {
            if configureVideoSession() {
                av_captureSession!.startRunning()
            }
        } else {
            if av_captureSession != nil {
                av_captureSession!.stopRunning()
            }
            clearScreens()
        }
        state_recording = record
        /* Using the isSelected property to 'toggle' between recording and not-recording 
         * status, simulating a toggle button */
        recordButton.isSelected = record
    }
    
    // MARK: UI Actions
    
    /* UI Actions
     * ------------------------------------------- */
    
    @IBAction func button_recordPressed(_ sender: Any) {
        setRecording( !state_recording )
    }
    
    /* ------------------------------------------- */
    
    @IBAction func switch_flipChanged(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            config_effects = config_effects | Effects.flipX.rawValue
        } else {
            config_effects = config_effects & ~Effects.flipX.rawValue
        }
    }
    
    /* ------------------------------------------- */
    
    @IBAction func switch_invertColorChanged(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            config_effects = config_effects | Effects.invertColor.rawValue
        } else {
            config_effects = config_effects & ~Effects.invertColor.rawValue
        }
    }
    
    /* ------------------------------------------- */
    
    func enableUI(_ enable: Bool ) {
        DispatchQueue.main.async {
            self.recordButton.isEnabled         = enable
            self.flipSwitch.isEnabled           = enable
            self.invertcolorSwitch.isEnabled    = enable
            self.switch_viewOpenCV.isEnabled    = enable
            self.switch_viewOpenGL.isEnabled    = enable
            self.switch_viewOriginal.isEnabled  = enable
            self.permissionDialog.isHidden      = enable
        }
    }
    
    /* ------------------------------------------- */
    
    func clearScreens() {
        DispatchQueue.main.async {
            self.viewOpenGL.clearScreen()
            self.viewOpenCV.image = nil
            self.viewOriginal.image = nil
        }
    }
    
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    
    /* captureOutput - new frame arrived
     * ------------------------------------------- */
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        /*
         * A frame has been captured and it can be processed here
         */
        
        let pixelBuffer: CVPixelBuffer! = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        // OpenGL
        if switch_viewOpenGL.isOn {
            viewOpenGL.processAndPresentFrame(pixelBuffer, apply: config_effects)
        } else {
            viewOpenGL.clearScreen()
        }
        
        // OpenCV
        if switch_viewOpenCV.isOn {
            OpenCVWrapper.processAndPresentFrame(sampleBuffer, in: viewOpenCV, apply: config_effects)
        } else if viewOpenCV.image != nil {
            DispatchQueue.main.async {
                self.viewOpenCV.image = nil
            }
        }
        
        // Display Original
        if switch_viewOriginal.isOn {
            let image = Helper.sampleBufferToUIImage(sampleBuffer: sampleBuffer)
            DispatchQueue.main.async {
                self.viewOriginal.image = image
            }
        } else if viewOriginal.image != nil {
            DispatchQueue.main.async {
                self.viewOriginal.image = nil
            }
        }
    }
    
    /* ------------------------------------------- */
    
    func orientationChanged(){
        let orientation = UIApplication.shared.statusBarOrientation
        if config_currentOrientation != orientation {
            config_currentOrientation = orientation
            
            if av_captureSession == nil {
                return
            }
            queue_session.async {
                self.av_captureSession!.beginConfiguration()
                
                let connection = self.av_captureVideoDataOutput!.connection(withMediaType: AVMediaTypeVideo)
                connection!.videoOrientation = orientation.videoOrientation!
                
                self.av_captureSession!.commitConfiguration()
            }
            
        }
    }
}




/* Make easy some convertions
 ------------------------------------------- */

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return nil
        }
    }
}
