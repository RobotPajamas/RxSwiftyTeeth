//
//  RxSwiftyTeeth.swift
//  RxSwiftyTeeth
//
//  Created by Suresh Joshi on 2018-03-16.
//

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
            
            return Disposables.create {
            }
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
    
    func read(from characteristic: String, in service: String) -> Observable<Data> {
        return Observable.create({ (observer) -> Disposable in
            self.base.read(from: characteristic, in: service, complete: { (data, error) in
                if data != nil {
                    observer.onNext(data!)
                }
                if error != nil {
                    observer.onError(error!)
                }
                observer.onCompleted()
            })
            
            return Disposables.create {
            }
        })
    }
    
    // TODO: Handle write-no-response
    func write(data: Data, to characteristic: String, in service: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            self.base.write(data: data, to: characteristic, in: service, complete: { (error) in
                if error != nil {
                    observer.onError(error!)
                }
                observer.onCompleted()
            })
            
            return Disposables.create {
            }
        })
    }
    
    func subscribe(to characteristic: String, in service: String) -> Observable<Data> {
        return Observable.create({ (observer) -> Disposable in
            self.base.subscribe(to: characteristic, in: service, complete: { (data, error) in
                if data != nil {
                    observer.onNext(data!)
                }
                if error != nil {
                    observer.onError(error!)
                }
            })
            
            return Disposables.create {
                // TODO: Unsubscribe
            }
        })
    }
}
