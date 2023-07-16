//
//  DeviceViewController.swift
//  SwiftyTeeth
//
//  Created by Suresh Joshi on 2017-02-05.
//
//

import CoreBluetooth
import RxSwift
import RxSwiftyTeeth
import SwiftyTeeth
import UIKit

class DeviceViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    var device: Device?
    let readButton = UIBarButtonItem(title: "Read", style: .plain, target: self, action: nil)
    let subscribeButton = UIBarButtonItem(
        title: "Subscribe", style: .plain, target: self, action: nil)
    let writeButton = UIBarButtonItem(title: "Write", style: .plain, target: self, action: nil)
    var disposeBag = DisposeBag()
    lazy var vm: DeviceViewModel = {
        return DeviceViewModel(navigator: self, screenLogger: self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [readButton, subscribeButton, writeButton]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = ""

        let output = vm.transform(
            input: DeviceViewModel.Input(
                peripheral: device!,
                readTapped: readButton.rx.tap.asDriver(),
                writeTapped: writeButton.rx.tap.asDriver(),
                subscribeTapped: subscribeButton.rx.tap.asDriver()))

        output.connection
            .subscribe(onNext: { (discoveredCharacteristic) in
                discoveredCharacteristic.characteristics.forEach {
                    self.printUi(
                        "App: Discovered characteristic: \($0.uuid.uuidString) in \(String(describing: discoveredCharacteristic.service.uuid.uuidString))"
                    )
                }
            })
            .disposed(by: disposeBag)

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
}

// MARK: - Navigator
extension DeviceViewController: DeviceViewModel.Navigator {
    func navigateBack() {

    }
}

// MARK: - Screen Logger
extension DeviceViewController: DeviceViewModel.ScreenLogger {
    func printUi(_ text: String?) {
        print(text ?? "")
        DispatchQueue.main.async {
            self.textView.text.append((text ?? "") + "\n")
        }
    }
}
