//
//  ViewController.swift
//  DataPersistencyToDoList
//
//  Created by riccardo silvi on 20/03/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    /*VERSIONE NON FUNZIONANTE CON USER DEFAULTS CHE
    NON ACCETTA OGGETTI MA SOLO I DATATYPES BASICI,
    DA ESEGUIRE A PURO SCOPO DIMOSTRATIVO DELL'ERRORE*/
    
    //array delle cose da fare
    var arrayOggetti = [ToDoItem]()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //carichiamo il nostro plist, se esiste
        if let arraySalvato = defaults.array(forKey: "ToDoListArray") as? [ToDoItem] {
            arrayOggetti = arraySalvato
        }
    }
    
    //MARK: - Metodi della tableView
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //tante righe quante le istanze nell'array
        return arrayOggetti.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //definiamo la cella
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let oggettoAttuale = arrayOggetti[indexPath.row]
        //il titolo sarà la stringa nell'array all'indice attuale
        cell.textLabel?.text = oggettoAttuale.titolo
        //ad ogni aggiornamento della table il checkmark rispecchierà lo stato della proprietà "fatto"
        cell.accessoryType = oggettoAttuale.fatto == true ? .checkmark : .none
        
        //restituiamo e mostriamo la cella
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //gestisci checkmark
        //se tocchiamo la cella lo stato fatto dell'istanza del model sarà uguale al contrario di se stessa
        arrayOggetti[indexPath.row].fatto = !arrayOggetti[indexPath.row].fatto
        
        tableView.reloadData()
        //deseleziona la cella
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
   
    //MARK: - IBActions
    
    @IBAction func bottoneAggiungiPremuto(_ sender: UIBarButtonItem) {
        //creiamo una variabile locale per acquisire la nuova Todo
        var textField = UITextField()
        //creiamo l'alert con un textField
        let alert = UIAlertController(title: "Aggiungi un nuovo ToDo", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Aggiungi", style: .cancel){ (action) in
            //quando premeremo il bottone aggiungeremo una nuova ToDo all'array dal textField
            if let testo = textField.text {
                //creiamo un nuovo oggetto
                let nuovoToDo = ToDoItem()
                nuovoToDo.titolo = testo
                //e lo aggiungiamo all'array
                self.arrayOggetti.append(nuovoToDo)
                self.defaults.setValue(self.arrayOggetti, forKey: "ToDoListArray")
                self.tableView.reloadData()//aggiornando la table
            }}
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Crea un nuovo ToDo"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
}

