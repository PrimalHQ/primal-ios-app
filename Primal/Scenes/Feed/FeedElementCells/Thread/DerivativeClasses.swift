//
//  DerivativeClasses.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.12.24..
//

import UIKit

// User Cell
class ParentThreadElementUserCell: ThreadElementUserCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class ChildThreadElementUserCell: ThreadElementUserCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// Text Cell
class ParentThreadElementTextCell: ThreadElementTextCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class ChildThreadElementTextCell: ThreadElementTextCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// Images Gallery
class ParentThreadElementImageGalleryCell: ThreadElementImageGalleryCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class MainThreadElementImageGalleryCell: ThreadElementImageGalleryCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .main, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class ChildThreadElementImageGalleryCell: ThreadElementImageGalleryCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// Zap Gallery
class ParentThreadElementSmallZapGalleryCell: ThreadElementSmallZapGalleryCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class ChildThreadElementSmallZapGalleryCell: ThreadElementSmallZapGalleryCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// Reactions
class ParentThreadElementReactionsCell: ThreadElementReactionsCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class ChildThreadElementReactionsCell: ThreadElementReactionsCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// Link Preview
class ParentThreadElementWebPreviewCell<T: LinkPreview>: ThreadElementWebPreviewCell<T> {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class MainThreadElementWebPreviewCell<T: LinkPreview>: ThreadElementWebPreviewCell<T> {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .main, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class ChildThreadElementWebPreviewCell<T: LinkPreview>: ThreadElementWebPreviewCell<T> {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// Article preview
class ParentThreadElementArticleCell: ThreadElementArticleCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class MainThreadElementArticleCell: ThreadElementArticleCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .main, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class ChildThreadElementArticleCell: ThreadElementArticleCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// Post preview
class ParentThreadElementPostPreviewCell: ThreadElementPostPreviewCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class MainThreadElementPostPreviewCell: ThreadElementPostPreviewCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .main, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class ChildThreadElementPostPreviewCell: ThreadElementPostPreviewCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// Invoice
class ParentThreadElementInvoiceCell: ThreadElementInvoiceCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class MainThreadElementInvoiceCell: ThreadElementInvoiceCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .main, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class ChildThreadElementInvoiceCell: ThreadElementInvoiceCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// Zap Preview
class ParentThreadElementZapPreviewCell: ThreadElementZapPreviewCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class MainThreadElementZapPreviewCell: ThreadElementZapPreviewCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .main, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class ChildThreadElementZapPreviewCell: ThreadElementZapPreviewCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// Info
class ParentThreadElementInfoCell: ThreadElementInfoCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class MainThreadElementInfoCell: ThreadElementInfoCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .main, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class ChildThreadElementInfoCell: ThreadElementInfoCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
