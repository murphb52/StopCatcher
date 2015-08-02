//
//  SCConfirmStopViewController.swift
//  Stop Catcher
//
//  Created by Brian Murphy on 02/08/2015.
//  Copyright (c) 2015 Stop Catcher. All rights reserved.
//

import UIKit

class SCConfirmStopViewController: SCViewController {

    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        self.confirmButton.addTarget(self, action: Selector("didTapConfirmButton"), forControlEvents:UIControlEvents.TouchUpInside)
    }
    
    func didTapConfirmButton()
    {
    }


}
