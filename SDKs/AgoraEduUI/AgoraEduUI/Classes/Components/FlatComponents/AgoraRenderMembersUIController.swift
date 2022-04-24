//
//  AgoraRenderMembersUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/4/24.
//

import AgoraUIBaseViews

// MARK: - Model
enum AgoraRenderUserState {
    case normal, none, window
}

enum AgoraRenderMediaState {
    case normal, off, forbidden
}

struct AgoraRenderMemberViewModel {
    var userId: String
    var userName: String
    var userState: AgoraRenderUserState
    var videoState: AgoraRenderMediaState
    var audioState: AgoraRenderMediaState
    
    // 待定
    var volume: Int
    var isWaving: Bool
    
    static func defaultNilValue() -> AgoraRenderMemberViewModel {
        return AgoraRenderMemberViewModel(userId: "",
                                          userName: "",
                                          userState: .none,
                                          videoState: .off,
                                          audioState: .off,
                                          volume: 0,
                                          isWaving: false)
    }
}

// MARK: - Delegate
protocol AgoraRenderUIControllerDelegate: NSObjectProtocol {
    func onClickMemberAt(view: UIView,
                         UUID: String)
    
    func onRequestSpread(firstOpen: Bool,
                         userId: String,
                         streamId: String,
                         fromView: UIView,
                         xaxis: CGFloat,
                         yaxis: CGFloat,
                         width: CGFloat,
                         height: CGFloat)
}

private let kItemGap: CGFloat = 4

class AgoraRenderMembersUIController: UIViewController {
    // data
    private weak var delegate: AgoraRenderUIControllerDelegate?
    private var dataSource: [AgoraRenderMemberViewModel] = []
    private var collectionViewLayout: UICollectionViewFlowLayout
    
    // views
    private var contentView: UIView!
    
    private var collectionView: UICollectionView!
    private var leftButton: UIButton!
    private var rightButton: UIButton!
    
    init(delegate: AgoraRenderUIControllerDelegate?,
         collectionViewLayout: UICollectionViewFlowLayout,
         dataSource: [AgoraRenderMemberViewModel]? = nil) {
        self.delegate = delegate
        self.collectionViewLayout = collectionViewLayout
        
        super.init(nibName: nil,
                   bundle: nil)

        if let data = dataSource {
            self.dataSource = data
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension AgoraRenderMembersUIController: UICollectionViewDataSource, UICollectionViewDelegate {
    // UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: UICollectionViewCell.self,
                                                      for: indexPath)
        // TODO: add view
        return cell
    }
    
    // UICollectionViewDelegate
        public func collectionView(_ collectionView: UICollectionView,
                                   didSelectItemAt indexPath: IndexPath) {
            collectionView.deselectItem(at: indexPath, animated: false)
            let u = dataSource[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath),
               u.userId != "" {
                delegate?.onClickMemberAt(view: cell,
                                          UUID: u.userId)
            }
        }
            
        public func collectionView(_ collectionView: UICollectionView,
                                   layout collectionViewLayout: UICollectionViewLayout,
                                   sizeForItemAt indexPath: IndexPath) -> CGSize {
            let itemWidth = (view.bounds.width + kItemGap) / 7.0 - kItemGap
            return CGSize(width: itemWidth, height: collectionView.bounds.height)
        }
        
        public func collectionView(_ collectionView: UICollectionView,
                                   layout collectionViewLayout: UICollectionViewLayout,
                                   minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return kItemGap
        }
        
        public func collectionView(_ collectionView: UICollectionView,
                                   layout collectionViewLayout: UICollectionViewLayout,
                                   insetForSectionAt section: Int) -> UIEdgeInsets {
            return .zero
        }
}

// MARK: - private
private extension AgoraRenderMembersUIController {
    func createViews() {
        let ui = AgoraUIGroup()
        contentView = UIView()
        view.addSubview(contentView)
        
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: collectionViewLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(cellWithClass: UICollectionViewCell.self)
        contentView.addSubview(collectionView)
    }
    
    func createConstraint() {
        contentView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(0)
            make?.bottom.equalTo()(0)
        }
        collectionView.mas_makeConstraints { make in
            make?.right.top().bottom().equalTo()(0)
            make?.left.equalTo()(contentView.mas_right)
        }
    }
}
