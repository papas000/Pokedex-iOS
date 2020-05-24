import UIKit

class FavoritesViewController: UITableViewController {
    var pokemons: [Pokemon] = []
    
    @IBAction func releaseAll() {
        PokemonManager.main.deleteAllPokemons()
        reload()
    }
    
    func reload() {
        pokemons = PokemonManager.main.getAllPokemons()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        reload()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath)
        cell.textLabel?.text = pokemons[indexPath.row].name.capitalized
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FavoritesSegue" {
            if let destination = segue.destination as? PokemonViewController {
                destination.pokemon = pokemons[(tableView.indexPathForSelectedRow?.row)!]
            }
        }
    }
}

