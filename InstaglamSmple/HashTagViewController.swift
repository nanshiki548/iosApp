////
////  HashTagViewController.swift
////  InstaglamSmple
////
////  Created by 松田竜弥 on 2020/06/14.
////  Copyright © 2020 松田竜弥. All rights reserved.
////
//
//import UIKit
//
//protocol HashTagInteractable: class {
//    var paramKey: String { get }
//    func getHashTag(interactURL: URL) -> String?
//    func createHashTagURL(hashTag: String) -> URL
//}
//extension HashTagInteractable {
//
//    var paramKey: String {
//        return "hash_tag"
//    }
//
//    func getHashTag(interactURL: URL) -> String? {
//        if let urlComponents = URLComponents(url: interactURL, resolvingAgainstBaseURL: true),
//            let queryItems = urlComponents.queryItems {
//            return queryItems.first(where: { queryItem -> Bool in queryItem.name == self.paramKey })?.value
//        }
//        return nil
//    }
//    func createHashTagURL(hashTag: String) -> URL {
//        var urlComponents = URLComponents(string: "app://hashtag")!
//        urlComponents.queryItems = [URLQueryItem(name: self.paramKey, value: hashTag)]
//        return urlComponents.url!
//    }
//}
//
//
//
//
//private extension String {
//    /// ハッシュタグサポート文字のみかチェックする
//    /// 別途Stringの拡張で定義されている [String.containsEmoji]は一部のサロゲートペアなどに対応しておらず、
//    /// 本処理ではハッシュタグとしてサポートしている文字のみが含まれているかをチェックするprivate拡張
//    /// - returns: true...ハッシュタグサポート文字のみ、false...ハッシュタグでサポートしていない文字が含まれている
//    var isOnlySupportedHashTag: Bool {
//        return !self.contains { $0.isSingleEmoji || $0.isContainsOtherSymbol }
//    }
//}
//private extension Character {
//    /// OtherSymbolが含まれるかチェックする
//    /// なお、OtherSymbolとは算術記号、通貨記号、または修飾子記号以外の記号を示す
//    /// - returns: true...otherSymbolが含まれる、false...otherSymbolが含まれない
//    var isContainsOtherSymbol: Bool {
//        return self.unicodeScalars.count > 1
//            && self.unicodeScalars.contains { $0.properties.generalCategory == Unicode.GeneralCategory.otherSymbol }
//    }
//
//    /// 1️⃣などの単体UnicodeであるEmoji是非
//    /// - returns: true...Emoji、false...Emojiではない
//    var isSingleEmoji: Bool {
//        return self.unicodeScalars.count == 1
//            && self.unicodeScalars.first?.properties.isEmojiPresentation ?? false
//    }
//}
//
//
//
//
//
//extension UITextView {
//    
//    /// 「#」から始まるハッシュタグに文字装飾を設定する
//    public func decorateHashTag() {
//        if self.markedTextRange != nil {
//            // 日本語入力中などは適用しないように制御
//            return
//        }
//
//        // 自身のDelegateがHashTagInteractableのprotocolを実装しているかチェックする
//        let hashTagInteractable = self.delegate as? HashTagInteractable
//
//        do {
//            // フォントの大きさなどを引き継ぐため、`NSMutableAttributedString init(attributedString:)`を使用する
//            let attrString = NSMutableAttributedString(attributedString: self.attributedText)
//
//            attrString.beginEditing()
//            defer {
//                attrString.endEditing()
//            }
//
//            // Emojiはサロゲートペアを含む
//            // このため、Emojiを含んだ正規表現でのNSRangeの長さは[String.utf16.count]を使用する
//            let range = NSRange(location: 0, length: self.text.utf16.count)
//            let regix = try NSRegularExpression(pattern: "(?:^|\\s)(#([^\\s]+))[^\\s]?", options: .anchorsMatchLines)
//            let matcher = regix.matches(in: self.text, options: .withTransparentBounds, range: range)
//
//            // 前回設定していたハッシュタグ用の文字装飾を除去する
//            attrString.removeAttribute(.foregroundColor, range: range)
//            attrString.removeAttribute(.underlineStyle, range: range)
//
//            let results = matcher.compactMap { (tagRange: $0.range(at: 1), contentRange: $0.range(at: 2)) }
//            let nsString = NSString(string: self.text)
//            for result in results {
//                let content = nsString.substring(with: result.contentRange)
//                if !content.isOnlySupportedHashTag  {
//                    // Emojiを含む場合は対象外とする
//                    continue
//                }
//
//                var attributes: [NSAttributedString.Key: Any] =
//                    [.foregroundColor: UIColor.blue,
//                     .underlineStyle: NSUnderlineStyle.single.rawValue]
//                if let hashTagInteractable: HashTagInteractable =  hashTagInteractable {
//                    // リンク化する場合は UITextViewDelegate textView(_:shouldInteractWith:in:interaction:)による起動を行う
//                    attributes[.link] = hashTagInteractable.createHashTagURL(hashTag: content)
//                }
//                attrString.addAttributes(attributes, range: result.tagRange)
//            }
//            attrString.endEditing()
//            self.attributedText = attrString
//        } catch {
//            debugPrint("convert hash tag failed.:=\(error)")
//        }
//    }
//}
//
//
//
