//
//  ViewController.swift
//  NavigationDrawer
//
//  Created by siva prasad on 14/07/18.
//  Copyright © 2018 SIVA PRASAD. All rights reserved.
//

import UIKit

class ViewController: NavigationDrawerController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sideMenu = self.storyboard!.instantiateViewController(withIdentifier: "navigationDrawer")
        super.roundCorners = false
        super.animateStatusBar = false
        super.rootViewAnimation = .none
        super.rootViewBackgroundColor = .red
        super.menuPosition = .front
        super.setNavigationDrawer(ViewController: sideMenu)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func openMenu(_ sender: UIButton) {
        super.openMenu()
    }
}

