//
//  ySelfSizingTableView.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-12-23.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class ySelfSizingTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = min(.infinity, contentSize.height)
        return CGSize(width: contentSize.width, height: height)
    }
}
