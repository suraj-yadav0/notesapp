# Convergence

So convergence is one of the Key features of Ubuntu Touch Applications. For Convergence compatibility we ensure the app’s layout is adaptable and responsive for different screen sizes like Mobile , Tablet and Desktop mode. In the Desktop mode You can multiple columns , to better utilise the space. Even the Navigation will be different according to screen size changes. 

This can be easily achieved by using Adaptive Page Layout. Read More about Adaptive Page Layout from here [https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout) 

[AdaptivePageLayout](https://phone.docs.ubuntu.com/en/apps/api-qml-current/index.html) stores pages added in a tree. Pages are added relative to a given page, either as sibling ([addPageToCurrentColumn](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#addPageToCurrentColumn-method)) or as child ([addPageToNextColumn](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#addPageToNextColumn-method)). This means that removing a non-leaf page from the Page tree will remove all its children from the page tree.

The columns are populated from left to right. The column a page is added to is detected based on the source page that is given to the functions adding the page. The pages can be added either to the same column the source page resides or to the column next to the source page. Giving a null value to the source page will add the page to the leftmost column of the view.

The primary page, the very first page must be specified either through the [primaryPage](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#primaryPage-prop) or [primaryPageSource](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#primaryPageSource-prop) properties. [primaryPage](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#primaryPage-prop) can only hold a Page instance, [primaryPageSource](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#primaryPageSource-prop) can either be a Component or a url to a document defining a Page. [primaryPageSource](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#primaryPageSource-prop) has precedence over [primaryPage](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#primaryPage-prop), and when set it will report the loaded Page through [primaryPage](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#primaryPage-prop) property, and will replace any value set into that property.

Adaptive page layout has 3 main Methods : 

- [**addPageToCurrentColumn**](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#addPageToCurrentColumn-method)(*sourcePage*, *page*, *properties*)
- [**addPageToNextColumn**](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#addPageToNextColumn-method)(*sourcePage*, *page*, *properties*)
- [**removePages**](https://phone.docs.ubuntu.com/en/apps/api-qml-current/Ubuntu.Components.AdaptivePageLayout#removePages-method)(*page*)

![Convergence - visual selection.png](docs/screenshots/Convergence - visual selection.png)

So we will be changing the `Main.qml` file of our application to this for Convergence support using Adaptive Page Layout : 

```jsx
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

import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Themes 1.3

// Import our own components
import "models"
import "controllers"
import "views"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'notesapp.surajyadav'
    automaticOrientation: true

    width: units.gu(60)
    height: units.gu(75)

    theme.palette: Palette {}

    NotesModel {
        id: notesModel
    }

    NotesController {
        id: notesController
        model: notesModel
    }

    AdaptivePageLayout {
        id: pageLayout
        anchors.fill: parent
        primaryPage: mainPage
         property Page thirdPage: todoPage
        
        property bool isMultiColumn: true

        layouts: [
            PageColumnsLayout {
                // Tablet Mode
                when: width > units.gu(80) && width < units.gu(130)
                PageColumn {
                    minimumWidth: units.gu(30)
                    maximumWidth: units.gu(50)
                    preferredWidth: width > units.gu(90) ? units.gu(20) : units.gu(15)
                }
                PageColumn {
                    minimumWidth: units.gu(50)
                    maximumWidth: units.gu(80)
                    preferredWidth: width > units.gu(90) ? units.gu(60) : units.gu(45)
                }
            },
            PageColumnsLayout {
                // Desktop Mode
                when: width >= units.gu(130)
                PageColumn {
                    minimumWidth: units.gu(30)
                    maximumWidth: units.gu(50)
                    preferredWidth: units.gu(40)
                }
                PageColumn {
                    minimumWidth: units.gu(65)
                    maximumWidth: units.gu(80)
                    preferredWidth: units.gu(50)
                }
                PageColumn {
                    fillWidth: true
                }
            }
        ]

        // Main notes list page
        MainPage {
            id: mainPage
            controller: notesController
            notesModel: notesModel

            onEditNoteRequested: {
                pageLayout.addPageToNextColumn(mainPage, noteEditPage)
            }
        }

        // Note editor page
        NoteEditPage {
            id: noteEditPage
            controller: notesController

            onBackRequested: {
                pageLayout.removePages(noteEditPage)
            }
        }
    }
}
```