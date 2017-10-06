//
//  ViewController.swift
//  MyApp34
//
//  Created by user22 on 2017/10/6.
//  Copyright © 2017年 Brad Big Company. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    

    // 設備 Mgr
    var mgr:CBPeripheralManager? = nil
    // 定義功能
    var chars:[String:CBMutableCharacteristic] = [:]
    
    var queue = DispatchQueue(label: "q1", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent)
    
    // BLE 狀態, 設定 Service / Characteristic
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else {
            print("BLE Power ERROR")
            return
        }
        peripheral.delegate = self
        
        var service:CBMutableService
        var char:CBMutableCharacteristic
        var charArray:[CBMutableCharacteristic] = []
        
        // Service
        service = CBMutableService(type: CBUUID.init(string: "D4AB3614-609E-45B8-9E91-41792E765BDC"), primary: true)
        
        // Characteristic => Notify, Read, Write
        
        // A001 => Notify
        char = CBMutableCharacteristic(type: CBUUID.init(string: "A001"), properties: .notify, value: nil, permissions: .readable)
        charArray += [char]
        chars["A001"] = char
        
        // A002 => Write
        char = CBMutableCharacteristic(type: CBUUID.init(string: "A002"), properties: .write, value: nil, permissions: .writeable)
        charArray += [char]
        chars["A002"] = char

        service.characteristics = charArray
        mgr?.add(service)
        
    }
    
    // 加入 Service, 並發出訊號
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        guard error == nil else {
            print("error")
            return
        }
        
        let deviceName = "Brad Device"
        let sendData:[String:Any] = [
            CBAdvertisementDataLocalNameKey: deviceName,
            CBAdvertisementDataServiceUUIDsKey:[service.uuid]
        ]
        
        peripheral.startAdvertising(sendData)
    }
    
    // 進行發送資料處理
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
        queue.async {
            var data:Data?
            var n:UInt32 = 0
            var temp:UInt32 = 0
            
            while true {
                temp = n.bigEndian
                data = NSData.init(bytes: &temp, length: MemoryLayout<UInt32>.size) as Data
                // sendData
                self.sendData(data!, uuidString: "A001")
                print("n = \(n)")
                
                n += 1
                
                sleep(1)
            }
            
            
            
            
        }
        
    }
    
    private func sendData(_ data : Data, uuidString: String) {
        let char = chars[uuidString]
        mgr?.updateValue(data, for: char!, onSubscribedCentrals: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mgr = CBPeripheralManager(delegate: self, queue: queue)
        
    }


}

