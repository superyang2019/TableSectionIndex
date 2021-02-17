//
//  ViewController.swift
//  TableSectionIndexDemo
//
//  Created by superyang on 2021/2/16.
//

import UIKit

class ViewController: UIViewController {
    private let identifier = "cell"
    private var dataSource = [(key:String, value:[QNPerson])]()
    private lazy var tableView:UITableView  = {
        let v = UITableView.init(frame: view.frame,style: .plain)
        v.showsVerticalScrollIndicator = false
        v.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "TableSectionIndexDemo"
        self.loadData()
        view.addSubview(tableView)
        
        let items = self.items()
        let configuration = TableSectionIndexViewConfiguration.init()
        configuration.adjustedContentInset = UIApplication.shared.statusBarFrame.size.height + 44
        tableView.sectionIndexView(items: items, configuration: configuration)
        
    }
    
    private func loadData() {
        guard let path = Bundle.main.path(forResource: "data.json", ofType: nil),
            let url = URL.init(string: "file://" + path),
            let data = try? Data.init(contentsOf: url),
            let arr = (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Array<Dictionary<String, String>>) else {
                return
        }
        self.dataSource = arr.compactMap({QNPerson.init(dic: $0)}).reduce(into: [String:[QNPerson]]()) {
            $0[$1.firstCharacter] = ($0[$1.firstCharacter] ?? []) + [$1]
        }.sorted{$0.key < $1.key}
    }
    
    private func items() -> [TableSectionIndexViewItemView] {
        var items = [TableSectionIndexViewItemView]()
        for (i, key) in self.dataSource.compactMap({ $0.key }).enumerated() {
            let item = TableSectionIndexViewItemView.init()
            
                item.title = key
                item.indicator = TableSectionIndexViewItemIndicator.init(title: key)
            
            items.append(item)
        }
        return items
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dataSource[section].key
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier, for: indexPath)
        cell.textLabel?.text = self.dataSource[indexPath.section].value[indexPath.row].fullName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

