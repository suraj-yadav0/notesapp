/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * notesapp is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

pragma Singleton
import QtQuick 2.9
import Lomiri.Components 1.3

QtObject {
    // Layout breakpoints
    readonly property int phoneMaxWidth: units.gu(80)
    readonly property int tabletMaxWidth: units.gu(130)
    
    // Common sizes
    readonly property int defaultButtonSize: units.gu(7)
    readonly property int defaultIconSize: units.gu(3)
    readonly property int defaultMargin: units.gu(2)
    readonly property int smallMargin: units.gu(1)
    readonly property int defaultHintSize: units.gu(8)
    
    // Animation durations
    readonly property int shortAnimationDuration: 200
    readonly property int defaultAnimationDuration: 300
    readonly property int longAnimationDuration: 500
    
    // Radial navigation
    readonly property real defaultRadialDistance: 1.5
    readonly property real defaultExpandedPosition: 0.6
    readonly property real defaultBgOpacity: 0.7
    
    // Timer intervals
    readonly property int defaultTimeoutSeconds: 2
    readonly property int navigationTimeoutSeconds: 3
    
    // App info
    readonly property string appName: "N O T E S"
    readonly property string appId: "notesapp.surajyadav"
}
