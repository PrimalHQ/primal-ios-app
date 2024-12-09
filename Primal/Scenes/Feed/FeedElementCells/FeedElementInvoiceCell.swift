//
//  FeedElementInvoiceCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class FeedElementInvoiceCell: PostCell {
    override class var cellID: String { "FeedElementInvoiceCell" }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(invoiceView)
        invoiceView
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        guard let invoice = content.invoice else { return }
        invoiceView.updateForInvoice(invoice)
    }
    
    override func updateMenu(_ content: ParsedContent) { }
}
