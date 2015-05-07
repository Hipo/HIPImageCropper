Pod::Spec.new do |s|

  s.name         = "HIPImageCropper"
  s.version      = "2.0.0"
  s.summary      = "Image cropping and scaling interface with edge snapping and high resolution support"
  s.homepage     = "https://github.com/Hipo/HIPImageCropper"
  s.screenshots  = "https://s3.amazonaws.com/f.cl.ly/items/0p2q2w0R040p3k3q1a1o/Image%202015-05-07%20at%203.54.05%20PM.png"
  s.license      = { :type => "Apache 2.0", :file => "LICENSE" }
  s.author             = { "Taylan Pince" => "taylan@hipolabs.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/Hipo/HIPImageCropper.git", :tag => "2.0.0" }
  s.source_files  = "Dependencies/HIPImageCropperView/*.{h,m}"
  s.requires_arc = true

end
