//
//  ChooseDifficultyViewController.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit

class ChooseDifficultyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func chooseAction(_ sender: UIButton) {
        loadPlayerVsComputerViewController(difficulty: sender.tag)
        
    }
    
    
    func loadPlayerVsComputerViewController(difficulty : Int){
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           
           guard let loadVC = storyboard.instantiateViewController(withIdentifier: "PlayerVsComputerViewController") as? PlayerVsComputerViewController else {
               return
           }
           
            loadVC.difficultyLevel = difficulty
           
           self.navigationController!.pushViewController(loadVC, animated: true)
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
