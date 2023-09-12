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
    
    func saveDataToDocuments(_ data: String?) {
        if (data == nil) {
            return
        }
        let encodedData = decodeStringToContacts(data: data!)
        let jsonFileURL = getDocumentsDirectory().appendingPathComponent(filename)
        if (encodedData == nil) { return }
        let json = encode(data: SipContacts(contacts: encodedData!))
        if (json != nil) {
            do {
                try json!.write(to: jsonFileURL)
            } catch {
                print("Error save sip contacts \(error.localizedDescription)")
            }
        }
    }
    
    func readDataFromDocuments() -> SipContacts? {
        let jsonFileURL = getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            let data = try self.decode(data: Data.init(contentsOf: jsonFileURL))
            return data
        } catch {
            print("Error reading sip contacts \(error)")
            return nil
        }
    }
    
    private func decodeStringToContacts(data: String) -> Dictionary<String, String>? {
        var contacts: Dictionary<String, String> = [:]
        var str = data
        str.remove(at: str.startIndex)
        str.remove(at: str.index(before: str.endIndex))
        let array = str.components(separatedBy: ",")
        array.map {
            let arr = $0.split(separator: ":")
            contacts.updateValue(String(arr[1])
                .trimmingCharacters(in: .whitespaces), forKey: String(arr[0]).trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return contacts
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
