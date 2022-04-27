import UIKit
import AVKit

class LandingPageViewController: UIViewController {
    
    var videoPlayer: AVPlayer?
    var videoPlayerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let bundlePath = Bundle.main.path(forResource: "PullUps", ofType: "mp4")
        guard bundlePath != nil else {return}
        
        let url = URL(fileURLWithPath: bundlePath!)
        
        let item = AVPlayerItem(url: url)
        
        videoPlayer = AVPlayer(playerItem: item)
        
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height)
        
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        videoPlayer?.playImmediately(atRate: 0.3)
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.object(forKey: "login") != nil {
            
            if UserDefaults.standard.bool(forKey: "login") == true {
                let homeVC = storyboard?.instantiateViewController(identifier: Constants.Stroyboard.homeViewControllerIdentifier) as? TabBarController
                view.window?.rootViewController = homeVC
                view.window?.makeKeyAndVisible()
            }
        }
    }

}
