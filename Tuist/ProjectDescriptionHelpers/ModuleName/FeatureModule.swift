public enum FeatureModule: String {
    case features = "Features"
    case entireTab = "EntireTabFeature"
    case people = "PeopleFeature"
    case posts = "PostsFeature"
    case settings = "SettingsFeature"

    var bundleNamespace: String {
        switch self {
        case .features:
            "features.root"
        case .entireTab:
            "features.entiretab"
        case .people:
            "features.people"
        case .posts:
            "features.posts"
        case .settings:
            "features.settings"
        }
    }

    var path: String {
        switch self {
        case .features:
            "Features"
        case .entireTab, .people, .posts, .settings:
            "Features/\(rawValue)"
        }
    }

    var interfaceTargetName: String {
        "\(rawValue)Interface"
    }

    var logicTargetName: String {
        "\(rawValue)Logic"
    }

    var uiTargetName: String {
        "\(rawValue)UI"
    }

    var routerTargetName: String {
        "\(rawValue)Router"
    }

    var testingTargetName: String {
        "\(rawValue)Testing"
    }

    var testsTargetName: String {
        "\(rawValue)Tests"
    }

    var interfaceBundleNamespace: String {
        "\(bundleNamespace).interface"
    }

    var logicBundleNamespace: String {
        "\(bundleNamespace).logic"
    }

    var uiBundleNamespace: String {
        "\(bundleNamespace).ui"
    }

    var routerBundleNamespace: String {
        "\(bundleNamespace).router"
    }

    var testingBundleNamespace: String {
        "\(bundleNamespace).testing"
    }
}
