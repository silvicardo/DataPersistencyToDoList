//
//  ViewController.swift
//  DataPersistencyToDoList
//
//  Created by riccardo silvi on 20/03/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    //array delle cose da fare, conterrà istanze del DataModel
    var arrayOggetti = [ToDoItem]()
   
    //Accediamo tramite la lazy var persistentContainer al contesto (del nostro DataModel)
    //in cui possiamo applicare modifiche
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //stampa in console percorso DataBase SQL
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //riempiamo l'arrayOggetti con il contenuto del nostro Database
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
        
        //il checkmark rifletterà lo stato della proprietà "fatto"
        cell.accessoryType = oggettoAttuale.fatto == true ? .checkmark : .none
        
        //restituiamo e mostriamo la cella
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //gestisci checkmark
        
        //se tocchiamo la cella lo stato fatto dell'istanza del model sarà uguale al contrario di se stessa
        arrayOggetti[indexPath.row].fatto = !arrayOggetti[indexPath.row].fatto
        
        //salviamo e ricarichiamo la table
        self.salvaDati()
        
        //deseleziona la cella
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let oggettoAttuale = arrayOggetti[indexPath.row]
    
        //si crea un istanza di UitableViewRowAction, si assegna uno stile,
        //si assegna un nome e si crea il codice da eseguire alla selezione del comando
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Elimina", handler: {(action, indexPath) -> Void in
            //rimuoviamo l'elemento dal context poi dall'array
            self.context.delete(oggettoAttuale)
            self.arrayOggetti.remove(at: indexPath.row)
            //rimuoviamo la cella attuale
            tableView.deleteRows(at: [indexPath], with: .fade)
            //salviamo i dati ricaricando la table
            self.salvaDati()
            })
        
        //restituiamo l'array di UITableViewRowAction da mostrare
        
        return [deleteAction]
    }
    //MARK: - IBActions
    
    @IBAction func bottoneAggiungiPremuto(_ sender: UIBarButtonItem) {
       
        //creiamo una variabile locale per acquisire la nuova Todo
        var textField = UITextField()
        
        //creiamo un UIAlertController  con un textField
        let alert = UIAlertController(title: "Aggiungi un nuovo ToDo", message: "", preferredStyle: .alert)
        //definiamo l'azione al tocco del pulsante aggiungi
        let action = UIAlertAction(title: "Aggiungi", style: .cancel){ (action) in
            //quando premeremo il bottone aggiungeremo una nuova ToDo all'array dal textField
            if let testo = textField.text {
               
                //creiamo una nuova istanza del database nel context
                //definendo ogni valore(non sono opzionali)
                let nuovoToDoItem = ToDoItem(context: self.context)
                
                nuovoToDoItem.titolo = testo
                
                nuovoToDoItem.fatto = false
                
                //Aggiungiamo all'array e salviamo
                self.arrayOggetti.append(nuovoToDoItem)
        
                self.salvaDati()
                
            }}
        //aggiungiamo un textfield all'UIAlertController
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Crea un nuovo ToDo"
            textField = alertTextField
        }
        //aggiungiamol'azione all'UIAlertController
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Metodi Gestione Dati con CoreData
    
    func salvaDati() {
        //salva le modifiche nel context
        do {
            try context.save()
        } catch  {
            print("Errore durante il salvataggio nel Context, problema: \(error)")
        }
        
        //aggiorniamo la table
        self.tableView.reloadData()
    }
    
    func caricaDati() {
        //creiamo una richiesta
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        //che produrrà un array di oggetti risultato
        //di tipo "ToDoItem"(la nostra Entity)
        do {
            //l'array delle cose da fare corrisponderà
            //al risultato di tale richiesta
            arrayOggetti =  try context.fetch(request)
        } catch  {
            print("Errore durante il caricamento, problema: \(error)")
        }
    }
}

