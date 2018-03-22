//
//  CategorieViewController.swift
//  DataPersistencyToDoList
//
//  Created by riccardo silvi on 21/03/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import CoreData

class CategorieViewController: UITableViewController {
    
    //array di Categorie
    
    var arrayCategorie = [Categoria]()
    
    //contesto
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        caricaDati()
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Una sezione
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Restituisci il numero di Categorie nell'array
        return arrayCategorie.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // definiamo la cella
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriaCell", for: indexPath)
        // textLabel della cella uguale al nome della categoria
        cell.textLabel?.text = arrayCategorie[indexPath.row].nome
        
        //restituiamo la cella
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //segue al "ToDoListViewController"
        performSegue(withIdentifier: "goToItems", sender: nil)
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //dato la Categoria all'indice tot dell'array
        let categoriaSelezionata = arrayCategorie[indexPath.row]
        
        //creiamo un azione Cancella
        let cancella = UITableViewRowAction(style: .destructive, title: "Cancella") { (action, indexPath) in
            //rimuoviamo la Categoria dal contesto
            self.context.delete(categoriaSelezionata)
            //rimuoviamo la Categoria dall'arrayCategorie
            self.arrayCategorie.remove(at: indexPath.row)
            //rimuoviamo la riga dalla table
            tableView.deleteRows(at: [indexPath], with: .fade)
            //applichiamo i cambiamenti ricaricando la table
            self.salvaDati()
        }
        
        //restituiamo l'array di UITableViewRowAction
        return [cancella]
    }
    
    @IBAction func bottoneAggiungiCategoriaPremuto(_ sender: UIBarButtonItem) {
        
        //var ponte per il TextField dell'Alert da costituire
        var testo = UITextField()
        //creiamo una nuovo UIAlertController
        let alertAggiungi = UIAlertController(title: "Aggiungi", message: "Nuova Categoria", preferredStyle: .alert)
        //creiamo un azione per l'UIAlertController
        let aggiungi = UIAlertAction(title: "OK", style: .default) { (action) in
            //creiamo una nuova istanza dell'Entity "Categoria"
            let nuovaCategoria = Categoria(context: self.context)
            //riempiamo la proprietà nome con il contenuto del TextField
            nuovaCategoria.nome = testo.text
            //aggiungiamo la nuovaIstanza all'array
            self.arrayCategorie.append(nuovaCategoria)
            //applichiamo i cambiamenti ricaricando la table
            self.salvaDati()
        }
        //aggiungiamo l'action appena definita
        alertAggiungi.addAction(aggiungi)
        //aggiungiamo un textField..
        alertAggiungi.addTextField { (campoTesto) in
            campoTesto.placeholder = "Digita nuova categoria"
            //..che passa il suo contenuto alla var ponte
            testo = campoTesto
            
        }
        //mostriamo l'UIAlertController
        self.present(alertAggiungi, animated: true, completion: nil)
    }
    
    
    //MARK: - Metodi Gestione Dati con CoreData
    
    func salvaDati(){
        
        do {//salviamo le modifiche attuali nel contesto
            try context.save()
        } catch  {
            //altrimenti segnaliamo e mostriamo la ragione dell'errore
            print("Errore durante il salvataggio, Errore: \(error)")
        }
        //ricarichiamo la table
        self.tableView.reloadData()
    }
    
    //creiamo la func con fetchRequest default per la nostra Entity "Categoria"
    func caricaDati(con request: NSFetchRequest<Categoria> = Categoria.fetchRequest()){
        
        //l'arrayCategoria sarà uguale al risultato della fetchRequest immessa nel context
        do {
            try self.arrayCategorie = context.fetch(request)
        } catch  {
            //altrimenti segnaliamo e mostriamo la ragione dell'errore
            print("Errore durante il caricamento, Errore: \(error)")
        }
        //ricarichiamo la table
        self.tableView.reloadData()
    }
    
    
    //MARK: - Navigazione
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //se il segue chiamato è "goToItems"
        if segue.identifier == "goToItems" {
            //il controller di destinazione sarà ToDoListViewController
            let destination = segue.destination as! ToDoListViewController
            //se l'indice per la cella toccata ha valore
            if let indexPath = tableView.indexPathForSelectedRow {
                //riempiamo la var ponte in categoria selezionata
                //con la categoria nell'array all'indice
                destination.categoriaSelezionata = self.arrayCategorie[indexPath.row]
            }
            
        }
    }
    
    
    
}
