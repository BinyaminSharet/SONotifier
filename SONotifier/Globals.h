/*
 * Copyright (C) 2012 Binyamin Sharet
 *
 * This file is part of SONotifier.
 * 
 * SONotifier is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * SONotifier is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with SONotifier. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef SONotifier_Globals_h
#define SONotifier_Globals_h

// ***** Source names ***** //
#define RESOURCE_NAME_ICON_ONLINE   @"icon_online"
#define RESOURCE_NAME_ICON_OFFLINE  @"icon_offline"
#define RESOURCE_NAME_ICON_UPDATE   @"icon_update"

// *****  NSUserDefaults keys  ***** //
#define DATA_KEY_UPDATE_INTERVAL    @"com_bsharet_sonotifier_update_interval"
#define DATA_KEY_USER_ID            @"com_bsharet_sonotifier_user_id"
#define DATA_KEY_USER_INFO          @"com_bsharet_sonotifier_user_info"
#define DATA_KEY_BADGES_INFO        @"com_bsharet_sonotifier_badges_info"
#define DATA_KEY_REPUTATION_CHANGE  @"com_bsharet_sonotifier_reputation_change"
#define DATA_KEY_CONFIGURED         @"com_bsharet_sonotifier_configured"
#define DATA_KEY_LAUNCH_AT_STARTUP  @"com_bsharet_sonotifier_launch_at_startup"

// *****  StackExchange API 2.0  ***** 
//  Base URL
#define API_20_BASE_URL             @"http://api.stackexchange.com/2.0"
#define API_20_FILTER_QUESTIONS     @"!-rf7acLF"
#define API_20_APP_ID               @"&client_id=287"
#define API_20_APP_KEY              @"&key=nWxVLEQliwjmk5QH5NZIpw(("


//  Keys for parsing server JSON response 
//    Reputation changes response
#define API_KEY_REPUTATION_CHANGE   @"reputation_change"
#define API_KEY_REPUTATION_TITLE    @"title"
#define API_KEY_REPUTATION_POST_ID  @"post_id"
//    User info response
#define API_KEY_USER_ID             @"user_id"
#define API_KEY_USER_TYPE           @"user_type"
#define API_KEY_USER_CREATION_DATE  @"creation_date"
#define API_KEY_USER_NAME           @"display_name"
#define API_KEY_USER_BADGES_DICT    @"badge_counts"
#define API_KEY_USER_BADGE_GOLD     @"gold"
#define API_KEY_USER_BADGE_SILVER   @"silver"
#define API_KEY_USER_BADGE_BRONZE   @"bronze"
#define API_KEY_USER_REPUTATION     @"reputation"
#define API_KEY_USER_REP_DAY        @"reputation_change_day"
#define API_KEY_USER_REP_WEEK       @"reputation_change_week"
#define API_KEY_USER_REP_MONTH      @"reputation_change_month"
#define API_KEY_USER_REP_QUARTER    @"reputation_change_quarter"
#define API_KEY_USER_REP_YEAR       @"reputation_change_year"
//    Recent questions response
#define API_KEY_QUESTION_ID             @"question_id"
#define API_KEY_QUESTION_SCORE          @"score"
#define API_KEY_QUESTION_ANSWER_COUNT   @"answer_count"
#define API_KEY_QUESTION_TITLE          @"title"
#define API_KEY_QUESTION_TAGS_ARRAY     @"tags"
#define API_KEY_QUESTION_LINK           @"link"
#define API_KEY_QUESTION_ANSWERED       @"is_answered"
//    Recent badges response
#define API_KEY_BADGES_ID               @"badge_id"
#define API_KEY_BADGES_RANK             @"rank"
#define API_KEY_BADGES_NAME             @"name"
#define API_KEY_BADGES_BADGE_TYPE       @"badge_type"
#define API_KEY_BADGES_AWARD_COUNT      @"award_count"
#define API_KEY_BADGES_LINK             @"link"
#define API_KEY_BADGES_USER_INFO        @"user"

// *****  Strings  ***** //
#define TEXT_SHAPE_CSTRING_UTF8_CIRCLE_SML  "\u25CF"
#define TEXT_SHAPE_CSTRING_UTF8_CIRCLE_MED  "\u26AB"

// *****  Connection properties  ***** //
#define DEFAULT_UPDATE_INTERVAL     (60. * 10)

// *****  Connection status strings  ***** //
#define CONNECTION_OFFLINE      @"Connection Problem"
#define CONNECTION_CONNECTING   @"Connecting..."
#define CONNECTION_CONNECTED    @"Connected"


#endif  //SONotifier_Globals_h
