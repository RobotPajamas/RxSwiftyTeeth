//
//  RxSwiftyTeeth.swift
//  RxSwiftyTeeth
//
//  Created by Suresh Joshi on 2018-03-16.
//

import CoreBluetooth
import RxSwift
import SwiftyTeeth

public extension Reactive where Base: SwiftyTeeth {
    func scan() -> Observable<Device> {
        return Observable.create({ (observer) -> Disposable in
            self.base.scan(changes: { (device) in
                observer.onNext(device)
            })
            
            return Disposables.create {
                self.base.stopScan()
            }
        })
    }
    
    // TODO: Switch to Single? It's a one-shot, without the changes callback... Can both be hooked up?
    func scan(for timeout: TimeInterval = 10) -> Observable<[Device]> {
        return Observable.create({ (observer) -> Disposable in
            self.base.scan(for: timeout, changes: nil, complete: { (devices) in
                observer.onNext(devices)
                observer.onCompleted()
            })
            
            return Disposables.create {
                self.base.stopScan()
            }
        })
    }
}

public extension Reactive where Base: Device {
    
    func connect() -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            self.base.connect(complete: { (isConnected) in
                observer.onNext(isConnected)
            })
            
            return Disposables.create()
        })
    }
    
    // TODO: How to disconnect as an observable?
//    func disconnect(autoReconnect: Bool = false) -> Observable<Bool> {
//        return Observable.create({ (observer) -> Disposable in
//            self.base.disconnect(autoReconnect: autoReconnect)
//
//            return Disposables.create {
//            }
//        })
//    }
    
    func discoverServices(with uuids: [CBUUID]? = nil) -> Observable<[CBService]> {
        return Observable.create({ (observer) -> Disposable in
            self.base.discoverServices(with: uuids, complete: { (result) in
                switch result {
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            })
            
            return Disposables.create {
                // Cancel
            }
        })
    }
    
    func discoverCharacteristics(with uuids: [CBUUID]? = nil, for service: CBService) -> Observable<DiscoveredCharacteristic> {
        return Observable.create({ (observer) -> Disposable in
            self.base.discoverCharacteristics(with: uuids, for: service, complete: { (result) in
                switch result {
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            })
            
            return Disposables.create {
                // Cancel
            }
        })
    }
    
    // Maybe this should be a Single/Completable vs Observable? 
    func read(from characteristic: String, in service: String) -> Observable<Data> {
        return Observable.create({ (observer) -> Disposable in
            self.base.read(from: characteristic, in: service, complete: { (result) in
                switch result {
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            })
            
            return Disposables.create {
                // Cancel
            }
        })
    }
    
    // TODO: Handle write-no-response
    // Should be Single<>?
    func write(data: Data, to characteristic: String, in service: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            self.base.write(data: data, to: characteristic, in: service, complete: { (result) in
                switch result {
                case .success:
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            })
            
            return Disposables.create {
                // Cancel
            }
        })
    }
    
    func subscribe(to characteristic: String, in service: String) -> Observable<Data> {
        return Observable.create({ (observer) -> Disposable in
            self.base.subscribe(to: characteristic, in: service, complete: { (result) in
                switch result {
                case .success(let value):
                    observer.onNext(value)
                case .failure(let error):
                    observer.onError(error)
                }
            })
            
            return Disposables.create {
                // TODO: Cancel/Unsubscribe
            }
        })
    }
}
