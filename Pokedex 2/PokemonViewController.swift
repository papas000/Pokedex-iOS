import UIKit

class PokemonViewController: UIViewController {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var pokemon: Pokemon!
    
    var mainUrl: URL!
    var imgUrl: URL!
    var speciesUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.bool(forKey: pokemon.name) {
            navigationItem.rightBarButtonItem?.title = "Release"
        }
        else {
            navigationItem.rightBarButtonItem?.title = "Catch"
        }
        
        nameLabel.text = pokemon.name.capitalized
        
        mainUrl = URL(string: pokemon.url)
        guard let mainUrl = mainUrl else {
            return
        }
        
        URLSession.shared.dataTask(with: mainUrl) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                let pokemonData = try JSONDecoder().decode(PokemonData.self, from: data)
                if pokemonData.sprites.front_default != nil {
                    self.imgUrl = URL(string: pokemonData.sprites.front_default!)
                }
                self.speciesUrl = URL(string: pokemonData.species.url)
                
                DispatchQueue.main.async {
                    self.numberLabel.text = String(format: "#%03d", pokemonData.id)
                    for typeEntry in pokemonData.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                            self.type2Label.isHidden = true
                        }
                        if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                            self.type2Label.isHidden = false
                        }
                    }
                }
            } catch let error {
                print("Error parsing data: \(error)")
            }
            if self.imgUrl != nil {
                do {
                    let data = try Data(contentsOf: self.imgUrl)
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                } catch let error {
                    print("Image could not be loaded: \(error)")
                }
            }
            
            guard let speciesUrl = self.speciesUrl else {
                return
            }
            URLSession.shared.dataTask(with: speciesUrl) { (data, response, error) in
                guard let data = data else {
                    return
                }
                do {
                    let speciesData = try JSONDecoder().decode(PokemonSpeciesData.self, from: data)
                    
                    DispatchQueue.main.async {
                        var notFound = true
                        for flavor: PokemonFlavor in speciesData.flavor_text_entries {
                            if flavor.language.name == "en" && notFound {
                                self.descriptionLabel.text = flavor.flavor_text
                                notFound = false
                            }
                        }
                    }
                } catch let error {
                    print("Species could not be loaded: \(error)")
                }
            }.resume()
        }.resume()
    }
    
    @IBAction func favoritePokemon() {
        if UserDefaults.standard.bool(forKey: pokemon.name) {
            PokemonManager.main.delete(pokemon: pokemon)
            UserDefaults.standard.set(false, forKey: pokemon.name)
            navigationItem.rightBarButtonItem?.title = "Catch"
        }
        else {
            let _ = PokemonManager.main.favorite(pokemon: pokemon)
            UserDefaults.standard.set(true, forKey: pokemon.name)
            navigationItem.rightBarButtonItem?.title = "Release"
            }
    }
}
