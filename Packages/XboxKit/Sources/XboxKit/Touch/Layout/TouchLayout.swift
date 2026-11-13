//
//  TouchLayout.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

public struct TouchLayout: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case content
        case styles
    }

    private enum ContentKeys: String, CodingKey {
        case layers
    }

    private enum StylesKeys: String, CodingKey {
        case colors
    }

    private enum ColorsKeys: String, CodingKey {
        case palette = "default"
        case highContrastPalette = "highContrast"
    }

    public var base: TouchLayer
    public var layers: [String: TouchLayer]
    public var palette: [String: TouchColor]
    public var highContrastPalette: [String: TouchColor]

    public init(
        base: TouchLayer,
        layers: [String: TouchLayer] = [:],
        palette: [String: TouchColor] = [:],
        highContrastPalette: [String: TouchColor] = [:]
    ) {
        self.base = base
        self.layers = layers
        self.palette = palette
        self.highContrastPalette = highContrastPalette
    }

    public init(json: Data, context: TouchContext) throws(TouchLayoutError) {
        let document: JSONValue

        do {
            document = try TouchJSONDecoder().decode(JSONValue.self, from: json)
        } catch {
            throw .malformedJSON(String(describing: error))
        }

        let resolved = try TouchReferenceResolver(layout: document, context: context.document)
            .resolvedLayout()

        do {
            self = try JSONDecoder().decode(TouchLayout.self, from: JSONEncoder().encode(resolved))
        } catch {
            throw .invalidLayout(String(describing: error))
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let content = try container.nestedContainer(keyedBy: ContentKeys.self, forKey: .content)
        let styles = try? container.nestedContainer(keyedBy: StylesKeys.self, forKey: .styles)
        let colors = try? styles?.nestedContainer(keyedBy: ColorsKeys.self, forKey: .colors)

        base = try container.decode(TouchLayer.self, forKey: .content)
        layers = try content.decodeIfPresent([String: TouchLayer].self, forKey: .layers) ?? [:]
        palette =
            (try? colors?.decodeIfPresent([String: TouchColor].self, forKey: .palette)) ?? [:]
        highContrastPalette =
            (try? colors?.decodeIfPresent([String: TouchColor].self, forKey: .highContrastPalette))
            ?? [:]
    }
}
