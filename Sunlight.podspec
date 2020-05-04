Pod::Spec.new do |s|
  s.name             = 'Sunlight'
  s.version          = '1.0.1'
  s.summary          = 'High precision sunrise and sunset times.'

  s.description      = <<-DESC
                      Calculate sunrise and sunset time for any 
                      location using high precision astronomical 
                      equations from cited authoritative sources.
                     DESC

  s.homepage         = "https://github.com/z3bi/Sunlight"
  s.license          = 'MIT'
  s.author           = { 'Ameir Al-Zoubi' => 'ameir@ameir.com' }
  s.source           = { :git => 'https://github.com/z3bi/Sunlight.git', :tag => '1.0.1' }

  s.social_media_url = 'https://twitter.com/ameir'

  s.swift_versions = ['5.0', '5.1', '5.2']

  s.ios.deployment_target = '8.0'

  s.source_files =  'Sources/**/*.{swift,h}'
  
end
