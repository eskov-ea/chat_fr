//
//  StorageManager.swift
//  Runner
//
//  Created by Cashalot Worker on 15.06.2023.
//

import Foundation

struct SipContacts: Codable {
    let contacts: Dictionary<String, String>
}


class StorageManager {
    
    let filename = "mcfef_sip_contacts.json"
    
    func saveDataToDocuments(_ data: Dictionary<String, String>, jsonFilename: String) {
        let jsonFileURL = getDocumentsDirectory().appendingPathComponent(jsonFilename)
        let json = encode(data: SipContacts(contacts: data))
        if (json != nil) {
            do {
                try json!.write(to: jsonFileURL)
            } catch {
                print("Error save sip contacts \(error.localizedDescription)")
            }
        }
    }
    
    func readDataFromDocuments(jsonFilename: String) -> SipContacts? {
        let jsonFileURL = getDocumentsDirectory().appendingPathComponent(jsonFilename)
        
        do {
            let data = try self.decode(data: Data.init(contentsOf: jsonFileURL))
            return data
        } catch {
            print("Error reading sip contacts \(error)")
            return nil
        }
    }
    
    private func encode(data: SipContacts) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let json = try encoder.encode(data)
            return json
        } catch {
            print("Error encoding \(error)")
            return nil
        }
    }
    
    private func decode(data: Data) -> SipContacts? {
        let decoder = JSONDecoder()
        
        do {
            let json = try decoder.decode(SipContacts.self, from: data)
            return json
        } catch {
            print("Error encoding \(error)")
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
}
