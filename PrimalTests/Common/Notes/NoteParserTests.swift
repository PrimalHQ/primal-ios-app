//
//  NoteParserTests.swift
//  PrimalTests
//
//  Created by Nikola Lukovic on 14.5.23..
//

import XCTest
@testable import Primal

final class NoteParserTests: XCTestCase {

    func testSimpleSentance() {
        let example = "Hello, World!"
        let parser = NoteParser(example)
        let tokens = parser.getLexedTokens()
        
        XCTAssert(tokens.count == 6)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
    
    func testSimpleSentanceWithHashtag() {
        let example = "Hello #World!"
        let parser = NoteParser(example)
        let tokens = parser.getLexedTokens()
        
        XCTAssert(tokens.count == 6)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
    
    func testSimpleSentanceWithMention() {
        let example = "Hello @World!"
        let parser = NoteParser(example)
        let tokens = parser.getLexedTokens()
        
        XCTAssert(tokens.count == 6)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
    
    func testSimpleSentanceWithColon() {
        let example = "Hello: @World!"
        let parser = NoteParser(example)
        let tokens = parser.getLexedTokens()
        
        XCTAssert(tokens.count == 7)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
    
    func testSimpleExpressionparseExpressions() {
        let example = "Hello, World!"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 6)
    }
    
    func testLetterOnlyHashtagExpressionParse() {
        let example = "Hello, this is a #Hashtag"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testNumberOnlyHashtagExpressionParse() {
        let example = "Hello, this is a #123456"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed1OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #Hash123"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed2OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #123Hash"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed3OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #Hash_123"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed4OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #Hash_123_"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed5OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #_Hash_123"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed6OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #_Hash_123_"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMultipleOnlyExpressionParse() {
        let example = "Hello, #this #is a #_Hash_123_"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMentionNpubExpressionParse() {
        let example = "Hello, this is a mention with @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 15)
    }
    
    func testMentionNpubAndHashtagExpressionParse() {
        let example = "Hello, this is a #hashtag_mention with @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 15)
    }
    
    func testNostrNpubExpressionParse() {
        let example = "Hello nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 4)
    }
    
    func testNostrNpubExpressionAndURLParse() {
        let example = "Hello nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg, this is cool https://pbs.twimg.com/media/FwCq7n0XgAMydpR?format=jpg&name=small"
        let parser = NoteParser(example)
        let result = parser.parse()
        
        XCTAssertTrue(result.mentions.count == 1)
        XCTAssert(result.mentions.first?.text == "nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg")
    }
    
    func testNostrNoteExpressionParse() {
        let example = "Hello nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 4)
    }
    
    func testNostrNpubNoteMixedExpressionParse() {
        let example = "Hello nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg, this post: nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep is so cool"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 18)
    }
    
    func testMentionNpubAndNostrNpubNoteMixedExpressionParse() {
        let example = "Hello @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg and nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg, this post: nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep is so cool"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 22)
    }
    
    func testMentionNpubAndHashtagAndNostrNpubAndNostrNoteMixedExpressionParse() {
        let example = "Hello @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg and nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg, this #post: nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep is so #cool_2023"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        let mentionNpub = parser.parsedExpressions[2] as! MentionNpubExpressionSyntax
        XCTAssertEqual(mentionNpub.mentionToken.text.lowercased(), "@")
        XCTAssertEqual(mentionNpub.npubToken.text, "npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg")
        
        let nostrNpub = parser.parsedExpressions[6] as! NostrNpubExpressionSyntax
        XCTAssertEqual(nostrNpub.nostrToken.text.lowercased(), "nostr")
        XCTAssertEqual(nostrNpub.npubToken.text, "npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg")
        
        let hashtag1 = parser.parsedExpressions[11] as! HashtagExpressionSyntax
        XCTAssertEqual(hashtag1.hashtagToken.text.lowercased(), "#")
        XCTAssertEqual(hashtag1.textToken.text, "post")
        
        let nostrNote = parser.parsedExpressions[14] as! NostrNoteExpressionSyntax
        XCTAssertEqual(nostrNote.nostrToken.text.lowercased(), "nostr")
        XCTAssertEqual(nostrNote.noteToken.text, "note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep")
        
        let hashtag2 = parser.parsedExpressions[20] as! HashtagExpressionSyntax
        XCTAssertEqual(hashtag2.hashtagToken.text.lowercased(), "#")
        XCTAssertEqual(hashtag2.textToken.text, "cool_2023")
        
        XCTAssert(parser.parsedExpressions.count == 22)
    }
    
    func testParsedContentByReplacingOccurences() {
        let example = "Hello @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg and nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg, this #post: nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep is so #cool_2023"
        let parser = NoteParser(example)
        let content = parser.parse()
        
        var result = example
        
        content.mentions.forEach { mention in
            result = result.replacingOccurrences(of: mention.text, with: "mention")
        }
        
        content.hashtags.forEach { hashtag in
            result = result.replacingOccurrences(of: hashtag.text, with: "hashtag")
        }
        
        content.notes.forEach { note in
            result = result.replacingOccurrences(of: note.text, with: "note")
        }
        
        XCTAssertEqual(result, "Hello mention and mention, this hashtag: note is so hashtag")
    }
    
    func testParsedContentWithHttpUrl() {
        let example = "Hello @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg and nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg, this #post: nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep is so #cool_2023 and url (http://sample.info/?insect=fireman&porter=attraction#cave) and this is cool too: https://pbs.twimg.com/media/FwGRukMWcAYiSRY?format=jpg&name=medium and http://example.net/"
        let parser = NoteParser(example)
        let content = parser.parse()
        
        var result = example
        
        result = result.replacingOccurrences(of: content.firstExtractedURL, with: "httpUrl")
        
        content.mentions.forEach { mention in
            result = result.replacingOccurrences(of: mention.text, with: "mention")
        }
        
        content.hashtags.forEach { hashtag in
            result = result.replacingOccurrences(of: hashtag.text, with: "hashtag")
        }
        
        content.notes.forEach { note in
            result = result.replacingOccurrences(of: note.text, with: "note")
        }
        
        content.httpUrls.forEach { httpUrl in
            result = result.replacingOccurrences(of: httpUrl.text, with: "httpUrl")
        }
        
        XCTAssertEqual(result, "Hello mention and mention, this hashtag: note is so hashtag and url (httpUrl) and this is cool too: httpUrl and httpUrl")
    }
    
    func testParsedContentWithHttpAndImageUrls() {
        let example = "Hello @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg and nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg, this #post: nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep is so #cool_2023 and url (http://sample.info/?insect=fireman&porter=attraction#cave) and this is cool too: https://cdn-images-1.medium.com/max/593/1*LCJRpFgJIjk8jSGRrXe62w.jpeg and http://example.net/"
        let parser = NoteParser(example)
        let content = parser.parse()
        
        var result = example
        
        result = result.replacingOccurrences(of: content.firstExtractedURL, with: "httpUrl")
        
        content.mentions.forEach { mention in
            result = result.replacingOccurrences(of: mention.text, with: "mention")
        }
        
        content.hashtags.forEach { hashtag in
            result = result.replacingOccurrences(of: hashtag.text, with: "hashtag")
        }
        
        content.notes.forEach { note in
            result = result.replacingOccurrences(of: note.text, with: "note")
        }
        
        content.httpUrls.forEach { httpUrl in
            result = result.replacingOccurrences(of: httpUrl.text, with: "httpUrl")
        }
        
        content.imageUrls.forEach { imageUrl in
            result = result.replacingOccurrences(of: imageUrl, with: "imageUrl")
        }
        
        XCTAssertEqual(content.imageUrls.count, 1)
        XCTAssertEqual(content.imageUrls.first, "https://cdn-images-1.medium.com/max/593/1*LCJRpFgJIjk8jSGRrXe62w.jpeg")
        XCTAssertEqual(result, "Hello mention and mention, this hashtag: note is so hashtag and url (httpUrl) and this is cool too: imageUrl and httpUrl")
    }
    
    func testInfiniteLoop1() {
        let example = "#[0]​ your email server seems to block mine so heres a patch over nostr instead for cln-nostr-wallet-connect\n\ncurl https://jb55.com/s/379a833ddd8114ef.txt | git am"
        
        let parser = NoteParser(example)
        let content = parser.parse()
        
        XCTAssertNotNil(content)
    }
    
    func testInfiniteLoop2() {
        let example = "Why Everything\'s Changing\n\nWhen building an economy on top of a global settlement layer, that currency or bedrock cannot deflect. For the past 40 years, that bedrock has been the US treasury market (it\'s massive - tens of trillions of dollars). And for 40 years, anyone who saved their retained earnings in that bedrock saw the value continue to appreciate in buying power. Everyone knows that when bond yields go down, prices go up. The chart below showing the drop in yield (up in price) is why this form of savings worked so well for the world. However, this only works if the bedrock doesn\'t start to deflect. In financial terms, the bedrock of bonds will deflect if inflation cannot be controlled. As any engineer understands, if the bedrock is deflecting, EVERYTHING built upon it starts to crack and break down. Why does inflation cause the bedrock to deflect? Because investors in bonds need to have a higher yield than inflation, or else they are guaranteed to lose buying power. If inflation is 5% and the bond yields 3%, then you\'ll lose -2% in buying power if those yields remain persistent.\n\nSo, why are we seeing inflation? I\'d argue inflation manifests itself through three main ways. The first and obvious way is just increasing the amount of monetary units in the overall system – everyone understands this one. What a lot of people don\'t understand is that you can add monetary units into a system, but they might not \"nest\" themselves in areas that most people see or expect. For example, trillions of monetary units were added into the system since 2008, and most of those monetary units \"nested\" themselves in the capitalization rates of stocks and bonds.  You didn\'t see the CPI gage ever go up. But if you\'re a person who doesn\'t own stocks and bonds, well, you wouldn\'t see that capital appreciation in your day-to-day life. The second way is through supply destruction. Imagine you were on a remote island that was fairly self-sufficient and a tropical storm destroyed a bunch of infrastructure. Through that event, everyone on the island quickly needs to preserve and own essential supplies like energy and food. What you would find while supply chains are damaged is a bidding of prices on desirable goods and services. With enough time, as long as a free and open markets were allowed to persist, the supply chains will naturally self-correct, and prices will return to normal (as long as the other two means of creating inflation weren\'t exercised). Finally, the third way inflation can happen is through supply destruction caused by manipulated incentives via public policy decisions. When policymakers create incentives for growth in infrastructure, what they rarely talk about is what they AREN\'T incentivizing through that action. The economy is massive, and one small incentive for sector XYZ seems harmless as a singular event. But when policy after policy is exercised by government bureaucrats, the things they AREN\'T incentivized really add up and create a false sense of \"free and open\" markets. The next thing you know, people are incentivized (due to policy) to build things that are less efficient and less constructive to society than what a REAL free and open market would produce. If you take these policy decisions far enough and long enough without the free and open market being able to experience creative destruction, then supply chains at large become completely dysfunctional and fragile.\n\nWhen we look at what happened with COVID, we literally have all three of these things playing out: manipulation of the money supply, 40 years of horrific policy decisions that have created hyper-fragile supply chains, and a global pandemic that disrupted organic activity. In addition to all of that (and maybe BECAUSE of that), countries that are net-producers are at war, or reconstructing trade agreements, with countries that are net-consumers. People might think the war between Russia and Ukraine is a localized situation, but it\'s actually much broader and strategic than that. In short, the net producers of the world don\'t want to give up their physical goods for the paper promises that net-consumers INSIST they accept as payment. The net-producers understand the bedrock is deflecting. The net-producers understand that the math behind these impaired bonds will remain impaired. Why? Because for the supply chains to actually become less fragile, the decades of poor incentives that were brought about through compounding poor policy decisions isn\'t going to end anytime soon. In fact, the problem is being amplified because net-consumers are trying to offset the bad policy decisions by adding more monetary units into the system (see #1 for creating inflation).\n\nSo, what CAN the world build upon that doesn\'t deflect? Well, anyone who follows my account probably already knows my opinion: Bitcoin. First and foremost, Bitcoin\'s decentralized nature ensures a robust and tamper-resistant foundation for the global economy. Unlike traditional currencies controlled by central banks and governments, Bitcoin operates on a decentralized network that is immune to political interference and manipulation. No more waiting for Jerome Powell to blink three times and watch the global markets move by $5 trillion. Next, the capped supply of 21 million coins addresses the issue of inflation that has plagued traditional currencies. With a finite supply, Bitcoin inherently resists inflationary pressures that erode the value of other currencies. This means that individuals and institutions who choose to store their wealth in Bitcoin can expect their purchasing power to be preserved over time, unlike those who rely on bonds and other assets that are vulnerable to more monetary units being added into the economy and into the hands of a chosen few. Additionally, Bitcoin transcends borders and mends the discord between net-producers and net-consumers: they no longer need to TRUST each other. The borderless and frictionless nature of Bitcoin allows for swift and cost-effective international settlements. By facilitating global trade and economic expansion, Bitcoin has the potential to usher in a new era of financial inclusion and prosperity. Finally, Bitcoin\'s ability to serve as a hedge against the deflection of traditional settlement layers is perhaps its most compelling attribute. As the bedrock of the global economy, it is crucial that the settlement layer remains stable and secure. \n\nIn my humble opinion, you can choose to start buying Bitcoin after thoroughly understanding the game theory and logic behind its continued appreciation in value, or you can learn by sitting back and watching others grow their buying power. Either way, you\'re eventually going to learn about Bitcoin, whether you like it or not. https://nostr.build/i/nostr.build_4a2536d00a6689fe865695d7ec261f8398c56a0a0e807e8d2b1eb24c74e1a770.png"
        
        let parser = NoteParser(example)
        let content = parser.parse()
        
        XCTAssertNotNil(content)
    }
}
