//
//  ContainerView.swift
//  IBPageView
//
//  Created by Иван Викторович on 15.03.2020.
//  Copyright © 2020 BosaIT. All rights reserved.
//

import UIKit

internal class ContainerView: UIView {
    
    typealias ResultClosure = (()->Void)
    
    internal var cornerRadius: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func zoom(value: CGFloat, duration: CGFloat, completion: ResultClosure?) {
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            self.layer.cornerRadius = self.cornerRadius
            self.transform = CGAffineTransform(scaleX: value, y: value)
            self.frame.origin.y += 30
        }) { (bool) in
            guard let completon = completion else {return}
            completon()
        }
    }
    
    func moveOnValue(valueX: CGFloat, duration: CGFloat, completion: ResultClosure?) {
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            self.frame.origin.x += valueX
        }) { (bool) in
            guard let completion = completion else {return}
            completion()
        }
    }
    
    func removeZoom(animated: Bool, duration: CGFloat?) {
        if animated {
            UIView.animate(withDuration: TimeInterval(duration ?? 0.5)) {
                self.transform = CGAffineTransform.identity
                self.layer.cornerRadius = 0
                UIView.animate(withDuration: TimeInterval(duration ?? 0.5)) {
                    self.frame.origin.y = 0
                }
            }
        } else {
            self.transform = CGAffineTransform.identity
            self.layer.cornerRadius = 0
            self.frame.origin.y = 0
        }
    }
}
