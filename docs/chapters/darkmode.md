# Dark Mode -Notes App

Well our app should look good both in light-mode and Dark mode. In `qml`  it is pretty straight - forward to implement Dark-Mode into our app. 

> Important
> 

One thing to keep in mind for our app , to be compatible with Dark Mode, avoid using too many different colors. And if you want to use different colors then Create functions to toggle them to different color when switched to dark mode. It can be little complex for someone who is just starting with `qml` development. So let us first stick to basics.

> Task 1
> 

1. Wherever you see a color property for background change it to `theme.palette.normal.background` .
2. Wherever you see a color property for border change it to `theme.palette.normal.border` .
3. Wherever you see a color property for Text change it to `theme.palette.normal.baseText` .
4. You can simply remove color property where not needed.

Now test your app by running `clickable desktop —dark-mode` .

> Task 2
> 

**Creating a button to toggle between Dark and Light Mode.**

1. Add a new action in the `PageHeader` of the `MainPage.qml` file.
2. Add the Given Code :

```jsx
 Action {
                iconName: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "weather-clear" : "weather-clear-night"
                text: theme.name === "Ubuntu.Components.Themes.SuruDark" ? i18n.tr("Light Mode") : i18n.tr("Dark Mode")
                onTriggered: {
                Theme.name = theme.name === "Ubuntu.Components.Themes.SuruDark" ? 
                        "Ubuntu.Components.Themes.Ambiance" : 
                        "Ubuntu.Components.Themes.SuruDark";
                }
            }
```

Do check for any missing commas and Brackets.

This button toggles and changes its icon when clicked or triggered and also changes the theme of of our app using `Ubuntu.Components.Themes.Ambiance` for Light mode and `Ubuntu.Components.Themes.SuruDark` for Dark mode. 

After applying all these things Your app should look something like this :

 ![DarkMode 1.1](/docs/screenshots/darkmode.1.png)

 ![DarkMode 1.1](/docs/screenshots/darkmode.2.png)

 ![DarkMode 1.1](/docs/screenshots/darkmode.3.png)

 ![DarkMode 1.1](/docs/screenshots/darkmode.4.png)