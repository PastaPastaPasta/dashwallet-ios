//  
//  Created by Pavel Tikhonenko
//  Copyright © 2022 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

private let kDefaultOpenedMapPosition: CGFloat = 260.0
private let kHandlerHeight: CGFloat = 24.0
private let kDefaultClosedMapPosition = -kHandlerHeight;

class ExploreMerchantAllLocationsViewController: UIViewController {
    private var mapView: ExploreMapView!
    private var listContainerView: UIView!
    private var showMapButton: UIButton!
    private var tableView: UITableView!
    private var contentViewTopLayoutConstraint: NSLayoutConstraint!
    
    @objc func moveAction(sender: UIPanGestureRecognizer) {
        let translatedPoint = sender.translation(in: self.view)
        
        contentViewTopLayoutConstraint.constant += translatedPoint.x;
        contentViewTopLayoutConstraint.constant += translatedPoint.y;
        
        sender.setTranslation(.zero, in: self.view)
        
        if(sender.state == .ended) {
            let velocityY = 0.2*sender.velocity(in: self.view).y
            var finalY = contentViewTopLayoutConstraint.constant + velocityY
            
            if(finalY < kDefaultOpenedMapPosition/2) {
                finalY = kDefaultClosedMapPosition;
            }else if (finalY > self.view.frame.size.height/2) {
                finalY = self.mapView.frame.size.height - kHandlerHeight;
            }else{
                finalY = kDefaultOpenedMapPosition;
            }
            
            let animationDuration = (abs(velocityY)*0.0002)+0.2;
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut) {
                self.contentViewTopLayoutConstraint.constant = finalY
                self.view.layoutSubviews()
            } completion: { [weak self] completed in
                self?.updateShowMapButtonVisibility()
            }
        }
    }
    
    @objc func showMapAction() {
        showMap()
    }
    
    private func updateShowMapButtonVisibility() {
        let isVisible = contentViewTopLayoutConstraint.constant == kDefaultClosedMapPosition
        showMapButton.isHidden = !isVisible
    }
    
    private func showMap(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.contentViewTopLayoutConstraint.constant = kDefaultOpenedMapPosition
                self.view.layoutSubviews()
            } completion: { [weak self] completed in
                self?.updateShowMapButtonVisibility()
            }
        }else{
            contentViewTopLayoutConstraint.constant = kDefaultOpenedMapPosition
            view.layoutSubviews()
            updateShowMapButtonVisibility()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        showMap(animated: false)
    }
}

extension ExploreMerchantAllLocationsViewController {
    func configureHierarchy() {
        
        let titleStack = UIStackView()
        titleStack.axis = .vertical
        titleStack.alignment = .center
        titleStack.spacing = 0
        
        let titleLabel = UILabel()
        titleLabel.font = .dw_navigationBarTitle()
        titleLabel.text = "AMC"
        titleStack.addArrangedSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.font = .dw_font(forTextStyle: .footnote)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.text = "5 locations"
        titleStack.addArrangedSubview(subtitleLabel)
        
        navigationItem.titleView = titleStack
        
        mapView = ExploreMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        listContainerView = UIView()
        listContainerView.backgroundColor = .dw_background()
        listContainerView.translatesAutoresizingMaskIntoConstraints = false
        listContainerView.clipsToBounds = false
        listContainerView.layer.masksToBounds = true
        listContainerView.layer.cornerRadius = 20
        listContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(listContainerView)
        
        let handlerView = DWExploreWhereToSpendHandlerView(frame: .zero)
        handlerView.translatesAutoresizingMaskIntoConstraints = false
        listContainerView.addSubview(handlerView)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveAction(sender:)))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        handlerView.addGestureRecognizer(panRecognizer)
        
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.clipsToBounds = false
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationCell.dw_reuseIdentifier)
        tableView.rowHeight = 94
        listContainerView.addSubview(tableView)
        
        showMapButton = UIButton(type: .custom)
        showMapButton.translatesAutoresizingMaskIntoConstraints = false
        showMapButton.isHidden = true
        showMapButton.tintColor = .white
        showMapButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        showMapButton.addTarget(self, action: #selector(showMapAction), for: .touchUpInside)
        showMapButton.setImage(UIImage(systemName: "map.fill"), for: .normal)
        showMapButton.setTitle(NSLocalizedString("Map", comment: "Map"), for: .normal)
        showMapButton.layer.masksToBounds = true
        showMapButton.layer.cornerRadius = 20
        showMapButton.layer.backgroundColor = UIColor.black.cgColor
        listContainerView.addSubview(showMapButton)
        
        contentViewTopLayoutConstraint = listContainerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -kHandlerHeight)
        
        NSLayoutConstraint.activate([
            contentViewTopLayoutConstraint,
            listContainerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            listContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            listContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            listContainerView.heightAnchor.constraint(equalToConstant: 310),
            listContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            handlerView.topAnchor.constraint(equalTo: listContainerView.topAnchor),
            handlerView.heightAnchor.constraint(equalToConstant: kHandlerHeight),
            handlerView.leadingAnchor.constraint(equalTo: listContainerView.leadingAnchor),
            handlerView.trailingAnchor.constraint(equalTo: listContainerView.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: handlerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: listContainerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: listContainerView.leadingAnchor, constant: 15),
            tableView.trailingAnchor.constraint(equalTo: listContainerView.trailingAnchor, constant: -15),
            
            showMapButton.widthAnchor.constraint(equalToConstant: 92),
            showMapButton.heightAnchor.constraint(equalToConstant: 40),
            showMapButton.centerXAnchor.constraint(equalTo: listContainerView.centerXAnchor),
            showMapButton.bottomAnchor.constraint(equalTo: listContainerView.bottomAnchor, constant: -15),
        ])
    }
}

extension ExploreMerchantAllLocationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.dw_reuseIdentifier, for: indexPath) as! LocationCell
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
//        let merchant = DWExploreMerchant.mockData()[1]
//        
//        let vc = ExploreOfflineMerchantViewController(merchant: merchant, isShowAllHidden: true)
//        navigationController?.pushViewController(vc, animated: true)
    }
}

class LocationCell: UITableViewCell {
    private var distanceLabel: UILabel!
    private var addressLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0.953, green: 0.959, blue: 0.967, alpha: 1)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.clipsToBounds = false
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 10
        insertSubview(bgView, at: 0)
        
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        contentView.addSubview(stackView)
        
        let distanceStackView = UIStackView()
        distanceStackView.spacing = 9
        distanceStackView.translatesAutoresizingMaskIntoConstraints = false
        distanceStackView.axis = .horizontal
        stackView.addArrangedSubview(distanceStackView)
        
        let distanceIcon = UIImageView(image: UIImage(named: "image.explore.dash.distance")!)
        distanceIcon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        //distanceIcon.translatesAutoresizingMaskIntoConstraints = false
        distanceStackView.addArrangedSubview(distanceIcon)
        
        distanceLabel = UILabel()
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.font = .dw_font(forTextStyle: .footnote)
        distanceLabel.textColor = .secondaryLabel
        distanceLabel.text = ["2 miles", "5 miles", "6 miles"][Int.random(in: 0...2)]
        distanceStackView.addArrangedSubview(distanceLabel)
        
        addressLabel = UILabel()
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.font = .dw_font(forTextStyle: .body)
        addressLabel.numberOfLines = 0
        addressLabel.textColor = .label
        addressLabel.text = ["457 Alfreton Road, Nottingham, NG7 5LX", "191 Baker Street, Marylebone, New York, NW1 6UY", "191 Baker Street, Marylebone, New York, NW1 6UY"][Int.random(in: 0...2)]
        stackView.addArrangedSubview(addressLabel)
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            bgView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }
}
