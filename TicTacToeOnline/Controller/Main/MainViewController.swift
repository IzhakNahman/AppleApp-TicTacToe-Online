//
//  MainViewController.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainViewController: UIViewController {

    @IBOutlet weak var greetingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showGreeting()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
          do {
              try Auth.auth().signOut()
              FlowController.shared.determineRoot()
          } catch {
              print(error)
          }
      }
    
    private func showGreeting() {
        //obtain user's display name
        guard let nickname = Auth.auth().currentUser?.displayName else {
            return
        }
        
        //show it on navigation item
        greetingLabel.text = "Hello " + nickname
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
