//
//  ThreadElementInvoiceCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class ThreadElementInvoiceCell: ThreadElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementInvoiceCell" }
    
    let invoiceView = LightningInvoiceView()
    
    override init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: position, style: style, reuseIdentifier: reuseIdentifier)
        
        secondRow.addSubview(invoiceView)
        invoiceView
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 0)
        
        invoiceView.copyButton.addAction(.init(handler: { [unowned self] _ in
            delegate?.postCellDidTap(self, .copy(.invoice))
        }), for: .touchUpInside)
        
        invoiceView.payButton.addAction(.init(handler: { [unowned self] _ in
            delegate?.postCellDidTap(self, .payInvoice)
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        guard let invoice = content.invoice else { return }
        invoiceView.updateForInvoice(invoice)
        invoiceView.updateTheme()
    }
}
