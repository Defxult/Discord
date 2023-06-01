/**
The MIT License (MIT)

Copyright (c) 2023-present Defxult

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

import Foundation

/// Represents a Discord user.
public class User : Object, Updateable, Hashable {
    
    /// The users ID.
    public let id: Snowflake
    
    /// The user's username, not unique across the platform.
    public internal(set) var name: String
    
    /// The user's 4-digit discord-tag.
    public internal(set) var discriminator: String
    
    /// The URL for the user's default avatar.
    public internal(set) var defaultAvatarUrl: String
    
    /// The user's avatar.
    public internal(set) var avatar: Asset?
    
    /// Whether the user is a bot.
    public let isBot: Bool
    
    /// Whether the user is an Official Discord System user (part of the urgent message system).
    public let isSystem: Bool
    
    /// The user's banner.
    public internal(set) var banner: Asset?
    
    /// The public flags on a user's account.
    public internal(set) var publicUserFlags: [PublicUserFlags]?
    
    // Hashable extras
    public static func == (lhs: User, rhs: User) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }

    // ---------- API Separated ----------

    /// Mention the user.
    public let mention: String
    
    /// The users name and discriminator.
    public var description: String { "\(name)#\(discriminator)" }

    // -----------------------------------

    init(userData: JSON) {
        id = Conversions.snowflakeToUInt(userData["id"])
        name = userData["username"] as! String
        discriminator = userData["discriminator"] as! String
        defaultAvatarUrl = HTTPClient.buildEndpoint(.cdn, endpoint: "/embed/avatars/\(Conversions.defaultUserAvatar(discriminator: discriminator))")
        
        let avatarHash = userData["avatar"] as? String
        avatar = avatarHash != nil ? Asset(hash: avatarHash!, fullURL: "/avatars/\(id)/\(Asset.determineImageTypeURL(hash: avatarHash!))") : nil

        isBot = userData["bot"] as? Bool == nil ? false : true
        isSystem = userData["system"] as? Bool == nil ? false : true
        
        let bannerHash = userData["banner"] as? String
        banner = bannerHash != nil ? Asset(hash: bannerHash!, fullURL: "/banners/\(id)/\(Asset.determineImageTypeURL(hash: bannerHash!))") : nil
        
        let flagValue = userData["public_flags"] as? Int
        if let flagValue = flagValue {
            publicUserFlags = PublicUserFlags.getUserFlags(userFlagValue: flagValue)
        }

        mention = Conversions.mention(.user, id: id)
    }
    
    /// Updates the properties of the user when recieved via `GuildEvent.userUpdate` and `GuildEvent.presenceUpdate`.
    func update(_ data: JSON) {
        for (k, v) in data {
            switch k {
            case "name":
                name = v as! String
            case "discriminator":
                discriminator = v as! String
            case "avatar":
                if let avatarHash = v as? String {
                    avatar = Asset(hash: avatarHash, fullURL: "/avatars/\(id)/\(Asset.determineImageTypeURL(hash: avatarHash))")
                }
            case "banner":
                if let bannerHash = v as? String {
                    banner = Asset(hash: bannerHash, fullURL: "/banners/\(id)/\(Asset.determineImageTypeURL(hash: bannerHash))")
                }
            case "public_flags":
                if let flagValue = v as? Int {
                    publicUserFlags = PublicUserFlags.getUserFlags(userFlagValue: flagValue)
                }
            default:
                break
            }
        }
    }
}

extension User {
    
    /// Represents the current status of a user.
    public enum Status : String {
        case idle = "idle"
        case dnd = "dnd"
        case online = "online"
        case offline = "offline"
    }
    
    /// Represents a users activity.
    public struct Activity {
        
        /// Activity's name.
        public let name: String
        
        /// Activity type.
        public let type: ActivityType
        
        /// Stream URL.
        public let url: String?
        
        /// When the activity was added to the user's session.
        public let createdAt: Date
        
        /// The start and/or end of the game.
        public private(set) var timestamps: ActivityTimestamp?
        
        /// Application ID for the game.
        public let applicationId: Snowflake?
        
        /// What the player is currently doing.
        public let details: String?
        
        /// User's current party status.
        public let state: String?
        
        /// Emoji used for a custom status.
        public private(set) var emoji: PartialEmoji?
        
        /// Information for the current party of the player.
        public private(set) var party: ActivityParty?
        
        /// Images for the presence and their hover texts.
        public private(set) var assets: ActivityAssets?
        
        /// Custom buttons shown in the Rich Presence (max 2).
        public private(set) var buttons: [ActivityButton]?
        
        init(activityData: JSON) {
            name = activityData["name"] as! String
            type = ActivityType(rawValue: activityData["type"] as! Int)!
            url = activityData["url"] as? String
            createdAt = Date(timeIntervalSince1970: (activityData["created_at"] as! TimeInterval) / 1000)
            
            if let timestampsObj = activityData["timestamps"] as? JSON {
                timestamps = .init(activityTimestampData: timestampsObj)
            }
            
            applicationId = Conversions.snowflakeToOptionalUInt(activityData["application_id"])
            details = activityData["details"] as? String
            state = activityData["state"] as? String
            
            if let emojiObj = activityData["emoji"] as? JSON {
                emoji = PartialEmoji(partialEmojiData: emojiObj)
            }
            
            if let partyObj = activityData["party"] as? JSON {
                party = ActivityParty(activityPartyData: partyObj)
            }
            
            if let assetsObj = activityData["assets"] as? JSON {
                assets = ActivityAssets(activityAssetsData: assetsObj, applicationId: applicationId)
            }
            
            if let buttonsArrayObjs = activityData["buttons"] as? [JSON] {
                buttons = []
                for buttonObj in buttonsArrayObjs {
                    buttons!.append(ActivityButton(activityButtonData: buttonObj))
                }
            }
        }
    }
    
    /// Represents an activity button.
    public struct ActivityButton {
        
        /// Text shown on the button (1-32 characters).
        public let label: String
        
        /// URL opened when clicking the button (1-512 characters).
        public let url: String
        
        init(activityButtonData: JSON) {
            label = activityButtonData["label"] as! String
            url = activityButtonData["url"] as! String
        }
    }
    
    /// Represents an activity asset.
    public struct ActivityAssets {
        
        /// The assets image in a large format.
        public private(set) var largeImage: (id: String, url: String)?
        
        /// The assets image in a small format.
        public private(set) var smallImage: (id: String, url: String)?
        
        /// Text displayed when hovering over the large image of the activity.
        public let largeText: String?
        
        /// Text displayed when hovering over the small image of the activity.
        public let smallText: String?
        
        init(activityAssetsData: JSON, applicationId: Snowflake?) {
            if let largeImgId = Conversions.snowflakeToOptionalUInt(activityAssetsData["large_image"]), let applicationId {
                largeImage = (String(largeImgId), "\(APIRoute.cdn.rawValue)" + "app-assets/\(applicationId)/\(largeImgId).png)")
            }
            if let smallImgId = Conversions.snowflakeToOptionalUInt(activityAssetsData["small_image"]), let applicationId {
                smallImage = (String(smallImgId), "\(APIRoute.cdn.rawValue)" + "app-assets/\(applicationId)/\(smallImgId).png)")
            }
            largeText = activityAssetsData["large_text"] as? String
            smallText = activityAssetsData["small_text"] as? String
        }
    }
    
    /// Represents an activity party.
    public struct ActivityParty {
        
        /// ID of the party.
        public let id: String?
        
        /// The party's current and maximum size.
        public private(set) var size: (current: Int, max: Int)?
        
        init(activityPartyData: JSON) {
            id = activityPartyData["id"] as? String
            if let sizeData = activityPartyData["size"] as? [Int] { size = (sizeData[0], sizeData[1]) }
        }
    }
    
    /// Represents a users activity type.
    public enum ActivityType : Int {
        
        /// "Playing Rocket League"
        case game = 0
        
        /// "Streaming Rocket League".  This supports Twitch. Only https://twitch.tv/ URLs will work.
        case streaming = 1
        
        /// "Listening to Spotify"
        case listening = 2
        
        /// "Watching YouTube Together".  This supports YouTube. Only https://youtube.com/ URLs will work.
        case watching = 3
        
        /// "🙂 I am cool"
        case custom = 4
        
        /// "Competing in Arena World Champions"
        case competing = 5
    }
    
    /// Represents the information used to update the bots presence via ``Discord/Discord/updatePresence(status:activity:)``.
    public struct PresenceActivity {
        
        /// The activity type. Bots cannot use type ``User/ActivityType/custom``. If using type ``User/ActivityType/streaming`` or ``User/ActivityType/watching``, a `url` must be set.
        public var type: ActivityType
        
        /// The name of the activity.
        public var name: String
        
        /// The associated URL when using type ``User/ActivityType/streaming`` or ``User/ActivityType/watching``.
        public var url: String?
        
        /// Initializes a presence activity for use in ``Discord/Discord/updatePresence(status:activity:)``.
        /// - Parameters:
        ///   - type: The activity type. Bots cannot use type ``User/ActivityType/custom``. If using type ``User/ActivityType/streaming`` or ``User/ActivityType/watching``, a `url` must be set.
        ///   - name: The name of the activity.
        ///   - url: The associated URL when using type ``User/ActivityType/streaming`` or ``User/ActivityType/watching``.
        public init(_ type: ActivityType, name: String, url: String? = nil) {
            self.type = type
            self.name = name
            self.url = url
        }
        
        func convert() throws -> [JSON] {
            var payload: JSON = ["name": name, "type": type.rawValue]
            if type == .streaming {
                if let url { payload["url"] = url }
                else { throw DiscordError.generic("When updating the presence with \(type), a URL must be set") }
            }
            return [payload]
        }
    }
    
    /// Represents the start and/or end of the game.
    public struct ActivityTimestamp {
        
        /// When the activity started.
        public private(set) var start: Date?
        
        /// When the activity ends.
        public private(set) var end: Date?
        
        init(activityTimestampData: JSON) {
            if let startUnix = activityTimestampData["start"] as? TimeInterval { start = Date(timeIntervalSince1970: startUnix / 1000) }
            if let endUnix = activityTimestampData["end"] as? TimeInterval { end = Date(timeIntervalSince1970: endUnix / 1000) }
        }
    }

    /// Represents the public flags on a user's account.
    public enum PublicUserFlags : Int, CaseIterable {
        
        /// User has no flags associated with their account.
        case none = 0
        
        /// Discord Employee.
        case staff = 1
        
        /// Partnered Server Owner.
        case partner = 2
        
        /// HypeSquad Events Member.
        case hypeSquad = 4
        
        /// Bug Hunter Level 1.
        case bugHunterLevel1 = 8
        
        /// House Bravery Member.
        case hypeSquadOnlineHouse1 = 64
        
        /// House Brilliance Member.
        case hypeSquadOnlineHouse2 = 128
        
        /// House Balance Member.
        case hypeSquadOnlineHouse3 = 256
        
        /// Early Nitro Supporter.
        case premiumEarlySupporter = 512
        
        /// User is a [team](https://discord.com/developers/docs/topics/teams).
        case teamPseudoUser = 1024
        
        /// Bug Hunter Level 2.
        case bugHunterLevel2 = 16384
        
        /// Verified Bot.
        case verifiedBot = 65536
        
        /// Early Verified Bot Developer.
        case verifiedDeveloper = 131072
        
        /// Discord Certified Moderator.
        case certifiedModerator = 262144
        
        /// Bot uses only [HTTP interactions](https://discord.com/developers/docs/interactions/receiving-and-responding#receiving-an-interaction) and is shown in the online member list.
        case botHttpInteractions = 524288
        
        /// User is an active developer.
        case activeDeveloper = 4194304

        static func getUserFlags(userFlagValue: Int) -> [PublicUserFlags] {
            var flags = [PublicUserFlags]()
            for flag in PublicUserFlags.allCases {
                if (userFlagValue & flag.rawValue) == flag.rawValue {
                    flags.append(flag)
                }
            }
            return flags
        }
    }
}

/// Represents the bots user information.
public class ClientUser : User {
    
    /// Whether the user has two factor enabled on their account.
    public let mfaEnabled: Bool
    
    /// The user's chosen language option.
    public let locale: Locale?
    
    /// Whether the email on this account has been verified.
    public let verified: Bool

    init(clientUserData: JSON) {
        mfaEnabled = clientUserData["mfa_enabled"] as! Bool
        
        let loc = clientUserData["locale"] as? String
        locale = loc == nil ? nil : Locale(rawValue: loc!)
        
        verified = clientUserData["verified"] as! Bool
        super.init(userData: clientUserData)
    }
}

/// Represents a Discord locale.
public enum Locale : String, CaseIterable {
    
    /// Native name: Bahasa Indonesia
    case indonesian = "id"
    
    /// Native name: Dansk
    case danish = "da"
    
    /// Native name: Deutsch
    case german = "de"
    
    /// Native name: English, UK
    case englishUK = "en-GB"
    
    /// Native name: English, US
    case englishUS = "en-US"
    
    /// Native name: Español
    case spanish = "es-ES"
    
    /// Native name: Français
    case french = "fr"
    
    /// Native name: Hrvatski
    case croatian = "hr"
    
    /// Native name: Italiano
    case italian = "it"
    
    /// Native name: Lietuviškai
    case lithuanian = "lt"
    
    /// Native name: Magyar
    case hungarian = "hu"
    
    /// Native name: Nederlands
    case dutch = "nl"
    
    /// Native name: Norsk
    case norwegian = "no"
    
    /// Native name: Polski
    case polish = "pl"
    
    /// Native name: Português do Brasil
    case portuguese = "pt-BR"
    
    /// Native name: Română
    case romanian = "ro"
    
    /// Native name: Suomi
    case finnish = "fi"
    
    /// Native name: Svenska
    case swedish = "sv-SE"
    
    /// Native name: Tiếng Việt
    case vietnamese = "vi"
    
    /// Native name: Türkçe
    case turkish = "tr"
    
    /// Native name: Čeština
    case czech = "cs"
    
    /// Native name: Ελληνικά
    case greek = "el"
    
    /// Native name: български
    case bulgarian = "bg"
    
    /// Native name: Pусский
    case russian = "ru"
    
    /// Native name: Українська
    case ukrainian = "uk"
    
    /// Native name: हिन्दी
    case hindi = "hi"
    
    /// Native name: ไทย
    case thai = "th"
    
    /// Native name: 中文
    case chineseChina = "zh-CN"
    
    /// Native name: 日本語
    case japanese = "ja"
    
    /// Native name: 繁體中文
    case chineseTaiwan = "zh-TW"
    
    /// Native name: 한국어
    case korean = "ko"
}
