//
//  Scryfall.swift
//  mtg
//
//  Created by Andrew McKnight on 12/30/23.
//

import Foundation

/* * * * * * * * * * * * * * * * * * * * * * * *  *\
 * Following are translations from the typescript  *
 * definitions in the scryfall git repo at         *
 * https://github.com/scryfall/api-types/tree/main *
 \* * * * * * * * * * * * * * * * * * * * * * * * */

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/Format.ts#L10
public enum ScryfallFormat: String, Codable, CodingKeyRepresentable {
    case standard
    case future
    case historic
    case gladiator
    case pioneer
    case explorer
    case modern
    case legacy
    case pauper
    case vintage
    case penny
    case commander
    case oathbreaker
    case brawl
    case alchemy
    case paupercommander
    case duel
    case oldschool
    case premodern
    case predh
    case timeless // proposed to add in https://github.com/scryfall/api-types/pull/8; merged ✅
    case standardbrawl // proposed to replace historicbrawl in https://github.com/scryfall/api-types/pull/22
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/PurchaseUris.ts#L7
public struct ScryfallPurchaseURLs: Codable {
    /** This card's purchase page on TCGPlayer. */
    public var tcgplayer: URL
    /** This card's purchase page on Cardmarket. Often inexact due to how Cardmarket links work. */
    public var cardmarket: URL
    /** This card's purchase page on Cardhoarder. */
    public var cardhoarder: URL
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/RelatedUris.ts
public struct ScryfallRelatedURLs: Codable {
    /** This card's Gatherer page. */
    public var gatherer: URL?
    /** TCGPlayer Infinite articles related to this card. */
    public var tcgplayer_infinite_articles: URL?
    /** TCGPlayer Infinite decks with this card. */
    public var tcgplayer_infinite_decks: URL?
    /** EDHREC's page for this card. */
    public var edhrec: URL?
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/Color.ts
public enum ScryfallColor: String, Codable {
    case W
    case U
    case B
    case R
    case G
    /** Colorless is not a color, but sometimes this API uses it as one. */
    case C
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/ManaType.ts
public enum ScryfallManaType: String, Codable {
    case W
    case U
    case B
    case R
    case G
    case C
    case T // see https://scryfall.com/card/24649a26-822e-456f-8f28-8e1d002fdd81, which produces a "tap" that can be used to activate a tapped ability on a card without tapping it; proposed to add in https://github.com/scryfall/api-types/pull/15
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/BorderColor.ts
public enum ScryfallBorderColor: String, Codable {
    case black
    case white
    case borderless
    case silver
    case gold
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/FrameEffect.ts
public enum ScryfallFrameEffect: String, Codable {
    /** The cards have a legendary crown */
    case legendary
    /** The miracle frame effect */
    case miracle
    /** The Nyx-touched frame effect */
    case nyxtouched
    /** The draft-matters frame effect */
    case draft
    /** The Devoid frame effect */
    case devoid
    /** The Odyssey tombstone mark */
    case tombstone
    /** A colorshifted frame */
    case colorshifted
    /** The FNM-style inverted frame */
    case inverted
    /** The sun and moon transform marks */
    case sunmoondfc
    /** The compass and land transform marks */
    case compasslanddfc
    /** The Origins and planeswalker transform marks */
    case originpwdfc
    /** The moon and Eldrazi transform marks */
    case mooneldrazidfc
    /** The waxing and waning crescent moon transform marks */
    case waxingandwaningmoondfc
    /** A custom Showcase frame */
    case showcase
    /** An extended art frame */
    case extendedart
    /** The cards have a companion frame */
    case companion
    /** The cards have an etched foil treatment */
    case etched
    /** The cards have the snowy frame effect */
    case snow
    /** The cards have the Lesson frame effect */
    case lesson
    /** The cards have the Shattered Glass frame effect */
    case shatteredglass
    /** The cards have More Than Meets the Eye™ marks */
    case convertdfc
    /** The cards have fan transforming marks */
    case fandfc
    /** The cards have the Upside Down transforming marks */
    case upsidedowndfc
    // proposed to add in https://github.com/scryfall/api-types/pull/9 but rejected as a fix to add it to promo_types is forthcoming
    case fullart
    // proposed to add in https://github.com/scryfall/api-types/pull/14
    case borderless
    // proposed to add in https://github.com/scryfall/api-types/pull/16
    case stamped
    // proposed to add in https://github.com/scryfall/api-types/pull/16
    case promo
    // proposed to add in https://github.com/scryfall/api-types/pull/17
    case textless
    case spree // from Outlaws of Thunder Junction
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/Game.ts
public enum ScryfallGame: String, Codable {
    /**
     * The printed paper game.
     * Released in 1993.
     */
    case paper
    /**
     * Magic: the Gathering Online
     * Released in 2002.
     */
    case mtgo
    /**
     * Magic: the Gathering: Arena
     * Released in 2018.
     */
    case arena
    /**
     * Magic: the Gathering (MicroProse)
     * Released in 1997.
     *
     * This game included an expansion named Astral that included some unique cards.
     */
    case astral
    /**
     * Magic: the Gathering (Sega Dreamcast)
     * Released in 2001.
     */
    case sega
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/Prices.ts#L4
public struct ScryfallPrices: Codable {
    public var usd: String?
    public var usd_foil: String?
    public var usd_etched: String?
    public var eur: String?
    public var eur_foil: String?
    public var tix: String?
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/Rarity.ts
public enum ScryfallRarity: String, Codable {
    case common
    case uncommon
    case rare
    case special
    case mythic
    case bonus
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/ImageStatus.ts
public enum ScryfallImageStatus: String, Codable {
    /**
     * This card's image is missing. It has not been added yet.
     * This is usually an error Scryfall will catch quickly, but some cases involve uploading cards that simply do not yet have images available at all, such as unsigned art cards.
     */
    case missing
    /**
     * This card's image is a placeholder Scryfall has generated and visibly marked as such.
     * This is most commonly seen for languages where no real images are yet available to us.
     */
    case placeholder
    /**
     * This card's image is low resolution.
     * This will most commonly be seen on recently previewed cards.
     */
    case lowres
    /**
     * This card's image is high resolution and/or a scan.
     * In theory this should be a scan, in practice it might be tripped by other large imagery.
     */
    case highres_scan
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/ImageSize.ts#L1
public enum ScryfallImageSize: String, Codable, CodingKeyRepresentable {
    /**
     * A small image.
     *
     * Dimensions: 146 x 204
     * Size: Approx 10kb
     * Filetype: JPG
     */
    case small
    /**
     * A normal image.
     *
     * Dimensions: 488 x 680
     * Size: Approx 60kb
     * Filetype: JPG
     */
    case normal
    /**
     * A large image.
     *
     * Dimensions: 672 x 936
     * Size: Approx 100kb
     * Filetype: JPG
     */
    case large
    /**
     * A large PNG with transparent corners.
     *
     * This is the highest quality image with the largest dimensions.
     *
     * Dimensions: 745 x 1040
     * Size: Approx 1mb
     * Filetype: PNG
     */
    case png
    /**
     * A crop from the PNG representing just the artwork portion of the card.
     *
     * Dimensions: Varies
     * Size: Approx 50kb-100kb
     * Filetype: JPG
     */
    case art_crop
    /**
     * A version of the image that crops off a precise amount around the edges to omit the border.
     *
     * Cards receive identical cropping regardless of how thick their actual border is. Even borderless cards will receive the same crop.
     *
     * This image size exists for backwards compatibility with MagicCards.info.
     * Some systems will use this and illustrate their own border around the edge in CSS.
     *
     * Dimensions: 480 x 680
     * Size: Approx 60kb
     * Filetype: JPG
     */
    case border_crop
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/PrintAttribute.ts#L53
/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/Finishes.ts#L9
public enum ScryfallPromoType: String, Codable {
    
    // these are from https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/Finishes.ts#L9
    
    /**
     * A glossy finish.
     */
    case glossy
    /**
     * The silverfoil finish.
     */
    case silverfoil
    /**
     * The confetti foil finish. This looks glimmery like confetti laying on top of the card.
     */
    case confettifoil
    /**
     * The Dungeons & Dragons glossy finish that superimposed an ampersand over the card.
     */
    case ampersand
    /**
     * Galaxy foil.
     * TODO
     */
    case galaxyfoil
    /**
     * Halo foil.
     * TODO
     */
    case halofoil
    /**
     * Surge foil
     */
    case surgefoil
    /**
     * Double the rainbow vs normal cards.
     */
    case doublerainbow
    /**
     * A textured foil finish.
     */
    case textured
    /**
     * A Phyrexian finish that involved dark cards embossed with shiny black gloss.
     */
    case oilslick
    /**
     * Neon ink embossd on the card frame and art.
     */
    case neonink
    /**
     * A Capenna foil style that embosses the art deco frame with shininess.
     */
    case gilded
    /**
     * Rainbow phyrexian symbols patterned over the card face.
     * @trivia The name was a reference to "step and repeat", a style of pattern used in printing banners.
     */
    
    case stepandcompleat
    
    // proposed to add in https://github.com/scryfall/api-types/pull/12
    case embossed
    
    // proposed to add in https://github.com/scryfall/api-types/pull/23
    /**
     * The showcase finish style from Murders at Karlov Manor.
     */
    case dossier
    
    // proposed to add in https://github.com/scryfall/api-types/pull/24
    /**
     * Special dossier cards from Murders at Karlov Manor with extra handwritten flavor text and imagery..
     */
    case invisibleink
    
    // proposed to add in https://github.com/scryfall/api-types/pull/26
    /**
     * Another showcase style from Murders at Karlov Manor.
     */
    case magnified
    
    // proposed to add in https://github.com/scryfall/api-types/pull/27
    /**
     * A special treatment applied to certain guild leader cards.
     */
    case ravnicacity
    
    // these are from https://github.com/armcknight/scryfall-api-types/blob/patch-2/src/objects/Card/values/PrintAttribute.ts
    
    case alchemy
    case arenaleague
    case boosterfun
    case boxtopper
    case brawldeck
    case bringafriend
    case bundle
    case buyabox
    case commanderparty
    case concept
    case convention
    case datestamped
    case draculaseries
    case draftweekend
    case duels
    case event
    case fnm
    case gameday
    case giftbox
    case godzillaseries
    case instore
    case intropack
    case jpwalker
    case judgegift
    case league
    case mediainsert
    case moonlitland
    case openhouse
    case planeswalkerdeck
    case plastic
    case playerrewards
    case playpromo
    case premiereshop
    case prerelease
    case promopack
    case rebalanced
    case release
    case schinesealtart
    case serialized
    case setextension
    case setpromo
    case stamped
    case starterdeck
    case storechampionship
    case themepack
    case thick
    case tourney
    case wizardsplaynetwork
    
    // proposed to add in https://github.com/scryfall/api-types/pull/11
    case scroll
    // proposed to add in https://github.com/scryfall/api-types/pull/13
    case poster

    case vault
    case rainbow
    case rainbowfoil
    case raisedfoil
    case ripplefoil
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/SecurityStamp.ts
public enum ScryfallSecurityStamp: String, Codable {
    case oval
    case triangle
    case acorn
    case circle
    case arena
    case heart
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Set/values/SetType.ts#L1
public enum ScryfallSetType: String, Codable {
    /** A yearly Magic core set (Tenth Edition, etc) */
    case core
    
    /** A rotational expansion set in a block (Zendikar, etc) */
    case expansion
    
    /** A reprint set that contains no new cards (Modern Masters, etc) */
    case masters
    
    /** An Arena set designed for Alchemy */
    case alchemy
    
    /** Masterpiece Series premium foil cards */
    case masterpiece
    
    /** A Commander-oriented gift set */
    case arsenal
    
    /** From the Vault gift sets */
    case from_the_vault
    
    /** Spellbook series gift sets */
    case spellbook
    
    /** Premium Deck Series decks */
    case premium_deck
    
    /** Duel Decks */
    case duel_deck
    
    /** Special draft sets, like Conspiracy and Battlebond */
    case draft_innovation
    
    /** Magic Online treasure chest prize sets */
    case treasure_chest
    
    /** Commander preconstructed decks */
    case commander
    
    /** Planechase sets */
    case planechase
    
    /** Archenemy sets */
    case archenemy
    
    /** Vanguard card sets */
    case vanguard
    
    /** A funny un-set or set with funny promos (Unglued, Happy Holidays, etc) */
    case funny
    
    /** A starter/introductory set (Portal, etc) */
    case starter
    
    /** A gift box set */
    case box
    
    /** A set that contains purely promotional cards */
    case promo
    
    /** A set made up of tokens and emblems. */
    case token
    
    /** A set made up of gold-bordered, oversize, or trophy cards that are not legal */
    case memorabilia
    
    /** A set that contains minigame card inserts from booster packs */
    case minigame
}


/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/LanguageCode.ts#L43
public enum ScryfallLanguageCode: String, Codable {
    /** English */
    case en
    /** Spanish */
    case es
    /** French */
    case fr
    /** German */
    case de
    /** Italian */
    case it
    /** Portuguese */
    case pt
    /** Japanese */
    case ja
    /** Korean */
    case ko
    /** Russian */
    case ru
    /** Simplified Chinese */
    case zhs
    /** Traditional Chinese */
    case zht
    /** Hebrew */
    case he
    /** Latin */
    case la
    /** Ancient Greek */
    case grc
    /** Arabic */
    case ar
    /** Sanskrit */
    case sa
    /** Phyrexian */
    case ph
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/Layout.ts
public enum ScryfallLayout: String, Codable {
    /** A standard Magic card with one face */
    case normal
    /** A split-faced card */
    case split
    /** Cards that invert vertically with the flip keyword */
    case flip
    /** Double-sided cards that transform */
    case transform
    /** Double-sided cards that can be played either-side */
    case modal_dfc
    /** Cards with meld parts printed on the back */
    case meld
    /** Cards with Level Up */
    case leveler
    /** Class-type enchantment cards */
    case `class`
    /** Saga-type cards */
    case saga
    /** Cards with an Adventure spell part */
    case adventure
    /** Cards with Mutate */
    case mutate
    /** Cards with Prototype */
    case prototype
    /** Battle-type cards */
    case battle
    /** Plane and Phenomenon-type cards */
    case planar
    /** Scheme-type cards */
    case scheme
    /** Vanguard-type cards */
    case vanguard
    /** Token cards */
    case token
    /** Tokens with another token printed on the back */
    case double_faced_token
    /** Emblem cards */
    case emblem
    /** Cards with Augment */
    case augment
    /** Host-type cards */
    case host
    /** Art Series collectable double-faced cards */
    case art_series
    /** A Magic card with two sides that are unrelated */
    case reversible_card
    
    // proposed to add in https://github.com/scryfall/api-types/pull/25
    /** A special type of multi-part enchantment from Murders at Karlov Manor */
    case `case`
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/RelatedCard.ts
public struct ScryfallRelatedCard: Codable {
    /**
     * An unique ID for this card in Scryfall’s database.
     */
    public var id: UUID
    /**
     * A field explaining what role this card plays in this relationship.
     */
    public enum Component: String, Codable {
        case token
        case meld_part
        case meld_result
        case combo_piece
    }
    public var component: Component
    /**
     * The name of this particular related card.
     */
    public var name: String
    /**
     * The type line of this card.
     */
    public var type_line: String
    /**
     * A URI where you can retrieve a full object describing this card on Scryfall’s API.
     */
    public var uri: URL
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/values/Legality.ts
public enum ScryfallLegality: String, Codable {
    case legal
    case not_legal
    case restricted
    case banned
}

/// - seealso: https://github.com/scryfall/api-types/blob/d0f5f7e17aaded2ec877db6d1a68868259ca1edc/src/objects/Card/CardFields.ts
public struct ScryfallCard: Codable {    
    /** The date this card was previewed. */
    public var previewed_at: Date?
    /** A link to the preview for this card. */
    public var source_uri: URL?
    /** The name of the source that previewed this card. */
    public var source: String?
    /**
     * The name of the illustrator of this card. Newly spoiled cards may not have this field yet.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var artist: String?
    /**
     * The IDs of the artists that illustrated this card. Newly spoiled cards may not have this field yet.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var artist_ids: [UUID]?
    /**
     * The lit Unfinity attractions lights on this card, if any.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var attraction_lights: [Int]?
    /**
     * Whether this card is found in boosters.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var booster: Bool?
    /**
     * This card’s border color: black, white, borderless, silver, or gold.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var border_color: ScryfallBorderColor?
    /**
     * This card’s collector number. Note that collector numbers can contain non-numeric characters, such as letters or ★.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var collector_number: String?
    /**
     * True if you should consider avoiding use of this print downstream.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var content_warning: Bool?
    /**
     * True if this card was only released in a video game.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var digital: Bool?
    /**
     * This card’s frame effects, if any.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var frame_effects: [ScryfallFrameEffect]?
    /**
     * This card’s frame layout.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var frame: String?
    /**
     * True if this card’s artwork is larger than normal.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var full_art: Bool?
    /**
     * A list of games that this card print is available in, paper, arena, and/or mtgo.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var games: [ScryfallGame]?
    /**
     * True if this card’s imagery is high resolution.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var highres_image: Bool?
    /**
     * A unique identifier for the card artwork that remains consistent across reprints. Newly spoiled cards may not have this field yet.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var illustration_id: UUID?
    /**
     * A computer-readable indicator for the state of this card’s image, one of missing, placeholder, lowres, or highres_scan.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var image_status: ScryfallImageStatus?
    /**
     * True if this card is oversized.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var oversized: Bool?
    /**
     * An object containing daily price information for this card, including usd, usd_foil, usd_etched, eur, eur_foil, eur_etched, and tix prices, as strings.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var prices: ScryfallPrices?
    /**
     * True if this card is a promotional print.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var promo: Bool?
    /**
     * An array of strings describing what categories of promo cards this card falls into.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var promo_types: [ScryfallPromoType]?
    /**
     * An object providing URIs to this card’s listing on major marketplaces. Omitted if the card is unpurchaseable.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var purchase_uris: ScryfallPurchaseURLs?
    /**
     * This card’s rarity.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var rarity: ScryfallRarity?
    /**
     * An object providing URIs to this card’s listing on other Magic: The Gathering online resources.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var related_uris: ScryfallRelatedURLs?
    /**
     * The date this card was first released.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var released_at: String?
    /**
     * True if this card is a reprint.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var reprint: Bool?
    /**
     * A link to this card’s set on Scryfall’s website.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var scryfall_set_uri: URL?
    /**
     * This card’s full set name.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var set_name: String?
    /**
     * A link to where you can begin paginating this card’s set on the Scryfall API.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var set_search_uri: URL?
    /**
     * The type of set this printing is in.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var set_type: ScryfallSetType?
    /**
     * A link to this card’s set object on Scryfall’s API.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var set_uri: URL?
    /**
     * This card’s set code.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var set: String?
    /**
     * This card’s Set object UUID.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var set_id: UUID?
    /**
     * True if this card is a Story Spotlight.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var story_spotlight: Bool?
    /**
     * True if the card is printed without text.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var textless: Bool?
    /**
     * The security stamp on this card, if any.
     * - note: Root level for a non-reversible card, card face level for a reversible card.
     */
    public var security_stamp: ScryfallSecurityStamp?
    /**
     * The Scryfall ID for the card back design present on this card.
     * - note: Single-sided only
     */
    public var card_back_id: UUID?
    /**
     * An object listing available imagery for this card. See the Card Imagery article for more information.
     * - note: Root level for single-sided cards, whether with single-part or multi-part; Card face level for cards with two sides, e.g. a DFC or a reversible card.
     */
    public var image_uris: [ScryfallImageSize: URL]?
    /** The localized name printed on this card, if any. */
    public var printed_name: String?
    /** The localized text printed on this card, if any. */
    public var printed_text: String?
    /** The localized type line printed on this card, if any. */
    public var printed_type_line: String?
    /** The printing ID of the printing this card is a variation of. */
    public var variation_of: UUID?
    /**
     * The colors in this card’s color indicator, if any. A null value for this field indicates the card does not have one.
     * - note: On multi-face cards, duplicated at the card and print level.
     */
    public var color_indicator: [ScryfallColor]?
    /**
     * The mana cost for this card. This value will be any empty string "" if the cost is absent. Remember that per the game rules, a missing mana cost and a mana cost of {0} are different  Multi-faced cards will report this value in card faces.
     * - note: On multi-face cards, duplicated at the card and print level.
     */
    public var mana_cost: String?
    /**
     * The name of this card.
     * - note: On multi-face cards, duplicated at the card and print level.
     */
    public var name: String
    /**
     * The type line of this card.
     * - note: On multi-face cards, duplicated at the card and print level.
     * - note: `nil` for `reversible_card` layouts
     */
    public var type_line: String?
    /**
     * The Oracle text for this card, if any.
     * - note: On multi-face cards, duplicated at the card and print level.
     */
    public var oracle_text: String?
    /** This card’s colors, if the overall card has colors defined by the rules. Otherwise the colors will be on the card_faces objects. */
    public var colors: [ScryfallColor]?
    /** A unique ID for this card in Scryfall’s database. */
    public var id: UUID
    /** A unique ID for this card’s oracle identity. This value is consistent across reprinted card editions, and unique among different cards with the same name (tokens, Unstable public variants, etc). Always present except for the reversible_card layout where it will be absent; oracle_id will be found on each face instead. */
    public var oracle_id: UUID?
    /** A language code for this printing. */
    public var lang: ScryfallLanguageCode
    /** A code for this card’s layout. */
    public var layout: ScryfallLayout
    /** A link to where you can begin paginating all re/prints for this card on Scryfall’s API. */
    public var prints_search_uri: URL
    /** A link to this card’s rulings list on Scryfall’s API. */
    public var rulings_uri: URL
    /** A link to this card’s permapage on Scryfall’s website. */
    public var scryfall_uri: URL
    /** A link to this card object on Scryfall’s API.  */
    public var uri: URL
    /** This card’s Arena ID, if any. A large percentage of cards are not available on Arena and do not have this ID. */
    public var arena_id: Int?
    /** This card’s Magic Online ID (also known as the Catalog ID), if any. A large percentage of cards are not available on Magic Online and do not have this ID. */
    public var mtgo_id: Int?
    /** This card’s foil Magic Online ID (also known as the Catalog ID), if any. A large percentage of cards are not available on Magic Online and do not have this ID. */
    public var mtgo_foil_id: Int?
    /** This card’s multiverse IDs on Gatherer, if any, as an array of integers. Note that Scryfall includes many promo cards, tokens, and other esoteric objects that do not have these identifiers. */
    public var multiverse_ids: [Int]?
    /** This card’s ID on TCGplayer’s API, also known as the productId. */
    public var tcgplayer_id: Int?
    /** This card’s ID on TCGplayer’s API, for its etched version if that version is a separate product. */
    public var tcgplayer_etched_id: Int?
    /** This card’s ID on Cardmarket’s API, also known as the idProduct. */
    public var cardmarket_id: Int?
    /** If this card is closely related to other cards, this property will be an array with Related Card Objects. */
    public var all_parts: [ScryfallRelatedCard]?
    /** An object describing the legality of this card across play formats. Possible legalities are legal, not_legal, restricted, and banned. */
    public var legalities: [ScryfallFormat: ScryfallLegality]
    /** An array of Card Face objects, if this card is multifaced. */
    public var card_faces: [CardFace]?
    /** This card’s hand modifier, if it is Vanguard card. This value will contain a delta, such as -1. */
    public var hand_modifier: String?
    /** This card’s life modifier, if it is Vanguard card. This value will contain a delta, such as +2. */
    public var life_modifier: String?
    /**
     * This card's defense, if any.
     * - note: automatically part of CardFaceSpecific.
     */
    public var defense: String?
    /**
     * This loyalty if any. Note that some cards have loyalties that are not numeric, such as X.
     * - note: automatically part of CardFaceSpecific.
     */
    public var loyalty: String?
    /**
     * This card’s power, if any. Note that some cards have powers that are not numeric, such as `"*"`.
     * - note: automatically part of CardFaceSpecific.
     */
    public var power: String?
    /**
     * This card’s toughness, if any. Note that some cards have toughnesses that are not numeric, such as `"*"`.
     * - note: automatically part of CardFaceSpecific.
     */
    public var toughness: String?
    /** The just-for-fun name printed on the card (such as for Godzilla series cards). */
    public var flavor_name: String?
    /** The flavor text, if any. */
    public var flavor_text: String?
    /** This card’s watermark, if any. */
    public var watermark: String?
    /**
     * The card’s mana value. Note that some funny cards have fractional mana costs.
     * - note: Root level for most layouts; card face level for reversible layouts.
     */
    public var cmc: Decimal?
    /**
     * This card’s color identity.
     * - note: Root level for most layouts; card face level for reversible layouts.
     */
    public var color_identity: [ScryfallColor]
    /**
     * This card’s overall rank/popularity on EDHREC. Not all cards are ranked.
     * - note: Root level for most layouts; card face level for reversible layouts.
     */
    public var edhrec_rank: Int?
    /**
     * An array of keywords that this card uses, such as 'Flying' and 'Cumulative upkeep'.
     * - note: Root level for most layouts; card face level for reversible layouts.
     */
    public var keywords: [String]
    /**
     * This card’s rank/popularity on Penny Dreadful. Not all cards are ranked.
     * - note: Root level for most layouts; card face level for reversible layouts.
     */
    public var penny_rank: Int?
    /**
     * Colors of mana that this card could produce.
     * - note: Root level for most layouts; card face level for reversible layouts.
     */
    public var produced_mana: [ScryfallManaType]?
    /**
     * True if this card is on the Reserved List.
     * - note: Root level for most layouts; card face level for reversible layouts.
     */
    public var reserved: Bool
    
    public struct CardFace: Codable {
        /** The ID of the illustrator of this card face. Newly spoiled cards may not have this field yet. */
        public var artist_id: UUID?
        /**
         * The colors in this card’s color indicator, if any. A null value for this field indicates the card does not have one.
         * - note: On multi-face cards, duplicated at the card and print level.
         */
        public var color_indicator: [ScryfallColor]?
        /**
         * The mana cost for this card. This value will be any empty string "" if the cost is absent. Remember that per the game rules, a missing mana cost and a mana cost of {0} are different  Multi-faced cards will report this value in card faces.
         * - note: On multi-face cards, duplicated at the card and print level.
         */
        public var mana_cost: String?
        /**
         * The name of this card.
         * - note: On multi-face cards, duplicated at the card and print level.
         */
        public var name: String
        /**
         * The type line of this card.
         * - note: On multi-face cards, duplicated at the card and print level.
         */
        public var type_line: String?
        /**
         * The Oracle text for this card, if any.
         * - note: On multi-face cards, duplicated at the card and print level.
         */
        public var oracle_text: String?
        /** A unique ID for this card’s oracle identity. This value is consistent across reprinted card editions, and unique among different cards with the same name (tokens, Unstable public variants, etc). Always present except for the reversible_card layout where it will be absent; oracle_id will be found on each face instead. */
        public var oracle_id: UUID?
        /** This card’s colors, if the overall card has colors defined by the rules. Otherwise the colors will be on the card_faces objects. */
        public var colors: [ScryfallColor]?
        /**
         * The card’s mana value. Note that some funny cards have fractional mana costs.
         * - note: Root level for most layouts; card face level for reversible layouts.
         */
        public var cmc: Decimal?
        /**
         * This card’s color identity.
         * - note: Root level for most layouts; card face level for reversible layouts.
         */
        public var color_identity: [ScryfallColor]?
        /**
         * This card’s overall rank/popularity on EDHREC. Not all cards are ranked.
         * - note: Root level for most layouts; card face level for reversible layouts.
         */
        public var edhrec_rank: Int?
        /**
         * An array of keywords that this card uses, such as 'Flying' and 'Cumulative upkeep'.
         * - note: Root level for most layouts; card face level for reversible layouts.
         */
        public var keywords: [String]?
        /**
         * This card’s rank/popularity on Penny Dreadful. Not all cards are ranked.
         * - note: Root level for most layouts; card face level for reversible layouts.
         */
        public var penny_rank: Int?
        /**
         * Colors of mana that this card could produce.
         * - note: Root level for most layouts; card face level for reversible layouts.
         */
        public var produced_mana: [ScryfallManaType]?
        /**
         * True if this card is on the Reserved List.
         * - note: Root level for most layouts; card face level for reversible layouts.
         */
        public var reserved: Bool?
        /**
         * The name of the illustrator of this card. Newly spoiled cards may not have this field yet.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var artist: String?
        /**
         * The IDs of the artists that illustrated this card. Newly spoiled cards may not have this field yet.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var artist_ids: [UUID]?
        /**
         * The lit Unfinity attractions lights on this card, if any.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var attraction_lights: [Int]?
        /**
         * Whether this card is found in boosters.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var booster: Bool?
        /**
         * This card’s border color: black, white, borderless, silver, or gold.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var border_color: ScryfallBorderColor?
        /**
         * This card’s collector number. Note that collector numbers can contain non-numeric characters, such as letters or ★.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var collector_number: String?
        /**
         * True if you should consider avoiding use of this print downstream.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var content_warning: Bool?
        /**
         * True if this card was only released in a video game.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var digital: Bool?
        /**
         * This card’s frame effects, if any.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var frame_effects: [ScryfallFrameEffect]?
        /**
         * This card’s frame layout.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var frame: String?
        /**
         * True if this card’s artwork is larger than normal.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var full_art: Bool?
        /**
         * A list of games that this card print is available in, paper, arena, and/or mtgo.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var games: [ScryfallGame]?
        /**
         * True if this card’s imagery is high resolution.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var highres_image: Bool?
        /**
         * A unique identifier for the card artwork that remains consistent across reprints. Newly spoiled cards may not have this field yet.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var illustration_id: UUID?
        /**
         * A computer-readable indicator for the state of this card’s image, one of missing, placeholder, lowres, or highres_scan.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var image_status: ScryfallImageStatus?
        /**
         * True if this card is oversized.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var oversized: Bool?
        /**
         * An object containing daily price information for this card, including usd, usd_foil, usd_etched, eur, eur_foil, eur_etched, and tix prices, as strings.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var prices: ScryfallPrices?
        /**
         * True if this card is a promotional print.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var promo: Bool?
        /**
         * An array of strings describing what categories of promo cards this card falls into.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var promo_types: [ScryfallPromoType]?
        /**
         * An object providing URIs to this card’s listing on major marketplaces. Omitted if the card is unpurchaseable.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var purchase_uris: ScryfallPurchaseURLs?
        /**
         * This card’s rarity.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var rarity: ScryfallRarity?
        /**
         * An object providing URIs to this card’s listing on other Magic: The Gathering online resources.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var related_uris: ScryfallRelatedURLs?
        /**
         * The date this card was first released.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var released_at: String?
        /**
         * True if this card is a reprint.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var reprint: Bool?
        /**
         * A link to this card’s set on Scryfall’s website.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var scryfall_set_uri: URL?
        /**
         * This card’s full set name.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var set_name: String?
        /**
         * A link to where you can begin paginating this card’s set on the Scryfall API.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var set_search_uri: URL?
        /**
         * The type of set this printing is in.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var set_type: ScryfallSetType?
        /**
         * A link to this card’s set object on Scryfall’s API.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var set_uri: URL?
        /**
         * This card’s set code.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var set: String?
        /**
         * This card’s Set object UUID.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var set_id: UUID?
        /**
         * True if this card is a Story Spotlight.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var story_spotlight: Bool?
        /**
         * True if the card is printed without text.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var textless: Bool?
        /**
         * The security stamp on this card, if any.
         * - note: Root level for a non-reversible card, card face level for a reversible card.
         */
        public var security_stamp: ScryfallSecurityStamp?
        /**
         * The Scryfall ID for the card back design present on this card.
         * - note: Single-sided only
         */
        public var card_back_id: UUID?
        /**
         * An object listing available imagery for this card. See the Card Imagery article for more information.
         * - note: Root level for single-sided cards, whether with single-part or multi-part; Card face level for cards with two sides, e.g. a DFC or a reversible card.
         */
        public var image_uris: [ScryfallImageSize: URL]?
        /**
         * This card's defense, if any.
         * - note: automatically part of CardFaceSpecific.
         */
        public var defense: String?
        /**
         * This loyalty if any. Note that some cards have loyalties that are not numeric, such as X.
         * - note: automatically part of CardFaceSpecific.
         */
        public var loyalty: String?
        /**
         * This card’s power, if any. Note that some cards have powers that are not numeric, such as `"*"`.
         * - note: automatically part of CardFaceSpecific.
         */
        public var power: String?
        /**
         * This card’s toughness, if any. Note that some cards have toughnesses that are not numeric, such as `"*"`.
         * - note: automatically part of CardFaceSpecific.
         */
        public var toughness: String?
    }
}
