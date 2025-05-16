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

import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components 1.3

// Import our own components
import "models"
import "controllers"
import "views"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'notesapp.surajyadav'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    
    NotesModel {
        id: notesModel
    }
    
   
    NotesController {
        id: notesController
        model: notesModel
    }
    
    PageStack {
        id: pageStack
        Component.onCompleted: push(mainPage)
        
        MainPage {
            id: mainPage
            controller: notesController
            notesModel: notesModel
            
            onEditNoteRequested: {
                pageStack.push(noteEditPage);
            }
        }
        
        NoteEditPage {
            id: noteEditPage
            controller: notesController
            
            onBackRequested: {
                pageStack.pop();
            }
        }
    }
}