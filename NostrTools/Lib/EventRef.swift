//
//  EventRef.swift
//  damus
//
//  Created by William Casarin on 2022-05-08.
//

import Foundation

enum EventRef {
    case thread_id(ReferencedId)
    case reply(ReferencedId)
    case reply_to_root(ReferencedId)
}

func build_mention_indices(_ blocks: [Block], type: MentionType) -> Set<Int> {
    return blocks.reduce(into: []) { acc, block in
        switch block {
        case .mention(let m):
            if m.type == type {
                if let idx = m.index {
                    acc.insert(idx)
                }
            }
        case .relay:
            return
        case .text:
            return
        case .hashtag:
            return
        case .url:
            return
        case .invoice:
            return
        }
    }
}

func interp_event_refs_without_mentions(_ refs: [ReferencedId]) -> [EventRef] {
    if refs.count == 0 {
        return []
    }
    
    if refs.count == 1 {
        return [.reply_to_root(refs[0])]
    }
    
    var evrefs: [EventRef] = []
    var first: Bool = true
    for ref in refs {
        if first {
            evrefs.append(.thread_id(ref))
            first = false
        } else {
            evrefs.append(.reply(ref))
        }
    }
    return evrefs
}
