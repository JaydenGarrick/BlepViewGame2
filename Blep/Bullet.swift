//
//  Bullet.swift
//  Blep
//
//  Created by Jayden Garrick on 9/5/18.
//  Copyright © 2018 Jayden Garrick. All rights reserved.
//

import UIKit

struct Bullet: Equatable {
    let id: String
    let view: UIView
    
    init(view: UIView, id: String = UUID().uuidString) {
        self.view = view
        self.id = id
    }
}

