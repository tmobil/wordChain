//
//  ViewController.swift
//  WordChainTM
//
//  Created by Harikrishna Thammepalli 
//  Copyright © 2018 Harikrishna Thammepalli. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell{
    @IBOutlet weak var titleLbl : UILabel?
    @IBOutlet weak var descriptionLbl : UILabel?
}
class ViewController: UIViewController {
    
    @IBOutlet weak var firstwordTxt : UITextField?
    @IBOutlet weak var secondwordTxt : UITextField?
    @IBOutlet weak var tblView : UITableView?
    var resultjson = [(String, AnyObject)]()
    var jsondict : [String : AnyObject] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = false
        parseDatafromJSONFile { (isparsed) in
            if isparsed{
                print("Parsing done \(jsondict.keys.count)")
            }
            self.view.isUserInteractionEnabled = true
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    func parseDatafromJSONFile(oncompletion: (Bool) -> Void){
        if let path = Bundle.main.path(forResource: "english", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String : AnyObject] {
                    jsondict = jsonResult
                    oncompletion(true)
                    // do stuff
                }
            } catch {
                // handle error
                oncompletion(false)
            }
        }
    }
    @IBAction func showResult(){
        self.view.resignFirstResponder()
        guard let firstword = firstwordTxt?.text, !firstword.isEmpty else {
            self.showAlert(withTitle: "Warning", message: "Please enter first word")
            return
        }
        guard let secondword = secondwordTxt?.text, !secondword.isEmpty else {
            self.showAlert(withTitle: "Warning", message: "Please enter second word")
            return
        }
        var allkeys = [String : AnyObject]()
        if let firstDesc = jsondict[firstword] as? [String]{
            allkeys[firstword] = firstDesc as AnyObject
        }
        if let secondDesc = jsondict[secondword] as? [String]{
            allkeys[secondword] = secondDesc as AnyObject
        }
        _ = Array(firstword).enumerated().map { (firstWordIndex,firstWordElement) -> Void in
            _ = Array(secondword).enumerated().map({ (secondWordIndex,secondWordElement) -> Void in
                var wordone = firstword
                var wordtwo = secondword
                if Array(wordone).indices.contains(secondWordIndex){
                    let index = wordone.index(wordone.startIndex, offsetBy: secondWordIndex)
                    wordone.replaceSubrange(index...index, with: secondWordElement.description)
                    if let result = jsondict[wordone] as? [String]{
                        allkeys[wordone] = result as AnyObject
                    }
                }
                if Array(wordtwo).indices.contains(firstWordIndex){
                    let index = wordone.index(wordone.startIndex, offsetBy: secondWordIndex)
                    wordtwo.replaceSubrange(index...index, with: firstWordElement.description)
                    if let result = jsondict[wordtwo] as? [String]{
                        allkeys[wordtwo] = result as AnyObject
                    }
                }
            })
        }
        resultjson.removeAll()
        resultjson = allkeys.sorted(by: { $0.0 < $1.0 })
        tblView?.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension ViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultjson.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifer = "cell"
        let cell : CustomCell = tableView.dequeueReusableCell(withIdentifier: identifer, for: indexPath) as! CustomCell
        let obj = resultjson[indexPath.row]
        cell.titleLbl?.text = obj.0
        var description = ""
        if let descriptionlist = obj.1 as? [String]{
            _ = descriptionlist.map({ (desc) -> Void in
                description = description +
                    "-> " + desc + "\n"
            })
            cell.descriptionLbl?.text = description
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
extension UIViewController {
    
    func showAlert(withTitle title: String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

