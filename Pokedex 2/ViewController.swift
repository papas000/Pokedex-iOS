import UIKit

class ViewController: UITableViewController, UISearchBarDelegate {
    
    var pokemons: [Pokemon] = []
    var pokemonsBackup: [Pokemon] = []
    
    @IBOutlet var searchBar: UISearchBar!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            pokemons = pokemonsBackup
        }
        else {
            pokemons = []
            for pokemon: Pokemon in pokemonsBackup {
                if pokemon.name.lowercased().contains(searchText.lowercased()) {
                    pokemons.append(pokemon)
                }
            }
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=1000")
            
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status Code: \(httpResponse.statusCode)")
                }          //status code check
                
                let pokemonList = try JSONDecoder().decode(PokemonList.self, from: data)
                self.pokemons = pokemonList.results
                self.pokemonsBackup = pokemonList.results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print("Error parsing data \(error)")
            }
        }.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        cell.textLabel?.text = pokemons[indexPath.row].name.capitalized
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PokemonSegue" {
            if let destination = segue.destination as? PokemonViewController {
                destination.pokemon = pokemons[(tableView.indexPathForSelectedRow?.row)!]
            }
        }
    }

}

