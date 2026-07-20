//
//  DerivativeClasses.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.12.24..
//

// Thread derivative classes are no longer needed.
// FeedElementBaseCell now auto-detects the thread position from the
// reuse identifier suffix and installs a ThreadLayout automatically.
// Register the base cell type with a position-suffixed identifier:
//
//   tableView.register(FeedElementTextCell.self,
//       forCellReuseIdentifier: FeedElementTextCell.cellID + ThreadPosition.parent.rawValue)
