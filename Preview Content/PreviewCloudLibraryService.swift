//
//  PreviewCloudLibraryService.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import StarfoldShared

struct PreviewCloudLibraryService: CloudLibraryService {
    let reply: PreviewReply
    let content: CloudLibrary

    func library() async throws -> CloudLibrary {
        try await reply.answer(content)
    }
}
#endif
