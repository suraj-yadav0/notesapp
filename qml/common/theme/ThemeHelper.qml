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
    readonly property bool isDarkTheme: Theme.name === "Ubuntu.Components.Themes.SuruDark"
    readonly property string lightThemeName: "Ubuntu.Components.Themes.Ambiance"
    readonly property string darkThemeName: "Ubuntu.Components.Themes.SuruDark"
    
    function toggleTheme() {
        Theme.name = isDarkTheme ? lightThemeName : darkThemeName
    }
    
    function getThemeToggleIcon() {
        return isDarkTheme ? "weather-clear-symbolic" : "weather-clear-night-symbolic"
    }
    
    function getThemeToggleText() {
        return isDarkTheme ? i18n.tr("Light Mode") : i18n.tr("Dark Mode")
    }
    
    function getTextColor() {
        return isDarkTheme ? "#FFFFFF" : "#0D141C"
    }
}
