//
//  RepositoryFactory.swift
//  Spike
//
//  Created by Cornerstone on 2020-10-17.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation

struct RepositoryFactory {
    
    static func createAdRepository() -> AdRepository {
        return AdRepositoryImpl()
    }
    
    static func createTemplateRepository() -> TemplateRepository {
        return TemplateRepositoryImpl()
    }
    
    static func createUserRepository() -> UserRepositoryImpl {
        return UserRepositoryImpl.shared
    }
}
