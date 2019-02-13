#
#  Be sure to run `pod spec lint S_CustomTimeKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "S_CustomTimeKit"
  s.version      = "0.0.1"
  s.summary      = "Custom DatePicker"

  s.description  = <<-DESC
			Custom DatePicker.
                   DESC

  s.homepage     = "https://github.com/Smiaomiao"
 
  s.license      = 'MIT'

  s.author             = { "杜菲" => "1540353516@qq.com" }
  
  s.platform     = :ios, '9.0'

  s.source       = { :git => "https://github.com/Smiaomiao/S_CustomTimeTest.git", :tag => "s.version" }

  s.source_files  = 'S_CustomDatePicker/**/*.{h,m}'

  s.framework  = "UIKit"

  s.requires_arc = true

  s.dependency 'Masonry'

end
