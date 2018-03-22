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
    
    //var ponte dal CategorieViewController(opzionale)
    var categoriaSelezionata : Categoria? {
        //con didSet definiamo l'azione alla creazione della var
        didSet {
            //riempiamo l'arrayOggetti con il contenuto del nostro Database
            caricaDati()
        }
    }
    //Accediamo tramite la lazy var persistentContainer al contesto (del nostro DataModel)
    //in cui possiamo applicare modifiche
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //stampa in console percorso DataBase SQL
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
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
                
                nuovoToDoItem.categoriaMadre = self.categoriaSelezionata
                
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
    
    ///è ora possibile aggiungere un predicato extra per rendere la funzione utilizzabile
    ///sia per il classico caricamento dati che per l'utilizzo della searchBar
    ///ora che abbiamo introdotto un sistema di Categorie
    func caricaDati(con request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        
        //appartenendo ora ad una categoria aggiungiamo un filtro.
        //Restituiamo gli oggetti dell'array il cui nome della categoria madre
        //corrisponde al nome della categoria in ingresso
        let predicatoCategoria = NSPredicate(format: "categoriaMadre.nome MATCHES[cd] %@", categoriaSelezionata!.nome!)
        
        //con optionalBinding
        //se il predicato input ha un valore
        if let predicatoAggiuntivo = predicate {
            //il predicato finale sarà uguale a  un oggetto definito da un insieme di predicati
            //di cui uno sarà il predicato categoria e l'altro il predicato input opzionale
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicatoCategoria, predicatoAggiuntivo])
        } else {//altrimenti se nil
            //il predicato finale sarà uguale al solo predicatoCategoria
            request.predicate = predicatoCategoria
        }
        
        //data la fetchRequest di default o dell'utente
        //produrrà un array di oggetti risultato
        //di tipo "ToDoItem"(la nostra Entity)
        do {
            //l'array delle cose da fare corrisponderà
            //al risultato di tale richiesta
            arrayOggetti =  try context.fetch(request)
        } catch  {
            print("Errore durante il caricamento, problema: \(error)")
        }
        //aggiorniamo la table
        self.tableView.reloadData()
    }
    
}

//MARK: - Metodi SearchBar

extension ToDoListViewController: UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            //mettiamo giù la tastiera attiva per l'editing della searchBar
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            caricaDati()
            DispatchQueue.main.async {
                //mettiamo giù la tastiera attiva per l'editing della searchBar
                searchBar.resignFirstResponder()
            }
        } else {
            //definiamo una richiesta di ricerca che restituisca istanze di ToDoItem
            let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            //definiamo il metro secondo cui saranno restituiti dei risultati
            //il predicato controllerà se per ogni istanza della nostra Entity
            //la proprietà titolo conterrà il valore che l'utente ha digitato nella searchBar
            request.predicate = NSPredicate(format: "titolo CONTAINS[cd] %@", searchBar.text!)
            //i dati resitituiti vengono ordinati alfabeticamente (ascendente)
            request.sortDescriptors = [NSSortDescriptor(key: "titolo", ascending: true)]
            //effettuiamo la ricerca da noi settata
            caricaDati(con: request)
        }
    }
    
    
    
}
