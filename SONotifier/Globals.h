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

#define DATA_KEY_UPDATE_INTERVAL    @"com_bsharet_sonotifier_update_interval"
#define DATA_KEY_USER_ID            @"com_bsharet_sonotifier_user_id"
#define DATA_KEY_USER_INFO          @"com_bsharet_sonotifier_user_info"
#define DATA_KEY_REPUTATION_CHANGE  @"com_bsharet_sonotifier_reputation_change"
#define DATA_KEY_CONFIGURED         @"com_bsharet_sonotifier_configured"

#define API_KEY_REPUTATION_CHANGE   @"reputation_change"
#define API_KEY_REPUTATION_TITLE    @"title"
#define API_KEY_USER_ID             @"user_id"
#define API_KEY_USER_TYPE           @"user_type"
#define API_KEY_USER_CREATION_DATE  @"creation_date"
#define API_KEY_USER_NAME           @"display_name"
#define API_KEY_USER_BADGES_DICT    @"badges_count"
#define API_KEY_USER_BADGE_GOLD     @"gold"
#define API_KEY_USER_BADGE_SILVER   @"silver"
#define API_KEY_USER_BADGE_BRONZE   @"bronze"
#define API_KEY_USER_REPUTATION     @"reputation"
#define API_KEY_USER_REP_DAY        @"reputation_change_day"
#define API_KEY_USER_REP_WEEK       @"reputation_change_week"
#define API_KEY_USER_REP_MONTH      @"reputation_change_month"
#define API_KEY_USER_REP_QUARTER    @"reputation_change_quarter"
#define API_KEY_USER_REP_YEAR       @"reputation_change_year"

#define DEFAULT_UPDATE_INTERVAL     (60. * 10)


#endif
