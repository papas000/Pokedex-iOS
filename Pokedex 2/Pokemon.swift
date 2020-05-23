import Foundation
import SQLite3

struct PokemonList: Codable {
    let results: [Pokemon]
}

struct Pokemon: Codable {
    let name: String
    let url: String
}

struct PokemonData: Codable {
    let id: Int
    let species: PokemonSpecies
    let sprites: PokemonSprite
    let types: [PokemonTypeEntry]
}

struct PokemonSpecies: Codable {
    let url: String
}

struct PokemonSpeciesData: Codable {
    let flavor_text_entries: [PokemonFlavor]
}

struct PokemonFlavor: Codable {
    let flavor_text: String
    let language: PokemonFlavorLanguage
}

struct PokemonFlavorLanguage: Codable {
    let name: String
}

struct PokemonSprite: Codable {
    let front_default: String?
}

struct PokemonTypeEntry: Codable {
    let slot: Int
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String
    let url: String
}

class PokemonManager {
    var database: OpaquePointer!
    
    static let main = PokemonManager()
    
    private init() {
        
    }
    
    func connect() {
        if database != nil {
            return
        }
        do {
            let databaseURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("pokemons.sqlite3")
            if sqlite3_open(databaseURL.path, &database) == SQLITE_OK {
                if sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS pokemons (name TEXT, url TEXT PRIMARY KEY)", nil, nil, nil) == SQLITE_OK {
                    
                } else {
                    print("Could not create table")
                }
            } else {
                print("Could not connect")
            }
        }
        catch let error {
            print("Could not create database", error)
        }
    }
    
    func favorite(pokemon: Pokemon) -> Int {
        connect()
        
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "INSERT INTO pokemons (name, url) VALUES (?, ?)", -1, &statement, nil) != SQLITE_OK {
            print("Could not create query")
            return -1
        }
        sqlite3_bind_text(statement, 1, NSString(string: pokemon.name).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, NSString(string: pokemon.url).utf8String, -1, nil)
        
        
        if sqlite3_step(statement)  != SQLITE_DONE {
            print("Could not insert note")
            return -1
        }
        
        sqlite3_finalize(statement)
        return Int(sqlite3_last_insert_rowid(database))
    }
    
    func getAllPokemons() -> [Pokemon] {
        connect()
        var result: [Pokemon] = []
        
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "SELECT name, url FROM pokemons", -1, &statement, nil) != SQLITE_OK {
            print("Eroor creating select")
            return []
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            result.append(Pokemon(name: String(cString: sqlite3_column_text(statement, 0)), url: String(cString: sqlite3_column_text(statement, 1))))
        }
        
        sqlite3_finalize(statement)
        return result
    }
    
    func delete(pokemon: Pokemon) {
        connect()
        
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "DELETE FROM pokemons WHERE url = ?", -1, &statement, nil) != SQLITE_OK {
            print("Could not create delete statement")
        }
        
        sqlite3_bind_text(statement, 1, NSString(string: pokemon.url).utf8String, -1, nil)
        
        if sqlite3_step(statement)  != SQLITE_DONE {
            print("Could not delete note")
        }
        
        sqlite3_finalize(statement)
    }
}
