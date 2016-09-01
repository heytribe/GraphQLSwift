Pod::Spec.new do |s|

  s.name         = "GraphQLSwift"
  s.version      = "1.0.0"
  s.summary      = "GraphQL Query Library"

  s.homepage     = "https://github.com/heytribe/GraphQLSwift"

  s.license      = "MIT"

  s.author             = { "Rémy Bourgoin" => "remy@tribe.pm" }
  s.social_media_url   = "https://twitter.com/heytribe"

  # s.platform     = :ios
  # s.platform     = :ios, "5.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/heytribe/GraphQLSwift.git", :tag => "#{s.version}" }

  s.source_files  = "Source", "Source/**/*.swift"

  s.requires_arc = true

end
