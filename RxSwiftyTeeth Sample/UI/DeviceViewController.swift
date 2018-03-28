//
//  DeviceViewController.swift
//  SwiftyTeeth
//
//  Created by Suresh Joshi on 2017-02-05.
//
//

import UIKit
import RxSwiftyTeeth
import SwiftyTeeth
import RxSwift

class DeviceViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var device: Device?
    let readButton = UIBarButtonItem(title: "Read", style: .plain, target: self, action: nil)
    let subscribeButton = UIBarButtonItem(title: "Subscribe", style: .plain, target: self, action: nil)
    let writeButton = UIBarButtonItem(title: "Write", style: .plain, target: self, action: nil)
    var disposeBag = DisposeBag()
    lazy var vm: DeviceViewModel = {
        return DeviceViewModel(navigator: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [readButton, subscribeButton, writeButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = ""
        connect()
        
        let output = vm.transform(input: DeviceViewModel.Input(peripheral: device!,
                                                  readTapped: readButton.rx.tap.asDriver(),
                                                  writeTapped: writeButton.rx.tap.asDriver(),
                                                  subscribeTapped: subscribeButton.rx.tap.asDriver()))
        
        output.readRequest
            .drive(onNext: { (data) in
                self.printUi("Read value: \(String(describing: data.base64EncodedString()))")
            })
            .disposed(by: disposeBag)
        
        output.writeRequest
            .drive(onNext: { () in
                self.printUi("Write response")
            })
            .disposed(by: disposeBag)
        
        output.subscribeRequest
            .drive(onNext: { (data) in
                self.printUi("Subscribed value: \(String(describing: data.base64EncodedString()))")
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        device?.disconnect()
        disposeBag = DisposeBag()
    }
    
    private func printUi(_ text: String?) {
        print(text ?? "")
        DispatchQueue.main.async {
            self.textView.text.append((text ?? "") + "\n")
        }
    }
}

// MARK: - Navigator
extension DeviceViewController: DeviceViewModel.Navigator {
    func navigateBack() {
        
    }
}


// MARK: - SwiftyTeethable
extension DeviceViewController {
    
    // TODO: Make reactive
    // Connect and iterate through services/characteristics
    func connect() {
        device?.connect(complete: { isConnected in
            guard isConnected == true else {
                return
            }
                
            self.printUi("App: Device is connected? \(isConnected)")
            print("App: Starting service discovery...")
            self.device?.discoverServices(complete: { result in
                let services = result.value ?? []
                services.forEach {
                    self.printUi("App: Discovering characteristics for service: \($0.uuid.uuidString)")
                    self.device?.discoverCharacteristics(for: $0, complete: { result in
                        let service = result.value?.service
                        let characteristics = result.value?.characteristics ?? []
                        characteristics.forEach {
                            self.printUi("App: Discovered characteristic: \($0.uuid.uuidString) in \(String(describing: service?.uuid.uuidString))")
                        }
                        
                        if service == services.last {
                            self.printUi("App: All services/characteristics discovered")
                        }
                    })
                }
            })

        })
    }
    
    func disconnect() {
        device?.disconnect()
    }
}
