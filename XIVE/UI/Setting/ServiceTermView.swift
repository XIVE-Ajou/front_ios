//
//  ServiceTermView.swift
//  XIVE
//
//  Created by 나현흠 on 5/4/24.
//

import SwiftUI

struct ServiceTermView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        VStack(spacing: 0){
            setupNavigationBar(presentationMode)
            ScrollView {
                VStack() {
                    Text("1. 서비스 이용 약관의 목적")
                        .padding(.leading, 24)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 20)).bold()
                    
                    
                    Text("다음의 기술한 ‘서비스 이용 약관’에는 ‘XIVE(카이브)’ 서비스 이용을 위해 유저가 이행해야 할 항목들과 ‘XIVE(카이브)’ 서비스 프로덕트 관리자가 이행해야 할 항목을 열거하여 명시되어 있습니다. 어떤 경우에도 본 서비스를 이용하려면 귀하는 대한민국(Republic of Korea) 연령 기준 만 9세 이상이어야 합니다.")
                        .padding(.bottom, 10)
                        .padding(.horizontal, 44)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12))
                    
                    CustomDivider(color: .XIVE_SettingDivider, height: 7)
                    
                    Text("2. 커뮤니티 가이드라인")
                        .padding(.leading, 24)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 20)).bold()
                    
                    Text("‘XIVE(카이브)’ 서비스를 이용하는 모든 사용자의 경우 다음 행위가 금지됩니다.\n- 거짓 정보를 제공하거나 불법 행위를 저지르거나 오해의 소지가 있거나 사기성이 있거나 다른 사람의 권리를 침해(허락 없이 다른 사람의 콘텐츠를 사용하는 경우 포함)하는 행위.\n-스팸, 괴롭힘, 나체 이미지 게시 등의 비도덕적인 커뮤니티 이용 \n- 가짜 계정을 만들거나 엑세스 권한이 없는 정보를 수집하거나 계정(또는 좋아요 및 팔로워 등의 계정의 일부)을 구매, 판매 또는 양도하거나 다른 사람의 계정에 로그인하는 행위 \n- 유저 이름에 도메인 또는 URL을 사용하는 행위 \n- 바이러스를 전송하는 행위, 본 서비스상에서 오버로딩(overloading), 플러딩(flooding) 또는 스패밍(spamming)을 실행하는 행위 등을 포함하여 사용자, 호스트 또는 네트워크의 접근을 방해하거나 중단시키는 행위 혹은 그러한 방해나 중단을 시도하는 행위 또는 본 서비스를 방해하거나 본 서비스상에서 심한 과부하를 일으키는 식으로 콘텐츠의 생성을 스크립팅(scripting)하는 행위 \n- 아티스트 및 공연/예술 등의 유관 사업에서의 저작권을 위반하는 행위 \n- 현재 사용 가능한 인터페이스 이외의 방법으로 본 서비스에 접근하는 행위 \n- 이 서비스의 비공개 영역, 당사의 컴퓨터 시스템 또는 당사 제공업체의 기술 전송 시스템에 엑세스하거나 이를 무단으로 변경 및 이용하는 행위 \n- 시스템 또는 네트워크의 취약성을 검사, 스캔 또는 테스트하거나 보안 조치 내지 인증 조치를 위반하거나 위반/우회하는 모든 행위")
                        .padding(.bottom, 10)
                        .padding(.horizontal, 44)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12))
                    
                    CustomDivider(color: .XIVE_SettingDivider, height: 7)
                    
                    Text("3. 콘텐츠 권한")
                        .padding(.leading, 24)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 20)).bold()
                    
                    Text("당사가 관련 법령에 따라 법률상 책임을 지는 경우를 제외하면, 유저는 유저 스스로의 본 서비스의 이용과 유저가 제공하는 콘텐츠(귀하의 콘텐츠가 관련 법률, 규정, 규칙을 준수하는지 여부 포함)에 대하여 책임이 있습니다.\n 유저는 유저 스스로가 타인과 편하게 공유할 수 있는 콘텐츠만을 제공하여야 합니다.‘XIVE(카이브)’에 기록하는 모든 콘텐츠의 소유권은 게시자에게 있습니다. 다만, 콘텐츠 제작에 사용되는 모든 데이터는 그 출처에 소유권이 있습니다. ‘커뮤니티 가이드라인’ 및 기타 비도덕적인 행위가 적발될 경우 콘텐츠가 삭제되거나 계정이 제한 또는 삭제될 수 있습니다.")
                        .padding(.bottom, 10)
                        .padding(.horizontal, 44)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12))
                    
                    CustomDivider(color: .XIVE_SettingDivider, height: 7)
                    
                    Text("4. XIVE(카이브) 이용 데이터의 저장 및 활용")
                        .padding(.leading, 24)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 20)).bold()
                    
                    Text("당사는 이용자에게 더 나은 서비스를 제공하기 위하여 이용자가 ‘XIVE(카이브)’를 이용하는 과정에서 발생하는 활동 데이터(티켓 기록, 커뮤니티 활동 등을 의미합니다)를 저장하여 ‘XIVE(카이브)’ 서비스의 성능 향상 및 추천 시스템 개선 등의 목적으로 활용할 수 있습니다.")
                        .padding(.bottom, 10)
                        .padding(.horizontal, 44)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12))
                    
                    CustomDivider(color: .XIVE_SettingDivider, height: 7)
                    
                    Text("5. 서비스 이용 약관에 관한 책임자 및 서비스")
                        .padding(.leading, 24)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 20)).bold()
                    
                    Text("‘XIVE(카이브)’는 회원의 개인정보를 최선으로 보호하고 관련된 불만을 처리하기 위해 노력하고 있습니다. \n\n- 당사는 서비스를 이용하는 유저로부터 제기되는 의견이나 불만이 정당하다고 인정할 경우 이를 처리하여야 합니다. 이때 처리과정에 대해서 고객에게 메일 및 알림 등의 방법으로 전달합니다. \n- 당사는 정보통신망 이용촉진 및 정보보호에 관한 법률, 통신비밀보호법, 전기통신사업법 등 서비스의 운영, 유지와 관련 있는 법규를 준수합니다. \n- 관련 문의사항은 책임자(이형기, dlgudrl1203@gmail.com )를 통해 전달해주시기 바랍니다.")
                        .padding(.bottom, 10)
                        .padding(.horizontal, 44)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12))
                    
                    CustomDivider(color: .XIVE_SettingDivider, height: 7)
                    
                    Text("6. 기타")
                        .padding(.leading, 24)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 20)).bold()
                    
                    Text("본 약관의 준거법은 대한민국 법으로 하며, 본 약관과 관련하여 소송이 제기되는 경우 민사소송법 상의 관할 법원을 재판관할을 갖는 법원으로 합니다. \n\n 이 ‘서비스 이용 약관’은 2024년 04월 10일에 최종적으로 개정되었습니다.")
                        .padding(.bottom, 10)
                        .padding(.horizontal, 44)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12))
                }
                .navigationBarBackButtonHidden(true)
            }
            .navigationBarBackButtonHidden(true)
            .background(Color.white)
            .preferredColorScheme(.light) // 다크 모드에서도 흰색 배경 유지
        }
    }
        @ViewBuilder
        private func setupNavigationBar(_ presentationMode: Binding<PresentationMode>) -> some View {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("back_arrow")
                        .padding(.leading, 15)
                }
                
                Spacer()
                
                Text("서비스 이용 약관")
                    .frame(alignment: .center)
                
                Spacer()
                
                Button(action: {
                }) {
                    Text("     ")
                }
            }
            .padding()
            .background(Color.white)
            .frame(height: 44) // Adjust the height as needed
        }
}

struct ServiceTermView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceTermView()
    }
}
