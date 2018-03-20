//
//  ViewController.swift
//  DataPersistencyToDoList
//
//  Created by riccardo silvi on 20/03/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    
    //array delle cose da fare
    let arrayOggetti = ["Compra cialde","Ricarica Telefono", "Trova telecomando"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - Metodi della tableView
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //tante righe quante le istanze nell'array
        return arrayOggetti.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //definiamo la cella
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        //il titolo sarà la stringa nell'array all'indice attuale
        cell.textLabel?.text = arrayOggetti[indexPath.row]
        //restituiamo e mostriamo la cella
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //gestisci checkmark
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        //deseleziona la cella
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
    }
   
}

