//
//  ViewController.swift
//  SwiftNetworkProject
//
//  Created by 이유리 on 2023/07/20.
//

import UIKit

class ViewController: UIViewController {
    lazy var networkManager = NetworkManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func getButtonTapped(_ sender: UIButton) {
        let urlString = "http://dummy.restapiexample.com/api/v1/employees"
        
        networkManager.requestGetMethod(with: urlString) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let secondVC = self?.storyboard?.instantiateViewController(withIdentifier: "secondVC") as! SecondViewController
                    secondVC.str = (data.data ?? []).description
                    self?.present(secondVC, animated: true)
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        
        let urlString = "http://dummy.restapiexample.com/api/v1/employees"
        let uploadData = UploadData(name: "yuri", salary: "4000", age: "25")
        
        networkManager.postRequest(with: urlString, postBody: uploadData) { result in
            switch result {
            case .success(let isSuccess):
                print(isSuccess)
            case .failure(let error):
                print(error)
            }
        }
    }
}

