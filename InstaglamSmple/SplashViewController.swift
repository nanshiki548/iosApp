//
//  SplashViewController.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/07/27.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //imageView作成
        self.imageView = UIImageView(frame: CGRectMake(0, 0, 200, 200))
        //中央寄せ
        self.imageView.center = self.view.center
        //画像を設定
        self.imageView.image = UIImage(named: "IMG_2867.PNG")
        //viewに追加
        self.view.addSubview(self.imageView)
    }
    
    // CGRectMakeをwrap
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //80%まで縮小させて・・・
        UIView.animate(withDuration: 0.7,
                       delay: 1.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: { () in
                        self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { (Bool) in
            
        })
        
        //8倍まで拡大！
        UIView.animate(withDuration: 0.2,
                       delay: 1.5,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: { () in
                        self.imageView.transform = CGAffineTransform(scaleX: 8.0, y: 8.0)
                        self.imageView.alpha = 0
        }, completion: { (Bool) in
            //で、アニメーションが終わったらimageViewを消す
            self.imageView.removeFromSuperview()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
            
            let ud = UserDefaults.standard
            let isLogin = ud.bool(forKey: "isLogin")
          //  let window = UIWindow(windowScene: scene as! UIWindowScene )
            if isLogin == true {
                //ログイン中だったら
             //   self.window = window
                //self.window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
//                self.window?.rootViewController = rootViewController
//                self.window?.backgroundColor = UIColor.white
//                self.window?.makeKeyAndVisible()
                
            }else {
                //ログインしていなかったら
               // self.window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
                 UIApplication.shared.keyWindow?.rootViewController = rootViewController
//                self.window?.rootViewController = rootViewController
//                self.window?.backgroundColor = UIColor.white
//                self.window?.makeKeyAndVisible()
            }
        }
    }
}
