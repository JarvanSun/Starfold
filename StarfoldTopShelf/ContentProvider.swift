//
//  ContentProvider.swift
//  StarfoldTopShelf
//
//  Created by Jiawen Sun on 2026/09/30.
//

import TVServices
import TopShelfKit

nonisolated final class ContentProvider: TVTopShelfContentProvider {
    override func loadTopShelfContent() async -> (any TVTopShelfContent)? {
        guard let snapshot = TopShelfStore().load(), !snapshot.isEmpty else { return nil }

        return TVTopShelfSectionedContent(sections: sections(for: snapshot))
    }
}

nonisolated private extension ContentProvider {
    func sections(
        for snapshot: TopShelfSnapshot
    ) -> [TVTopShelfItemCollection<TVTopShelfSectionedItem>] {
        let games = section(snapshot.gamesTitle, items: snapshot.games) { item, shouldPlay in
            .game(id: item.id, name: item.title, shouldPlay: shouldPlay)
        }
        let consoles = section(snapshot.consolesTitle, items: snapshot.consoles) { item, _ in
            .console(id: item.id, name: item.title)
        }
        return [games, consoles].filter { !$0.items.isEmpty }
    }

    func section(
        _ title: String,
        items: [TopShelfItem],
        link: (TopShelfItem, Bool) -> TopShelfLink
    ) -> TVTopShelfItemCollection<TVTopShelfSectionedItem> {
        let collection = TVTopShelfItemCollection(
            items: items.map { shelfItem(for: $0, link: link) }
        )
        collection.title = title
        return collection
    }

    func shelfItem(
        for item: TopShelfItem,
        link: (TopShelfItem, Bool) -> TopShelfLink
    ) -> TVTopShelfSectionedItem {
        let shelfItem = TVTopShelfSectionedItem(identifier: item.id)
        shelfItem.title = item.title
        shelfItem.imageShape = .hdtv

        if let url = item.imageURL {
            shelfItem.setImageURL(url, for: [.screenScale1x, .screenScale2x])
        }

        shelfItem.displayAction = TVTopShelfAction(url: link(item, false).url)
        shelfItem.playAction = TVTopShelfAction(url: link(item, true).url)
        return shelfItem
    }
}
