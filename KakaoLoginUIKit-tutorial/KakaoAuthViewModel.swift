//
//  KakaoAuthViewModel.swift
//  KakaoLoginUIKit-tutorial
//
//  Created by 백래훈 on 2023/01/31.
//

import Foundation
import Combine
import KakaoSDKAuth
import KakaoSDKUser

class KakaoAuthViewModel: ObservableObject {
    var subscriptions = Set<AnyCancellable>()
    
    @Published var isLoggedIn: Bool = false
    
    lazy var loginStatusInfo: AnyPublisher<String?, Never> =
    $isLoggedIn.compactMap { $0 ? "로그인 상태" : "로그아웃 상태" }.eraseToAnyPublisher()
    
    init() {
        print("akaoAuthViewModel - init() called")
    }
    
    //카카오톡 앱으로 로그인 인증
    func kakaoLoginWithApp() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                    continuation.resume(returning: false)
                } else {
                    print("loginWithKakaoTalk() success.")
                    
                    //do something
                    _ = oauthToken
                    continuation.resume(returning: true)
                }
            }
        }
    }
    
    // 카카오 계정으로 로그인 인증
    func kakaoLoginWithAccount() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                    continuation.resume(returning: false)
                } else {
                    print("loginWithKakaoAccount() success.")
                    
                    //do something
                    _ = oauthToken
                    continuation.resume(returning: true)
                }
            }
        }
    }
    
    //login
    @MainActor
    func kakaoLogin() {
        print("KakaoAuthViewModel - handleKakaoLogin() called")
        Task {
            // 카카오톡 실행 가능 여부 확인
            if (UserApi.isKakaoTalkLoginAvailable()) {
                //카카오톡 앱으로 로그인 인증
                self.isLoggedIn = await kakaoLoginWithApp()
            } else {// 카카오톡 실행이 불가능한 경우
                //카카오톡 계정으로 로그인 인증
                self.isLoggedIn = await kakaoLoginWithAccount()
            }
        }
    }
    
    //logout
    @MainActor
    func kakaoLogout() {
        Task {
            if await handleKakaoLogout() {
                self.isLoggedIn = false
            }
        }
    }
    
    func handleKakaoLogout() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.logout {(error) in
                if let error = error {
                    print(error)
                    continuation.resume(returning: false)
                }
                else {
                    print("logout() success.")
                    continuation.resume(returning: true)
                }
            }
        }
    }
}
