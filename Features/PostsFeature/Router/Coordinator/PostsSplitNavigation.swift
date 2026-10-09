import InnoRouter
import Observation
import OSLog
import PostsFeatureInterface

/// One authority preserves detail history while the native host changes with width.
@MainActor
@Observable
final class PostsSplitNavigation {
    enum Mode: Equatable, Sendable { case compact, split }

    let layout: RouterTwoColumnSplitLayout
    let store: RouterStore<PostsRoute>
    private(set) var mode: Mode
    private let logger = Logger(subsystem: "com.innosquad.InnoSample", category: "PostsNavigation")

    init(mode: Mode = .split) throws {
        self.mode = mode
        layout = try RouterTwoColumnSplitLayout(preferredCompactColumn: .sidebar)
        let initial = try Self.state(mode: mode, path: [], layout: layout)
        store = try PostsRoute.makeRouterStore(
            initialState: initial,
            configuration: .init(hostDescriptor: Self.descriptor(mode: mode, layout: layout))
        )
    }

    func adapt(to target: Mode) async {
        guard mode != target else { return }
        let path = mode == .compact ? RouterScopePath.root : .root.appending(layout.detailScopeID)
        guard case .stack(let stack) = store.state.node(at: path) else {
            logger.error("host adaptation found an incompatible detail scope")
            return
        }
        do {
            let state = try Self.state(mode: target, path: stack.path, layout: layout, budget: store.resourceBudget)
            let outcome = await store.replaceHost(
                with: .init(state: state), descriptor: Self.descriptor(mode: target, layout: layout)
            )
            switch outcome {
            case .applied, .unchanged:
                mode = target
            default:
                logger.error("host adaptation did not commit")
            }
        } catch {
            logger.error("host adaptation failed validation")
        }
    }

    func showDetail(_ post: FeaturePost) async {
        let action = RouterAction<PostsRoute>.replaceStack([.detail(post)])
        let detail = await store.perform(mode == .compact ? action : action.inScope(layout.detailScopeID))
        switch detail {
        case .applied, .unchanged: break
        default:
            logger.error("detail transition did not commit")
            return
        }
        if mode == .split {
            let compact = await store.perform(.setPreferredCompactColumn(.detail))
            if case .rejected = compact {
                logger.error("compact column transition rejected")
            }
        }
        logger.debug("detail scope committed, revision \(self.store.revision)")
    }

    private static func descriptor(mode: Mode, layout: RouterTwoColumnSplitLayout) -> RouterHostDescriptor<PostsRoute> {
        if mode == .compact {
            return .init(root: .stack, rootDeclarations: [.init(meaning: .declarationID("posts.list"))])
        }
        return .init(root: layout.hostShape, rootDeclarations: layout.hostRootDeclarations(
            for: PostsRoute.self, sidebarDeclarationID: "posts.list", detailDeclarationID: "posts.detail"
        ))
    }

    private static func state(
        mode: Mode, path: [PostsRoute], layout: RouterTwoColumnSplitLayout,
        budget: RouterResourceBudget = .provisional
    ) throws -> RouterState<PostsRoute> {
        if mode == .compact {
            return try RouterStateDraft(root: .stack(path: path)).build(resourceBudget: budget)
        }
        let split = try RouterSplitState(preferredCompactColumn: path.isEmpty ? .sidebar : .detail)
        let container = try RouterContainerState<PostsRoute>(
            style: .split, selection: layout.detailScopeID,
            branches: [.init(id: layout.sidebarScopeID), .init(id: layout.detailScopeID, node: .stack(path: path))],
            split: split
        )
        return try RouterStateDraft(root: .container(container)).build(resourceBudget: budget)
    }
}
