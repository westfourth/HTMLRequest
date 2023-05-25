#

Pod::Spec.new do |spec|

  spec.name         = "HTMLRequest"
  spec.version      = "0.0.7"
  spec.summary      = "HTML网络请求"

  spec.description  = <<-DESC
  						HTML网络请求，依赖hpple
                   DESC

  spec.homepage     = "https://cocoapods.org/pods/HTMLRequest"
  spec.license      = "MIT"
  spec.author             = { "xisixisi" => "xisixisi@gmail.com" }
  spec.platform     = :ios, "14.0"

  spec.source       = { :git => "https://github.com/westfourth/HTMLRequest.git" }

  spec.source_files  = "HTMLRequest/*.{h,m}"
  spec.public_header_files = "HTMLRequest/*.h"

  spec.dependency "hpple"

end
