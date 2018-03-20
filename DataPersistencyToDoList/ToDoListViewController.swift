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
    var arrayOggetti = [ToDoItem]()
    //Definiamo il percorso del nostro file plist all'interno della cartella Documents nella Sanbox dell'App
    let percorsoFileDiDati = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ToDos.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //carichiamo i dati dal plist all'arrayOggetti
        caricaDati()
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
        
        cell.accessoryType = oggettoAttuale.fatto == true ? .checkmark : .none
        
        //restituiamo e mostriamo la cella
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //gestisci checkmark
        //se tocchiamo la cella lo stato fatto dell'istanza del model sarà uguale al contrario di se stessa
        arrayOggetti[indexPath.row].fatto = !arrayOggetti[indexPath.row].fatto
        //salviamo
        self.salva()
        
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
                //usando il coder salviamo nel plist il nuovo stato di arrayOggetti
                self.salva()
                //aggiorniamo la table
                self.tableView.reloadData()
            }}
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Crea un nuovo ToDo"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - CARICAMENTO/SALVATAGGIO
    
    func salva() {
        //usando il coder salviamo nel plist il nuovo stato di arrayOggetti
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.arrayOggetti)
            try data.write(to:self.percorsoFileDiDati!)
        } catch {
            print("Errore nel salvataggio")
        }
    }
    
    func caricaDati() {
        //usando il decoder estraiamo il contenuto del nostro plist e lo riversiamo in arrayOggetti
        if let data = try? Data(contentsOf: percorsoFileDiDati!){
            let decoder = PropertyListDecoder()
            do{
                arrayOggetti = try decoder.decode([ToDoItem].self, from: data)
            } catch {
                print("Errore di caricamento")
            }
        }
        
    }
}

