#
#  Be sure to run `pod spec lint TableSectionIndex.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "TableSectionIndex"
  s.version      = "0.0.1"
  s.summary      = "A short description of TableSectionIndex."

  s.homepage     = "https://github.com/superyang2019/TableSectionIndex"
  s.license      = "MIT"

  s.author             = { "YangLiu" => "15172330362@163.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/superyang2019/TableSectionIndex.git", :tag => s.version }

  spec.source_files  = "Sources/TableSectionIndex/**/*.{h,m}"

  s.framework  = "UIKit"
  s.requires_arc = true

end
