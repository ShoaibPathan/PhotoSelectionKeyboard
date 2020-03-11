//
//  ViewController.swift
//  PhotoSelectionKeyboard
//
//  Created by Anoop M on 2020-03-07.
//  Copyright © 2020 Anoop M. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var textFld:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(true)
        textFld.inputView = PhotoSelectionKeyboard(withAccessPermission: false)         
     }


}

