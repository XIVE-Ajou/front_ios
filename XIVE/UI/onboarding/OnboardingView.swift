//
//  OnboardingView.swift
//  XIVE
//
//  Created by 나현흠 on 4/3/24.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: viewModel.tabSelectionBinding) {
                    ForEach(OnboardingInformationState.allCases) { state in
                        VStack(alignment: .leading) {
                            Text(state.headerText)
                                .foregroundColor(.XIVE_Black)
                            
                            Text(state.text)
                                .multilineTextAlignment(.leading)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.leading, 25)
                                .padding(.top, 45)
                                .padding(.bottom, 5)
                                .foregroundColor(.black)
                                .tracking(-0.02)
                            
                            Text(state.subtext)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .padding(.leading, 25)
                                .foregroundColor(.gray)
                                .padding(.bottom, 20)
                                .tracking(-0.02)
                            
                            OnboardingLottieView(name: state.lottieFileName)
                                .frame(width: state.width, height: state.height)
                                .frame(width: 400.0, height: 400.0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .tag(state)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                OnboardingViewIndicator(currentPage: viewModel.model.informationState.rawValue, total: 3)
                    .animation(.spring(), value: viewModel.model.informationState)
                    .padding(.vertical, 0)
                    .padding(.bottom, 80)
                
                NavigationLink(destination: HomeView(), isActive: $viewModel.isLastPage) { EmptyView() }
                
                Button(viewModel.model.informationState == .third ? "시작하기" : "다음") {
                    viewModel.moveToNext()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.model.informationState == .third ? Color.XIVE_Purple : Color.XIVE_Black)
                .foregroundColor(.XIVE_White)
                .cornerRadius(10)
                .padding(.horizontal, 35)
                .padding(.bottom, 10)
                .tracking(-0.02)
            }
            .navigationBarBackButtonHidden(true)
            .background(Color.white)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
