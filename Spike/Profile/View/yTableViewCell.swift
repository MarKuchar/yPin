import UIKit

class yTableViewCell: UITableViewCell {
    
    
    let title: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lb.font = UIFont(name: "Optima Regular", size: 20)
        return lb
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        let hSV = HorizontalStackView(
            arrangedSubviews: [title], distribution: .fill)
        self.addSubview(hSV)
        hSV.matchParent(padding: .init(top: 16, left: 32, bottom: 16, right: 32))
        self.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
