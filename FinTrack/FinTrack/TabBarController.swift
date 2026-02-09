//
//  TabBarController.swift
//  FinTrack
//
//  Created by Ihor Melashchenko on 9/4/21.
//

import UIKit

class TabBarController: UITabBarController { // DELETE THIS FILE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // launch Home tab by default (not the Stats tab)
        self.selectedIndex = 0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
