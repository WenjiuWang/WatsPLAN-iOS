//
//  registerUserViewModel.swift
//  WatsPLAN
//
//  Created by Jack Zhang on 2020-06-15.
//  Copyright © 2020 Jiawen Zhang. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class RegisterUserViewModel: ObservableObject {
    
    
    @Published var username: String = "".trimmingCharacters(in: .whitespacesAndNewlines)
    @Published var email: String = "".trimmingCharacters(in: .whitespacesAndNewlines)
    @Published var password: String = "".trimmingCharacters(in: .whitespacesAndNewlines)
    @Published var confirmPassword: String = "".trimmingCharacters(in: .whitespacesAndNewlines)
    @Published var userNameValidator = UsernameValidation.emptyUsername
    @Published var emailValidator = EmailValidation.emptyEmail
    @Published var passwordValidator = PasswordValidation.empty
    @Published var isValid: Bool = false
    @Published var userNameError: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    
    private var cancellableSet: Set<AnyCancellable> = []
    init() {
        Publishers.CombineLatest4(self.validUserNamePublisher, self.emailValidatorPublisher, self.passwordValidatorPublisher, self.confirmPasswordValidatorPublisher)
            .dropFirst()
            .sink { _usernameError, _emailError, _passwordValidator , _confirmPasswordValidator in
                
                self.isValid = _usernameError == nil && _emailError == nil &&
                    _passwordValidator.errorMessage == nil &&
                    _confirmPasswordValidator.confirmPasswordErrorMessage == nil
        }
        .store(in: &cancellableSet)
        
        validUserNamePublisher
        .dropFirst()
            .sink { (_usernameError) in
            self.userNameError = _usernameError
            }
        .store(in: &cancellableSet)
        
        emailValidatorPublisher
            .dropFirst()
            .sink { (_emailError) in
                self.emailError = _emailError
                }
            .store(in: &cancellableSet)
        
        passwordValidatorPublisher
            .dropFirst()
            .sink { (_passwordValidator) in
            self.passwordError = _passwordValidator.errorMessage
            }
            .store(in: &cancellableSet)
        
        confirmPasswordValidatorPublisher
                .dropFirst()
                   .sink { (_passwordValidator) in
                   self.confirmPasswordError = _passwordValidator.confirmPasswordErrorMessage
                   }
                   .store(in: &cancellableSet)
    }
    
    private var validUserNamePublisher: AnyPublisher<String?, Never> {
        
        $username
        
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { _username in
                if _username.isEmpty {
                    return "Please enter username"
                } /*else if !_username.isValidEmail {
                    return "Please enter valid email"
                }*/ else {
                    return nil
                }
        }
        .eraseToAnyPublisher()
    }
    
    private var emailValidatorPublisher: AnyPublisher<String?, Never> {
        
        $email
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { _email in
                if _email.isEmpty {
                    return "Please enter email"
                } else if !_email.isValidEmail {
                    return "Please enter valid email"
                } else {
                    return nil
                }
        }
        .eraseToAnyPublisher()
    }
    
    private var passwordValidatorPublisher: AnyPublisher<PasswordValidation, Never> {
        $password
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map { password in
                if password.isEmpty {
                    return .empty
                } else {
                    return passwordStrengthChecker(forPassword: password)
                }
        }
        .eraseToAnyPublisher()
    }
    
    private var confirmPasswordValidatorPublisher: AnyPublisher<PasswordValidation, Never> {
        $confirmPassword
            .debounce(for: 0.0, scheduler: RunLoop.main)
            .map { confirmPassword in
                if confirmPassword.isEmpty {
                    return .confirmPasswordEmpty
                } else if self.password != confirmPassword {
                    return .notMatch
                } else {
                    return .reasonable
                }
        }
        .eraseToAnyPublisher()
    }
}

