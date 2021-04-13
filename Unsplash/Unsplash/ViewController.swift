//
//  ViewController.swift
//  Unsplash
//
//  Created by Leximelyano
//  Copyright © 2020 Leximelyano. All rights reserved.
//

import UIKit

struct CellViewModel {
    let id: String
    let url: URL
    var state: State
}

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, ImageLoaderDelegate {
    
    private let loader = Loader()
    private var flagIcon = true
    //MARK: - Search properties
    var searchTaskWorkItem: DispatchWorkItem?
    private var searchToken = ""
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 250, height: 16))
    private let hint = UILabel()
    
    //MARK: - Collection properties
    private var collectionView: UICollectionView!
    private let service: UnsplashService = UnsplashServiceImplementation()
    private var viewModels: [CellViewModel] = []
    private var pageNumber = 5
    private let leftAndRightPaddings: CGFloat = 16.0
    private var isDoubleImages = true
    private var itemWidth = UIScreen.main.bounds.width - 16
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()
        URLSession.shared.configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        URLSession.shared.configuration.allowsExpensiveNetworkAccess = true
        loader.delegate = self
        setupCollection()
        setupHintLabel()
        setupRickButton()
    }
    
    func didFinishLoad(image: UIImage, with id: String, from url: URL) {
        DispatchQueue.main.async {
            if let index = self.viewModels.firstIndex(where: { $0.id == id }) {
                self.viewModels[index].state = .image(image)
                let indexPath = IndexPath(row: index, section: 0)
                if let cell = self.collectionView.cellForItem(at: indexPath) as? Cell, self.collectionView.visibleCells.contains(cell) {
                    cell.configure(with: .image(image))
                }
            }
        }
    }
    
    //         Если запрос выполняется впервые или это новый запрос:
    //              - загружается первая страница
    //              - инициируется запрос картинок, только если поисковой токен изменился
    //              - обновляется модель
    
    private func configureRequest(_ firstResponse: Bool, page: inout Int) -> Bool {
        page = firstResponse ? 0 : pageNumber
        if firstResponse == true {
            if searchToken == searchBar.text { return false }
            viewModels.removeAll()
            collectionView.reloadData()
        }
        searchToken = searchBar.text ?? ""
        return true
    }
    
    
    private func getDataBySearchResponse(firstResponse: Bool = false) {
        var page = 0
        if !configureRequest(firstResponse, page: &page) {return}
        
        // Выполняется запрос
        print("Log: - start request by key \(searchToken)")
        service.searchImages(with: searchToken, page: page) { (objects, error)  in
            if let _ = error, firstResponse {
                self.handleErrorResponse()
                return
            }
            let newViewModels = objects.map {
                CellViewModel(id: $0.id,
                              url: URL(string: $0.urls["regular"]!)!,
                              state: .filledColor(UIColor.init(hex: $0.color)!)) }
            print("page number", self.pageNumber)
            
            DispatchQueue.main.async {
                self.hint.text = ""
                if !firstResponse { self.pageNumber += 1 }
                self.viewModels.append(contentsOf: newViewModels)
                self.collectionView.reloadData()
            }
        }
    }
    
    private func handleErrorResponse() {
        DispatchQueue.main.async {
            self.viewModels = []
            self.hint.text = "По вашему запросу ничего не найдено"
            self.collectionView.reloadData()
            
        }
    }
    
    private func setupRickButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "doubleScreen"),
                                                            style: .plain,
                                                            target: self,
                                                            action:  #selector(switchSize))
    }
    
    private func setupCollection() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.identifier)
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Поиск"
        let leftBarSearchItem = UIBarButtonItem(customView: searchBar)
        navigationItem.leftBarButtonItem = leftBarSearchItem
    }
    
    
    private func setupHintLabel() {
        hint.text = "Здесь будут отображаться\n результаты поиска"
        hint.textColor = .gray
        hint.textAlignment = .center
        hint.numberOfLines = 0
        hint.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hint)
        NSLayoutConstraint.activate([
            hint.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            hint.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
        print(viewModels[indexPath.row].id, "for index : ", indexPath)
        cell.configure(with: viewModels[indexPath.row].state)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = (collectionView.cellForItem(at: indexPath) as? Cell)?.cellImage
        let fullImageVC = FullImageViewController()
        fullImageVC.imageView = UIImageView(image: image)
        navigationController?.pushViewController(fullImageVC, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewModels.count > indexPath.row, viewModels.count > 0 {
            let model = viewModels[indexPath.row]
            if model.state.isPlaceholder {
                print(indexPath.row, ": loading cancel for id: ", model.id)
                loader.cancel(for: model.id)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewModels.count > indexPath.row, viewModels.count > 0 {
            
            let model = viewModels[indexPath.row]
            if model.state.isPlaceholder {
                print(indexPath.row,": loading start for id: ", model.url)
                loader.loadImage(with: model.id, from: model.url)
            }
        }
    }
}

extension ViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        if (scrollOffset + scrollViewHeight > scrollContentSizeHeight - 100) {
            if !service.isTaskActivate, searchBar.text != "" {
                getDataBySearchResponse()
            }
        }
    }
}

//TODO: - скрывать Keyboard - когда тапаешь вне поиска
extension ViewController: UISearchBarDelegate {
    
    @objc func switchSize() {
        switch isDoubleImages {
            case true:
                isDoubleImages = false
                itemWidth = UIScreen.main.bounds.width - 16
            case false:
                isDoubleImages = true
                itemWidth = (UIScreen.main.bounds.width - 16) / 2
        }
        collectionView.reloadData()
        if isDoubleImages {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "doubleScreen"),
            style: .plain,
            target: self,
            action:  #selector(switchSize))
        }else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "screen"),
            style: .plain,
            target: self,
            action:  #selector(switchSize))
        }
    }
    
    private func startRequest() {
        if let _ = searchTaskWorkItem {
            searchTaskWorkItem?.cancel()
            searchTaskWorkItem = nil
            
        }
        searchTaskWorkItem = DispatchWorkItem(block: {
            self.getDataBySearchResponse(firstResponse: true)
        })
        
        if let _ = searchTaskWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: searchTaskWorkItem!)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        startRequest()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        startRequest()
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}


