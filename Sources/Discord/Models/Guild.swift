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

/// Represents a Discord server.
public class Guild : Object, Hashable, Updateable  {
    
    /// Guild ID.
    public let id: Snowflake
    
    /// Guild name.
    public internal(set) var name: String
    
    /// Guild avatar.
    public internal(set) var icon: Asset?
    
    /// The guild owners ID.
    public internal(set) var ownerId: Snowflake
    
    /// Guild splash.
    public internal(set) var splash: Asset?
    
    /// Guild discovery splash.
    public internal(set) var discoverySplash: Asset?
    
    /// ID of AFK channel.
    public internal(set) var afkChannelId: Snowflake?
    
    /// AFK timeout in seconds.
    public internal(set) var afkChannelTimeout: Int
    
    /// If the guild widget is enabled.
    public internal(set) var widgetEnabled: Bool
    
    /// The channel ID that the widget will generate an invite to, or `nil` if set to no invite.
    public internal(set) var widgetChannelId: Snowflake?
    
    /// Verification level required for the guild.
    public internal(set) var verificationLevel: VerificationLevel
    
    /// Default message notifications level.
    public internal(set) var defaultMessageNotifications: MessageNotificationLevel
    
    /// Explicit content filter level.
    public internal(set) var explicitContentFilter: ExplicitContentFilterLevel
    
    /// Roles in the guild.
    public internal(set) var roles = [Role]()

    /// Custom guild emojis.
    public internal(set) var emojis = Set<Emoji>()
    
    /// Enabled guild features.
    public internal(set) var features = [Feature]()
    
    /// Required MFA level for the guild.
    public internal(set) var mfaLevel: MFALevel
    
    /// Application ID of the guild creator if it is bot-created.
    public internal(set) var applicationId: Snowflake?
    
    /// The ID of the channel where guild notices such as welcome messages and boost events are posted.
    public internal(set) var systemChannelId: Snowflake?
    
    /// The values set for the guild system channel.
    public internal(set) var systemChannelFlags = [SystemChannelFlags]()
    
    /// The ID of the channel where Community guilds can display rules and/or guidelines.
    public internal(set) var rulesChannelId: Snowflake?
    
    /// The maximum number of presences for the guild.
    public internal(set) var maxPresences: Int?
    
    /// The maximum number of members for the guild.
    public internal(set) var maxMembers: Int?
    
    /// The vanity URL code for the guild.
    public internal(set) var vanityUrlCode: String?
    
    /// The description of a guild.
    public internal(set) var description: String?
    
    /// The guild banner.
    public internal(set) var banner: Asset?
    
    /// The server boost level of the guild.
    public internal(set) var premiumTier: PremiumTier
    
    /// The number of boosts this guild currently has.
    public internal(set) var premiumSubscriptionCount: Int?
    
    /// The preferred locale of a Community guild.
    public internal(set) var preferredLocale: Locale
    
    /// The ID of the channel where admins and moderators of Community guilds receive notices from Discord.
    public internal(set) var publicUpdatesChannelId: Snowflake?
    
    /// The maximum amount of users in a video channel.
    public internal(set) var maxVideoChannelUsers: Int?
    
    /// Approximate number of members in this guild.
    public internal(set) var approximateMemberCount: Int?
    
    /// Approximate number of non-offline members in this guild.
    public internal(set) var approximatePresenceCount: Int?
    
    /// Guild NSFW level.
    public internal(set) var nsfwLevel: NSFWLevel
    
    /// Custom guild stickers.
    public internal(set) var stickers = [GuildSticker]()
    
    /// Whether the guild has the boost progress bar enabled.
    public internal(set) var premiumProgressBarEnabled: Bool
    
    /// The ID of the channel where admins and moderators of Community guilds receive safety alerts from Discord.
    public internal(set) var safetyAlertsChannelId: Snowflake?

    // ------------- The below properties are set via the extra fields in the GUILD_CREATE gateway event ------------------
    
    /// All channels available in the Guild.
    public var channels: [GuildChannel] { channelsCache.values.map({ $0 }) }
    var channelsCache = [Snowflake: GuildChannel]()

    /// All members in the guild.
    public var members: [Member] { membersCache.values.map({ $0 }) }
    private var membersCache = [Snowflake: Member]()

    /// All active stage instances.
    public internal(set) var stageInstances = [StageInstance]()

    /// The scheduled events in the guild.
    public internal(set) var scheduledEvents = [ScheduledEvent]()
    
    /// Members voice connection status.
    public internal(set) var voiceStates = [VoiceChannel.State]()

    // --------------------------------------------------------------------------------------------------------------------
    
    
    // ------------------------------ API Separated -----------------------------------
    
    /// All text channels.
    public var textChannels: [TextChannel] {
        get {
            let texts = channels.filter { $0.type == .guildText}
            return texts as! [TextChannel]
        }
    }

    /// All voice channels.
    public var voiceChannels: [VoiceChannel] {
        get {
            let voices = channels.filter { $0.type == .guildVoice}
            return voices as! [VoiceChannel]
        }
    }

    /// All stage channels.
    public var stageChannels: [StageChannel] {
        get {
            let stages = channels.filter { $0.type == .guildStageVoice}
            return stages as! [StageChannel]
        }
    }
    
    /// All forums.
    public var forumChannels: [ForumChannel] {
        get {
            let forums = channels.filter { $0.type == .guildForum }
            return forums as! [ForumChannel]
        }
    }
    
    /// All active threads in the guild that current user has permission to view.
    public var threads: [ThreadChannel] {
        get {
            let threads = channels.filter { $0.type == .publicThread || $0.type == .privateThread || $0.type == .announcementThread }
            return threads as! [ThreadChannel]
        }
    }

    /// The guilds default role. AKA the @everyone role.
    public var defaultRole: Role { getRole(id)! }

    /// The owner of the guild.
    public var owner: Member? { getMember(ownerId) }

    /// The bot member object.
    public var me: Member { getMember(bot!.user!.id)! }
    
    /// Whether the guild is available for use. If `false`, it's best not to do anything with it until it becomes available again.
    public internal(set) var isAvailable = true

    // --------------------------------------------------------------------------------
    
    // Hashable extras
    public static func == (lhs: Guild, rhs: Guild) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    /// Your bot instance.
    public weak private(set) var bot: Discord?
    
    init(bot: Discord, guildData: JSON, fromGateway: Bool = false) {
        self.bot = bot
        id = Conversions.snowflakeToUInt(guildData["id"])
        name = guildData["name"] as! String
        
        let iconHash = guildData["icon"] as? String
        icon = iconHash != nil ? Asset(hash: iconHash!, fullURL: "/icons/\(id)/\(Asset.determineImageTypeURL(hash: iconHash!))") : nil

        ownerId = Conversions.snowflakeToUInt(guildData["owner_id"])
        
        let splashHash = guildData["splash"] as? String
        splash = splashHash != nil ? Asset(hash: splashHash!, fullURL: "/splash/\(id)/\(Asset.determineImageTypeURL(hash: splashHash!))") : nil
        
        let discoverySplashHash = guildData["splash"] as? String
        splash = discoverySplashHash != nil ? Asset(hash: discoverySplashHash!, fullURL: "/discovery-splashes/\(id)/\(Asset.determineImageTypeURL(hash: discoverySplashHash!))") : nil
    
        afkChannelId = Conversions.snowflakeToOptionalUInt(guildData["afk_channel_id"])
        afkChannelTimeout = guildData["afk_timeout"] as! Int
        widgetEnabled = Conversions.optionalBooltoBool(guildData["widget_enabled"])
        widgetChannelId = Conversions.snowflakeToOptionalUInt(guildData["widget_channel_id"])
        verificationLevel = VerificationLevel(rawValue: guildData["verification_level"] as! Int)!
        defaultMessageNotifications = MessageNotificationLevel(rawValue: guildData["default_message_notifications"] as! Int)!
        explicitContentFilter = ExplicitContentFilterLevel(rawValue: guildData["explicit_content_filter"] as! Int)!

        let roleData = guildData["roles"] as! [JSON]
        for roleJsonObj in roleData {
            roles.append(.init(bot: bot, roleData: roleJsonObj, guildId: id))
        }
        
        let emojiData = guildData["emojis"] as! [JSON]
        for emojiJsonObj in emojiData {
            emojis.update(with: .init(bot: bot, guildId: id, emojiData: emojiJsonObj))
        }

        let featureData = guildData["features"] as! [String]
        features = Feature.get(featureData)

        mfaLevel = MFALevel(rawValue: guildData["mfa_level"] as! Int)!
        applicationId = Conversions.snowflakeToOptionalUInt(guildData["application_id"])
        systemChannelId = Conversions.snowflakeToOptionalUInt(guildData["system_channel_id"])
        systemChannelFlags = SystemChannelFlags.determineFlags(value: guildData["system_channel_flags"] as! Int)
        rulesChannelId = Conversions.snowflakeToOptionalUInt(guildData["rules_channel_id"])
        maxPresences = guildData["max_presences"] as? Int
        maxMembers = guildData["max_members"] as? Int
        vanityUrlCode = guildData["vanity_url_code"] as? String
        description = guildData["description"] as? String
        
        let bannerHash = guildData["banner"] as? String
        banner = bannerHash != nil ? Asset(hash: bannerHash!, fullURL: "/banners/\(id)/\(Asset.determineImageTypeURL(hash: bannerHash!))") : nil

        premiumTier = PremiumTier(rawValue: guildData["premium_tier"] as! Int)!
        premiumSubscriptionCount = guildData["premium_subscription_count"] as? Int
        preferredLocale = Locale(rawValue: guildData["preferred_locale"] as! String) ?? Locale.englishUS
        publicUpdatesChannelId = Conversions.snowflakeToOptionalUInt(guildData["public_updates_channel_id"])
        maxVideoChannelUsers = guildData["max_video_channel_users"] as? Int
        approximateMemberCount = guildData["approximate_member_count"] as? Int
        approximatePresenceCount = guildData["approximate_presence_count"] as? Int
        nsfwLevel = NSFWLevel(rawValue: guildData["nsfw_level"] as! Int)!

        if let stickerListData = guildData["stickers"] as? [JSON] {
            for stickerData in stickerListData {
                stickers.append(GuildSticker(bot: bot, guildStickerData: stickerData))
            }
        }

        premiumProgressBarEnabled = guildData["premium_progress_bar_enabled"] as! Bool
        safetyAlertsChannelId = Conversions.snowflakeToOptionalUInt(guildData["safety_alerts_channel_id"])

        // ------------------------ Gateway ------------------------
        
        if fromGateway {
            for ch in guildData["channels"] as! [JSON] {
                let chType = ch["type"] as! Int
                cacheChannel(determineGuildChannelType(type: chType, data: ch, bot: bot))
            }
            for mem in guildData["members"] as! [JSON] {
                let member = Member(bot: bot, memberData: mem, guildId: id)
                bot.cacheUser(member.user!)
                cacheMember(member)
            }
            for th in guildData["threads"] as! [JSON] {
                cacheChannel(ThreadChannel(bot: bot, threadData: th))
            }
            for st in guildData["stage_instances"] as! [JSON] {
                stageInstances.append(StageInstance(bot: bot, stageInstanceData: st))
            }
            for ev in guildData["guild_scheduled_events"] as! [JSON] {
                scheduledEvents.append(ScheduledEvent(bot: bot, eventData: ev))
            }
            for voiceStateObj in guildData["voice_states"] as! [JSON] {
                voiceStates.append(VoiceChannel.State(bot: bot, voiceStateData: voiceStateObj, guildId: id))
            }
        }
    
        // ---------------------------------------------------------
    }
    
    func cacheChannel(_ channel: GuildChannel) { channelsCache[channel.id] = channel }
    @discardableResult func removeChannelFromCache(_ channelId: Snowflake) -> GuildChannel? { return channelsCache.removeValue(forKey: channelId) }
    
    func cacheMember(_ member: Member) { membersCache[member.id] = member }
    func removeMemberFromCache(_ memberId: Snowflake) { membersCache[memberId] = nil }
    
    /**
     Retrieve the audit logs for the guild.
     
     - Parameters:
        - user: Entries from a specific user.
        - actionType: Type of action that occurred.
        - limit: Maximum number of entries (between 1-100) to return.
        - before: Entries before the specified date.
        - after: Entries after the specified date.
     - Returns: The guilds audit logs matching the parameters.
     - Note: When using `before`, entries are ordered by the in descending order (newer entries first). If `after` is used, entries are reversed and appears in ascending order (older entries first).
             Omitting both `before` and `after` defaults to `before` the current timestamp and will show the most recent entries in descending order.
     */
    public func auditLogs(user: User? = nil, actionType: AuditLog.Action? = nil, limit: Int = 50, before: Date? = nil, after: Date? = nil) async throws -> AuditLog {
        var queryItems = [URLQueryItem]()
        queryItems.append(.init(name: "limit", value: "\(limit < 1 ? 1 : min(limit, 100))"))
        
        if let user { queryItems.append(.init(name: "user_id", value: String(user.id))) }
        if let before { queryItems.append(.init(name: "before", value: "\(before.asSnowflake)")) }
        if let after { queryItems.append(.init(name: "after", value: "\(after.asSnowflake)")) }
        
        var queryParams = queryItems.map({ $0.description + "&" }).joined()
        queryParams.removeLast() // Remove the last "&"
        
        return try await bot!.http.getGuildAuditLog(guildId: id, queryParams: queryParams)
    }
    
    /// Retrieve all moderation rules in the guild.
    public func autoModerationRules() async throws -> [AutoModerationRule] {
        return try await bot!.http.listAutoModerationRulesForGuild(guildId: id)
    }
    
    /// Retrieve all application commands for the guild.
    public func applicationCommands() async throws -> [ApplicationCommand] {
        return try await bot!.http.getGuildApplicationCommands(botId: bot!.user!.id, guildId: id)
    }
    
    /// Retireve all application command permissions for your bot in the current guild.
    /// - Returns: All application command permissions.
    public func applicationCommandPermissions() async throws -> [GuildApplicationCommandPermissions] {
        return try await bot!.http.getGuildApplicationCommandPermissions(botId: bot!.user!.id, guildId: id)
    }
    
    /// Retireve a specific application command permission for your bot in the current guild.
    /// - Parameter for: The application command permission ID.
    /// - Returns: The application command permissions.
    public func applicationCommandPermissions(for command: Snowflake) async throws -> GuildApplicationCommandPermissions {
        return try await bot!.http.getApplicationCommandPermissions(botId: bot!.user!.id, guildId: id, commandId: command)
    }
    
    /**
     Ban a user from the guild.
     
     - Parameters:
        - user: User to ban.
        - deleteMessageSeconds: Number of seconds to delete messages for, between 0 and 604800 (7 days).
        - reason: The reason for creating the ban.
     - Throws: `HTTPError.notFound` The requested user was not found
     - Throws: `HTTPError.forbidden` You do not have the proper permissions to ban.
     */
    public func ban(user: User, deleteMessageSeconds: Int = 0, reason: String? = nil) async throws {
        try await bot!.http.createGuildBan(guildId: id, userId: user.id, deleteMessageSeconds: deleteMessageSeconds, reason: reason)
    }
    
    /**
     Unban a user from the guild.
     
     - Parameters:
        - user: User to unban.
        - reason: The reason for creating the unban.
     - Throws: `HTTPError.notFound` The requested user was not found
     - Throws: `HTTPError.forbidden` You do not have the proper permissions to unban.
     */
    public func unban(userId: Snowflake, reason: String? = nil) async throws {
        try await bot!.http.removeGuildBan(guildId: id, userId: userId, reason: reason)
    }
    
    /**
     Retrieve ban entries that contains each user that was banned.
     
     - Parameters:
        - limit: Number of entries to return. If `nil`, all entries are returned. The more banned users, the longer this will take.
        - before: Entries to retrieve before the specified date.
        - after: Entries to retrieve after the specified date.
     - Note: If both `before` and `after` are provided, only `before` is respected.
     */
    public func bans(limit: Int? = 1000, before: Date? = nil, after: Date? = nil) -> Guild.AsyncBans {
        let limit = limit != nil ? max(1, limit!) : nil
        return Guild.AsyncBans(guild: self, limit: limit, before: before, after: after)
    }
    
    /**
     Create an auto-moderation rule.
     
     - Parameters:
        - name: The rule name.
        - eventType: The event type.
        - triggerType: The trigger type.
        - metadata: Additional information needed based on the `triggerType`. This can only be `nil` when the `triggerType` is `TriggerType.spam`.
        - actions: The actions which will execute when the rule is triggered.
        - enabled: Whether the rule is enabled.
        - exemptRoles: The roles that should not be affected by the rule (maximum of 20).
        - exemptChannels: The channels that should not be affected by the rule (maximum of 50).
        - reason: The reason for creating the rule. This shows up in the guilds audit logs.
     - Returns: The newly created auto-moderation rule.
     */
    @discardableResult
    public func createAutoModerationRule(
        name: String,
        eventType: AutoModerationRule.EventType,
        triggerType: AutoModerationRule.TriggerType,
        metadata: AutoModerationRule.Metadata?, // Only when it's `TriggerType.spam`, this can be `nil`
        actions: [AutoModerationRule.Action],
        enabled: Bool = false,
        exemptRoles: [Role]? = nil,
        exemptChannels: [GuildChannelMessageable]? = nil,
        reason: String? = nil
    ) async throws -> AutoModerationRule {
        var payload: JSON = [
            "name": name,
            "event_type": eventType.rawValue,
            "trigger_type": triggerType.rawValue,
            "actions": actions.map({ $0.convert() }),
            "enabled": enabled
        ]
        
        if let metadata { payload["trigger_metadata"] = metadata.convert() }
        if let exemptRoles { payload["exempt_roles"] = Role.toSnowflakes(exemptRoles) }
        if let exemptChannels { payload["exempt_channels"] = exemptChannels.map({ $0.id }) }
        
        return try await bot!.http.createAutoModerationRule(guildId: id, data: payload, reason: reason)
    }
    
    /**
     Creates a guild category.
     
     - Parameters:
        - name: Name of the category.
        - position: Sorting position of the channel.
        - overwrites: Explicit permission overwrites for members and roles.
        - reason: The reason for creating the category.
     - Returns: The newly created category.
     */
    public func createCategory(name: String, position: Int? = nil, overwrites: [PermissionOverwrites]? = nil, reason: String? = nil) async throws -> CategoryChannel {
        return try await bot!.http.createGuildCategory(guildId: id, name: name, position: position, overwrites: overwrites, reason: reason)
    }
    
    /**
     Create an emoji.
     
     - Parameters:
        - name: Name of the emoji.
        - file: The image file (.gif, .png, .jpeg) for the emoji.
        - roles: The roles that will be allowed to use the emoji. If left as `nil` or an empty array, everyone will be allowed to use it.
        - reason: The reason for creating the emoji.
     - Returns: The newly created emoji.
     */
    public func createEmoji(name: String, file: File, roles: [Role]? = nil, reason: String? = nil) async throws -> Emoji {
        return try await bot!.http.createGuildEmoji(guildId: id, name: name, file: file, roles: roles?.map({ $0.id }), reason: reason)
    }
    
    /**
     Create a forum channel.
     
     - Parameters:
        - name: Name of the channel
        - defaultThreadAutoArchiveDuration: The amount of time threads will stop showing in the channel list after the specified period of inactivity.
        - defaultReactionEmoji: The emoji to show in the add reaction button on a thread.
        - topic:  This is shown in the "Guidelines" section within the Discord.
        - position: Sorting position of the channel.
        - nsfw: Whether the channel is NSFW.
        - overwrites: Explicit permission overwrites for members and roles.
        - category: The category the channel should be placed in.
        - slowmode: Amount of seconds a user has to wait before sending another message.
        - threadCreationSlowmode: Amount of seconds a user has to wait before creating another thread.
        - availableTags: A set of tags that have been applied to a thread.
        - sortOrder: The default sort order used to order posts.
        - layout: The default forum layout view used to display posts.
        - reason: The reason for creating the emoji. This shows up in the guilds audit log.
     - Returns: The newly created forum channel.
     */
    public func createForum(
        name: String,
        defaultThreadAutoArchiveDuration: ThreadChannel.ArchiveDuration = .threeDays,
        defaultReactionEmoji: PartialEmoji? = nil,
        topic: String? = nil,
        position: Int? = nil,
        nsfw: Bool = false,
        overwrites: [PermissionOverwrites]? = nil,
        category: CategoryChannel? = nil,
        slowmode: Int? = nil,
        threadCreationSlowmode: Int? = nil,
        availableTags: [ForumChannel.Tag]? = nil,
        sortOrder: ForumChannel.SortOrder? = nil,
        layout: ForumChannel.Layout = .notSet,
        reason: String? = nil
    ) async throws -> ForumChannel {
        return try await bot!.http.createForumChannel(
            guildId: id,
            name: name,
            categoryId: category?.id,
            topicAKAguidelines: topic,
            position: position,
            nsfw: nsfw,
            overwrites: overwrites,
            slowmode: slowmode,
            defaultArchiveDuration: defaultThreadAutoArchiveDuration.rawValue,
            defaultThreadSlowmode: threadCreationSlowmode,
            defaultReactionEmoji: defaultReactionEmoji,
            availableTags: availableTags,
            sortOrder: sortOrder,
            layout: layout,
            reason: reason
        )
    }
    
    /**
     Creates a scheduled event for the guild.
     
     - Parameters:
        - name: The name of the scheduled event.
        - entityType: The entity type of the scheduled event.
        - startTime: The time to schedule the scheduled event.
        - endTime: The time when the scheduled event is scheduled to end.
        - channelId: The channel id of the scheduled event.
        - location: Location of the event (1-100 characters).
        - description: The description of the scheduled event.
        - image: The cover image of the scheduled event.
        - reason: The reason for creating the emoji. This shows up in the guilds audit log.
     - Returns: The newly created sscheduled event.
     */
    public func createScheduledEvent(
        name: String,
        entityType: ScheduledEvent.EntityType,
        startTime: Date,
        endTime: Date? = nil,
        channelId: Snowflake? = nil,
        location: String? = nil,
        description: String? = nil,
        image: File? = nil,
        reason: String? = nil
    ) async throws -> ScheduledEvent {
        // If the `entityType` == `.external`, a `location` is required
        guard !((entityType == .external) && location == nil) else { throw HTTPError.badRequest("A location is required when the entity type is external") }
        
        // If the `entityType` == `.external`, a `endTime` is required
        guard !((entityType == .external) && endTime == nil) else { throw HTTPError.badRequest("An endTime must be set when the entity type is external") }
        
        // If the `entityType` != `.external`, a `channelId` is required
        guard !((entityType != .external) && channelId == nil) else { throw HTTPError.badRequest("A channel ID is required when the entity type is not external") }
        
        return try await bot!.http.createScheduledEventForGuild(
            guildId: id,
            name: name,
            startTime: startTime,
            endTime: endTime,
            channelId: channelId,
            location: location,
            description: description,
            entityType: entityType,
            image: image,
            reason: reason
        )
    }
    
    /**
     Creates a text channel.
     
     - Parameters:
        - name: Name of the channel.
        - category: The category the channel should be placed in.
        - topic: The channel topic.
        - slowmode: Amount of seconds a user has to wait before sending another message.
        - overwrites: Explicit permission overwrites for members and roles.
        - nsfw: Whether the channel is NSFW.
        - reason: The reason for creating the channel.
    - Returns: The newly created text channel.
    */
    public func createTextChannel(
        name: String,
        topic: String? = nil,
        category: CategoryChannel? = nil,
        slowmode: Int? = nil,
        position: Int? = nil,
        overwrites: [PermissionOverwrites]? = nil,
        nsfw: Bool = false,
        reason: String? = nil
    ) async throws -> TextChannel {
        return try await bot!.http.createGuildTextChannel(guildId: id, name: name, categoryId: category?.id, topic: topic, slowmode: slowmode, position: position, overwrites: overwrites, nsfw: nsfw, reason: reason)
    }
    
    /**
     Creates a voice channel.
     
     - Parameters:
        - name: Name of the channel.
        - category: The category the channel should be placed in.
        - bitrate: The bitrate of the channel.
        - userLimit: The user limit of the channel.
        - position: Sorting position of the channel.
        - overwrites: Explicit permission overwrites for members and roles.
        - region: Voice region for the channel.
        - quality: The camera video quality mode of the voice channel.
        - nsfw: Whether the channel is NSFW.
        - reason: The reason for creating the channel.
     - Returns: The newly created voice channel.
     */
    public func createVoiceChannel(
        name: String,
        category: CategoryChannel? = nil,
        bitrate: Int = 64000,
        userLimit: Int? = nil,
        position: Int? = nil,
        overwrites: [PermissionOverwrites]? = nil,
        region: VoiceChannel.RtcRegion = .automatic,
        quality: VoiceChannel.VideoQualityMode = .auto,
        nsfw: Bool = false,
        reason: String? = nil
    ) async throws -> VoiceChannel {
        return try await bot!.http.createGuildVoiceChannel(guildId: id, name: name, category: category, bitrate: bitrate, userLimit: userLimit, position: position, overwrites: overwrites, region: region, quality: quality, nsfw: nsfw, reason: reason)
    }
    
    /**
     Creates a role.
     
     - Parameters:
        - name: Name of the role, max 100 characters.
        - permissions: The permissions for the role.
        - color: Color of the role.
        - hoist: Whether the role should be displayed separately in the sidebar.
        - emoji: The role's emoji. Only available of the guild has the `Feature.roleIcons` feature.
        - mentionable: Whether the role should be mentionable.
     - Returns: The newly created role.
     */
    public func createRole(
        name: String? = nil,
        permissions: Permissions = Permissions.default,
        color: Color? = nil,
        hoist: Bool = false,
        icon: File? = nil,
        emoji: String? = nil,
        mentionable: Bool = false,
        reason: String? = nil
    ) async throws -> Role {
        return try await bot!.http.createGuildRole(guildId: id, name: name, permissions: permissions, color: color , hoist: hoist, icon: icon, emoji: emoji, mentionable: mentionable, reason: reason)
    }
    /**
     Creates a stage channel.
     
     - Parameters:
        - name: Stage channel name.
        - bitrate: The bitrate of the channel.
        - position: Sorting position of the channel.
        - overwrites: Explicit permission overwrites for members and roles.
        - region: Voice region for the channel.
        - reason: The reason for creating the channel.
     - Returns: The newly created channel.
     */
    public func createStageChannel(
        name: String,
        bitrate: Int = 64000,
        position: Int? = nil,
        overwrites: [PermissionOverwrites]? = nil,
        region: VoiceChannel.RtcRegion = .automatic,
        reason: String? = nil
    ) async throws -> StageChannel{
        return try await bot!.http.createGuildStageChannel(guildId: id, name: name, bitrate: bitrate, position: position, overwrites: overwrites, region: region, reason: reason)
    }
    
    /**
     Create a sticker in the guild.
     
     - Parameters:
        - name: Name of the sticker
        - description: Description of the sticker
        - emoji: The **name** of a unicode emoji. You can typically find the name of a unicode emoji by typing a colon in the discord app. For example, the 🍕 emoji's name would be "pizza".
        - file: The sticker file.
        - reason: The reason for creating the sticker. This shows up in the guilds audit log.
     - Returns: The newly created sticker.
     */
    public func createSticker(name: String, description: String?, emoji: String, file: File, reason: String? = nil) async throws -> GuildSticker {
        return try await bot!.http.createGuildSticker(guildId: id, name: name, description: description, tagAKAemoji: emoji, file: file, reason: reason)
    }
    
    /**
     Create a guild template.
     
     - Parameters:
        - name: Name of the template (100 characters max).
        - description: Description for the template (120 characters max.
     - Returns: The created template.
     */
    public func createTemplate(name: String, description: String? = nil) async throws -> Template {
        return try await bot!.http.createGuildTemplate(guildId: id, name: name, description: description)
    }
    
    /// Delete the guild. The bot must be the owner.
    public func delete() async throws {
        try await bot!.http.deleteGuild(guildId: id)
    }
    
    /**
     Edit the guild.
      
     - Parameters:
        - edits: The enum containing all values to be updated or removed for the guild.
        - reason: The reason for editing the guild. This shows up in the guilds audit-logs.
     - Note: The returned guild has the same limitations as `bot.requestGuild()`.
     - Returns: The updated guild.
     */
    @discardableResult
    public func edit(_ edits: Guild.Edit..., reason: String? = nil) async throws -> Guild {
        // Don't perform an HTTP request when nothing was changed
        guard !(edits.count == 0) else { return self }
        
        var payload: JSON = [:]
        for edit in edits {
            switch edit {
            case .name(let name):
                payload["name"] = name
            case .verificationLevel(let verificationLevel):
                payload["verification_level"] = verificationLevel.rawValue
            case .defaultMessageNotifications(let defaultMessageNotifications):
                payload["default_message_notifications"] = defaultMessageNotifications.rawValue
            case .explicitContentFilter(let explicitContentFilter):
                payload["explicit_content_filter"] = explicitContentFilter.rawValue
            case .afkChannel(let afkChannelId):
                payload["afk_channel_id"] = nullable(afkChannelId)
            case .afkTimeout(let afkTimeoutSeconds):
                payload["afk_timeout"] = afkTimeoutSeconds
            case .icon(let icon):
                payload["icon"] = nullable(icon?.asImageData)
            case .owner(let ownerId):
                payload["owner_id"] = ownerId
            case .splash(let splash):
                payload["splash"] = nullable(splash?.asImageData)
            case .discoverySplash(let discoverySplash):
                payload["discovery_splash"] = nullable(discoverySplash?.asImageData)
            case .banner(let banner):
                payload["banner"] = nullable(banner?.asImageData)
            case .systemChannel(let systemChannelId):
                payload["system_channel_id"] = nullable(systemChannelId)
            case .systemChannelFlags(let systemChannelFlags):
                payload["system_channel_flags"] = SystemChannelFlags.getBitSetForFlags(systemChannelFlags)
            case .rulesChannel(let rulesChannelId):
                payload["rules_channel_id"] = nullable(rulesChannelId)
            case .publicUpdatesChannel(let publicUpdatesChannelId):
                payload["public_updates_channel_id"] = nullable(publicUpdatesChannelId)
            case .preferredLocale(let preferredLocale):
                payload["preferred_locale"] = preferredLocale.rawValue
            case .description(let description):
                payload["description"] = nullable(description)
            case .premiumProgressBarEnabled(let enabled):
                payload["premium_progress_bar_enabled"] = enabled
            }
        }
        return try await bot!.http.modifyGuild(guildId: id, payload: payload, reason: reason)
    }
    
    /**
     Edit role positions.
     
     - Parameters:
        - positions: New positions for each role.
        - reason: The reason for editing the role positions. This shows up in the guilds audit-logs.
     */
    @discardableResult
    public func editRolePositions(_ positions: [Role: Int], reason: String? = nil) async throws -> [Role] {
        return try await bot!.http.modifyGuildRolePositions(guildId: id, positions: positions, reason: reason)
    }
    
    /// Retrieve a channel from this guilds internal cache.
    /// - Parameter id: ID of the channel to retrieve.
    /// - Returns: The channel that matches the given ID, or `nil` if not found.
    public func getChannel(_ id: Snowflake) -> GuildChannel? {
        return channelsCache[id]
    }
    
    /// Retrieve an emoji from this guilds internal cache.
    /// - Parameter id: ID of the emoji.
    /// - Returns: The emoji matching the provided ID, or `nil` if not found.
    public func getEmoji(_ id: Snowflake) -> Emoji? {
        return emojis.first(where: { $0.id == id })
    }
    
    /// Retrieve a member from this guilds internal cache.
    /// - Parameter id: ID of the member to retrieve.
    /// - Returns: The member that matches the given ID, or `nil` if not found.
    public func getMember(_ id: Snowflake) -> Member? {
        return membersCache[id]
    }
    
    /// Retrieve a role from this guilds internal cache.
    /// - Parameter id: ID of the role to retrieve.
    /// - Returns: The role that matches the given ID, or `nil` if not found.
    public func getRole(_ id: Snowflake) -> Role? {
        return roles.first(where: { $0.id == id })
    }
    
    /// Retrieve a sticker from this guilds internal cache.
    /// - Parameter id: ID of the sticker to retrieve.
    /// - Returns: The sticker that matches the given ID, or `nil` if not found.
    public func getSticker(_ id: Snowflake) -> GuildSticker? {
        return stickers.first(where: { $0.id == id })
    }
    
    /// Retrieve a scheduled event from the guilds internal cache.
    /// - Parameter id: ID of the scheduled event.
    /// - Returns: The scheduled event that matches the given ID, or `nil` if not found.
    public func getScheduledEvent(_ id: Snowflake) -> ScheduledEvent? {
        return scheduledEvents.first(where: { $0.id == id })
    }
    
    /// Retrieve a thread from the guilds internal cache.
    /// - Parameter id: ID of the thread.
    /// - Returns: The thread that matches the given ID, or `nil` if not found.
    public func getThread(_ id: Snowflake) -> ThreadChannel? {
        return threads.first(where: { $0.id == id })
    }
    
//    /**
//     Get the amount of members that would be kicked via ``Guild/prune(days:includeRoles:computePruneCount:)``.
//
//     - Parameters:
//        - days: Number of days a user has to be inactive (1-30).
//        - includedRoles: Role(s) to include. By default, members with roles cannot be pruned unless specifically included.
//     - Returns: The amount of members that would be pruned.
//     */
//    public func getPruneCount(days: Int, includedRoles: [Role]? = nil) async throws -> Int {
//        return try await bot!.http.getGuildPruneCount(guildId: id, days: days, includeRoles: includedRoles)
//    }
    
    /**
     Kick inactive members.
     
     - Parameters:
        - days: Number of days a user has to be inactive (1-30).
        - includeRoles: Role(s) to include. By default, members with roles cannot be pruned unless specifically included.
        - computePruneCount: Whether the amount of pruned members is returned.
     - Returns: The amount of members that were pruned or `nil` if `computePruneCount` was set to `false`.
     */
    @discardableResult
    public func prune(days: Int, includeRoles: [Role]? = nil, computePruneCount: Bool = true) async throws -> Int? {
        return try await bot!.http.beginGuildPrune(guildId: id, days: days, computePruneCount: computePruneCount, includeRoles: includeRoles ?? [])
    }
    
    /// Retrieve all integrations in the guild.
    ///  - Returns: An array of integrations for the guild.
    public func integrations() async throws -> [Integration] {
        return try await bot!.http.getIntegrations(guildId: id)
    }
    
    /// Retrieve all invites in the guild.
    ///  - Returns: An array of invites for the guild.
    public func invites() async throws -> [Invite] {
        return try await bot!.http.getGuildInvites(guildId: id)
    }
    
    /// Leave the guild.
    public func leave() async throws {
        try await bot!.http.leaveGuild(guildId: id)
    }
    
    /// Retrieve a guilds onboarding.
    /// - Returns: The guilds onboarding setup.
    public func onboarding() async throws -> Onboarding {
        try await bot!.http.getGuildOnboarding(guildId: id)
    }
    
     /// Retrieves the guilds preview.
     /// - Returns: The guilds preview.
    public func preview() async throws -> Preview {
        return try await bot!.http.guildPreview(guildId: id)
    }
    
    /**
     Retrieve an auto-moderation rule.
     
     - Parameter id: The ID of the auto-moderation rule.
     - Returns: The auto-moderation rule matching the given ID.
     */
    public func requestAutoModerationRule(_ id: Snowflake) async throws -> AutoModerationRule  {
        return try await bot!.http.getAutoModerationRule(guildId: self.id, ruleId: id)
    }
    
    /**
     Request a ban entry for the user that was banned.
     
     - Parameter for: ID of the user.
     - Returns: The ban entry.
     - Throws: `HTTPError.notFound` The ban was not found in the guild.
     */
    public func requestBan(`for` userID: Snowflake) async throws -> Guild.Ban {
        return try await bot!.http.getGuildBan(guildId: id, userId: userID)
    }
    
     /// Requests all channels available in the guild. Compared to `guild.channels`, this is an API call. For general use purposes, use `guild.channels` instead.
     /// - Returns: All channels in the guild.
    public func requestChannels() async throws -> [GuildChannel] {
        return try await bot!.http.getGuildChannels(guildId: id)
    }
    
    /**
     Request an emoji. This is an API call. For general use purposes, use ``getEmoji(_:)`` instead.
     
     - Parameter id: The guild emoji ID.
     - Returns: The guild emoji.
     */
    public func requestEmoji(_ id: Snowflake) async throws -> Emoji {
        return try await bot!.http.getGuildEmoji(guildId: self.id, emojiId: id)
    }
    
     /// Request all emojis. Compared to `guild.emojis`, this is an API call. For general use purposes, use `guild.emojis` instead.
     /// - Returns: All emojis in the guild.
    public func requestEmojis() async throws -> [Emoji] {
        return try await bot!.http.getGuildEmojis(guildId: id)
    }
    
    /// Request all roles. Compared to `guild.roles`, this is an API called. For general use purposes, use `guild.roles` instead.
    /// - Returns: All roles in the guild.
    public func requestRoles() async throws -> [Role] {
        return try await bot!.http.getGuildRoles(guildId: id)
    }
    
    /**
     Retrieve a scheduled event by it's ID. Unlike ``getScheduledEvent(_:)``, this is an API call.
     
     - Parameter id: ID of the schduled event.
     - Returns: The scheduled event.
     */
    public func requestScheduledEvent(_ id: Snowflake) async throws -> ScheduledEvent {
        return try await bot!.http.getScheduledEventForGuild(guildId: self.id, eventId: id)
    }
    
    /// Retrieve all scheduled events.
    public func requestScheduledEvents() async throws -> [ScheduledEvent] {
        return try await bot!.http.getListScheduledEventsForGuild(guildId: id)
    }
    
    /// Returns all active threads in the guild, including public and private threads.
    /// - Returns: All active threads.
    public func requestActiveThreads() async throws -> [ThreadChannel] {
        return try await bot!.http.getActiveGuildThreads(guildId: id)
    }
    
    /// Request a member. Compared to ``getMember(_:)``, this is an API call. For general use purposes, use ``getMember(_:)`` instead if you have the ``Intents/guildMembers`` intent enabled.
    /// - Parameter id: The ID of the member.
    /// - Returns: The requested member.
    public func requestMember(_ id: Snowflake) async throws -> Member {
        return try await bot!.http.getGuildMember(guildId: self.id, userId: id)
    }
    
    /**
     Request members in the guild. This is an API call. For general use purposes, use the ``members`` property instead.
     
     Below is an example on how to request members:
     ```swift
     do {
         for try await members in guild.requestMembers()! {
             // ...
         }
     } catch {
         // Handle error
     }
     ```
     Each iteration of the async for-loop contains batched members. Meaning `members` will be an array of at most 1000 members. You will receive batched members until
     all members matching the function parameters are fully received.
     
     - Parameters:
        - limit: The amount of members to return. If `nil`, all members will be returned. The larger the guild, the longer this will take.
        - after: Members to retrieve after the specified date.
     - Returns: The requested members. Can be `nil` if the bot doesn't have the ``Intents/guildMembers`` intent enabled.
     - Requires: Privileaged intents are required and must be enabled in your bots setting via the [developer portal](https://discord.com/developers/applications).
     */
    public func requestMembers(limit: Int? = 1000, after: Date? = nil) -> Guild.AsyncMembers? {
        if !(bot!.intents.contains(.guildMembers)) { return nil }
        let limit = limit != nil ? max(1, limit!) : nil
        return Guild.AsyncMembers(guild: self, limit: limit, after: after)
    }
    
    /**
     Request a sticker in the guild.
     
     - Parameter id: The ID of the sticker.
     - Returns: The requested sticker.
     - Note: The `user` property in the sticker will be `nil` if the bot doesn't have `Permissions.manageEmojisAndStickers` enabled.
     */
    public func requestSticker(_ id: Snowflake) async throws -> GuildSticker {
        return try await bot!.http.getGuildSticker(guildId: self.id, stickerId: id)
    }
    
    /// Request all stickers in the guild.
    /// - Returns: All guild stickers.
    public func requestAllStickers() async throws -> [GuildSticker] {
        return try await bot!.http.getAllGuildStickers(guildId: id)
    }
    
    /**
     Search members by their username or nickname.
     
     - Parameters:
        - name: Their username or nickname.
        - limit: Max number of members to return (1-1000).
     - Returns: All members whose username or nickname starts with a provided *name*.
     */
    public func searchMembers(name: String, limit: Int = 1000) async throws -> [Member] {
        return try await bot!.http.searchGuildMembers(guildId: id, query: name, limit: limit)
    }
    
    /// Retrieve the templates for the guild.
    /// - Returns: The guilds current templates.
    public func templates() async throws -> [Template] {
        return try await bot!.http.getGuildTemplates(guildId: id)
    }
    
    /// Updates the properties of the guild when recieved via `GUILD_UPDATE`.
    func update(_ data: JSON) {
        for (k, v) in data {
            switch k {
            case "name":
                name = v as! String
            case "icon":
                if let hash = v as? String {
                    icon = Asset(hash: hash, fullURL: "/icons/\(id)/\(Asset.determineImageTypeURL(hash: hash))")
                }
            case "owner_id":
                ownerId = Conversions.snowflakeToUInt(v as! String)
            case "splash":
                break
                //splash = Asset(hash: v as! String, fullURL: "/splash/\(id)/\(Asset.determineImageTypeURL(hash: v as! String))")
            case "afk_channel_id":
                afkChannelId = Conversions.snowflakeToOptionalUInt(v as? String)
            case "afk_timeout":
                afkChannelTimeout = v as! Int
            case "widget_enabled":
                widgetEnabled = Conversions.optionalBooltoBool(v)
            case "widget_channel_id":
                widgetChannelId = Conversions.snowflakeToOptionalUInt(v)
            case "verification_level":
                verificationLevel = VerificationLevel(rawValue: v as! Int)!
            case "default_message_notifications":
                defaultMessageNotifications = MessageNotificationLevel(rawValue: v as! Int)!
            case "explicit_content_filter":
                explicitContentFilter = ExplicitContentFilterLevel(rawValue: v as! Int)!
            case "roles":
                let rolesData = v as! [JSON]
                var roles = [Role]()
                
                for roleObj in rolesData {
                    roles.append(Role(bot: bot!, roleData: roleObj, guildId: id))
                }
                self.roles = roles
            case "emojis":
                let emojiData = v as! [JSON]
                emojis.removeAll()
                for emojiObj in emojiData {
                    emojis.update(with: Emoji(bot: bot!, guildId: id, emojiData: emojiObj))
                }
            case "features":
                let featureData = v as! [String]
                features = Feature.get(featureData)
            case "mfa_level":
                mfaLevel = MFALevel(rawValue: v as! Int)!
            case "system_channel_id":
                systemChannelId = Conversions.snowflakeToOptionalUInt(v)
            case "system_channel_flags":
                systemChannelFlags = SystemChannelFlags.determineFlags(value: v as! Int)
            case "rules_channel_id":
                rulesChannelId = Conversions.snowflakeToOptionalUInt(v)
            case "max_presences":
                maxPresences = v as? Int
            case "max_members":
                maxMembers = v as? Int
            case "vanity_url_code":
                vanityUrlCode = v as? String
            case "description":
                description = v as? String
            case "banner":
                let bannerHash = v as? String
                banner = bannerHash != nil ? Asset(hash: bannerHash!, fullURL: "/banners/\(id)/\(Asset.determineImageTypeURL(hash: bannerHash!))") : nil
            case "premium_tier":
                premiumTier = PremiumTier(rawValue: v as! Int)!
            case "premium_subscription_count":
                premiumSubscriptionCount = v as? Int
            case "preferred_locale":
                preferredLocale = Locale(rawValue: v as! String) ?? Locale.englishUS
            case "public_updates_channel_id":
                publicUpdatesChannelId = Conversions.snowflakeToOptionalUInt(v)
            case "max_video_channel_users":
                maxVideoChannelUsers = v as? Int
            case "approximate_member_count":
                approximateMemberCount = v as? Int
            case "approximate_presence_count":
                approximatePresenceCount = v as? Int
            case "nsfw_level":
                nsfwLevel = NSFWLevel(rawValue: v as! Int)!
            case "stickers":
                let stickerListData = v as! [JSON]
                var stickers = [GuildSticker]()
                
                for stickerObj in stickerListData {
                    stickers.append(GuildSticker(bot: bot!, guildStickerData: stickerObj))
                }
                self.stickers = stickers
            case "premium_progress_bar_enabled":
                premiumProgressBarEnabled = v as! Bool
            default:
                break
            }
        }
    }
    
    /// Retrieve the guilds vanity invite. The guild needs to have feature ``Guild/Feature/vanityUrl``.
    ///  - Returns: The vanity invite. If the guild does not have one, `code`
    public func vanityInvite() async throws -> Invite {
        return try await bot!.http.getGuildVanityUrl(guildId: id)
    }
    
    /**
     Edit the guilds welcome screen.
     
     - Parameters:
        - edits: The enum containing all values to be updated or removed for the guild.
        - reason: The reason for editing the welcome screen. This shows up in the guilds audit-logs.
     - Returns: The updated welcome screen.
     */
    @discardableResult
    public func editWelcomeScreen(_ edits: WelcomeScreenEdit..., reason: String? = nil) async throws -> WelcomeScreen {
        // I would have a `guard` here to prevent empty requests, but we're not in a `WelcomeScreen`, so I can't use `return self`
        var payload: JSON = [:]
        for e in edits {
            switch e {
            case .enabled(let enabled):
                payload["enabled"] = enabled
            case .welcomeChannels(let wsChannels):
                payload["welcome_channels"] = wsChannels.map({ $0.toDiscordPayload() })
            case .description(let description):
                payload["description"] = description
            }
        }
        
        return try await bot!.http.modifyGuildWelcomeScreen(guildId: id, data: payload, reason: reason)
    }
    
    /// Retrieves the guilds welcome screen if it's enabled.
    /// - Returns: The guilds welcome screen.
    public func welcomeScreen() async throws -> WelcomeScreen {
        return try await bot!.http.getGuildWelcomeScreen(guildId: id)
    }
    
    /// Retireves all webhooks in the guild.
    /// - Returns: All webhooks.
    public func webhooks() async throws -> [Webhook] {
        return try await bot!.http.getGuildWebhooks(guildId: id)
    }
     
    /// Retrieve the guild widget if it's enabled.
    /// - Returns: The active guild widget.
    public func widget() async throws -> Widget {
        return try await bot!.http.getGuildWidget(guildId: id)
    }
}

extension Guild {
    
    /// Represents a guilds onboarding setup.
    public struct Onboarding {
        
        /// Represents an ``Guild/Onboarding`` prompt.
        public struct Prompt {
            
            /// ID of the prompt.
            public let id: Snowflake
            
            /// Type of prompt.
            public let type: PromptType?
            
            /// Options available within the prompt.
            public let options: [PromptOption]
            
            /// Title of the prompt.
            public let title: String
            
            /// Indicates whether users are limited to selecting one option for the prompt.
            public let singleSelect: Bool
            
            /// Indicates whether the prompt is required before a user completes the onboarding flow
            public let required: Bool
            
            /// Indicates whether the prompt is present in the onboarding flow. If false, the prompt will only appear in the Channels & Roles tab
            public let inOnboarding: Bool
            
            init(promptData: JSON) {
                id = Conversions.snowflakeToUInt(promptData["id"])
                type = PromptType(rawValue: promptData["type"] as! Int)
                
                let promptOptionObjs =  promptData["options"] as! [JSON]
                var options = [PromptOption]()
                for promptOptionObj in promptOptionObjs { options.append(.init(promptOptionData: promptOptionObj)) }
                self.options = options
                
                title = promptData["title"] as! String
                singleSelect = promptData["single_select"] as! Bool
                required = promptData["required"] as! Bool
                inOnboarding =  promptData["in_onboarding"] as! Bool
            }
        }
        
        /// Represents an ``Guild/Onboarding`` prompt option.
        public struct PromptOption {
            
            /// ID of the prompt option.
            public let id: Snowflake

            /// IDs for channels a member is added to when the option is selected.
            public let channelIds: [Snowflake]

            /// IDs for roles assigned to a member when the option is selected
            public let roleIds: [Snowflake]

            /// Emoji of the option.
            public let emoji: PartialEmoji

            /// Title of the option.
            public let title: String

            /// Description of the option.
            public let description: String?
            
            init(promptOptionData: JSON) {
                id = Conversions.snowflakeToUInt(promptOptionData["id"])
                channelIds = Conversions.strArraySnowflakeToSnowflake(promptOptionData["channel_ids"] as! [String])
                roleIds = Conversions.strArraySnowflakeToSnowflake(promptOptionData["role_ids"] as! [String])
                emoji = PartialEmoji(partialEmojiData: promptOptionData["emoji"] as! JSON)
                title = promptOptionData["title"] as! String
                description = promptOptionData["description"] as? String
            }
        }
        
        /// Represents the onboarding prompt type.
        public enum PromptType : Int {
            case multipleChoice
            case dropdown
        }
        
        /// ID of the guild this onboarding is part of.
        public let guildId: Snowflake
        
        /// Prompts shown during onboarding and in customize community
        public let prompts: [Prompt]
        
        /// Channel IDs that members get opted into automatically.
        public let defaultChannelIds: [Snowflake]
        
        /// Whether onboarding is enabled in the guild.
        public let enabled: Bool
        
        init(onboardingData: JSON) {
            guildId = Conversions.snowflakeToUInt(onboardingData["guild_id"])
            
            let promptObjs = onboardingData["prompts"] as! [JSON]
            var prompts = [Guild.Onboarding.Prompt]()
            for promptObj in promptObjs { prompts.append(.init(promptData: promptObj)) }
            self.prompts = prompts
            
            defaultChannelIds = Conversions.strArraySnowflakeToSnowflake(onboardingData["default_channel_ids"] as! [String])
            enabled = onboardingData["enabled"] as! Bool
        }
    }
    
    /// Represents an asynchronous iterator used for ``Guild/bans(limit:before:after:)``.
    public struct AsyncBans : AsyncSequence, AsyncIteratorProtocol {
        
        public typealias Element = [Guild.Ban]

        let guild: Guild
        let indefinite = -1
        var remaining = 0
        var beforeSnowflakeTime: Snowflake
        var afterSnowflakeTime: Snowflake
        var hasMore = true

        init(guild: Guild, limit: Int?, before: Date?, after: Date?) {
            self.guild = guild
            self.remaining = limit ?? indefinite
            self.beforeSnowflakeTime = before?.asSnowflake ?? 0
            self.afterSnowflakeTime = after?.asSnowflake ?? 0
        }
        
        private func req(limit: Int, before: Snowflake, after: Snowflake) async throws -> [JSON] {
            // Set the values to `nil` if 0. `http.getGuildBans()` doesnt take into account that 0
            // means `nil` in this context. So change that ourselves here to prevent both URL queries
            // from being added unless intentionally added via `.init().
            let newBefore = before == 0 ? nil : before
            let newAfter = after == 0 ? nil : after
            
            return try await guild.bot!.http.getGuildBans(guildId: guild.id, limit: limit, before: newBefore, after: newAfter)
        }
        
        public mutating func next() async throws -> Element? {
            if !hasMore { return nil }
            
            var bans = [Guild.Ban]()
            let requestAmount = (remaining == indefinite ? 1000 : Swift.min(remaining, 1000))
            let data = try await req(limit: requestAmount, before: beforeSnowflakeTime, after: afterSnowflakeTime)
            
            // If the amount of bans received is less 1000, theres no more data after it, so set
            // this to false to prevent an extra HTTP request that is not needed.
            if data.count < 1000 {
                hasMore = false
            }
            
            for obj in data {
                bans.append(.init(banData: obj))
                if remaining != indefinite {
                    remaining -= 1
                    if remaining == 0 {
                        hasMore = false
                        return bans
                    }
                }
            }
            
            beforeSnowflakeTime = bans.last?.user.id ?? 0
            afterSnowflakeTime = beforeSnowflakeTime
            return bans
        }
        
        public func makeAsyncIterator() -> AsyncBans {
            self
        }
    }
    
    /// Represents an asynchronous iterator used for ``Guild/requestMembers(limit:after:)``.
    public struct AsyncMembers : AsyncSequence, AsyncIteratorProtocol {
        
        public typealias Element = [Member]

        let guild: Guild
        let indefinite = -1
        var remaining = 0
        var afterSnowflakeTime: Snowflake
        var hasMore = true

        init(guild: Guild, limit: Int?, after: Date?) {
            self.guild = guild
            self.remaining = limit ?? indefinite
            self.afterSnowflakeTime = after?.asSnowflake ?? 0
        }
        
        private func req(limit: Int, after: Snowflake) async throws -> [JSON] {
            return try await guild.bot!.http.getMultipleGuildMembers(guildId: guild.id, limit: limit, after: after)
        }
        
        public mutating func next() async throws -> Element? {
            if !hasMore { return nil }
            
            var members = [Member]()
            let requestAmount = (remaining == indefinite ? 1000 : Swift.min(remaining, 1000))
            let data = try await req(limit: requestAmount, after: afterSnowflakeTime)
            
            // If the amount of members received is less 1000, theres no more data after it, so set
            // this to false to prevent an extra HTTP request that is not needed.
            if data.count < 1000 {
                hasMore = false
            }
            
            for obj in data {
                members.append(.init(bot: guild.bot!, memberData: obj, guildId: guild.id))
                if remaining != indefinite {
                    remaining -= 1
                    if remaining == 0 {
                        hasMore = false
                        return members
                    }
                }
            }
            afterSnowflakeTime = members.last?.id ?? 0
            return members
        }
        
        public func makeAsyncIterator() -> AsyncMembers {
            self
        }
    }
    
    /// Represents a guild integration.
    public struct Integration {
        
        /// Integration ID.
        public let id: Snowflake
        
        /// Integration name.
        public let name: String
        
        /// Integration type. Either twitch, youtube, discord, or guild subscription.
        public let type: String
        
        /// Is this integration enabled.
        public let enabled: Bool
        
        /// Is this integration syncing. Not provided for discord bot integrations.
        public let syncing: Bool?
        
        /// ID that this integration uses for "subscribers". Not provided for discord bot integrations.
        public let roleId: Snowflake?
        
        private let guildId: Snowflake
        
        /// Whether emoticons should be synced for this integration (twitch only currently). Not provided for discord bot integrations.
        public let emoticonsEnabled: Bool?
        
        /// The behavior of expiring subscribers. Not provided for discord bot integrations.
        public let expireBehavior: ExpireBehavior?
        
        /// Tthe grace period (in days) before expiring subscribers. Not provided for discord bot integrations.
        public let expireGracePeriod: Int?
        
        /// User for this integration. Some older integrations may not have an attached user.
        public let user: User?
            
        /// Integration account information.
        public let account: Account
        
        /// When this integration was last synced. Not provided for discord bot integrations.
        public let syncedAt: Date?
        
        /// How many subscribers this integration has. Not provided for discord bot integrations.
        public let subscriberCount: Int?
        
        /// Has this integration been revoked. Not provided for discord bot integrations.
        public let revoked: Bool?
        
        /// The bot/OAuth2 application for discord integrations.
        public let application: Integration.Application?
            
        /// The scopes the application has been authorized for.
        public private(set) var scopes: Set<OAuth2Scopes>?
        
        /// Your bot instance.
        public private(set) weak var bot: Discord?
        
        init(bot: Discord?, integrationData: JSON, guildId: Snowflake) {
            self.bot = bot
            self.guildId = guildId
            id = Conversions.snowflakeToUInt(integrationData["id"])
            name = integrationData["name"] as! String
            type = integrationData["type"] as! String
            enabled = integrationData["enabled"] as! Bool
            syncing = integrationData["syncing"] as? Bool
            roleId = Conversions.snowflakeToOptionalUInt(integrationData["role_id"])
            emoticonsEnabled = integrationData["enable_emoticons"] as? Bool
            
            if let expBehValue = integrationData["expire_behavior"] as? Int { expireBehavior = .init(rawValue: expBehValue) }
            else { expireBehavior = nil }
            
            expireGracePeriod = integrationData["expire_grace_period"] as? Int
            
            if let userObj = integrationData["user"] as? JSON { user = User(userData: userObj) }
            else { user = nil }
            
            account = Account(accountData: integrationData["account"] as! JSON)
            
            if let lastSynced = integrationData["synced_at"] as? String { syncedAt = Conversions.stringDateToDate(iso8601: lastSynced) }
            else { syncedAt = nil }
            
            subscriberCount = integrationData["subscriber_count"] as? Int
            revoked = integrationData["revoked"] as? Bool
            
            if let appObj = integrationData["application"] as? JSON { application = Application(appData: appObj) }
            else { application = nil }
            
            if let scopes = integrationData["scopes"] as? [String] {
                self.scopes = OAuth2Scopes.getScopes(scopes)
            }
        }
        
        /// Deletes the integration as well as any associated webhooks. This also kicks the associated bot if there is one.
        /// - Parameter reason: The reason for deleting the integration.
        public func delete(reason: String? = nil) async throws {
            try await bot!.http.deleteGuildIntegration(guildId: guildId, integrationId: id, reason: reason)
        }
    }
    
    /// Represents a guild welcome screen.
    public struct WelcomeScreen {

        /// The guild description shown in the welcome screen.
        public let description: String?

        /// The channels shown in the welcome screen.
        public private(set) var welcomeChannels = [WelcomeScreenChannel]()

        init(welcomeScreenData: JSON) {
            description = welcomeScreenData["description"] as? String

            for screenChannelData in welcomeScreenData["welcome_channels"] as! [JSON] {
                welcomeChannels.append(.init(welcomeScreenChannelData: screenChannelData))
            }
        }
    }
    
    /// Edits the guilds welcome screen with the associated values.
    public enum WelcomeScreenEdit {
        
        /// Whether the welcome screen is enabled.
        case enabled(Bool)
        
        /// Channels linked in the welcome screen and their display option. This *replaces* the current welcome channels.
        case welcomeChannels([WelcomeScreenChannel])
        
        /// The guild description to show in the welcome screen.
        case description(String?)
    }

    /// Represents a guild welcome screen channel.
    public struct WelcomeScreenChannel {

        /// The channel's ID.
        public let channelId: Snowflake
        
        /// The description shown for the channel.
        public let description: String
        
        /// The emoji ID, if the emoji is custom.
        public let emojiId: Snowflake?
        
        /// The emoji name if custom, the unicode character if standard, or null if no emoji is set.
        public let emojiName: String?
        
        /**
         Initializes a new welcome screen channel
         
         - Parameters:
            - channelId: The channel's ID.
            - description: The description shown for the channel.
            - emojiId: The emoji ID, if the emoji is custom.
            - emojiName: The emoji name if custom, the unicode character if standard, or null if no emoji is set.
         */
        public init(channelId: Snowflake, description: String?, emojiId: Snowflake?, emojiName: String?) {
            self.channelId = channelId
            self.description = description ?? String.empty
            self.emojiId = emojiId
            self.emojiName = emojiName
        }

        init(welcomeScreenChannelData: JSON) {
            channelId = Conversions.snowflakeToUInt(welcomeScreenChannelData["channel_id"])
            description = welcomeScreenChannelData["description"] as! String
            emojiId = Conversions.snowflakeToOptionalUInt(welcomeScreenChannelData["emoji_id"])
            emojiName = welcomeScreenChannelData["emoji_name"] as? String
        }

        func toDiscordPayload() -> JSON {
            return [
                "channel_id": channelId,
                "description": description,
                "emoji_id": emojiId as Any,
                "emoji_name": emojiName as Any
            ]
        }
    }
    
    /// Represents the values that should be edited in a ``Guild``.
    public enum Edit {
        
        /// The new name for the guild.
        case name(String)
        
        /// The new verification level for the guild.
        case verificationLevel(VerificationLevel)
        
        /// The new default notification level for the guild.
        case defaultMessageNotifications(MessageNotificationLevel)
        
        /// The new explicit content filter for the guild.
        case explicitContentFilter(ExplicitContentFilterLevel)
        
        /// The new AFK channel. Can be set to `nil` to disable AFK channels.
        case afkChannel(Snowflake?)
        
        /// Update the amount of time it takes for someone to be automatically moved to the AFK channel.
        case afkTimeout(Int)
        
        /// The new guild icon. Can be animated if the guild has the feature `Guild.Feature.animatedIcon`. Can be set to `nil` to remove the icon.
        case icon(File?)
        
        /// Transfer guild ownership (bot must be the owner of the guild).
        case owner(Snowflake)
        
        /// The new splash image. Guild must have the feature `Guild.Feature.inviteSplash`.  Can be set to `nil` to remove the guild splash image.
        case splash(File?)
        
        /// The new discovery splash image. Guild must have the feature `Guild.Feature.discoverable`. Can be set to `nil` to remove the guild discovery splash image.
        case discoverySplash(File?)
        
        /// The new banner image. Guild must have the feature `Guild.Feature.banner`. Can be animated if the guild has the `Guild.Feature.animatedBanner` feature.
        /// Can be set to `nil` to remove the guild banner.
        case banner(File?)
        
        /// The new channel where guild notices such as welcome messages and boost events are posted. Can be set to `nil` to disable the system channel.
        case systemChannel(Snowflake?)
        
        /// The new values for the guild system channel.
        case systemChannelFlags([SystemChannelFlags])
        
        /// The new channel where Community guilds display rules and/or guidelines. Can be set to `nil` to disable the rules channel.
        case rulesChannel(Snowflake?)
        
        /// The new channel where admins and moderators of Community guilds receive notices from Discord. Only available for guilds with the `Guild.Feature.community` feature.
        /// Can be set to `nil` to disable the public updates channel.
        case publicUpdatesChannel(Snowflake?)
        
        /// The new preferred locale of a Community guild used in server discovery and notices from Discord.
        case preferredLocale(Locale)
        
        /// The new description for the guild. Only available for guilds with the `Guild.Feature.community` feature.
        /// Can be set to `nil` to remove the description.
        case description(String?)
        
        /// Enable/disable the guild's boost progress bar.
        case premiumProgressBarEnabled(Bool)
    }

    /// Represents a guild widget.
    public struct Widget : Object {
        
        /// Represents a guilds widget settings.
        public struct Settings {

            /// Whether the widget is enabled.
            public let enabled: Bool

            /// The widget channel ID.
            public let channelId: Snowflake?

            init(widgetSettingsData: JSON) {
                enabled = widgetSettingsData["enabled"] as! Bool
                channelId = Conversions.snowflakeToOptionalUInt(widgetSettingsData["channel_id"])
            }
        }
        
        /// Guild ID.
        public let id: Snowflake

        /// Guild name.
        public let name: String

        /// Instant invite for the guilds specified widget invite channel.
        public let instantInvite: String?

        /// Voice and stage channels which are accessible by @everyone.
        public private(set) var channels = [GuildChannel]()

        /// Special widget user objects that includes users presence (Limit 100).
        /// - Note: Discord stated that the properties `id`, `discriminator` and `avatar` are anonymized to prevent abuse.
        public private(set) var members = [User]()

        /// Number of online members in this guild.
        public let presenceCount: Int
        
        /// Your bot instance.
        public private(set) weak var bot: Discord?
        
        init(bot: Discord, widgetData: JSON) {
            self.bot = bot
            id = Conversions.snowflakeToUInt(widgetData["id"])
            name = widgetData["name"] as! String
            instantInvite = widgetData["instant_invite"] as? String

            let channelObjs = widgetData["channels"] as! [JSON]
            for channelObj in channelObjs {
                let channelId = Conversions.snowflakeToUInt(channelObj["id"])
                channels.append(bot.getChannel(channelId) as! GuildChannel)
            }
            
            let userObjects = widgetData["members"] as! [JSON]
            for userObj in userObjects {
                members.append(.init(userData: userObj))
            }

            presenceCount = widgetData["presence_count"] as! Int
        }
        
        /**
         Edit the widget.
         
         - Parameters:
            - enabled: Whether the widget is enabled.
            - channelId: The widget channel ID.
            - reason: The reason for editing the widget.
         */
        public func edit(enabled: Bool, channelId: Snowflake?, reason: String? = nil) async throws {
            try await bot!.http.modifyGuildWidget(guildId: id, enabled: enabled, widgetChannelId: channelId, reason: reason)
        }
        
        /// Retrieve the widgets settings.
        public func settings() async throws -> Settings {
            try await bot!.http.getGuildWidgetSettings(guildId: id)
        }
    }

    /// Represents a ban register for the guild.
    public struct Ban {
        
        /// The reason for the ban.
        public let reason: String?
        
        /// The banned user.
        public let user: User

        init(banData: JSON) {
            reason = banData["reason"] as? String
            user = .init(userData: banData["user"] as! JSON)
        }
    }

    /// Represents a guild preview.
    public struct Preview {
        
        /// Guild ID.
        public let id: Snowflake
        
        /// Guild name.
        public let name: String
        
        /// Guild avatar,
        public let icon: Asset?
        
        /// Guild splash.
        public let splash: Asset?
        
        /// Guild discovery splash.
        public let discoverySplash: Asset?
        
        /// Custom guild emojis.
        public internal(set) var emojis = [Emoji]()
        
        /// Enabled guild features.
        public internal(set) var features = [Feature]()
        
        /// Approximate number of members in this guild.
        public let approximateMemberCount: Int
        
        /// Approximate number of non-offline members in this guild.
        public let approximatePresenceCount: Int
        
        /// The description of a guild.
        public let description: String?
        
        /// Custom guild stickers.
        public internal(set) var stickers = [Sticker]()

        init(bot: Discord, previewData: JSON) {
            id = Conversions.snowflakeToUInt(previewData["id"])
            name = previewData["name"] as! String
            
            let iconHash = previewData["icon"] as? String
            icon = iconHash != nil ? Asset(hash: iconHash!, fullURL: "/icons/\(id)/\(Asset.determineImageTypeURL(hash: iconHash!))") : nil
            
            let splashHash = previewData["splash"] as? String
            splash = splashHash != nil ? Asset(hash: splashHash!, fullURL: "/splashes/\(id)/\(Asset.determineImageTypeURL(hash: splashHash!))") : nil
            
            let discoverySplashHash = previewData["discovery_splash"] as? String
            discoverySplash = discoverySplashHash != nil ? Asset(hash: discoverySplashHash!, fullURL: "/discovery-splashes/\(id)/\(Asset.determineImageTypeURL(hash: discoverySplashHash!))") : nil

            let emojiListData = previewData["emojis"] as! [JSON]
            if emojiListData.count > 0 {
                for emojiJsonObj in emojiListData {
                    emojis.append(Emoji(bot: bot, guildId: id, emojiData: emojiJsonObj))
                }
            }

            let featureInfo = previewData["features"] as! [String]
            features.append(contentsOf: Feature.get(featureInfo))

            approximateMemberCount = previewData["approximate_member_count"] as! Int
            approximatePresenceCount = previewData["approximate_presence_count"] as! Int
            description = previewData["description"] as? String

            let stickerData = previewData["stickers"] as! [JSON]
            for stickerJsonObj in stickerData {
                stickers.append(Sticker(stickerData: stickerJsonObj))
            }
        }
    }

    /// Represents a guilds message notification level.
    public enum MessageNotificationLevel : Int, CaseIterable {
        
        /// Members will receive notifications for all messages by default.
        case allMessages
        
        /// Members will receive notifications only for messages that @mention them by default.
        case onlyMentions
    }

    /// Represents a guilds explicit content filter level.
    public enum ExplicitContentFilterLevel : Int, CaseIterable {
        
        /// Media content will not be scanned.
        case disabled

        // Media content sent by members without roles will be scanned.
        case membersWithoutRoles
        
        /// Media content sent by all members will be scanned.
        case allMembers
    }

    /// Represents a guilds MFA/2FA level.
    public enum MFALevel : Int, CaseIterable {

        /// Guild has no MFA/2FA requirement for moderation actions.
        case none
        
        /// Guild has a 2FA requirement for moderation actions.
        case elevated
    }

    /// Represents a guilds verification level.
    public enum VerificationLevel : Int, CaseIterable {
        
        /// Unrestricted.
        case none
        
        /// Must have verified email on account.
        case low

        /// Must be registered on Discord for longer than 5 minutes.
        case medium
        
        /// Must be a member of the server for longer than 10 minutes.
        case high

        /// Must have a verified phone number.
        case veryHigh
    }

    /// Represents a guilds NSFW level.
    public enum NSFWLevel : Int, CaseIterable {
        case `default`
        case explicit
        case safe
        case ageRestricted
    }

    /// Represents a guilds premium tier.
    public enum PremiumTier : Int, CaseIterable {
        
        /// Guild has not unlocked any Server Boost perks.
        case none
        
        /// Guild has unlocked Server Boost level 1 perks.
        case tier1

        /// Guild has unlocked Server Boost level 2 perks.
        case tier2

        /// Guild has unlocked Server Boost level 3 perks.
        case tier3
    }

    public enum SystemChannelFlags : Int, CaseIterable {
        
        /// Suppress member join notifications.
        case suppressJoinNotifications = 1
        
        /// Suppress server boost notifications.
        case suppressPremiumSubscriptions = 2
        
        /// Suppress server setup tips.
        case suppressGuildReminderNotifications = 4
        
        /// Hide member join sticker reply buttons.
        case suppressJoinNotificationReplies = 8
        
        static func determineFlags(value: Int) -> [SystemChannelFlags] {
            var flags = [SystemChannelFlags]()
            for flag in SystemChannelFlags.allCases {
                if (value & flag.rawValue) == flag.rawValue {
                    flags.append(flag)
                }
            }
            return flags
        }

        static func getBitSetForFlags(_ flags: [SystemChannelFlags]) -> Int {
            var value = 0
            for flag in flags {
                value |= flag.rawValue
            }
            return value
        }
    }

    /// Represents a Discord guild feature.
    public enum Feature : String, CaseIterable {

        /// Guild has access to set an animated guild banner image.
        case animatedBanner = "ANIMATED_BANNER"
        
        /// Guild has access to set an animated guild icon.
        case animatedIcon = "ANIMATED_ICON"
        
        /// Guild is using the old permissions configuration behavior.
        case applicationCommandPermissionsV2 = "APPLICATION_COMMAND_PERMISSIONS_V2"
        
        /// Guild has set up auto moderation rules.
        case autoModeration = "AUTO_MODERATION"
        
        /// Guild has access to set a guild banner image.
        case banner = "BANNER"
        
        /// Guild can enable welcome screen, Membership Screening, stage channels and discovery, and receives community updates.
        case community = "COMMUNITY"
        
        /// Guild has enabled monetization
        case creatorMonetizableProvisional = "CREATOR_MONETIZABLE_PROVISIONAL"
        
        /// Guild has enabled the role subscription promo page.
        case creatorStorePage = "CREATOR_STORE_PAGE"
        
        /// Guild has been set as a support server on the App Directory.
        case developerSupportServer = "DEVELOPER_SUPPORT_SERVER"
        
        /// Guild is able to be discovered in the directory.
        case discoverable = "DISCOVERABLE"
        
        /// Guild is able to be featured in the directory.
        case featurable = "FEATURABLE"
        
        /// Guild has paused invites, preventing new users from joining.
        case invitesDisabled = "INVITES_DISABLED"
        
        /// Guild has access to set an invite splash background.
        case inviteSplash = "INVITE_SPLASH"
        
        /// Guild has enabled Membership Screening.
        case memberVerificationGateEnabled = "MEMBER_VERIFICATION_GATE_ENABLED"
        
        /// Guild has enabled monetization.
        case monetizationEnabled = "MONETIZATION_ENABLED"
        
        /// Guild has increased custom sticker slots.
        case moreStickers = "MORE_STICKERS"
        
        /// Guild has access to create news channels.
        case news = "NEWS"
        
        /// Guild is partnered.
        case partnered = "PARTNERED"
        
        /// Guild can be previewed before joining via Membership Screening or the directory.
        case previewEnabled = "PREVIEW_ENABLED"
        
        /// Guild has disabled alerts for join raids in the configured safety alerts channel.
        case raidAlertsDisabled = "RAID_ALERTS_DISABLED"
        
        /// Guild has access to create private threads.
        case privateThreads = "PRIVATE_THREADS"
        
        /// Guild is able to set role icons.
        case roleIcons = "ROLE_ICONS"
        
        /// Guild has role subscriptions that can be purchased.
        case roleSubscriptionsAvailableForPurchase = "ROLE_SUBSCRIPTIONS_AVAILABLE_FOR_PURCHASE"
        
        /// Guild has enabled role subscriptions.
        case roleSubscriptionsEnabled = "ROLE_SUBSCRIPTIONS_ENABLED"
        
        /// Guild has enabled ticketed events.
        case ticketedEventsEnabled = "TICKETED_EVENTS_ENABLED"
        
        /// Guild has text in voice enabled.
        case textInVoiceEnabled = "TEXT_IN_VOICE_ENABLED"
        
        /// Guild has access to set a vanity URL.
        case vanityUrl = "VANITY_URL"
        
        /// Guild is verified.
        case verified = "VERIFIED"
        
        /// Guild has access to set 384kbps bitrate in voice (previously VIP voice servers).
        case vipRegions = "VIP_REGIONS"
        
        /// Guild has enabled the welcome screen.
        case welcomeScreenEnabled = "WELCOME_SCREEN_ENABLED"
        
        static func get(_ features: [String]) -> [Feature] {
            var currentFtrs = [Feature]()
            for ftr in features {
                if let foundFtr = Feature(rawValue: ftr) {
                    currentFtrs.append(foundFtr)
                }
            }
            return currentFtrs
        }
    }

    /// Represents a guilds scheduled event.
    public struct ScheduledEvent : Object {

        /// The ID of the scheduled event.
        public let id: Snowflake
        
        /// The guild the event belongs to.
        public var guild: Guild { bot!.getGuild(guildId)! }
        private let guildId: Snowflake
        
        /// The channel ID in which the scheduled event will be hosted, or `nil` if the scheduled entity type is ``Guild/ScheduledEvent/EntityType-swift.enum/external``.
        public let channelId: Snowflake?
        
        /// The name of the scheduled event.
        public let name: String
        
        /// The description of the scheduled event.
        public let description: String?

        /// The time the scheduled event will start.
        public let scheduledStartTime: Date
        
        /// The time the scheduled event will end.
        public let scheduledEndTime: Date?

        /// The privacy level of the scheduled event.
        public let privacyLevel: PrivacyLevel

        /// The status of the scheduled event.
        public let status: Status
        
        /// The type of the scheduled event.
        public let entityType: EntityType
        
        /// The ID of an entity associated with a guild scheduled event.
        public let entityId: Snowflake?

        /// Where the event will take place.
        public let location: String?
        
        /// The user that created the scheduled event.
        public let creator: User?
        
        /// The cover image of the scheduled event.
        public let image: Asset?
        
        /// Your bot instance.
        public weak private(set) var bot: Discord?

        init(bot: Discord, eventData: JSON) {
            self.bot = bot
            id = Conversions.snowflakeToUInt(eventData["id"])
            guildId = Conversions.snowflakeToUInt(eventData["guild_id"])
            channelId = Conversions.snowflakeToOptionalUInt(eventData["channel_id"])
            name = eventData["name"] as! String
            description = eventData["description"] as? String
            scheduledStartTime = Conversions.stringDateToDate(iso8601: eventData["scheduled_start_time"] as! String)!
            
            if let endTime = eventData["scheduled_end_time"] as? String { scheduledEndTime = Conversions.stringDateToDate(iso8601: endTime) }
            else { scheduledEndTime = nil }

            privacyLevel = PrivacyLevel(rawValue: eventData["privacy_level"] as! Int)!
            status = Status(rawValue: eventData["status"] as! Int)!
            entityType = EntityType(rawValue: eventData["entity_type"] as! Int)!
            entityId = Conversions.snowflakeToOptionalUInt(eventData["entity_id"])

            if let entityMetadata = eventData["entity_metadata"] as? JSON { location = entityMetadata["location"] as? String }
            else { location = nil }

            let userObj = eventData["creator"] as? JSON
            creator = userObj != nil ? User(userData: userObj!) : nil

            if let imageHash = eventData["image"] as? String { image = Asset(hash: imageHash, fullURL: "/guild-events/\(id)/\(Asset.determineImageTypeURL(hash: imageHash))") }
            else { image = nil }
        }
        
        /**
         Edit the scheduled event.
         
         - Parameters:
            - edits: Values that should be changed.
            - reason: The reason for editing the scheduled event. This shows up in the guilds audit-logs.
         */
        @discardableResult
        public func edit(_ edits: ScheduledEvent.Edit..., reason: String? = nil) async throws -> ScheduledEvent {
            // Don't perform an HTTP request when nothing was changed
            guard !(edits.count == 0) else { return self }
            
            var payload: JSON = [:]
            for e in edits {
                switch e {
                case .channelId(let channelId):
                    payload["channel_id"] = nullable(channelId)
                case .privacyLevel(let privacyLevel):
                    payload["privacy_level"] = privacyLevel.rawValue
                case .startTime(let startTime):
                    payload["scheduled_start_time"] = startTime.asISO8601
                case .endTime(let endTime):
                    payload["scheduled_end_time"] = endTime.asISO8601
                case .description(let description):
                    payload["description"] = nullable(description)
                case .entityType(let etype, channelId: let channelId, location: let location, endTime: let endTime):
                    guard !((etype == .voice || etype == .stageInstance) && channelId == nil) else {
                        throw HTTPError.badRequest("When setting the EntityType to .voice or .external, the channelId is required")
                    }
                    /**
                     [FROM DISCORD]
                     
                     If updating `entity_type` to EXTERNAL:
                        -  `channel_id` is required and must be set to null
                        -  `entity_metadata` with a location field must be provided
                        -  `scheduled_end_time` must be provided

                     */
                    if etype == .external {
                        payload["channel_id"] = NIL
                        let errorMsg = "When setting the EntityType to external, the location and endTime are required"
                        
                        if let loc = location { payload["entity_metadata"] = ["location": loc] }
                        else { throw HTTPError.badRequest(errorMsg) }
                        
                        if let eTime = endTime { payload["scheduled_end_time"] = eTime.asISO8601 }
                        else { throw HTTPError.badRequest(errorMsg) }
                    } else {
                        payload["channel_id"] = channelId!
                    }
                    payload["entity_type"] = etype.rawValue
                    payload["scheduled_end_time"] = endTime?.asISO8601
                case .status(let status):
                    // Discord: "Once `status` is set to `COMPLETED` or `CANCELED`, the status can no longer be updated"
                    if self.status == .completed || self.status == .canceled {
                        continue
                    }
                    payload["status"] = status.rawValue
                case .image(let image):
                    payload["image"] = image?.asImageData
                }
            }
            
            return try await bot!.http.modifyGuildScheduledEvent(guildId: guildId, eventId: id, data: payload, reason: reason)
        }
        
        /// Cancel the scheduled event.
        public func cancel() async throws {
            if status == .scheduled {
                try await edit(.status(.canceled))
            }
        }
        
        /// Delete the scheduled event.
        public func delete(reason: String? = nil) async throws {
            try await bot!.http.deleteGuildScheduledEvent(guildId: guildId, eventId: id)
        }
        
        /// Start the scheduled event.
        public func start() async throws {
            if status == .scheduled {
                try await edit(.status(.active))
            }
        }
        
        /// Stop the scheduled event.
        public func stop() async throws {
            if status == .active {
                try await edit(.status(.completed))
            }
        }
        
        /**
         The list of guild scheduled event users subscribed ("interested") to the event.
         
         - Parameters:
            - limit: Number of users to return (up to maximum 100).
            - before: Consider only users before given user ID.
            - after: Consider only users after given user ID.
         - Returns: Users subscribed to the event.
         */
        public func users(limit: Int = 100, before: Snowflake? = nil, after: Snowflake? = nil) async throws -> [User] {
            return try await bot!.http.getGuildScheduledEventUsers(guildId: guildId, eventId: id, limit: limit, before: before, after: after)
        }
    }

    /// Represents a guild template.
    public struct Template {

        /// The template code (unique ID).
        public let code: String
        
        /// Template name.
        public let name: String
        
        /// The description for the template.
        public let description: String?
        
        /// Number of times this template has been used.
        public let usageCount: Int
        
        /// The ID of the user who created the template.
        public let creatorId: Snowflake
        
        /// The user who created the template.
        public let creator: User
        
        /// When this template was created.
        public let createdAt: Date
        
        /// When this template was last synced to the guild.
        public let updatedAt: Date
        
        /// The ID of the guild this template is based on.
        public let sourceGuildId: Snowflake
        
        /// Whether the template has unsynced changes.
        public let isDirty: Bool?
        
        // NOTE:
        // serializedSourceGuild is intentionally excluded. Using a template, you
        // only recieve a partial guild object, and it's not worth creating an entire PartialGuild class
        // which also supports channels and roles. Given the fact that when recieving a template, you don't
        // have access to the source guild. Meaning almost all of `Guild`s methods/properties would be useless.
        // The source guild ID is still availabe, and if someone really wants to access the guild, I think it's
        // better to just use .requestGuild() to access all it's features if the bot shares that guild.
        
        // ------------------------------ API Separated -----------------------------------
        
        /// The full URL for the template.
        public let url: String
        
        // --------------------------------------------------------------------------------
        
        /// Your bot instance.
        public weak private(set) var bot: Discord?

        init(bot: Discord, templateData: JSON) {
            self.bot = bot
            code = templateData["code"] as! String
            name = templateData["name"] as! String
            description = templateData["description"] as? String
            usageCount = templateData["usage_count"] as! Int
            creatorId = Conversions.snowflakeToUInt(templateData["creator_id"])
            creator = User(userData: templateData["creator"] as! JSON)
            createdAt = Conversions.stringDateToDate(iso8601: templateData["created_at"] as! String)!
            updatedAt = Conversions.stringDateToDate(iso8601: templateData["updated_at"] as! String)!
            sourceGuildId = Conversions.snowflakeToUInt(templateData["source_guild_id"])
            isDirty = templateData["is_dirty"] as? Bool
            url = "https://discord.new/\(code)"
        }
        
        /**
         Edit the template.
         
         - Parameter edits: Values that should be changed.
         - Returns: The updated template.
         */
        @discardableResult
        public func edit(_ edits: Template.Edit...) async throws -> Template {
            // Don't perform an HTTP request when nothing was changed
            guard !(edits.count == 0) else { return self }
            
            var payload: JSON = [:]
            for e in edits {
                switch e {
                case .name(let name):
                    payload["name"] = name
                case .description(let description):
                    payload["description"] = nullable(description)
                }
            }
            return try await bot!.http.modifyGuildTemplate(guildId: sourceGuildId, code: code, data: payload)
        }
        
        /// Deletes the template.
        public func delete() async throws {
            try await bot!.http.deleteGuildTemplate(guildId: sourceGuildId, code: code)
        }
        
        /// Syncs the template to the guild's current state.
        /// - Returns: The guilds templated.
        public func sync() async throws -> Template {
            return try await bot!.http.syncGuildTemplate(guildId: sourceGuildId, code: code)
        }
    }
}

extension Guild.Template {
    
    /// Represents the values that should be edited in a ``Guild/Template``.
    public enum Edit {
        
        /// Name of the template (100 characters max).
        case name(String)
        
        /// Description for the template (120 characters ax).
        case description(String?)
    }
}

extension Guild.ScheduledEvent {
    
    /// Represents the schduled events status.
    public enum Status : Int {
        case scheduled = 1
        case active
        case completed
        case canceled
    }

    /// Represents the entity type of the scheduled event.
    public enum EntityType : Int {
        case stageInstance = 1
        case voice
        case external
    }

    /// Represents the privacy level of the scheduled event.
    public enum PrivacyLevel : Int {
        case guildOnly = 2
    }

    /// Represents the values that should be edited in a ``Guild/ScheduledEvent``.
    public enum Edit {
        
        /// The new channel of the scheduled event.
        case channelId(Snowflake?)
        
        /// The privacy level of the scheduled event.
        case privacyLevel(PrivacyLevel)
        
        /// The time to schedule the scheduled event.
        case startTime(Date)
        
        /// The time when the scheduled event is scheduled to end.
        case endTime(Date)
        
        /// The new description of the scheduled event. Can be set to `nil` to remove the description.
        case description(String?)
        
        /// The entity type of the scheduled event. If updating entity type to ``Guild/ScheduledEvent/EntityType-swift.enum/external``, `location` and  `endTime` must be provided.
        case entityType(EntityType, channelId: Snowflake? = nil, location: String? = nil, endTime: Date? = nil)
        
        /// The status of the scheduled event.
        case status(Status)
        
        /// The cover image of the scheduled event. Can be set to `nil` to remove the cover image.
        case image(File?)
    }
}

extension Guild.Integration {
    
    /// Representst the bot/OAuth2 application for discord integrations.
    public struct Application {
        
        /// The ID of the app.
        public let id: Snowflake
        
        /// The name of the app.
        public let name: String
        
        /// The icon asset of the app.
        public let icon: Asset?
        
        /// The description of the app.
        public let description: String
        
        /// The bot associated with this application.
        public let bot: User?
        
        init(appData: JSON) {
            id = Conversions.snowflakeToUInt(appData["id"])
            name = appData["name"] as! String
            
            if let iconHash = appData["icon"] as? String { icon = Asset(hash: iconHash, fullURL: "/app-icons/\(id)/\(iconHash).png") }
            else { icon = nil }
            
            description = appData["description"] as! String
            
            if let userObj = appData["user"] as? JSON { bot = User(userData: userObj) }
            else { bot = nil }
        }
    }
    
    /// Represents a Integration account.
    public struct Account {
        
        /// ID of the account.
        public let id: String
        
        /// Name of the account.
        public let name: String
        
        init(accountData: JSON) {
            id = accountData["id"] as! String
            name = accountData["name"] as! String
        }
    }
    
    /// Represents the behavior of expiring subscribers.
    public enum ExpireBehavior: Int {
        case removeRole
        case kick
    }
}
